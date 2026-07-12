Time=love.timer.getTime
Sleep=love.timer.sleep
if love._openConsole then love._openConsole() end
--------------------------------------------------------------
local ins,rem=table.insert,table.remove
require'Zenitha'
ZENITHA.setMainLoopSpeed(30)
ZENITHA.setRenderRate(10)
ZENITHA.setUpdateRate(100)
ZENITHA.setAppInfo('zita_revive','')
--------------------------------------------------------------
Config=FILE.load('botconf.lua','-lua')
print("--------------------------")
print("<< CONF >>")
print("Bot ID: "..Config.botID)
print("Admin name: "..Config.adminName)
print("# Super admin ID:")
for _,id in next,Config.superAdminID do print(id) end
print("# Group managing:")
for _,id in next,Config.groupManaging do print(id) end

local ws=WS.new{
    host=Config.host,
    port=Config.port,
    connTimeout=Config.connectInterval,
    sleepInterval=0.1,
}
--------------------------------------------------------------
-- Remove spaces and convert to lower case
function SimpStr(s) return s:gsub('%s',''):lower() end

local esc={['&amp;']='&',['&#91;']='[',['&#93;']=']',['&#44;']=','}
-- Unescape & Remove username in CQ:at
function RawStr(s)
    s=s:gsub('%[CQ:at,qq=(%d+),name=.-%]','[CQ:at,qq=%1]')
    for k,v in next,esc do s=s:gsub(k,v) end
    return s
end

-- Check if a message is sent by group admin
function AdminMsg(M) return M.sender and (M.sender.role=='owner' or M.sender.role=='admin') end -- Encode cq path

CQ={
    at=function(data) return "[CQ:at,qq="..data.."]" end,
    img=function(data) return Config.imageMode>0 and "[CQ:image,file="..data.."]" or "【图片功能未开启】" end,
    rec=function(data) return "[CQ:record,file="..data.."]" end,
    face=function(data) return "[CQ:face,id="..data.."]" end,
    card_user=function(data) return "[CQ:contact,type=qq,id="..data.."]" end,
    card_group=function(data) return "[CQ:contact,type=group,id="..data.."]" end,
    music=function(plat,data) return "[CQ:music,type="..plat..",id="..data.."]" end,
}
--------------------------------------------------------------
Emoji=require'data.emoji'

local Bot={
    state='dead', ---@type 'dead'|'connecting'|'running'
    delayedAction={}, ---@type {time:number, func:function, data:any}[]
    handlerID=0,
    handlerCache={}, ---@type Map<function>
    stat={
        connectAttempts=0,
        launchTime=Time(),

        connectTime=Time(),
        messageSent=0,
    },
}
_G.Bot=Bot

---@class Task_raw
---@field message? fun(S:Session, M: OneBot.Event.Message, D:Session.data):boolean if returns true, message won't be passed to next task
---@field notice? fun(S:Session, N: OneBot.Event.Notice, D:Session.data):boolean if returns true, message won't be passed to next task
---@field request? fun(S:Session, R: OneBot.Event.GroupRequest, D:Session.data):boolean if returns true, message won't be passed to next task
---@field init? fun(S:Session, D:Session.data)? if exist, execute when task created, jsut after launching

---@class Task : Task_raw
---@field id string
---@field prio number

---@alias Sendable string|number|boolean|string.buffer|table

---@param data table
function Bot._send(data)
    if data.handler then
        if data.echo then LOG('warn',"Bot._send: req.handler overwrites req.echo") end
        Bot.handlerID=Bot.handlerID+1
        data.echo='handler_'..Bot.handlerID
        Bot.handlerCache[data.echo]=data.handler
        data.handler=nil
    end
    local suc,res=pcall(JSON.encode,data)
    if suc then
        if Config.debugLog_send then
            print(TABLE.dump(data))
        end
        ws:send(res)
        return true
    else
        LOG('warn',"Error encoding json:\n"..debug.traceback(res))
    end
end
---@param message Sendable
---@param id number
---@param priv? boolean is private message
---@param echo? string
function Bot.sendMsg(message,id,priv,echo)
    if priv==nil then priv=not SessionMap['g'..id] end -- Prefer Group
    local mes
    if type(message)=='table' then
        -- Forward message
        mes={
            action='send_forward_msg',
            params={
                [priv and 'user_id' or 'group_id']=id,
                messages=message,
            },
            echo=echo,
        }
    else
        -- Normal message
        mes={
            action='send_msg',
            params={
                [priv and 'user_id' or 'group_id']=id,
                message=tostring(message),
            },
            echo=echo,
        }
    end
    if Bot._send(mes) then
        Bot.stat.messageSent=Bot.stat.messageSent+1
    end
