local Time=love.timer.getTime
love._openConsole()
--------------------------------------------------------------
require'Zenitha'
ZENITHA.setMaxFPS(30)
ZENITHA.setDrawFreq(10)
ZENITHA.setUpdateFreq(100)
--------------------------------------------------------------
local initCharge=620
local maxCharge=620
local ws=WS.new{
    host='localhost',
    port='3001',
    connTimeout=2.6,
    sleepInterval=0.26,
}
local botConf={
    receiveDelay=0.26,
}
local Bot={
    receiveTimer=botConf.receiveDelay,
}
---@param M LLOneBot.Event.Base
function Bot.receiveMessage(M)
    if M.post_type=='message' then
        ---@cast M LLOneBot.Event.PrivateMessage
        if M.message_type=='private' then
            -- if M.sub_type=='friend' then
            --     SearchDict(M.raw_message,nil,M.user_id)
            -- elseif M.sub_type=='group' then
            --     SearchDict(M.raw_message,M.group_id,M.user_id)
            -- end
        else
            ---@cast M LLOneBot.Event.GroupMessage
            SearchDict(M.raw_message,M.group_id,nil,M.sender.role~='member')
        end
    elseif M.post_type=='notice' then
        ---@cast M LLOneBot.Event.Notice
    elseif M.post_type=='request' then
        ---@cast M LLOneBot.Event.FriendRequest
        if M.request_type=='friend' then
        else
            ---@cast M LLOneBot.Event.GroupRequest
        end
    else
        print("Unknown post_type: "..M.post_type)
    end
end
---@param data LLOneBot.SimpMes
function Bot.sendMessage(data)
    local mes={params={message=data.message}}
    if data.group_id then
        mes.action='send_group_msg'
        mes.params.group_id=data.group_id
    else
        mes.action='send_private_msg'
        mes.params.user_id=data.user_id
    end
    ws:send(JSON.encode(mes))
end
function Bot.mainLoop() -- Coroutine!
    print("Connected to LLOneBot")
    while true do
        if ws.state=='dead' then return end
        Bot.receiveTimer=Bot.receiveTimer-coroutine.yield()
        if Bot.receiveTimer<=0 then
            Bot.receiveTimer=botConf.receiveDelay
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
                            -- print(TABLE.dump(M))
                            Bot.receiveMessage(res)
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
---@class Group
---@field charge number
---@field maxCharge number
---@field lastUpdateTime number
---@field lastHintTimeMap table<string,number>
local Group={}

---@return Group
function Group.new()
    local g={
        charge=initCharge,
        maxCharge=maxCharge,
        lastUpdateTime=0,
        lastHintTimeMap={},
    }
    setmetatable(g,{__index=Group})
    return g
end
function Group.updateAll(map,dt)
    for id,g in next,map do
        g:update(dt)
    end
end

function Group:update()
    self.charge=math.min(self.charge+(Time()-self.lastUpdateTime),self.maxCharge)
    self.lastUpdateTime=Time()
end
function Group:canShowHint(opt,minDT)
    self:update()
    if Time()-(self.lastHintTimeMap[opt] or -1e99)>minDT then
        self.lastHintTimeMap[opt]=Time()
        return true
    end
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
    end
})

--------------------------------------------------------------
local dictData=require'dict_zh'
local function simpStr(s)
    return s:gsub('%s',''):lower()
end
for i=1,#dictData do
    dictData[simpStr(dictData[i][1])]=dictData[i]
end
function SearchDict(word,group_id,user_id,free)
    if not group_id then return end
    if word:sub(1,1)~='#' then return end

    local entry=dictData[simpStr(word:sub(2))]
    if not entry then return end

    if not free and not groupMap[group_id]:cost(62) then
        if groupMap[group_id]:canShowHint('dictPower',26) then
            Bot.sendMessage{
                group_id=group_id,
                message="达到查询频率限制，每十分钟只能查十次",
            }
        end
        return
    end

    local result=entry[1]..": \n"..entry[2]
    if entry[3] then
        result=result.."\n相关链接: "..entry[3]
    end
    Bot.sendMessage{
        group_id=group_id,
        message=result,
    }
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
    if k=='space' then
        print('--------------------------\nGroups Info:')
        for id,g in next,groupMap do
            print('Group '..id..' :')
            for key,val in next,g do print(key,val) end
        end
    end
end
function scene.draw() end
function scene.unload() end

SCN.add('main', scene)
ZENITHA.setFirstScene('main')
