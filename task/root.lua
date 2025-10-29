local codeEnv={}
for _,v in next,{
    'next','print','tonumber','tostring',
    'ipairs','pairs','pcall','xpcall',
    'Time','CQ',
    'math','string','table',
    'MATH','STRING','TABLE','GC','FILE',
    'Config','SessionMap','Bot','Session','Emoji',
} do codeEnv[v]=_G[v] end

local denyTexts={
    "你没有足够的权限喵",
    "Permission Denied喵",
    "你是谁！（后跳）",
    Config.adminName.."才能这样做喵",
    "我只听"..Config.adminName.."的喵！",
}
---@param S Session
local function noPermission(S)
    if S:forceLock('no_permission',62) then
        S:delaySend(nil,TABLE.getRandom(denyTexts))
    end
end

---@type table<string,string|{level:number,func:fun(S:Session, args:string[], M:OneBot.Event.Message, D:Session.data)}>
local commands={
    ['%test']={level=1,func=function(S,args,M,D)
        -- something
    end},
    ['%help']={level=0,func=function(S)
        local result=STRING.trimIndent([[
            小z可以做这些事情喵：
            %help 帮助  %task 事务列表
            %stop 急停  %shutdown 关机
            %lock 锁群  %unlock 解锁群
            %restart 失忆  %log 日志
            %stat 统计  %del 删除回复的消息
            ![lua代码] pwn
        ]],true)
        S:send(result)
    end},
    ['%task']={level=2,func=function(S)
        local result="本群有这些事务喵："
        for _,task in next,S.taskList do
            result=result..'\n'..task.id
        end
        S:send(result)
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
                    S:send("无法唯一确定会话喵")
                    return
                elseif privS or groupS then
                    uid=privS and privS.uid or groupS.uid
                end
            end
            if SessionMap[uid] then
                SessionMap[uid]=nil
                print("Delete Session: "..uid)
                S:send("会话数据清空了喵")
            else
                print("No Session: "..uid)
                S:send("找不到会话喵")
            end
        else
            S:send("（咚）\n……\n这里是哪里喵？")
            SessionMap[S.id]=nil
        end
    end},
    ['%log']={level=2,func=function(_,_,M,D)
        D._log=not D._log
        Bot.reactMessage(M.message_id,D._log and Emoji.check_mark_button or Emoji.cross_mark)
    end},
    ['%stat']={level=2,func=function(S)
        local result=STRING.repD(STRING.trimIndent[[
                本轮工作汇报
                运行时间:$1($2)
                连接次数:$3
                发消息数:$4
            ]],
            STRING.time(Time()-Bot.stat.launchTime),
            STRING.time(Time()-Bot.stat.connectTime),
            Bot.stat.connectAttempts,
            Bot.stat.messageSent
        )
        S:send(result)
    end},
    ['%!']={level=2,func=function(S)
        local vars=TABLE.getKeys(codeEnv)
        S:send("有这些变量喵："..table.concat(TABLE.sort(vars),', '))
    end},
}

---@type Task_raw
return {
    message=function(S,M,D)
        if D._log then print(TABLE.dump(M)) end
        if #M.message==1 and M.message[1].type=='text' then
            local level=Bot.isAdmin(M.user_id) and 2 or AdminMsg(M) and 1 or 0
            local mes=STRING.trim(M.message[1].data.text)
            if mes:find('!')==1 or mes:find('！')==1 then
                if #mes<6.26 then return false end
                if level<2 then
                    noPermission(S)
                    return true
                end
                local func,err=loadstring("local S=...\n"..(mes:find('!')==1 and mes:sub(2) or mes:sub(4)))
                if func then
                    setfenv(func,codeEnv)
                    local suc,res=pcall(func,S,D)
                    if suc then
                        if res then
                            S:send(tostring(res))
                        else
                            Bot.reactMessage(M.message_id,144)
                        end
                    else
                        S:send("坏了！\n"..tostring(res))
                    end
                elseif err then
                    S:send("不对！\n"..tostring(err))
                end
                return true
            elseif mes:sub(1,1)=='%' then
                local args=STRING.split(mes,' ')
                local cmd=table.remove(args,1)
                local C=commands[cmd]
                if C then
                    if level>=C.level then
                        C.func(S,args,M,D)
                    else
                        noPermission(S)
                    end
                end
                return true
            end
        elseif M.message[1].type=='reply' and Config.groupManaging[S.id] then
            if M.raw_message:find('%del',nil,true) then
                local level=Bot.isAdmin(M.user_id) and 2 or AdminMsg(M) and 1 or 0
                if level>=2 then
                    S:delete(tonumber(M.message[1].data.id))
                    S:delete(M.message_id)
                else
                    noPermission(S)
                end
                return true
            end
        end
        return false
    end,
    notice=function(_,N,D)
        if D._log then print(TABLE.dump(N)) end
        return false
    end,
}