end
---@param mes_id number
function Bot.deleteMsg(mes_id)
    Bot._send{
        action='delete_msg',
        params={
            message_id=mes_id,
        },
    }
end
function Bot.reactMessage(mes_id,emoji_id)
    Bot._send{
        action='set_msg_emoji_like',
        params={
            message_id=mes_id,
            emoji_id=emoji_id,
        },
    }
end
function Bot.sendLike(uid,count)
    Bot._send{
        action='send_like',
        params={
            uid=uid,
            times=count or 10,
        },
    }
end
---@param R OneBot.Event.GroupRequest
---@param approve boolean
---@param reason? string only useful when approve is false
function Bot.resolveJoinRequest(R,approve,reason)
    Bot._send{
        action='set_group_add_request',
        params={
            flag=R.flag,
            sub_type=R.sub_type,
            approve=approve,
            reason=reason,
        },
    }
end
local imgCnt=0
---@param canvas love.Canvas
---@return string
---@nodiscard
function Bot.canvasToImage(canvas,x,y,w,h)
    if Config.imageMode<2 then return "绘图功能未开启" end
    local file="temp_"..imgCnt..".png"
    imgCnt=(imgCnt+1)%10
    if not x then x,y,w,h=0,0,canvas:getWidth(),canvas:getHeight() end
    GC.saveCanvas(canvas,file,'png',0,1,x,y,w,h)
    local full=love.filesystem.getSaveDirectory()..'/'..file
    os.execute('chmod 644 '..full)
    os.execute('mv '..full..' '..Config.sandboxRealPath..file)
    return CQ.img(Config.sandboxPath..file)
end
---@param group_id number
---@param user_id number
---@param time? number minutes
function Bot.ban(group_id,user_id,time)
    if not time then time=1 end
    if time>=1 then
        Bot._send{
            action='set_group_ban',
            params={
                group_id=group_id,
                user_id=user_id,
                duration=math.min(math.floor(time)*60,30*86400),
            },
        }
    end
end
---@param group_id number
---@param user_id number
---@param reject_rejoin? boolean
function Bot.kick(group_id,user_id,reject_rejoin)
    Bot._send{
        action='set_group_kick',
        params={
            group_id=group_id,
            user_id=user_id,
            reject_rejoin=reject_rejoin,
        },
    }
end

local function userInfoHandler(data)
            if data.user_id then
                Config.botID=data.user_id
            else
                LOG('warn',"Failed to get bot ID")
            end
            if data.nickname then
                Config.nickName=data.nickname
            else
                LOG('warn',"Failed to get bot nickname")
            end
end
function Bot.refreshUserInfo()
    if Config.botID and Config.botID>0 then return end
    Bot._send{
        action='get_login_info',
        handler=userInfoHandler,
    }
end
---@param msg_id number
---@param handler fun(data:table)
function Bot.getMsg(msg_id,handler)
    Bot._send{
        action='get_msg',
        params={message_id=msg_id},
        handler=handler,
    }
end
---@param handler fun(data:table)
function Bot.getGroupInfo(group_id,handler)
    Bot._send{
        action='get_group_info',
        params={group_id=group_id},
        handler=handler,
    }
end
---@param handler fun(data:table)
function Bot.getMemberList(group_id,handler)
    Bot._send{
        action='get_group_member_list',
        params={group_id=group_id},
        handler=handler,
    }
end

function Bot.isManaging(gid)
    return TABLE.find(Config.groupManaging,gid)
end
function Bot.isAdmin(pid)
    return TABLE.find(Config.superAdminID,pid)
end
function Bot.adminNotice(text)
    for _,id in next,Config.superAdminID do
        Bot.sendMsg(text,id,true)
    end
end
function Bot.reset()
    for id in next,SessionMap do
        SessionMap[id]=nil
    end
end
function Bot.stop(time)
    if time then
        TASK.forceLock('bot_blockRestart',time or 600)
        ws:close()
    else
        ws:close()
        love.event.quit()
    end
end

