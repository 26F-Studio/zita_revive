Time=love.timer.getTime
love._openConsole()
--------------------------------------------------------------
local ins,rem=table.insert,table.remove
require'Zenitha'
ZENITHA.setMaxFPS(30)
ZENITHA.setDrawFreq(10)
ZENITHA.setUpdateFreq(100)
ZENITHA.setVersionText('')
function SimpStr(s) return s:gsub('%s',''):lower() end -- Remove spaces and lower case
local esc={['&amp;']='&',['&#91;']='[',['&#93;']=']',['&#44;']=','}
function RawStr(s) -- Unescape & Remove username in CQ:at
    s=s:gsub('%[CQ:at,qq=(%d+),name=.-%]','[CQ:at,qq=%1]')
    for k,v in next,esc do s=s:gsub(k,v) end
    return s
end
function CQpic(path) return "[CQ:image,file=file:///"..path:gsub("/","\\").."]" end -- Encode cq path
function AdminMsg(M) return M.sender and (M.sender.role=='owner' or M.sender.role=='admin') end -- Encode cq path
--------------------------------------------------------------
local ws=WS.new{
    host='localhost',
    port='3001',
    connTimeout=2.6,
    sleepInterval=0.1,
}
Config={
    adminName="管理员",
    receiveDelay=0.26,
    maxCharge=620,
    debugLog_send=false,
    debugLog_receive=false,
    debugLog_response=false,
    safeMode=false,
    superAdminID={},
    groupManaging={},
    safeSessionID={},
    extraData=nil,
}
xpcall(function()
    local data=FILE.load('conf.luaon','-luaon')
    ---@cast data Data
    Config.adminName=data.adminName
    Config.superAdminID=TABLE.getValueSet(data.superAdminID)
    Config.groupManaging=TABLE.getValueSet(data.groupManaging)
    Config.safeSessionID=TABLE.getValueSet(data.safeSessionID)
    Config.extraData=data.extraData
    print("conf.luaon successfully loaded")
end,function(mes)
    print("Error in loading conf.luaon: "..mes)
    print("Some settings may not be loaded correctly")
end)
print("--------------------------")
print("Admin name: "..Config.adminName)
print("# Super admin ID:")
for id in next,Config.superAdminID do print(id) end
print("# Group managing:")
for id in next,Config.groupManaging do print(id) end
print("# Safe session ID:")
for id in next,Config.safeSessionID do print(id) end
--------------------------------------------------------------
Bot={
    taskPriv={
        {'log',-100},
        {'admin_control',-99},
        {'help_public',1},
        {'zictionary',2},
        {'phtool',3},
        {'ab_guess',4},
    },
    taskGroup={
        {'log',-100},
        {'admin_control',-99},
        {'help_public',1},
        {'response',2},
        {'ab_guess',3},
        {'zictionary',4},
        {'repeater',100},
    },
    msgDelQueue={},
    stat={
        connectAttempts=0,
        launchTime=Time(),
        totalMessageSent=0,

        connectLogDelay=0,
        connectLogDelaySum=0,

        connectTime=Time(),
        messageSent=0,
    },
}

---@class Task_raw
---@field func fun(S:Session, M: LLOneBot.Event.Message, D:Session.data):boolean
---@field init fun(S:Session, D:Session.data)?

---@class Task : Task_raw
---@field id string
---@field prio number

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
        print("Error encoding json:\n"..debug.traceback(res))
    end
end
---@param message string
---@param group? number
---@param user? number
---@param echo? string
function Bot.sendMsg(message,group,user,echo)
    local mes={
        action='send_msg',
        params={
            user_id=user,
            group_id=group,
            message=message,
        },
        echo=echo,
    }
    if Config.safeMode and not Config.safeSessionID[group and 'g'..group or 'p'..user] then
        if TASK.lock('safeModeBlock',10) then
            print("Message blocked in safe mode")
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
        Bot.sendMsg(text,nil,id)
    end
end
function Bot.restart()
    for id in next,SessionMap do
        SessionMap[id]=nil
    end
end
function Bot.stop(time)
    TASK.forceLock('bot_lock',time or 600)
    ws:close()
end

---@return true? #if any message processed
function Bot._update()
    local pack,op=ws:receive()
    if not pack then return end
    if op=='text' then
        local suc,res=pcall(JSON.decode,pack)
        ---@cast res LLOneBot.Event.Base
        if not suc then
            print("Error decoding json: "..res)
            print(pack)
            return true
        end
        if res.post_type=='meta_event' then
            ---@cast res LLOneBot.Event.Meta
            if res.meta_event_type=='lifecycle' then
                print("Lifecycle event: "..res.sub_type)
            end
        elseif rawget(res,'retcode') then
            ---@cast res LLOneBot.Event.Response
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
        elseif res.post_type=='message' then
            ---@cast res LLOneBot.Event.Message
            local priv=res.message_type=='private'
            local id=priv and res.user_id or res.group_id
            local S=SessionMap[(priv and 'p' or 'g')..id]
            if not S then
                if TASK.getLock('newSession_'..id) then return true end
                S=Session.new(id,priv)
                SessionMap[S.uid]=S
            end
            S:receive(res)
        elseif res.post_type=='notice' then
            -- TODO
        elseif res.post_type=='request' then
            -- TODO
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
---@field id number
---@field uid string just 'p' or 'g' + id, for being used as unique key in SessionMap
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
    __index=function(self,k) rawset(self,k,-1e99) return -1e99 end,
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

    local template=priv and Bot.taskPriv or Bot.taskGroup
    for _,task in next,template do
        s:newTask(task[1],task[2])
    end
    local extra=Config.extraData.extraTask[s.uid]
    if extra then
        for i=1,#extra do
            s:newTask(extra[i][1],extra[i][2])
        end
    end
    return s
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
            print("Task created failed: Task '"..task.."' already exists")
            return
        elseif prio==t.prio then
            print("Task created failed: Prio '"..prio.."' already used by task '"..t.id.."'")
            return
        elseif not insPos and prio<t.prio then
            insPos=i
        end
    end
    if not insPos then insPos=#self.taskList+1 end
    ins(self.taskList,insPos,{
        prio=prio,
        id=id,
        func=task.func,
    })
    self.data[id]={}
    if task.init then task.init(self,self.data[id]) end
