local available=Config.extraData.llmModel and Config.extraData.llmSystemPrompt and Config.extraData.llmKey and Config.extraData.llmTimeWindow
if not available then LOG('warn',"LLM模块需要配置4个参数") end
local errMsg="有人能告诉"..Config.adminName.."，我的AI有问题"
local atStr="%[CQ:at,qq="..Config.botID.."%]"

local msgID=0
local curlCmd=[[
curl -s https://api.deepseek.com/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $1" \
  -d @$2
]]
local tools={
    {
        ['type']='function',
        ['function']={
            name='tetris_dict',
            description="收录了大量俄罗斯方块相关术语的词典，输入一个术语返回一个词条",
            parameters={
                type='object',
                properties={
                    term={
                        type='string',
                        description="术语名称（尽量短，不区分大小写，）",
                    },
                },
                required={'term'},
            },
        },
    },
}

local failBuffer={}
local buf=STRING.newBuf()
local function executeTool(S,func)
    local suc,args=pcall(JSON.decode,func.arguments)
    if not suc then return "错误：工具参数解析失败 "..args end

    if func.name=='tetris_dict' then
        if type(args.term)~='string' then return "错误：参数term必须是字符串" end
        local entry=Config.extraData._zict[args.term:gsub('%s',''):lower()]
        LOG('debug',"LLM查询词典 "..args.term..(entry and "（成功）" or "（未找到）"))
        if not entry then
            table.insert(failBuffer,args.term)
            return "未找到词条："..args.term
        end
        buf:reset()
        if entry.title then buf:put("# "..entry.title.."\n") end
        if entry.text then buf:put(entry.text.."\n") end
        if entry.detail then buf:put("[额外内容]\n"..entry.detail.."\n") end
        if entry.link then buf:put("[相关链接]\n"..entry.link.."\n") end
        return #buf>0 and buf:get() or "词条内容为空"
    else
        return "错误：未知工具 "..func.name
    end
end

---@param M OneBot.Event.Base
local function convertMsg(M,prefix)
    ---@cast M OneBot.Event.PrivateMessage | OneBot.Event.GroupMessage
    return {
        role='user',
        content=string.format("%s %s %s\n%s",
            prefix,
            "用户"..M.user_id,
            os.date("%Y-%m-%d %H:%M:%S",M.time),
            M.raw_message
        ),
    }
end

---@param S Session
---@param M OneBot.Event.PrivateMessage | OneBot.Event.GroupMessage
---@param tag '<互动>'|'<提及>'|'<潜在提问>'
local function task_apiCallThread(S,M,tag)
    msgID=msgID+1
    local sid="["..msgID.."]"
    LOG('debug',("%s %s-%s LLM输入 %s\n%s"):format(sid,S.uid,M.user_id,tag,M.raw_message))

    local messages={}
    table.insert(messages,{role='system',content=Config.extraData.llmSystemPrompt})
    for _,m in next,S.history do
        if M.time-m.time>Config.extraData.llmTimeWindow then
            table.insert(messages,convertMsg(m,'<上下文>'))
        end
    end
    table.insert(messages,convertMsg(M,tag))
    local data={
        model=Config.extraData.llmModel,
        thinking={type='disabled'},
        reasoning_effort='high',
        stream=false,
        messages=messages,
        tools=tools,
    }

    for _=1,5 do
        local jsonSend,jsonRecv
        do
            local suc,res=pcall(JSON.encode,data)
            if not suc then
                if S:forceLock('llm_json_encode_error',26) then
                    LOG('warn',sid.." LLM错误：json打包失败 "..res)
                    if S:lock('llm_error') then S:send(errMsg) end
                end
                return
            end
            jsonSend=res
        end

        local tmpf=os.tmpname()
        do
            local fh=io.open(tmpf,'w')
            fh:write(jsonSend)
            fh:close()
        end
        ASYNC.runCmd('llm_'..sid,STRING.repD(curlCmd,Config.extraData.llmKey,tmpf))
        repeat
            TASK.yieldT(.26)
            jsonRecv=ASYNC.get('llm_'..sid)
        until jsonRecv
        ASYNC.runCmd('llm_rm_tmp','rm -f '..tmpf)

        local msg
        do
            local suc,res=pcall(JSON.decode,jsonRecv)
            if not suc then
                if S:forceLock('llm_json_decode_error',26) then
                    LOG('warn',sid.." LLM错误：json解析失败 "..res)
                    if S:lock('llm_error') then S:send(errMsg) end
                end
                return
            end
            suc,res=pcall(TABLE.listIndex,res,{'choices',1,'message'})
            if not (suc and res) then
                if S:forceLock('llm_json_decode_error',26) then
                    LOG('warn',sid.." LLM错误：结果获取失败 "..res)
                    if S:lock('llm_error') then S:send(errMsg) end
                end
                return
            end
            msg=res
        end

        if msg.tool_calls and #msg.tool_calls>0 then
            -- Tool call
            table.insert(messages,msg)
            for _,tc in ipairs(msg.tool_calls) do
                table.insert(messages,{
                    role='tool',
                    tool_call_id=tc.id,
                    content=select(2,pcall(executeTool,S,tc['function'])),
                })
            end
        else
            -- 404 Notify
            if #failBuffer>0 then
                local terms=table.concat(failBuffer,", ")
                TABLE.clear(failBuffer)
                for _,qq in next,Config.extraData.llmDict404notify or NONE do
                    Bot.sendMsg("词典404："..terms,qq)
                end
            end
            -- Response
            if msg.content then
                if msg.content:match("<忽略>") then
                    LOG('debug',sid.."LLM跳过发言")
                    if tag~='<潜在提问>' then
                        Bot.reactMessage(M.message_id,Emoji.white_question_mark)
                    end
                else
                    local final=msg.content:gsub("%*%*","")
                    LOG('debug',sid.."LLM发言："..final)
                    S:send(final)
                end
            else
                if S:forceLock('llm_no_content',26) then
                    LOG('warn',sid.." LLM错误：没有返回内容")
                    if S:lock('llm_error') then S:send(errMsg) end
                end
            end
            return
        end
    end

    LOG('warn',sid.." LLM错误：工具调用轮次过多")
    if S:lock('llm_error') then S:send(errMsg) end
end

---@type Task_raw
return {
    message=function(S,M)
        if not available then return false end
        local isAdmin=Bot.isAdmin(M.user_id)
        local msg=STRING.trim(M.raw_message)
        if msg:match(atStr) then
            if isAdmin or S:lock('llm_cd_interact',16) then
                TASK.new(task_apiCallThread,S,M,'<互动>')
            else
                Bot.reactMessage(M.message_id,Emoji.snail)
            end
            return true
        elseif msg:lower():match("小z") or msg:lower():match("zita") then
            if isAdmin or S:lock('llm_cd_mention',26) then
                TASK.new(task_apiCallThread,S,M,'<提及>')
            else
                Bot.reactMessage(M.message_id,Emoji.snail)
            end
            return true
        elseif (msg:match("%?$") or msg:match("？$") or msg:match("吗$")) and MATH.between(#msg,12,260) then
            if isAdmin or S:lock('llm_cd_question',42) then
                TASK.new(task_apiCallThread,S,M,'<潜在提问>')
            else
                Bot.reactMessage(M.message_id,Emoji.snail)
            end
            return true
        end
        return false
    end,
}