---@return true? #if any message processed
function Bot._update()
    local pack,op=ws:receive()
    if not pack then return end
    if op=='text' then
        local suc,res=pcall(JSON.decode,pack)
        ---@cast res OneBot.Event.Base
        if not suc then
            LOG('info',"Error decoding json: "..res)
            print(pack)
            return true
        end
        if res.post_type=='meta_event' then
            ---@cast res OneBot.Event.Meta
            if res.meta_event_type=='lifecycle' then
                LOG("Lifecycle event: "..res.sub_type)
            end
        elseif res.post_type=='message' then
            ---@cast res OneBot.Event.Message
            local priv=res.message_type=='private'
            local id=priv and res.user_id or res.group_id
            local S=SessionMap[(priv and 'p' or 'g')..id]
            if not S then
                if TASK.getLock('newSession_'..id) then return true end
                S=Session.new(id,priv)
                SessionMap[S.uid]=S
            end
            S:receive(res,'message')
        elseif res.post_type=='notice' then
            ---@cast res OneBot.Event.Notice
            if res.group_id then
                local id=res.group_id
                local S=SessionMap['g'..id]
                if not S then
                    if TASK.getLock('newSession_'..id) then return true end
                    S=Session.new(id,false)
                    SessionMap[S.uid]=S
                end
                S:receive(res,'notice')
            end
        elseif res.post_type=='request' then
            -- OneBot.Event.Request not considered now
            ---@cast res OneBot.Event.GroupRequest
            if res.group_id then
                local id=res.group_id
                local S=SessionMap['g'..id]
                if not S then
                    if TASK.getLock('newSession_'..id) then return true end
                    S=Session.new(id,false)
                    SessionMap[S.uid]=S
                end
                S:receive(res,'request')
            else
                ---@cast res OneBot.Event.Request
            end
        elseif rawget(res,'retcode') then
            -- API response
            ---@cast res OneBot.Event.Response
            if res.echo then
                local echo=res.echo ---@type string
                if Bot.handlerCache[echo] then
                    local handler=Bot.handlerCache[echo]
                    Bot.handlerCache[echo]=nil
                    local s,r=pcall(handler,res.data)
                    if not s then LOG('warn',"Handler Error: "..r) end
                elseif echo:match(':') then
                    local sid,echoStr=echo:match('(.+):(.+)')
                    local S=SessionMap[sid]
                    if S then
                        S.echoMesMap[echoStr]=res.data.message_id
                    end
                end
            end
            if res.data and res.data.message_id and TABLE.getSize(res.data)==1 then
                Bot.getMsg(res.data.message_id,function(data)
                    ---@cast data OneBot.Event.PrivateMessage | OneBot.Event.GroupMessage
                    if data.message_type=='group' then
                        SessionMap['g'..data.group_id]:appendHistory(data)
                    elseif data.message_type=='private' then
                        SessionMap['p'..data.user_id]:appendHistory(data)
                    end
                end)
            end
        end
        if Config.debugLog_message and res.post_type=='message' then print("[DEBUG] message",TABLE.dump(res)) end
        if Config.debugLog_notice and res.post_type=='notice' then print("[DEBUG] notice",TABLE.dump(res)) end
        if Config.debugLog_request and res.post_type=='request' then print("[DEBUG] request",TABLE.dump(res)) end
        if Config.debugLog_response and not res.post_type then print("[DEBUG] response",TABLE.dump(res)) end
    elseif op~='pong' then
        print("[inside: "..op.."]")
        if type(pack)=='string' and #pack>0 then print(pack) end
    end
    return true
end
--------------------------------------------------------------
---@alias Session.data table
---@class Session
---@field id number Number, may collide (privID & groupID)
---@field uid string just 'p' or 'g' + id, for being used as unique key in SessionMap, etc.
---@field priv boolean
---@field group boolean #not priv
---@field taskList Task[]
---@field locks Map<number>
---@field echoMesMap Map<number>
---@field data Map<Session.data>
---@field history OneBot.Event.Base[]
---
---@field charge number
---@field maxCharge number
---@field lastUpdateTime number
Session={}

local lockMapMeta={
    __index=function(self,k)
        rawset(self,k,-1e99)
        return -1e99
    end,
    __newindex=function(self,k) rawset(self,k,-1e99) end,
}
---@return Session
function Session.new(id,priv)
    ---@type Session
    local s={
        id=id,
        uid=(priv and 'p' or 'g')..id,
        priv=priv,
        group=not priv,
        admin=not priv and Bot.isManaging(id),
        taskList={},
        locks=setmetatable({},lockMapMeta),
        echoMesMap={},
        data={},
        history={},

        charge=Config.maxCharge,
        maxCharge=Config.maxCharge,
        lastUpdateTime=Time(),
    }
    setmetatable(s,{__index=Session})

    if Config.spSession[s.uid] then
        for _,task in next,Config.spSession[s.uid] or {} do
            s:newTask(unpack(task))
        end
    else
        local template=priv and Config.privTask or Config.groupTask
        for _,task in next,template do
            s:newTask(task[1],task[2])
        end
        for _,exTask in next,Config.extraTask[s.uid] or {} do
            s:newTask(unpack(exTask))
        end
    end
    return s
