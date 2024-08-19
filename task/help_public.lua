local wordList=TABLE.getValueSet({"小z在吗","#help","#帮助"})
---@type Task_raw
return {
    func=function(S,M)
        ---@cast M LLOneBot.Event.PrivateMessage|LLOneBot.Event.GroupMessage
        local mes=M.raw_message:lower()
        if not wordList[mes] then return false end
        if S:forceLock('help_public',62) then
            S:send("【Zita-Revive】 小z回来啦！\n萌新有疑问时发送#[关键词]就可以查询小Z词典精简版\n词条标题前双井号表示有补充信息，紧接着发送“##”查看完整内容\n技术还处于试验阶段，随时可能停机，对不起喵！")
        else
            S:send(M.raw_message:lower()=="小z在吗" and "不在喵" or "刚刚发过了，不要刷屏谢谢喵")
        end
        return true
    end,
}
