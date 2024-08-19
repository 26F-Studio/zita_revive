---@type Task_raw
return {
    func=function(S,M)
        -- Log
        if Config.debugLog_receive then
            print((S.priv and "Priv-" or "Group-")..S.id..": "..M.raw_message)
            print(TABLE.dump(M))
            -- TODO
        end
        return false
    end,
}
