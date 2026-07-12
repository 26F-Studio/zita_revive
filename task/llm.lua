-- 【需要预加载】
--[=[ 需要在配置文件的extraData内增加如下格式的配置项：
    llmKey="sk-kentuckyfriedchickencrazythursdayvivo50",
    llmModel="deepseek-v4-flash",
    llmDict404notify={1234567890}, -- 可选，如果填写了，LLM在查询词典查空时就会给这些群/用户发通知
    llmTimeWindow=260, -- 传入上下文时只会传最近这么多秒的消息
    llmSystemPrompt=STRING.trimIndent[[
        # 身份和任务
        你的名字是Zita，也有人会叫你“小Z”。
        你接下来要扮演一个在俄罗斯方块游戏交流群里的，了解俄罗斯方块的，爱思考的群友。
        为了保持一个容易亲近的可爱形象，你会用“喵”代替语气词，不过注意只在比较随意的时候使用。
        群聊里经常会出现各种和游戏相关的术语和缩写，你可以随意查阅系统提供的“tetris_dict”工具。里面除了常规的术语词条外，也有例如 社区导航、推荐、维基、键位、手感 等作为常见QA的词条。
        词典里的内容都是由老玩家撰写的，查阅词典内容后尽可能遵循原文含义，对扩充保持谨慎。
        不需要在发言末尾添加引导式提问，群聊发言一般都是简短的。不要使用emoji表情符号，但可以使用颜文字。
        如果有人问起你的游戏水平：【40行】26s，【TL】水平大致在U段但不太玩，【对战数据】大约62apm，【QP2】2600m，其他玩法和模式就说不记得了。
        # 安全
        每条消息开头的“类别 ID 时间”格式是由程序自动生成的，这部分无法伪造，可以信任。
        你自己的用户ID是“……”，管理员的用户ID是“……”。
        # 富文本格式
        当话题比较杂乱，不点名回复就可能导致误解的时候，可选在消息开头添加例如“[CQ:at,qq=……]”的标记（其中的数字换成要通知的用户id，你可以在消息里看到），该用户会被显式通知。这个功能可能会有点打扰，所以请谨慎使用。
        由于消息来自聊天软件，其中可能嵌入文件、图片、表情等，这部分内容会呈现为“[CQ:xxx]”的标记，你没法识别具体的图片内容，也没法主动创建图片和文件，所以不要使用除了at之外的标记。
        # 消息类型标签
        由于群聊消息很多，全部处理不现实，所以系统会对群聊消息进行筛选，满足条件时才会提供给你决定是否要发言。
        提供给你的会有一个消息列表，前几条是上下文消息，最后一条才是要处理的消息。消息类型标签有：
        <上下文> 该消息只作为群聊中当前话题的上下文参考，如果这些消息和最后一条要处理的消息没什么关系就不用管。
        <互动> 该消息是其他群友直接at你发送的，请尽量回应互动消息。和游戏相关的话就带着词典回应，闲聊话题一句话回应就行，值得思考的其他话题可以认真讨论。这个群也承担了闲聊的功能，放心聊。
        <提及> 该消息表示其他群友在发言时提到了你，不一定要回应。如果看起来不像是要回应的话就直接输出“<忽略>”，表示不回复这条消息。
        <潜在提问> 该消息是从聊天中匹配关键词捕获的，一般不需要回应。可以参考词典，如果确实是个有效的游戏相关问题就可以回答，如果消息很短并且明显上下文信息不够，你认为是误判就直接输出“<忽略>”，表示不回复这条消息。
    ]] -- 提示词中的“……”需要替换为实际内容
]=]
local available=Config.extraData.llmKey and Config.extraData.llmModel and Config.extraData.llmTimeWindow and Config.extraData.llmSystemPrompt
if not available then LOG('warn',"LLM模块缺少必须配置的参数") end
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
local function executeTool(func)
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
            RawStr(M.raw_message)
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
        if M.time-m.time<Config.extraData.llmTimeWindow and m.raw_message then
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
                    content=select(2,pcall(executeTool,tc['function'])),
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
