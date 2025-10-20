Time=love.timer.getTime
if love._openConsole then love._openConsole() end
--------------------------------------------------------------
local ins,rem=table.insert,table.remove
require'Zenitha'
ZENITHA.setMainLoopSpeed(30)
ZENITHA.setRenderRate(10)
ZENITHA.setUpdateRate(100)
ZENITHA.setAppInfo('zita_revive','')
--------------------------------------------------------------
Config={
    connectInterval=2.6,
    reconnectInterval=600,
    receiveDelay=0.26,
    maxCharge=620,
    debugLog_send=false,
    debugLog_message=false,
    debugLog_notice=false,
    debugLog_request=false,
    debugLog_response=false,
    safeMode=false,
    botID=false,
    adminName="管理员",
    superAdminID={},
    groupManaging={},
    safeSessionID={},
    privTask={},
    groupTask={},
    extraData={},
}
xpcall(function()
    local data=FILE.load('botconf.lua','-lua')
    ---@cast data Data
    Config.host=data.host
    Config.port=data.port

    Config.botID=data.botID
    Config.adminName=data.adminName

    Config.superAdminID=TABLE.getValueSet(data.superAdminID)
    Config.groupManaging=TABLE.getValueSet(data.groupManaging)
    Config.safeSessionID=TABLE.getValueSet(data.safeSessionID)
    Config.privTask=data.privTask or Config.privTask
    Config.groupTask=data.groupTask or Config.groupTask
    Config.extraTask=data.extraTask or Config.extraTask
    Config.extraData=data.extraData or Config.extraData

    LOG('info',"botconf.lua successfully loaded")
end,function(mes)
    LOG('error',"Error in loading botconf.lua: "..mes)
    LOG('error',"Some settings may not be loaded correctly")
end)
print("--------------------------")
print("Bot ID: "..Config.botID)
print("Admin name: "..Config.adminName)
print("# Super admin ID:")
for id in next,Config.superAdminID do print(id) end
print("# Group managing:")
for id in next,Config.groupManaging do print(id) end
print("# Safe session ID:")
for id in next,Config.safeSessionID do print(id) end

local ws=WS.new{
    host='localhost',
    port='3001',
    connTimeout=2.6,
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
    img=function(data) return "[CQ:image,file="..data.."]" end,
}
--------------------------------------------------------------
Bot={
    state='dead', ---@type 'dead'|'connecting'|'running'
    delayedAction={}, ---@type {time:number, func:function, data:any}[]
    stat={
        connectAttempts=0,
        launchTime=Time(),
        totalMessageSent=0,

        connectTime=Time(),
        messageSent=0,
    },
}

---@class Task_raw
---@field message? fun(S:Session, M: OneBot.Event.Message, D:Session.data):boolean true means message won't be passed to next task
---@field notice? fun(S:Session, N: OneBot.Event.Message, D:Session.data):boolean true means message won't be passed to next task
---@field init? fun(S:Session, D:Session.data)? if exist, execute when task created, jsut after launching

---@class Task : Task_raw
---@field id string
---@field prio number

---@alias Sendable string|number|boolean|string.buffer

---Check if a user is configured as super admin
function Bot.isAdmin(id)
    return Config.superAdminID[id]
end

---@param data table
function Bot._send(data)
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
---@param uid string 'p123456' or 'g123456'
---@param echo? string
function Bot.sendMsg(message,uid,echo)
    if tonumber(uid) then uid='g'..uid end
    local mes={
        action='send_msg',
        params={
            [uid:sub(1,1)=='g' and 'group_id' or 'user_id']=tonumber(uid:sub(2)),
            message=tostring(message),
        },
        echo=echo,
    }
    if Config.safeMode and not Config.safeSessionID[uid] then
        if TASK.lock('safeModeBlock',10) then
            LOG("Message (to"..uid..") blocked in safe mode")
        end
        return
    end
    if Bot._send(mes) then
        Bot.stat.messageSent=Bot.stat.messageSent+1
        Bot.stat.totalMessageSent=Bot.stat.totalMessageSent+1
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
function Bot.sendSticker(mes_id)
    -- Bot._send{
    --     action='msg_emoji_like',
    --     params={
    --         message_id=mes_id,
    --     },
    -- }
end
function Bot.sendLike(uid,times)
    Bot._send{
        action='send_like',
        params={
            uid=uid,
            times=times or 10,
        },
    }
end
---@param group_id number
---@param user_id number
---@param time? number
function Bot.ban(group_id,user_id,time)
    local mes={
        action='set_group_ban',
        params={
            group_id=group_id,
            user_id=user_id,
            duration=time or 60,
        },
    }
    Bot._send(mes)
end
function Bot.adminNotice(text)
    for id in next,Config.superAdminID do
        Bot.sendMsg(text,'p'..id)
    end
end
function Bot.reset()
    for id in next,SessionMap do
        SessionMap[id]=nil
    end
