---@type Task_raw
return {
    func=function(S,M,D)
        -- Log
        if Config.debugLog_receive or D.log then
            print((S.priv and "Priv-" or "Group-")..S.id..": "..TABLE.dump(M))
            -- TODO
        end
        return false
    end,
}
