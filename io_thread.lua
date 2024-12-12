local userInput=love.thread.getChannel('userInput')
while true do
    local input=io.read()
    userInput:push(input)
end