end
function Bot.stop(time)
    TASK.forceLock('bot_blockRestart',time or 600)
    ws:close()
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
            if Config.debugLog_message then
                print("message",TABLE.dump(res))
            end
        elseif res.post_type=='notice' then
            ---@cast res OneBot.Event.Notice
            local id=res.group_id
            if id then
                local S=SessionMap['g'..id]
                if not S then
                    if TASK.getLock('newSession_'..id) then return true end
                    S=Session.new(id,false)
                    SessionMap[S.uid]=S
                end
                S:receive(res,'notice')
            end
            if Config.debugLog_notice then
                print("notice",TABLE.dump(res))
            end
        elseif res.post_type=='request' then
            -- TODO
            if Config.debugLog_request then
                print("request",TABLE.dump(res))
            end
        elseif rawget(res,'retcode') then
            ---@cast res OneBot.Event.Response
            if res.echo then
                local uid=STRING.before(res.echo,':')
                local S=SessionMap[uid]
                if S then
                    S.echos[STRING.after(res.echo,':')]=res.data
                end
            end
            if Config.debugLog_response then
                print(TABLE.dump(res))
            end
        end
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
---@field checkpoints Map<number>
---@field echos Map<table>
---@field data Map<Session.data>
---
---@field createTime number
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
        admin=not priv and Config.groupManaging[id],
        taskList={},
        locks=setmetatable({},lockMapMeta),
        checkpoints={},
        echos={},
        data={},

        createTime=Time(),
        charge=Config.maxCharge,
        maxCharge=Config.maxCharge,
        lastUpdateTime=Time(),
    }
    setmetatable(s,{__index=Session})

    local template=priv and Config.privTask or Config.groupTask
    for _,task in next,template do
        s:newTask(task[1],task[2])
    end
    for _,exTask in next,Config.extraTask[s.uid] or {} do
        s:newTask(unpack(exTask))
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
function Session:freshLock()
    for k,v in next,self.locks do
        if Time()>v then self.locks[k]=nil end
    end
end
function Session:clearLock()
    for k in next,self.locks do
        self.locks[k]=nil
    end
end

function Session:setTimeCheckpoint(name)
    self.checkpoints[name]=Time()
end
function Session:getTimeCheckpoint(name)
    return Time()-(self.checkpoints[name] or self.createTime)
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
---@param type 'message' | 'notice'
function Session:receive(M,type)
    for _,task in next,self.taskList do
        local suc2,res2=pcall(task[type],self,M,self.data[task.id])
        if suc2 then
            if res2==true then break end
        else
            LOG('warn',STRING.repD("Session-$1 Task-$2 ($3) Error:\n$4",self.id,task.id,os.date("%m/%d %H:%M:%S"),res2))
            break
        end
    end
end

---@param text Sendable
---@param echo? string
function Session:send(text,echo)
    if not self:isAlive() then return end
    if echo then echo=self.uid..':'..echo end
    Bot.sendMsg(text,self.uid,echo)
end
---@param id number|string string means search id from Session.echos
function Session:delete(id)
    if not self:isAlive() then return end
    if type(id)=='number' then
        Bot.deleteMsg(id)
    else
        if self.echos[id] then
            Bot.deleteMsg(self.echos[id].message_id)
            self.echos[id]=nil
        end
    end
end
---@param M OneBot.Event.Message
function Session:sticker(M)
    Bot.sendSticker(M.message_id)
end

---Notice that time must be less than 86400 (1 day)
---@param time number|nil seconds
---@param text string
---@param echo? string
function Session:delaySend(time,text,echo)
    if time and time>86400 then return end
    if time==nil then time=.26+math.random() elseif time<=0 then return self:send(text,echo) end
    if echo then echo=self.uid..':'..echo end
    self:_timeTask(self.send,time,{self,text,echo})
end
---Notice that time must be less than 86400 (1 day)
---@param time number seconds
---@param id number|string string means search id from Session.echos
function Session:delayDelete(time,id)
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
        LOG('info',STRING.repD("Connecting... ($1)",Bot.stat.connectAttempts))
    elseif ws.state=='connecting' then
        ws:update()
    elseif ws.state=='running' then
        if Bot.state~='running' then
            Bot.state='running'
            Config.connectInterval=Config.reconnectInterval
            LOG('info',"Connected")
            if TABLE.find(arg,"startWithNotice") then
                Bot.adminNotice(Bot.stat.connectAttempts==1 and "小z启动了喵！" or STRING.repD("小z回来了喵…（第$1次）",Bot.stat.connectAttempts))
            end
        end
        if TASK.lock('bot_timing',1) then
            while true do
                local m=Bot.delayedAction[1]
                if not m or Time()<m.time then break end
                m.func(unpack(m.data))
                rem(Bot.delayedAction,1)
            end
        end
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
            TASK.freshLock()
            for _,S in next,SessionMap do
                S:freshLock()
            end
        end
    end
end)

print("--------------------------")
for _,t in next,Config.privTask do require('task.'..t[1]) end
for _,t in next,Config.groupTask do require('task.'..t[1]) end
