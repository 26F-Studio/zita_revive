local codeEnv={}
for _,v in next,{
    'next','print','tonumber','tostring','type',
    'ipairs','pairs','pcall','xpcall',
    'Time','CQ',
    'math','string','table',
    'MATH','STRING','TABLE','GC','FILE','TASK',
    'Config','SessionMap','Bot','Session','Emoji',
} do codeEnv[v]=_G[v] end
codeEnv.os={
    time=os.time,
    date=os.date,
    clock=os.clock,
}

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
    ['%llm']={level=2,func=function(S,args,M,D)
        local param={
            model="mistralai/ministral-3-3b",
            input=args[1] or "Hello",
        }
        local buf=STRING.newBuf()
        buf:put("curl -s http://localhost:1234/api/v1/chat")
        buf:put(" -H 'Content-Type: application/json'")
        buf:put(" -d '"..JSON.encode(param).."'")
        ASYNC.runCmd('llm',buf:get())
        TASK.new(function()
            local t,res=0,nil
            while true do
                res=ASYNC.get('llm')
                t=t+1
                if res or t>=260 then break end
                TASK.yieldT(.1)
            end
            if not res then
                LOG('warn',"LLM timeout")
                return
            end
            res=JSON.decode(res)
            for i=1,#res.output do
                if res.output[i].type=="message" then
                    buf:put(res.output[i].content)
                end
            end
            S:send(buf)
        end)
    end},
    ['%help']={level=0,func=function(S)
        local result=STRING.trimIndent([[
            小z可以做这些事情喵：
            %stat 统计  %log 日志
            %del (回复)删除回复的消息
            %task 事务  %stop <分钟> 急停
            %shutdown 关机  %restart 重启
            ![lua代码] pwn
        ]],true)
        S:send(result)
    end},
    ['%stat']={level=2,func=function(S)
        S:send(STRING.repD("已运行$1，共发$2条消息",STRING.time_simp(Time()-Bot.stat.launchTime),Bot.stat.messageSent))
    end},
    ['%log']={level=2,func=function(_,_,M,D)
        D._log=not D._log
        Bot.reactMessage(M.message_id,D._log and Emoji.hollow_red_circle or Emoji.cross_mark)
    end},
    ['%task']={level=2,func=function(S)
        local result="本群有这些事务喵："
        for _,task in next,S.taskList do
            result=result..'\n'..task.id
        end
        S:send(result)
    end},
    ['%stop']={level=1,func=function(S,args)
        local time=math.max(tonumber(args[1]) or 30,1)
        LOG('warn',"[STOP] "..S.uid..", "..time.."m")
        S:send(("本群紧急停机%d分钟喵！"):format(time))
        TASK.lock('newSession_'..S.id,time*60)
        SessionMap[S.uid]=nil
    end},
    ['%shutdown']={level=2,func=function(S)
        LOG('warn',"[SHUTDOWN]")
        S:send("小z紧急停止了喵！")
        Bot.stop()
    end},
    ['%restart']={level=2,func=function(S,args)
        LOG('warn',"[RESTART]")
        if args[1]=='all' then
            S:send("（咚）\n……\n我是谁来着喵？")
            Bot.reset()
        elseif args[1] then
            local uid=args[1]
            if not SessionMap[uid] then
                local privS=SessionMap['p'..uid]
                local groupS=SessionMap['g'..uid]
                if privS and groupS then
                    LOG('info',"Twin Session: "..uid)
                    S:send("无法唯一确定会话喵")
                    return
                elseif privS or groupS then
                    uid=privS and privS.uid or groupS.uid
                end
            end
            if SessionMap[uid] then
                SessionMap[uid]=nil
                LOG('info',"Delete Session: "..uid)
                S:send("会话数据清空了喵")
            else
                LOG('info',"No Session: "..uid)
                S:send("找不到会话喵")
            end
        else
            S:send("（咚）\n……\n这里是哪里喵？")
            SessionMap[S.id]=nil
        end
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
        if not M.message[1] then return false end
        if M.message[1].type=='text' then
            local level=Bot.isAdmin(M.user_id) and 2 or AdminMsg(M) and 1 or 0
            local mes=STRING.trim(M.message[1].data.text)
            if mes:find('!')==1 then
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
        elseif M.message[1].type=='reply' and Bot.isManaging(S.id) then
            if M.raw_message:find('%del',nil,true) then
                local level=Bot.isAdmin(M.user_id) and 2 or AdminMsg(M) and 1 or 0
                if level>=2 then
                    ---@diagnostic disable-next-line
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
    notice=function(S,N,D)
        if D._log then print(TABLE.dump(N)) end
        -- 2nd way to delete message
        if N.notice_type=='group_msg_emoji_like' then
            ---@cast N OneBot.Event.Notice.Emoji
            if N.is_add and Bot.isManaging(S.id) and Bot.isAdmin(N.user_id) then
                if N.likes[1].emoji_id=="5" then
                    S:delete(N.message_id)
                    return true
                end
            end
        end
        return false
    end,
}
