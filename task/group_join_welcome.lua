--[[ 需要在配置文件的extraData内增加如下格式的配置项：
    groupJoinWelcome={
        [000000000]="欢迎加入俄罗斯方块XX群~~\n本群话题以讨论XX为主，群规见置顶公告",
    },
]]
---@type Task_raw
return {
    notice=function(S,N)
        if N.notice_type=='group_increase' then
            local mes=(Config.extraData.groupJoinWelcome or NULL)[S.id]
            if mes and S:lock('welcome',62) then S:delaySend(2.6,mes) end
            return true
        end
        return false
    end,
}
