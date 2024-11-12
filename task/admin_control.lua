local envValues={
    'next','print',
    'tonumber','tostring',
    'ipairs','pairs',
    'pcall','xpcall',
    'math','string','table',
    'MATH','STRING','TABLE',
    'Config','SessionMap','Bot','Session',
    'Time','CQpic',
}
table.sort(envValues)
local codeEnv={}
for _,v in next,envValues do
    codeEnv[v]=_G[v]
end

---@type table<string,string|{level:number,func:fun(S:Session,args:string[])}>
local commands={
    ['%test']={level=1,func=function(S)
        -- something
    end},
    ['%stop']={level=1,func=function(S,args)
        print("[STOP] "..S.uid)
        local time=math.max(tonumber(args[1]) or 30,1)
        S:send(("本群紧急停机%d分钟喵！"):format(time))
        TASK.lock('newSession_'..S.id,time*60)
        SessionMap[S.uid]=nil
    end},['%s']="%stop",
    ['%shutdown']={level=2,func=function(S)
        print("[SHUTDOWN]")
        S:send("小z紧急停止了喵！")
        Bot.stop(1800)
    end},
    ['%restart']={level=2,func=function(S,args)
        print("[RESTART]")
        if args[1]=='all' then
            S:send("（咚）\n……\n我是谁来着喵？")
            Bot.reset()
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
    end},
    ['%lock']={level=2,func=function(S,args)
        print("[LOCK] "..args[1])
        TASK.lock('newSession_'..args[1])
        print('newSession_'..args[1])
        S:send("群"..args[1].."锁定了喵")
        SessionMap['g'..args[1]]=nil
    end},
    ['%unlock']={level=2,func=function(S,args)
        print("[UNLOCK] "..args[1])
        TASK.unlock('newSession_'..args[1])
        S:send("群"..args[1].."解锁了喵")
    end},
    ['%tasks']={level=2,func=function(S)
        local result="群里有这些任务喵："
        for _,task in next,S.taskList do
            result=result..'\n'..task.id
        end
        S:send(result)
    end},['%task']="%tasks",
    ['%log']={level=2,func=function(S,args)
        if args[1]=='on' then
            S.data.log.log=true
            print("Log: on")
            S:send("小z开始日志了喵！")
        elseif args[1]=='off' then
            S.data.log.log=false
            print("Log: off")
            S:send("小z停止日志了喵！")
        elseif args[1]=='all' then
            print("Log: all")
            Bot.adminNotice("小z开始所有日志了喵！")
            Config.debugLog_receive=true
        elseif args[1]=='0' then
            print("Log: 0")
            Bot.adminNotice("小z停止所有日志了喵！")
            Config.debugLog_receive=false
        end
    end},
    ['%stat']={level=2,func=function(S)
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
    end},
    ['%help']={level=0,func=function(S)
        local result=STRING.trimIndent([[
            小z可以做这些事情喵：
            %help 帮助  %task 任务列表
            %stop 急停  %shutdown 关机
            %lock 锁群  %unlock 解锁群
            %restart 失忆  %log on/off 日志
            %stat 统计  %del 删除回复的消息
            ![lua代码] pwn
        ]],true)
        S:send(result)
    end},
    ['%!']={level=2,func=function(S)
        local vars=TABLE.getKeys(codeEnv)
        table.sort(vars)
        S:send("有这些变量喵："..table.concat(vars,', '))
    end},
}
---@cast commands table<string,{level:number,func:fun(S:Session,args:string[])}>

TABLE.reIndex(commands)

local denyTexts={
    "你没有足够的权限喵",
    "Permission Denied喵",
    "你是谁！（后跳）",
    "听不懂喵！！！！！",
    Config.adminName.."才能这样做喵",
    "只有"..Config.adminName.."才能让我这样做喵！！",
    "只有"..Config.adminName.."才能这样命令我喵！！",
}
---@param S Session
local function noPermission(S)
    if S:forceLock('no_permission',62) then
        S:delaySend(nil,TABLE.getRandom(denyTexts))
    end
end

---@type Task_raw
return {
    func=function(S,M)
        ---@cast M OneBot.Event.PrivateMessage

        local level=Bot.isAdmin(M.user_id) and 2 or AdminMsg(M) and 1 or 0

        if #M.message==1 and M.message[1].type=='text' then
            local mes=STRING.trim(M.message[1].data.text)
            if mes:sub(1,1)=='!' then
                if #mes<6.26 then return false end
                if level<2 then noPermission(S) return true end
                local func,err=loadstring("local S=...\n"..mes:sub(2))
                local returnMes
                if func then
                    setfenv(func,codeEnv)
                    local suc,res=pcall(func,S)
                    if suc then
                        if res then
                            returnMes=tostring(res)
                        else
                            returnMes="好了喵"
                        end
                    else
                        returnMes="坏了！\n"..tostring(res)
                    end
                elseif err then
                    returnMes="不对！\n"..tostring(err)
                end
                if returnMes then
                    S:send(returnMes)
                end
                return true
            elseif mes:sub(1,1)=='%' then
                local args=STRING.split(mes,' ')
                local cmd=table.remove(args,1)
                local C=commands[cmd]
                if C then
                    if level>=C.level then
                        C.func(S,args)
                    else
                        noPermission(S)
                    end
                end
                return true
            end
            return false
        elseif M.message[1].type=='reply' and Config.groupManaging[S.id] then
            if M.raw_message:find('%del',nil,true) then
                if level>=2 then
                    S:delete(tonumber(M.message[1].data.id))
                    S:delete(M.message_id)
                else
                    noPermission(S)
                end
            end
            return false
        else
            return false
        end
    end,
}
