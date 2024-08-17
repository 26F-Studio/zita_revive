local utf8=require('utf8')
---@type Task_raw
return {
    func=function(S,M)
        if S.priv or M.raw_message:find("CQ") or S:getLock('repeater') then return false end
        local len=utf8.len(M.raw_message)
        if len>=26 or math.random()>MATH.interpolate(1,0.0626,26,0.0126,len) then return false end
        S:lock('repeater',26)
        S:send(M.raw_message)
        return true
    end,
}
