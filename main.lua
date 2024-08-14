love._openConsole()
--------------------------------------------------------------
require'Zenitha'
ZENITHA.setMaxFPS(30)
ZENITHA.setDrawFreq(0.1)
ZENITHA.setUpdateFreq(100)
--------------------------------------------------------------
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
            if M.sender.role~='member' then
                SearchDict(M.raw_message,M.group_id)
            end
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
local dictData=require'dict_zh'
local function simpComp(a,b)
    a=a:gsub('%s',''):lower()
    b=b:gsub('%s',''):lower()
    return a==b
end
function SearchDict(word,group_id,user_id)
    if word:sub(1,1)~='#' then return end
    local searchWord=word:sub(2)
    local result
    for i=1,#dictData do
        if simpComp(dictData[i][1],searchWord) then
            result=dictData[i][1]..": \n"..dictData[i][2]
            if dictData[i][3] then
                result=result.."\n相关链接: "..dictData[i][3]
            end
            break
        end
    end
    if group_id then
        Bot.sendMessage{
            group_id=group_id,
            message="[仅群管理可用] "..result,
        }
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
local scene={}

function scene.load() end
function scene.update() end
function scene.draw() end
function scene.unload() end

SCN.add('main', scene)
ZENITHA.setFirstScene('main')
