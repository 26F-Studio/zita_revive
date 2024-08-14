love._openConsole()

require'Zenitha'
ZENITHA.setMaxFPS(60)
ZENITHA.setDrawFreq(26)
ZENITHA.setUpdateFreq(100)

local ws=WS.new{
    host='localhost',
    port='3001',
    connTimeout=2.6,
    sleepInterval=0.26,
}
local botConf={
    receiveDelay=0.26,
}
--[[
    -- /api 样例
    {
        "action": "send_private_msg",
        "params": {
            "user_id": 10001000,
            "message": "你好"
        },
        "echo": "123"
    }
]]
local Bot={
    receiveTimer=botConf.receiveDelay,
}
---@param M LLOneBot.Event.Message
function Bot.receiveMessage(M)
    print(TABLE.dump(M))
    if M.post_type=='message' then
    elseif M.post_type=='notice' then
    elseif M.post_type=='request' then
    else
        print("Unknown post_type: "..M.post_type)
    end
end
function Bot.sendMessage(M)
    -- TODO
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
                        else
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


local scene={}

function scene.load() end
function scene.update() end
function scene.draw() end
function scene.unload() end

SCN.add('main', scene)
ZENITHA.setFirstScene('main')
