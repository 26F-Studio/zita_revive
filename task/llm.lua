local available=Config.extraData.llmModel and Config.extraData.llmSystemPrompt and Config.extraData.llmKey

if not available then LOG('warn',"LLM模块需要配置3个参数") end

local curlCmd=[[
curl -s https://api.deepseek.com/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $1" \
  -d '$2'
]]

local ansPool={}
local function parseAnswer(json) return JSON.decode(json).choices[1].message.content end
local function task_pollAnswer(S,sid)
    local suc,res
    repeat
        res=ASYNC.get('llm_'..sid)
        TASK.yieldT(.26)
    until res
    suc,res=pcall(parseAnswer,res)
    S:send(suc and res or "结果解析失败："..res)
    ansPool[sid]=nil
end

---@type Task_raw
return {
    message=function(S,M)
        if not available then return false end
        local msg=STRING.trim(M.raw_message):match("^%[CQ:at,qq="..Config.botID.."%]%s*(.*)$")
        if not msg then return false end
        if not Bot.isAdmin(M.user_id) then
            if S:forceLock('llm_permission_denied',26) then S:send(Config.adminName.."才能这样做喵") end
            return true
        end

        local extraInfo="\n现在是"..os.date("%Y-%m-%d %H:%M:%S")
        local data={
            model=Config.extraData.llmModel,
            thinking={type='disabled'},
            reasoning_effort='high',
            stream=false,
            messages={
                {role='system',content=Config.extraData.llmSystemPrompt..extraInfo},
                {role='user',  content=msg},
            },
        }
        local suc,res=pcall(JSON.encode,data)
        if not suc then
            if S:forceLock('llm_json_encode_error',26) then S:send("json打包错误："..res) end
            return true
        end

        local sid
        repeat sid=math.random(260) until not ansPool[sid]
        ansPool[sid]=true

        ASYNC.runCmd('llm_'..sid,STRING.repD(curlCmd,Config.extraData.llmKey,res))
        TASK.new(task_pollAnswer,S,sid)
        return true
    end,
}