end
function Session:isAlive()
    if SessionMap[self.uid] then return true end
end

---@param id string Task name
---@param prio number Task priority
function Session:newTask(id,prio)
    ---@type Task_raw
    local task=require('task.'..id)
    local insPos
    for i=1,#self.taskList do
        local t=self.taskList[i]
        if id==t.id then
            LOG('info',"Task created failed: Task '"..id.."' already exists")
            return
        elseif prio==t.prio then
            LOG('info',"Task created failed: Prio '"..prio.."' already used by task '"..t.id.."'")
            return
        elseif not insPos and prio<t.prio then
            insPos=i
        end
    end
    if not insPos then insPos=#self.taskList+1 end
    ins(self.taskList,insPos,{
        prio=prio,
        id=id,
        message=task.message or NULL,
        notice=task.notice or NULL,
        request=task.request or NULL,
    })
    self.data[id]={}
    if task.init then task.init(self,self.data[id]) end
end
---@param id string
function Session:removeTask_id(id)
    for i=1,#self.taskList do
        if self.taskList[i].id==id then
            LOG('info',"Task removed: "..id)
            rem(self.taskList,i)
            return
        end
    end
end
function Session:removeAllTask()
    for id,task in next,self.taskList do
        if task.prio>0 then
            self.taskList[id]=nil
        end
    end
    LOG('info',"All user tasks cleared")
end

---@param name any
---@param time? number
---@return boolean
function Session:lock(name,time)
    if Time()>=self.locks[name] then
        self.locks[name]=Time()+(time or 1e99)
        return true
    else
        return false
    end
end
---@param name any
---@param time? number
---@return boolean
function Session:forceLock(name,time)
    local res=Time()>=self.locks[name]
    self.locks[name]=Time()+(time or 1e99)
    return res
end
---@param name any
function Session:unlock(name)
    self.locks[name]=-1e99
end
---@param name any
---@return number|false
function Session:getLock(name)
    local v=self.locks[name]-Time()
    return v>0 and v
end
function Session:purgeLock()
    for k,v in next,self.locks do
        if Time()>v then self.locks[k]=nil end
    end
end
function Session:clearLock()
    for k in next,self.locks do
        self.locks[k]=nil
    end
end

function Session:update()
    self.charge=math.min(self.charge+(Time()-self.lastUpdateTime),self.maxCharge)
    self.lastUpdateTime=Time()
end
function Session:costCharge(charge)
    self:update()
    if self.charge>=charge then
        self.charge=self.charge-charge
        return true
    else
        return false
    end
end
function Session:useCharge(charge)
    self:update()
    self.charge=math.max(self.charge-charge,0)
end

---@param M OneBot.Event.Base
---@param type 'message' | 'notice' | 'request'
function Session:receive(M,type)
    for _,task in next,self.taskList do
        local suc,res=pcall(task[type],self,M,self.data[task.id])
        if suc then
            if res==true then break end
        else
            LOG('warn',STRING.repD("Session-$1 Task-$2 ($3) Error:\n$4",self.id,task.id,os.date("%m/%d %H:%M:%S"),res))
            break
        end
    end
    self:appendHistory(M)
end
---@param M OneBot.Event.Base
function Session:appendHistory(M)
    table.insert(self.history,M)
    while #self.history>Config.sessionHistoryLen do
        table.remove(self.history,1)
    end
end

---@param text Sendable
---@param echo? string
function Session:send(text,echo)
    if not self:isAlive() or not text then return end
    if echo then echo=self.uid..':'..echo end
    Bot.sendMsg(text,self.id,nil,echo)
end
---@param id number|string string means search id from Session.echos
function Session:delete(id)
    if not self:isAlive() then return end
    if type(id)=='number' then
        Bot.deleteMsg(id)
    else
        if self.echoMesMap[id] then
            Bot.deleteMsg(self.echoMesMap[id])
            self.echoMesMap[id]=nil
        end
    end
end
---@param text Sendable
---@param time? number seconds (default to 0.26~1.26s), must <= 86400 (1 day)
function Session:delaySend(text,time)
    if time and time>86400 or not text then return end
    if time==nil then time=.26+math.random() elseif time<=0 then return self:send(text,echo) end
    self:_timeTask(self.send,time,{self,text})
