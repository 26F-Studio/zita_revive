---@type Task_raw
return {
    message=function(S,M)
        local msg=M.raw_message
        if msg:match("^%[CQ:at,id="..Config.botID) then
            S:send("喵？")
        end
        return false
    end,
}
