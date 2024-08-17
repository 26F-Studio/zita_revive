local Time=love.timer.getTime
love._openConsole()
--------------------------------------------------------------
require'Zenitha'
ZENITHA.setMaxFPS(30)
ZENITHA.setDrawFreq(10)
ZENITHA.setUpdateFreq(100)
ZENITHA.setVersionText('')
function SimpStr(s) return s:gsub('%s',''):lower() end
--------------------------------------------------------------
local ws=WS.new{
    host='localhost',
    port='3001',
    connTimeout=2.6,
    sleepInterval=0.1,
}
Config={
    receiveDelay=0.26,
    maxCharge=620,
    debugLog_message=false,
    debugLog_response=false,
    safeMode=false,
    superAdmin={},
}
print('--------------------------')
if love.filesystem.getInfo('adminList.txt') then
    print('Super Admins:')
    for line in love.filesystem.lines('adminList.txt') do
        local id=tonumber(line)
        if id then
            Config.superAdmin[id]=true
            print(id)
        end
    end
else
    print("File 'adminList.txt' not found, no super admin")
end
--------------------------------------------------------------
---@class Group
---@field charge number
---@field maxCharge number
---@field lastUpdateTime number
---@field lastHintTimeMap table<string,number>
Group={}

---@return Group
function Group.new()
    local g={
        charge=Config.maxCharge,
        maxCharge=Config.maxCharge,
        lastUpdateTime=0,
        lastHintTimeMap={},
    }
    setmetatable(g,{__index=Group})
    return g
end
function Group:update()
    self.charge=math.min(self.charge+(Time()-self.lastUpdateTime),self.maxCharge)
    self.lastUpdateTime=Time()
end
function Group:cost(pow)
    self:update()
    if self.charge>=pow then
        self.charge=self.charge-pow
        return true
    else
        return false
    end
end
function Group:use(pow)
    self:update()
    self.charge=math.max(self.charge-pow,0)
end

---@type table<number, Group>
GroupMap=setmetatable({},{
    __index=function(t,id)
        t[id]=Group.new()
        return t[id]
    end,
})
--------------------------------------------------------------
Bot={}

Bot.stat={
    connectAttempts=0,
    launchTime=Time(),
    totalSendCount=0,

    connectLogDelay=0,
    connectLogDelaySum=0,

    connectTime=Time(),
    sendCount=0,
}

---@enum (key) Task.filter
local Filter={
    any=function() return true end,
    message=function(M)
        return M.post_type=='message'
    end,
    friendMes=function(M)
        return M.post_type=='message' and M.message_type=='private' and M.sub_type=='friend'
    end,
    privateMes=function(M)
        return M.post_type=='message' and M.message_type=='private' and M.sub_type=='group'
    end,
    groupMes=function(M)
        return M.post_type=='message' and M.message_type=='group' and M.sub_type=='normal'
    end,
    notice=function(M)
        return M.post_type=='notice'
    end,
    request=function(M)
        return M.post_type=='request'
    end,
}

---@class Task_raw
---@field filter Task.filter
---@field func fun(M: LLOneBot.Event.Base):boolean

---@class Task : Task_raw
---@field id string
---@field prio number

---@type Task[]
Bot.tasks={}

---@param task Task_raw
---@param prio number
function Bot.newTask(task,prio)
    local insPos=1
    for i=1,#Bot.tasks do
        local t=Bot.tasks[i]
        if t.id==task then
            print("Task created failed: Task '"..task.."' already exists")
            return
        elseif t.prio==prio then
            print("Task created failed: Prio '"..prio.."' already used by task '"..t.id.."'")
            return
        elseif t.prio>prio then
            insPos=i
            break
        end
    end
    table.insert(Bot.tasks,insPos,{
        prio=prio,
        id=task,
        filter=task.filter,
        func=task.func,
    })
end
---@param id string
function Bot.removeTask_id(id)
    for i=1,#Bot.tasks do
        if Bot.tasks[i].id==id then
            print("Task removed: "..id)
            table.remove(Bot.tasks,i)
            return
        end
    end
