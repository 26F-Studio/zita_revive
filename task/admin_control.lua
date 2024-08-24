local envValues={
    'next','print',
    'tonumber','tostring',
    'ipairs','pairs',
    'pcall','xpcall',
    'math','string','table',
    'MATH','STRING','TABLE',
    'Config','SessionMap','Bot','Session',
    'Time',
}
table.sort(envValues)
local codeEnv={}
for _,v in next,envValues do
    codeEnv[v]=_G[v]
end

---@type table<string,fun(S:Session,args:string[])|string>
local commands={
    ['%test']=function(S)
        -- something
    end,
    ['%stop']=function(S)
        print("[STOP]")
        S:send("小z紧急停止了喵！")
        Bot.stop(1800)
    end,['%s']="%stop",
    ['%sleep']=function(S,args)
        local time=tonumber(args[1]) or 600
        print("[DISCONNECT] "..time)
        S:send("小z准备睡觉了喵！")
        Bot.stop(time)
    end,
    ['%restart']=function(S,args)
        print("[RESTART]")
        if args[1]=='all' then
            S:send("（咚）\n……\n我是谁来着喵？")
            Bot.restart()
        elseif args[1] then
            local uid=args[1]
            if not SessionMap[uid] then
                local privS=SessionMap['p'..uid]
                local groupS=SessionMap['g'..uid]
                if privS and groupS then
                    print("Twin Session: "..uid)
                    S:send("有两个会话奇迹般地id一样喵！小z不知道是指哪个喵！")
                elseif privS or groupS then
                    uid=privS and privS.uid or groupS.uid
                end
            end
            if SessionMap[uid] then
                print("Delete Session: "..uid)
                S:send("小z忘记那里的事情了喵！")
                SessionMap[uid]=nil
            else
                print("No Session: "..uid)
                S:send("小z不知道那是哪里喵…？")
            end
        else
            S:send("（咚）\n……\n这里是哪里喵？")
            SessionMap[S.id]=nil
        end
    end,
    ['%lock']=function(S,args)
        print("[LOCK] "..args[1])
        TASK.lock('newSession_'..args[1])
        print('newSession_'..args[1])
        S:send("群"..args[1].."锁定了喵")
        SessionMap['g'..args[1]]=nil
    end,
    ['%unlock']=function(S,args)
        print("[UNLOCK] "..args[1])
        TASK.unlock('newSession_'..args[1])
        S:send("群"..args[1].."解锁了喵")
    end,
    ['%tasks']=function(S)
        local result="群里有这些任务喵："
        for _,task in next,S.taskList do
            result=result..'\n'..task.id
        end
        S:send(result)
    end,['%task']="%tasks",
    ['%log']=function(S,args)
        local on=args[1]==''
        print("Log: "..(on and "on" or "off"))
        S:send(on and "小z开始日志了喵！" or "小z停止日志了喵！")
        Config.debugLog_receive=on
    end,
    ['%stat']=function(S)
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
    ['%help']=function(S)
        local result=STRING.trimIndent([[
            小z可以做这些事情喵：
            %help 帮助  %task 任务列表
            %stop 急停  %sleep 睡觉
            %lock 锁群  %unlock 解锁群
            %restart 失忆  %log on/off 日志
            %stat 统计  ![lua代码] 运行代码
        ]],true)
        S:send(result)
    end,
    ['%!']=function(S)
        local vars=TABLE.getKeys(codeEnv)
        table.sort(vars)
        S:send("有这些变量喵："..table.concat(vars,', '))
    end,
}
TABLE.reIndex(commands)

local texts={
    {
        Config.adminName.."才能这样做喵",
        "你没有足够的权限喵",
        "Permission Denied喵",
    },
    {
        "你是谁！（后跳）",
        "听不懂喵！！！！！",
        "只有"..Config.adminName.."才能这样命令我喵！！",
    },
}
local function no_permission(S,i)
    if S:forceLock('no_permission',12) then
        S:send(texts[i][math.random(#texts[i])])
    end
end

---@type Task_raw
return {
    func=function(S,M)
        ---@cast M LLOneBot.Event.PrivateMessage
        local mes=STRING.trim(RawStr(M.raw_message))
        local args=STRING.split(mes,' ')
        local cmd=table.remove(args,1)
        if commands[cmd] then
            if not Bot.isAdmin(M.user_id) then
                no_permission(S,1)
                return true
            end
            commands[cmd](S,args)
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
