local codeEnv={}
for _,v in next,{'next','print','tonumber','tostring','ipairs','pairs','math','string','table','MATH','STRING','TABLE','Config','SessionMap','Bot','Session'} do
    codeEnv[v]=_G[v]
end

---@type table<string,fun(S:Session,args:string[])|string>
local commands={
    ['#stop']=function(S)
        print("[STOP]")
        S:send("小z紧急停止了喵！")
        Bot.stop(1800)
    end,['#s']="#stop",
    ['#sleep']=function(S,args)
        local time=tonumber(args[1]) or 600
        print("[DISCONNECT] "..time)
        S:send("小z准备睡觉了喵！")
        Bot.stop(time)
    end,
    ['#restart']=function(S,args)
        print("[RESTART]")
        if args[1]=='all' then
            S:send("（喷一下）这是什么？")
            Bot.restart()
        elseif tonumber(args[1]) then
            S:send("好的，小z忘记那里了喵！")
            SessionMap[tonumber(args[1])]=nil
        else
            S:send("（咚）\n……\n小z失忆了喵！")
            SessionMap[S.id]=nil
        end
    end,
    ['#tasks']=function(S)
        local result="群里有这些任务喵："
        for _,task in next,S.taskList do
            result=result..'\n'..task.id
        end
        S:send(result)
    end,['#task']="#tasks",
    ['#log']=function(S,args)
        local on=args[1]==''
        print("Log: "..(on and "on" or "off"))
        S:send(on and "小z开始日志了喵！" or "小z停止日志了喵！")
        Config.debugLog_message=on
    end,
    ['#stat']=function(S)
        local result=STRING.repD(STRING.trimIndent[[
            我做了这些事情喵：
            本次运行时间:$1
            本次发消息数:$2

            连接次数:$3
            总运行时间:$4
            总发消息数:$5
        ]],
            STRING.time(love.timer.getTime()-Bot.stat.connectTime),
            Bot.stat.messageSent,
            Bot.stat.connectAttempts,
            STRING.time(love.timer.getTime()-Bot.stat.launchTime),
            Bot.stat.totalMessageSent
        )
        S:send(result)
    end,
    ['#help']=function(S)
        local result=STRING.trimIndent([[
            zita可以做这些事情喵：
            #help 帮助
            #stop 急停
            #sleep 睡觉
            #restart 失忆
            #task 任务列表
            #log on/off 日志
            #stat 统计
            ![lua代码] 执行代码
                Config
                SessionMap
                Bot
                Session
        ]],true)
        S:send(result)
    end,
}
TABLE.reIndex(commands)

local texts={
    {
        "Z酱才能这样做喵",
        "你没有足够的权限喵",
        "Permission Denied喵",
    },
    {
        "你是谁！（后跳）",
        "听不懂喵！！！！！",
        "只有Z酱才能这样命令我喵！！",
    },
}
local function no_permission(S,i)
    if S:forceLock('no_permission',6.26) then
        S:send(texts[i][math.random(#texts[i])])
    end
end

---@type Task_raw
return {
    func=function(S,M)
        ---@cast M LLOneBot.Event.PrivateMessage
        local mes=M.raw_message
        local args=STRING.split(mes,' ')
        if commands[args[1]] then
            if not Bot.isAdmin(M.user_id) then
                no_permission(S,1)
                return true
            end
            commands[args[1]](S,TABLE.sub(args,2))
            return true
        elseif mes:sub(1,1)=='!' then
            if not Bot.isAdmin(M.user_id) then
                no_permission(S,2)
                return true
            end
            local func,err=loadstring(mes:sub(2))
            local returnMes
            if func then
                setfenv(func,codeEnv)
                local suc,res=pcall(func)
                if suc then
                    returnMes="好了喵"..(res~=nil and "\n"..tostring(res) or "")
                else
                    returnMes="坏了！\n"..tostring(res)
                end
            elseif err then
                returnMes="不对！\n"..tostring(err)
            end
            S:send(returnMes)
            return true
        end
        return false
    end,
}