end
function Bot.removeAllTask()
    for id,task in next,Bot.tasks do
        if task.prio>0 then
            Bot.tasks[id]=nil
        end
    end
    print("All user tasks cleared")
end

function Bot.isAdmin(id)
    return Config.superAdmin[id]
end

---@param data LLOneBot.SimpMes
function Bot.sendMes(data)
    local mes={params={message=data.message}}
    if data.group and data.user then
        mes.action='send_msg'
        mes.params.group_id=data.group
        mes.params.user_id=data.user
    elseif data.group then
        if Config.safeMode and not TASK.lock('safemode_group_'..data.group,60) then
            print("Interrupted because of safeMode: Group "..data.group)
            return
        else
            mes.action='send_group_msg'
            mes.params.group_id=data.group
        end
    else
        if Config.safeMode and not TASK.lock('safemode_private_'..data.user,26) then
            print("Interrupted because of safeMode: User "..data.user)
            return
        else
            mes.action='send_private_msg'
            mes.params.user_id=data.user
        end
    end
    local suc,res=pcall(JSON.encode,mes)
    if suc then
        ws:send(res)
    else
        print("Error encoding json:\n"..debug.traceback(res))
    end
    Bot.stat.sendCount=Bot.stat.sendCount+1
    Bot.stat.totalSendCount=Bot.stat.totalSendCount+1
end
function Bot.adminNotice(text)
    for id in next,Config.superAdmin do
        Bot.sendMes{user=id,message=text}
    end
end

function Bot.help()
    local cmds=TABLE.getKeys(Bot)
    table.sort(cmds)
end

---@return true? #if any message processed
function Bot._update()
    local pack,op=ws:receive()
    if not pack then return end
    if op=='text' then
        local suc,res=pcall(JSON.decode,pack)
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
        elseif res.retcode then
            ---@cast res LLOneBot.Event.Response
            if Config.debugLog_response then
                print(TABLE.dump(res))
            end
        else
            for i=1,#Bot.tasks do
                local task=Bot.tasks[i]
                if (Filter[task.filter] or NULL)(res) then
                    local suc2,res2=pcall(task.func,res)
                    if suc2 then
                        if res2==true then break end
                    else
                        print(STRING.repD("$1 Task Error:\n$2",task.id,res2))
                        break
                    end
                end
            end
        end
    elseif op~='pong' then
        print("[inside: "..op.."]")
        if type(pack)=='string' and #pack>0 then print(pack) end
    end
    return true
end
--------------------------------------------------------------
ZENITHA.globalEvent.drawCursor=NULL
ZENITHA.globalEvent.clickFX=NULL
local scene={}

function scene.load() end
function scene.update()
    if ws.state=='dead' then
        TASK.unlock('bot_running')
        Bot.stat.connectAttempts=Bot.stat.connectAttempts+1
        Bot.stat.connectLogDelay=10
        Bot.stat.connectLogDelaySum=0
        TASK.forceLock('connect_message',10)
        ws:connect()
        print('--------------------------')
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
            if TABLE.find(arg,"startWithNotice") then
                Bot.adminNotice(Bot.stat.connectAttempts==1 and "小z启动了喵！" or STRING.repD("小z回来了喵…（第$1次）",Bot.stat.connectAttempts))
            end
        end
        repeat until not Bot._update()
    end
end
function scene.keyDown(k)
    if k=='g' then
        print('--------------------------\nGroups Info:')
        for id,g in next,GroupMap do
            print('Group '..id..' :')
            for key,val in next,g do print(key,val) end
        end
    elseif k=='s' then
        print('--------------------------\nStatistics:')
        print("Alive time: "..STRING.time(Time()-Bot.stat.connectTime))
        print("Messages sent: "..Bot.stat.sendCount)
    end
end
function scene.draw() end
function scene.unload() end

SCN.add('main', scene)
ZENITHA.setFirstScene('main')
--------------------------------------------------------------
Bot.newTask(require('task.admin_control'),-100)
Bot.newTask(require('task.help_public'),1)
Bot.newTask(require('task.zictionary'),2)
