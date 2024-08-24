local wordList=TABLE.getValueSet{"小z在吗","#help","#帮助"}
---@type Task_raw
return {
    func=function(S,M)
        ---@cast M LLOneBot.Event.PrivateMessage|LLOneBot.Event.GroupMessage
        local mes=SimpStr(M.raw_message)
        if not wordList[mes] then return false end
        if S:forceLock('help_public',62) then
            S:send(STRING.trimIndent[[
                【Zita-Revive】 小z回来啦！
                萌新有疑问时发送#[关键词]就可以查询小Z词典精简版
                标题前双井号表示有详细信息，补发一条“##”查看
                #游戏 查询目前大家玩的都是什么方块游戏
                试验阶段，随时可能停机，对不起喵！
                （%stop 群管理紧急停机）
            ]])
        else
            S:send(M.raw_message:lower()=="小z在吗" and "不在喵" or "刚刚发过了，不要刷屏谢谢喵")
        end
        return true
    end,
}
