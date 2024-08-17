---@type Task_raw
return {
    func=function(S,M)
        ---@cast M LLOneBot.Event.PrivateMessage|LLOneBot.Event.GroupMessage
        if not (M.raw_message:lower()=="小z在吗" or M.raw_message=="#help") then return false end
        local lockID='help_'..M.group_id
        if TASK.lock(lockID,62) then
            S:send("【Zita-Revive】 小z回来啦！\n萌新有疑问时发送#[关键词]就可以查询小Z词典精简版\n技术还处于试验阶段，随时可能停机，对不起喵！")
        else
            S:send(M.raw_message:lower()=="小z在吗" and "不在喵" or "刚刚发过了，不要刷屏谢谢喵")
            TASK.unlock(lockID)
            TASK.lock(lockID,62)
        end
        return true
    end,
}
