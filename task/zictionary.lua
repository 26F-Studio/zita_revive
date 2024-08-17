local Dict=FILE.load('task/zictionary_data.lua','-lua')
assert(Dict,"Dict data not found")
---@type Task_raw
return {
    func=function(S,M)
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

        if S.group and not (M.sender and (M.sender.role=='owner' or M.sender.role=='admin')) then
            S:update()
            local chargeNeed=26+#result/6.2
            if S.charge<math.min(62,chargeNeed) then
                if TASK.forceLock('dictCharge_'..S.id,26) then S:send("词典能量耗尽！请稍后再试") end
                return true
            end
            S:useCharge(chargeNeed)
            if S.charge<=120 then
                result=result..STRING.repD("\n能量低($1/$2)，请勿刷屏",math.floor(S.charge),S.maxCharge)
            end
        end

        S:send(result)
        return true
    end,
}