end
---@param id string
function Session:removeTask_id(id)
    for i=1,#self.taskList do
        if self.taskList[i].id==id then
            print("Task removed: "..id)
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
    print("All user tasks cleared")
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

function Session:receive(M)
    for _,task in next,self.taskList do
        local suc2,res2=pcall(task.func,self,M,self.data[task.id])
        if suc2 then
            if res2==true then break end
        else
            print(STRING.repD("Session-$1 Task-$2 Error:\n$3",self.id,task.id,res2))
            break
        end
    end
end

---@param text string
---@param echo? string
function Session:send(text,echo)
    if echo then echo=self.uid..':'..echo end
    if self.priv then
        Bot.sendMsg(text,nil,self.id,echo)
    else
        Bot.sendMsg(text,self.id,nil,echo)
    end
end
---@param id number
---@param echo? string
function Session:delete(id,echo)
    if echo then echo=self.uid..':'..echo end
    Bot.deleteMsg(id)
end

---@param time number|nil
---@param text string
---@param echo? string
function Session:delaySend(time,text,echo)
    if time==nil then time=.26+math.random() elseif time<=0 then return self:delete(id,echo) end
    if echo then echo=self.uid..':'..echo end
    if self.priv then
        self:_timeTask('send',time,{text,nil,self.id,echo})
    else
        self:_timeTask('send',time,{text,self.id,nil,echo})
    end
end
---@param time number
---@param id number
---@param echo? string
function Session:delayDelete(time,id,echo)
    if time==nil then time=.26+math.random() elseif time<=0 then return self:delete(id,echo) end
    if echo then echo=self.uid..':'..echo end
    self:_timeTask('delete',time,{id,echo})
end
---@param action 'send'|'delete'
---@param time number
---@param data any[]
function Session:_timeTask(action,time,data)
    time=Time()+time
    local queue=Bot.msgDelQueue
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
    ins(queue,insPos,{
        time=time,
        func=
            action=='send' and Bot.sendMsg or
            action=='delete' and Bot.deleteMsg or
            print("Invalid action: "..tostring(action)) or NULL,
        data=data,
    })
    print("#Queue:"..#queue)
end

---@type table<string, Session>
SessionMap={}
--------------------------------------------------------------
ZENITHA.globalEvent.drawCursor=NULL
ZENITHA.globalEvent.clickFX=NULL
local scene={}

function scene.load() end
function scene.update()
    if ws.state=='dead' then
        if TASK.getLock('bot_lock') then return end
        TASK.unlock('bot_running')
        Bot.stat.connectAttempts=Bot.stat.connectAttempts+1
        Bot.stat.connectLogDelay=10
        Bot.stat.connectLogDelaySum=0
        TASK.forceLock('connect_message',Bot.stat.connectLogDelay)
        ws:connect()
        print("--------------------------")
        print("Connecting to LLOneBot...")
    elseif ws.state=='connecting' then
        ws:update()
        if TASK.lock('connect_message',Bot.stat.connectLogDelay) then
            Bot.stat.connectLogDelaySum=Bot.stat.connectLogDelaySum+Bot.stat.connectLogDelay
            print(STRING.repD("Connecting... ($1s taken)",Bot.stat.connectLogDelaySum))
            Bot.stat.connectLogDelay=math.min(Bot.stat.connectLogDelay*2,3600)
        end
    elseif ws.state=='running' then
        if not TASK.getLock('bot_running') then
            TASK.lock('bot_running')
            print("CONNECTED")
            -- if TABLE.find(arg,"startWithNotice") then
            --     Bot.adminNotice(Bot.stat.connectAttempts==1 and "小z启动了喵！" or STRING.repD("小z回来了喵…（第$1次）",Bot.stat.connectAttempts))
            -- end
        end
        if TASK.lock('bot_timing',1) then
            while true do
                local m=Bot.msgDelQueue[1]
                if not m or Time()<m.time then break end
                m.func(unpack(m.data))
                rem(Bot.msgDelQueue,1)
            end
        end
        repeat until not Bot._update()
    end
end
function scene.keyDown(k)
    if k=='s' then
        print("--------------------------")
        print("Statistics:")
        print("Alive time: "..STRING.time(Time()-Bot.stat.connectTime))
        print("Messages sent: "..Bot.stat.messageSent)
    end
end
function scene.draw() end
function scene.unload() end

SCN.add('main', scene)
ZENITHA.setFirstScene('main')

TASK.new(function()
    while true do
        TASK.yieldT(10*60)
        if TASK.getLock('bot_running') then
            TASK.freshLock()
            for _,S in next,SessionMap do
                S:freshLock()
            end
        end
    end
end)

print("--------------------------")
for i=1,#Bot.taskPriv do require('task.'..Bot.taskPriv[i][1]) end
for i=1,#Bot.taskGroup do require('task.'..Bot.taskGroup[i][1]) end
