local Time=love.timer.getTime
love._openConsole()
local superENV={
    math=math,
    string=string,
    table=table,
    MATH=MATH,
    STRING=STRING,
    TABLE=TABLE,
}
--------------------------------------------------------------
require'Zenitha'
ZENITHA.setMaxFPS(30)
ZENITHA.setDrawFreq(10)
ZENITHA.setUpdateFreq(100)
--------------------------------------------------------------
local ws=WS.new{
    host='localhost',
    port='3001',
    connTimeout=2.6,
    sleepInterval=0.1,
}
local config={
    receiveDelay=0.26,
    maxCharge=620,
    debugLog=false,
    superAdmin={},
}
print('--------------------------')
if love.filesystem.getInfo('adminList.txt') then
    print('Super Admins:')
    for line in love.filesystem.lines('adminList.txt') do
        local id=tonumber(line)
        if id then
            config.superAdmin[id]=true
            print(id)
        end
    end
else
    print("File 'adminList.txt' not found, no super admin")
end
--------------------------------------------------------------
local function simpStr(s) return s:gsub('%s',''):lower() end
--------------------------------------------------------------
---@class Group
---@field charge number
---@field maxCharge number
---@field lastUpdateTime number
---@field lastHintTimeMap table<string,number>
local Group={}

---@return Group
function Group.new()
    local g={
        charge=config.maxCharge,
        maxCharge=config.maxCharge,
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
local groupMap=setmetatable({},{
    __index=function(t,id)
        t[id]=Group.new()
        return t[id]
    end,
})
--------------------------------------------------------------
local Bot={}

Bot.stat={
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

---@class Task
---@field name string
---@field prio number
---@field filter Task.filter
---@field func fun(M: LLOneBot.Event.Base):boolean

---@type Task[]
Bot.plan={
    {
        name="Log",
        prio=-1e99,
        filter='any',
        func=function(M)
            if not config.debugLog then return false end
            print(TABLE.dump(M))
            -- TODO
            return false
        end,
    },
    {
        name="Arbitrary Code Execution",
        prio=-1,
        filter='friendMes',
        func=function(M)
            ---@cast M LLOneBot.Event.PrivateMessage
            if M.raw_message:sub(1,1)~='!' or not config.superAdmin[M.user_id] then return false end

            local func,err=loadstring(M.raw_message:sub(2))
            local returnMes
            if func then
                setfenv(func,superENV)
                local suc,res=pcall(func)
                if suc then
                    returnMes="Done"..(res~=nil and "\n"..tostring(res) or "")
                else
                    returnMes="Runtime Error:\n"..tostring(res)
                end
            elseif err then
                returnMes="Compile Error:\n"..tostring(err)
            end
            Bot.sendMes{user=M.user_id,message=returnMes}
            return true
        end,
    },
    {
        name="Help",
        prio=0,
        filter='groupMes',
        func=function(M)
            ---@cast M LLOneBot.Event.PrivateMessage|LLOneBot.Event.GroupMessage
            if not (M.raw_message:lower()=='小z在吗' or M.raw_message=='#help') then return false end
            local lockID='help_'..M.group_id
            if TASK.lock(lockID,62) then
                Bot.sendMes{
                    group=M.group_id,
                    message="小Z词典-Revive 堂堂复活！\n遇到萌新有疑问时发送#[关键词]就可以查询小Z词典精简版的内容\n还在试验阶段，随时可能停机，对不起喵！",
                }
            elseif M.raw_message:lower()=='小z在吗' then
                Bot.sendMes{
                    group=M.group_id,
                    message="不在",
                }
                TASK.unlock(lockID)
                TASK.lock(lockID,62)
            end
            return true
        end,
    },
    {
        name="Zictionary",
        prio=1,
        filter='message',
        func=function(M)
            ---@cast M LLOneBot.Event.PrivateMessage|LLOneBot.Event.GroupMessage
            local mes=M.raw_message
            if mes:sub(1,1)~='#' then return false end
            local word,detail
            if mes:sub(2,2)=='#' then
                word=simpStr(mes:sub(3))
                detail=true
            else
                word=simpStr(mes:sub(2))
            end

            local entry=Bot.dict[word]
            if not entry then return false end

            local group_id,user_id=M.group_id,M.user_id
            if M.message_type=='group' and M.sub_type=='normal' then user_id=nil end
            local free=group_id and M.sender and (M.sender.role=='owner' or M.sender.role=='admin')
            free=false

            local result=entry.title
            if entry.detail then
                result="*"..result
            end
            if entry.text then
                result=result..":\n"..entry.text
            end
            if detail and entry.detail then
                result=result.."\n"..entry.detail
            end
            if entry.link then
                result=result.."\n相关链接: "..entry.link
            end

            local chargeNeed=26+#result/6.2

            if (group_id and not user_id) and not free then
                local g=groupMap[group_id]
                g:update()
                if g.charge<math.min(62,chargeNeed) then
                    local lockID='dictPower_'..group_id
                    if TASK.lock(lockID,26) then
                        Bot.sendMes{
                            group=group_id,
                            user=user_id,
                            message="词典能量耗尽！请稍后再试",
                        }
                    else
                        TASK.unlock(lockID)
                        TASK.lock(lockID,26)
                    end
                    return true
                end
                g:use(chargeNeed)
                if g.charge<=120 then
                    result=result..STRING.repD("\n能量低($1/$2)，请勿刷屏",math.floor(g.charge),g.maxCharge)
                end
            end

            Bot.sendMes{
                group=group_id,
                user=user_id,
                message=result,
            }
            return true
        end,
    },
}
---@param data LLOneBot.SimpMes
function Bot.sendMes(data)
    local mes={params={message=data.message}}
    if data.group and data.user then
        mes.action='send_msg'
        mes.params.group_id=data.group
        mes.params.user_id=data.user
    elseif data.group then
        mes.action='send_group_msg'
        mes.params.group_id=data.group
    else
        mes.action='send_private_msg'
        mes.params.user_id=data.user
    end
    ws:send(JSON.encode(mes))
    Bot.stat.sendCount=Bot.stat.sendCount+1
end
local receiveTimer=config.receiveDelay
--- THIS IS Coroutine
function Bot.mainLoop()
    print("Connected to LLOneBot")
    while true do
        if ws.state=='dead' then return end
        receiveTimer=receiveTimer-coroutine.yield()
        if receiveTimer<=0 then
            receiveTimer=config.receiveDelay
            local pack,op=ws:receive()
            if pack then
                if op=='text' then
                    local suc,res=pcall(JSON.decode,pack)
                    if suc then
                        if res.post_type=='meta_event' then
                            ---@cast res LLOneBot.Event.Meta
                            if res.meta_event_type=='lifecycle' then
                                print("Lifecycle event: "..res.sub_type)
                            end
                        elseif res.retcode then
                            ---@cast res LLOneBot.Event.Response
                            -- print(TABLE.dump(res))
                        else
                            for i=1,#Bot.plan do
                                local task=Bot.plan[i]
                                if (Filter[task.filter] or NULL)(res) then
                                    local suc2,res2=pcall(task.func,res)
                                    if suc2 then
                                        if res2==true then break end
                                    else
                                        print(STRING.repD("$1 Task Error:\n$2",task.name,res2))
                                        break
                                    end
                                end
                            end
                        end
                    else
                        print("Error decoding json: "..res)
                    end
                elseif op~='pong' then
                    print("[inside: "..op.."]")
                    if type(pack)=='string' and #pack>0 then print(pack) end
                end
            end
        end
        coroutine.yield()
    end
end
--------------------------------------------------------------
print('--------------------------')
ws:connect()
repeat
    love.timer.sleep(1)
    ws:update()
    print("WS state: "..ws.state)
until ws.state~='connecting'

print('--------------------------')
if ws.state=='dead' then
    print("Connection failed")
else
    TASK.new(Bot.mainLoop)
end
--------------------------------------------------------------
ZENITHA.globalEvent.drawCursor=NULL
ZENITHA.globalEvent.clickFX=NULL
local scene={}

function scene.load() end
function scene.update() end
function scene.keyDown(k)
    if k=='g' then
        print('--------------------------\nGroups Info:')
        for id,g in next,groupMap do
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
Bot.dict=require'zictionary'
--------------------------------------------------------------
superENV.botConf=config
superENV.groupMap=groupMap
superENV.Bot=Bot
superENV.Group=Group
superENV._s=Bot.sendMes
