-- 【需要预加载】
--[[ 需要在配置文件的extraData内增加如下格式的配置项：
    groupJoinReview={
        [000000000]={
            accept={
                "10..?.?.?20",
                "10..?.?.?20",
                "十..?.?.?二十",
                "二十..?.?.?十",
            },
            refuse={
                "求通过",
                "想聊天",
                "交友",
            },
            refuse_reply="（自动拒绝）请直接回答问题，谢谢",
        },
    },
]]

if Config.extraData.groupJoinReview then
    LOG('info',"Groups with join review: "..TABLE.getSize(Config.extraData.groupJoinReview))
else
    LOG('warn',"group_join_review: No join review configured")
end

---@type Task_raw
return {
    request=function(S,R)
        local dat=(Config.extraData.groupJoinReview or NULL)[S.id]
        if dat and Bot.isManaging(S.id) and R.sub_type=='add' then
            local mes=STRING.after(R.comment,"\n")
            if not mes then return false end
            for _,pattern in next,dat.accept do
                if string.find(mes,pattern) then
                    Bot.resolveJoinRequest(R,true)
                    LOG('info',"[通过申请] 群"..S.id..", 用户"..R.user_id)
                    return false
                end
            end
            for _,pattern in next,dat.refuse do
                if string.find(mes,pattern) then
                    Bot.resolveJoinRequest(R,false,dat.refuse_reply or "你的加群申请被自动拒绝了喵")
                    LOG('info',"[拒绝申请] 群"..S.id..", 用户"..R.user_id)
                    return false
                end
            end
        end
        return false
    end,
}
