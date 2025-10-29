---@type Task_raw
return {
    message=function(S,M)
        if not M.raw_message:find("^%[CQ:json") then return false end
        local data=M.raw_message:match([[b23.tv\/(%w+)?share]])
        if not data then return false end
        S:send("b23.tv/"..data)
        return true
    end,
}
