---@type Task_raw
return {
    message=function(S,M,D)
        if D.log then
            print((S.priv and "Priv-" or "Group-")..S.id..": "..TABLE.dump(M))
        end
        return false
    end,
}
