local Dict=FILE.load('task/zictionary_data.lua','-lua')
assert(Dict,"Dict data not found")
---@type Task_raw
return {
    filter='message',
    func=function(M)
        ---@cast M LLOneBot.Event.PrivateMessage|LLOneBot.Event.GroupMessage
        local mes=M.raw_message
        if mes:sub(1,1)~='#' then return false end
        local word,detail
        if mes:sub(2,2)=='#' then
            word=SimpStr(mes:sub(3))
            detail=true
        else
            word=SimpStr(mes:sub(2))
        end

        local entry=Dict[word]
        if not entry then return false end

        local group_id,user_id=M.group_id,M.user_id
        if M.message_type=='group' and M.sub_type=='normal' then user_id=nil end
        local free=group_id and M.sender and (M.sender.role=='owner' or M.sender.role=='admin')
        free=false

        local result=entry.title
        if entry.detail then
            result="*"..result
        end
        if entry.text then
            result=result..":\n"..entry.text
        end
        if detail and entry.detail then
            result=result.."\n"..entry.detail
        end
        if entry.link then
            result=result.."\n相关链接: "..entry.link
        end

        local chargeNeed=26+#result/6.2

        if (group_id and not user_id) and not free then
            local g=GroupMap[group_id]
            g:update()
            if g.charge<math.min(62,chargeNeed) then
                local lockID='dictPower_'..group_id
                if TASK.lock(lockID,26) then
                    Bot.sendMes{
                        group=group_id,
                        user=user_id,
                        message="词典能量耗尽！请稍后再试",
                    }
                else
                    TASK.unlock(lockID)
                    TASK.lock(lockID,26)
                end
                return true
            end
            g:use(chargeNeed)
            if g.charge<=120 then
                result=result..STRING.repD("\n能量低($1/$2)，请勿刷屏",math.floor(g.charge),g.maxCharge)
            end
        end

        Bot.sendMes{
            group=group_id,
            user=user_id,
            message=result,
        }
        return true
    end,
}
