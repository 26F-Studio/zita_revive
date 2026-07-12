-- 【需要预加载】
--[[ 需要在配置文件的extraData内增加如下格式的配置项：
    groupJoinWelcome={
        [000000000]="欢迎加入俄罗斯方块XX群~~\n本群话题以讨论XX为主，群规见置顶公告",
    },
]]

if Config.extraData.groupJoinWelcome then
    LOG('info',"Groups with welcome message: "..TABLE.getSize(Config.extraData.groupJoinWelcome))
else
    LOG('warn',"group_join_welcome: No welcome message configured")
end

---@type Task_raw
return {
    notice=function(S,N)
        if N.notice_type=='group_increase' then
            local mes=(Config.extraData.groupJoinWelcome or NULL)[S.id]
            if mes and S:lock('welcome',62) then S:delaySend(mes,2.6) end
            return true
        end
        return false
    end,
}