end
---@param id number|string string means search id from Session.echos
---@param time? number seconds (default to 0.26~1.26s), must <= 86400 (1 day)
function Session:delayDelete(id,time)
    if time and time>86400 then return end
    if time==nil then time=.26+math.random() elseif time<=0 then return self:delete(id) end
    self:_timeTask(self.delete,time,{self,id})
end
---@param action function
---@param time number seconds
---@param data any[]
function Session:_timeTask(action,time,data)
    time=Time()+time
    local queue=Bot.delayedAction
    local insPos
    if not queue[1] or time<queue[1].time then
        insPos=1
    elseif time<queue[#queue].time then
        local i,j=1,#queue
        while i<=j do
            local m=math.floor((i+j)/2)
            if queue[m].time>time then
                j=m-1
            else
                i=m+1
            end
        end
        insPos=i
    end
    ins(queue,insPos or #queue+1,{
        time=time,
        func=action,
        data=data,
    })
end

---@type table<string, Session>
SessionMap={}
--------------------------------------------------------------
ZENITHA.globalEvent.drawCursor=NULL
ZENITHA.globalEvent.clickFX=NULL
ZENITHA.globalEvent.quit=function()
    ws:close()
    ws:update()
    love.timer.sleep(0.0626)
end

local scene={}

function scene.load() end

local userInput=love.thread.getChannel('userInput')
local cmdList
cmdList={
    help=function()
        print("[Help]")
        print("Available commands: "..table.concat(TABLE.getKeys(cmdList),","))
    end,
    echo=function(...)
        print("[Echo]")
        print(...)
    end,
    send=function(uid,...)
        Bot.sendMsg(table.concat({...}," "),uid)
    end,
    stat=function()
        print("\n[Statistics]")
        print("Alive time: "..STRING.time(Time()-Bot.stat.connectTime))
        print("Messages sent: "..Bot.stat.messageSent)
    end,
    exit=function()
        print("\n[EXIT]")
        Bot.stop(MATH.inf)
        love.event.quit()
    end,
}
function scene.update()
    if userInput:getCount()>0 then
        local args=STRING.split(userInput:pop(),' ')
        local cmd=table.remove(args,1)
        local func=cmdList[cmd] or cmdList.help
        func(unpack(args))
    end
    if ws.state=='dead' then
        if Bot.state=='running' then
            -- Disconnected from running state
            Bot.reset()
            LOG('error',"Disconnected")
            LOG('info',"Retry after "..Config.connectInterval.."s...")
            Bot.state='dead'
        elseif Bot.state=='connecting' then
            -- Disconnected from connecting state
            LOG('error',"Cannot connect")
            LOG('info',"Retry after "..Config.connectInterval.."s...")
            Bot.state='dead'
        end
        if TASK.getLock('bot_blockRestart') then return end
        Bot.state='connecting'
        Bot.stat.connectAttempts=Bot.stat.connectAttempts+1
        if Bot.stat.connectAttempts>=10 then
            Config.connectInterval=Config.reconnectInterval
        end
        TASK.lock('bot_blockRestart',Config.connectInterval)
        ws:connect()
        print("--------------------------")
        print("<< LOG >>")
        LOG('info',STRING.repD("Connecting... ($1)",Bot.stat.connectAttempts))
    elseif ws.state=='connecting' then
        ws:update()
    elseif ws.state=='running' then
        if Bot.state~='running' then
            Bot.state='running'
            Config.connectInterval=Config.reconnectInterval
            LOG('info',"Connected")
            Bot.refreshUserInfo()
            -- Bot.adminNotice(Bot.stat.connectAttempts==1 and "小z启动了喵！" or STRING.repD("小z回来了喵…（第$1次）",Bot.stat.connectAttempts))
        end
        while true do
            local m=Bot.delayedAction[1]
            if not m or Time()<m.time then break end
            m.func(unpack(m.data))
            rem(Bot.delayedAction,1)
        end
        if TASK.lock('bot_gc',26) then collectgarbage() end
        repeat until not Bot._update()
    end
end
function scene.keyDown(k)
    if k=='e' then
        cmdList.exit()
    elseif k=='s' then
        cmdList.stat()
    end
end
function scene.unload() end

-- love.thread.newThread('io_thread.lua'):start()

SCN.add('main', scene)
ZENITHA.setFirstScene('main')

-- Lock-freshing Daemon
TASK.new(function()
    while true do
        TASK.yieldT(10*60)
        if Bot.state=='running' then
            TASK.purgeLock()
            for _,S in next,SessionMap do
                S:purgeLock()
            end
        end
    end
end)

print("--------------------------")
print("<< PRELOAD >>")
for _,t in next,Config.preloadTask do require('task.'..t) end
