local deningText={
    Config.adminName.."才能这样做喵",
    "你没有足够的权限喵",
    "Permission Denied喵",
}

---@type Task_raw
return {
    func=function(S,M)
        ---@cast M LLOneBot.Event.PrivateMessage
        local mes=STRING.trim(RawStr(M.raw_message))
        if mes=='%stop' then
            if AdminMsg(M) then
                print("[LOCK] "..S.uid)
                S:send("本群紧急停机半小时喵！")
                TASK.lock('newSession_'..S.id,1800)
                SessionMap[S.uid]=nil
            else
                if S:lock('no_permission',12) then
                    S:send(TABLE.getRandom(deningText))
                end
            end
            return true
        end
        return false
    end,
}
