local utf8=require('utf8')
local badWords={"cq:","zita","z酱","mrz"}
---@type Task_raw
return {
    func=function(S,M)
        if S.priv or S:getLock('repeater_silence') then return false end
        for i=1,#badWords do if M.raw_message:lower():find(badWords[i]) then return false end end
        local len=utf8.len(M.raw_message)
        if len>=26 or not S:lock('repeater_fastFilter',4.2) then return false end
        local dt=S:getTimeCheckpoint('repeater')
        local startRate=.0626+MATH.cLerp(0,1,dt/626)*.042
        if MATH.roll(MATH.interpolate(1,startRate,26,.0126,len)) then
            S:setTimeCheckpoint('repeater')
            S:lock('repeater_silence',26)
            S:send(M.raw_message)
        end
        return true
    end,
}
