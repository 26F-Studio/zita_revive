local utf8=require('utf8')
local badWords=STRING.split("cq: zita z酱 mrz 我 傻 逼 菜 弱 典 孝 急 色"," ")
local signs=TABLE.getValueSet(STRING.split([[` ~ ! @ # $ % ^ & * ( ) _ + - = [ ] \ { } | ; ' : " , . / < > ?]]," "))
---@type Task_raw
return {
    func=function(S,M)
        if S.priv or S:getLock('repeater_silence') then return false end

        local mes=M.raw_message
        for _,word in next,badWords do if mes:lower():find(word) then return false end end
        if signs[mes:sub(1,1)] then return false end

        local len=utf8.len(mes)
        if len>=26 or not S:lock('repeater_fastFilter',6.2) then return false end
        local dt=S:getTimeCheckpoint('repeater')
        local startRate=.026+MATH.cLerp(0,1,dt/626)*.012

        if MATH.roll(MATH.interpolate(1,startRate,26,.00626,len)) then
            S:setTimeCheckpoint('repeater')
            S:lock('repeater_silence',26)
            S:send(mes)
        end
        return true
    end,
}
