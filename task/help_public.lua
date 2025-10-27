---@type Task_raw
return {
    message=function(S,M)
        ---@cast M OneBot.Event.PrivateMessage|OneBot.Event.GroupMessage
        if SimpStr(M.raw_message)~="#help" then return false end

        if not S:forceLock('help_public',62) then
            Bot.sendEmojiReact(M.message_id,MATH.coin(Emoji.up_button,Emoji.upwards_button))
            return true
        end

        S:send(STRING.trimIndent[[
            【Zita-Revive】 小z回来了喵！
            萌新有疑问时发送#[关键词]就可以查询小Z词典精简版
            标题前双井号表示有详细信息，补发一条“##”查看
            #推荐/分类/表格 看看目前大家玩的都是什么方块游戏
            （试验阶段，随时可能停机）（群管急停：%s）
        ]])
        return true
    end,
}
