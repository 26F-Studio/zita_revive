-- 【需要预加载】
--[=[ 需要在配置文件的extraData内提供如下配置项：
    llmKey="sk-...",              -- 必填，LLM密钥
    llmModel="deepseek-v4-flash", -- 必填，LLM模型
    llmTimeWindow=260,            -- 可选，传入上下文的时间窗口（秒），默认260
    模块行为：
    - 被点名（@或句首叫小z/zita）、提及、疑似提问时触发
    - 点名/提及触发冷却16秒，提问/抽查触发冷却42秒（过于频繁会回应蜗牛emoji）
    - 不聊天，只在找到合适词条时发送“猜你想找：#词条1、#词条2”消息
]=]
local available=Config.extraData.llmKey and Config.extraData.llmModel
if not available then LOG('warn',"whatabout模块缺少必须配置的参数") end
local msgSec={
    {"猜你","你可能","你也许"},
    {"想找","想了解","需要"},
}
local errMsg="有人能告诉"..Config.adminName.."，我的AI有问题"
local timeWindow=Config.extraData.llmTimeWindow or 260
local systemPrompt=STRING.trimIndent[[
    <背景>
    你运行在俄罗斯方块社区机器人Zita上，该账号提供了很多便民功能如游戏词典，检测到他人发送“#XXX”就能查询词典词条，词典里收录了大量方块游戏相关词汇与术语，对新手特别有用。
    这个群偶尔会有新人提问，一些常见问题能直接从词典里找到答案，如询问概念，或者是能从定义轻松推理出答案的。
    </背景>

    <任务>
    - 系统会检测句子里的“？”或“吗”等疑问词，如果是疑问句的话就会把这条消息和一些上文打包提供给你。
    - 如果你判断确实是有人真的有疑问，而不是正常游戏交流、无关话题、反问句，就用 tetris_dict 工具主动检索相关词条，词典里可能包含相关信息。
    - 如果找到了存在且对于回答问题很有帮助的词条，就把关键词汇总成一个列表并调用 submit 工具提交。
    - 否则只需要提交空列表。
    </任务>

    <注意>
    你输出的正文不会被发送到群里，只有调用 submit 工具才会真正发送消息。
    注意该工具较为特殊，调用的同时标志着本轮消息的结束，你不再会获得后续的消息回填。
    </注意>

    接下来的输入是一段时间窗口内的群聊消息，每条消息开头有 <类别> 标签：<上下文> 是历史背景，仅供了解话题；最后一条 <当前> 标注的是触发本次任务的消息。
]]
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
            description="俄罗斯方块术语词典。输入一个词汇，返回对应的解释。收录范围：概念、技巧、游戏、社区俚语、社区贡献者、常见QA。（常见QA例如：社区导航 游戏推荐 游戏分类 新手入门 维基 键位 手感）",
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
    {
        ['type']='function',
        ['function']={
            name='submit',
            description="提交词条列表",
            parameters={
                type='object',
                properties={
                    terms={
                        type='array',
                        items={type='string'},
                        description="词条列表",
                    },
                },
                required={'terms'},
            },
        },
    },
}
local msgID=0
local failBuffer={}

local buf=STRING.newBuf()
local function executeTool(func)
    local suc,args=pcall(JSON.decode,func.arguments)
    if not suc then return "错误：工具参数解析失败 "..args end

    if func.name=='tetris_dict' then
        if type(args.term)~='string' then return "错误：参数term必须是字符串" end
        local entry=Config.extraData._zict[args.term:gsub('%s',''):lower()]
        LOG('debug',"whatabout查询词典 "..args.term..(entry and "（成功）" or "（未找到）"))
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
        content=prefix.." 用户"..M.user_id.."\n"..RawStr(M.raw_message),
    }
end

---@param S Session
---@param M OneBot.Event.PrivateMessage | OneBot.Event.GroupMessage
---@param mode 'explicit' | 'implicit'
local function task_guessThread(S,M,mode)
    msgID=msgID+1
    local sid="["..msgID.."]"
    LOG('debug',("%s %s-%s whatabout输入\n%s"):format(sid,S.uid,M.user_id,M.raw_message))

    local messages={}
    table.insert(messages,{role='system',content=systemPrompt})
    for _,m in next,S.history do
        ---@cast m OneBot.Event.PrivateMessage | OneBot.Event.GroupMessage
        if M.time-m.time<timeWindow and m.raw_message then
            table.insert(messages,convertMsg(m,'<上下文>'))
        end
    end
    table.insert(messages,convertMsg(M,'<当前>'))
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
                if S:forceLock('whatabout_json_encode_error',26) then
                    LOG('warn',sid.." whatabout错误：json打包失败 "..res)
                    if S:lock('whatabout_error',260) then S:send(errMsg) end
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
        ASYNC.runCmd('whatabout_'..sid,STRING.repD(curlCmd,Config.extraData.llmKey,tmpf))
        repeat
            TASK.yieldT(.26)
            jsonRecv=ASYNC.get('whatabout_'..sid)
        until jsonRecv
        ASYNC.runCmd('whatabout_rm_tmp','rm -f '..tmpf)

        local msg
        do
            local suc,res=pcall(JSON.decode,jsonRecv)
            if not suc then
                if S:forceLock('whatabout_json_decode_error',26) then
                    LOG('warn',sid.." whatabout错误：json解析失败 "..res)
                    if S:lock('whatabout_error',260) then S:send(errMsg) end
                end
                return
            end
            suc,res=pcall(TABLE.listIndex,res,{'choices',1,'message'})
            if not (suc and res) then
                if S:forceLock('whatabout_json_decode_error',26) then
                    LOG('warn',sid.." whatabout错误：结果获取失败 "..res)
                    if S:lock('whatabout_error',260) then S:send(errMsg) end
                end
                return
            end
            msg=res
        end

        if not msg.tool_calls or #msg.tool_calls==0 then
            LOG('debug',sid.."whatabout无工具调用，跳过")
            return
        end
        table.insert(messages,msg)
        for _,tc in ipairs(msg.tool_calls) do
            if tc['function'].name=='submit' then
                -- 404 Notify
                if #failBuffer>0 then
                    local terms=table.concat(failBuffer,", ")
                    TABLE.clear(failBuffer)
                    for _,qq in next,Config.extraData.llmDict404notify or NONE do
                        Bot.sendMsg("词典404："..terms,qq)
                    end
                end

                -- Response
                local ok,args=pcall(JSON.decode,tc['function'].arguments)
                if not ok or type(args)~='table' or type(args.terms)~='table' then
                    LOG('warn',sid.." whatabout错误：submit工具参数解析失败")
                    if S:lock('whatabout_error',260) then S:send(errMsg) end
                    return
                end
                local terms={}
                local zict=Config.extraData._zict
                for _,v in next,args.terms do
                    v=v:gsub('%s',''):lower()
                    if zict[v] then table.insert(terms,v) end
                end
                if #terms==0 then
                    if mode=='explicit' then
                        LOG('warn',sid.." whatabout错误：submit参数中没有有效词条（"..table.concat(args.terms,",").."）")
                        if S:lock('whatabout_empty',26) then Bot.reactMessage(M.message_id,Emoji.white_question_mark) end
                    end
                    return
                end
                local text="#"..table.concat(terms," #")
                LOG('debug',sid.."输出提示："..text)
                S:send(TABLE.getRandom(msgSec[1])..TABLE.getRandom(msgSec[2]).." "..text)
                return
            end

            table.insert(messages,{
                role='tool',
                tool_call_id=tc.id,
                content=select(2,pcall(executeTool,tc['function'])),
            })
        end
    end

    LOG('warn',sid.." whatabout错误：工具调用轮次过多")
end

---@type Task_raw
return {
    message=function(S,M)
        if not available then return false end
        local msg=STRING.trim(RawStr(M.raw_message))
        local lower=msg:lower()
        if msg:match("%[CQ:at,qq="..Config.botID.."%D") or lower:find("小z") or lower:find("zita") then
            if Bot.isAdmin(M.user_id) or S:lock('whatabout_cd',16) then
                TASK.new(task_guessThread,S,M,'explicit')
            else
                Bot.reactMessage(M.message_id,Emoji.snail)
            end
            return true
        elseif
            (
                msg:match("%?$") or
                msg:match("？$") or
                msg:match("吗$")
            ) and MATH.between(#msg,12,160) and S:lock('whatabout_cd',42)
        then
            TASK.new(task_guessThread,S,M,'implicit')
            return true
        end
        return false
    end,
}
