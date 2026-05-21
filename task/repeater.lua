local badWords=STRING.split(Config.extraData.badWords or "cq: 傻 马","%s+",true)
local goodWords=STRING.split(Config.extraData.goodWords or "大神 机心","%s+",true)
LOG('info',"Repeater: "..#badWords.."/"..#goodWords.." bad/good words loaded")

local signs=TABLE.getValueSet(STRING.atomize([[`~!@#$%^&*()_+-=[]\{}|;':",./<>?]]))
---@type Task_raw
return {
    init=function(_,D)
        D.messageCharge=0

        D.lastmes=""
        D.repMesCount=0
        D.repeaters={}
    end,
    message=function(S,M,D)
        -- 冷却
        if S:getLock('repeater_cooldown') then return false end
        local mes=M.raw_message
        -- 长消息
        if #mes>62 then return false end
        -- 符号开头
        if signs[mes:sub(1,1)] then return false end
        -- 复读中
        if mes==D.lastmes and D.repMesCount<0 then return false end
        -- 坏消息
        local lmes=mes:lower()
        for _,word in next,badWords do if lmes:find(word) then return false end end

        -- 充能
        D.messageCharge=D.messageCharge+1

        -- 复读检测
        if mes==D.lastmes then
            -- 复读中

            -- 完全忽略重复复读
            if TABLE.find(D.repeaters,M.user_id) then return true end

            table.insert(D.repeaters,M.user_id)
            D.repMesCount=D.repMesCount+1
        else
            -- 非复读
            D.lastmes=mes
            D.repMesCount=0
            if D.repeaters[2] then TABLE.clear(D.repeaters) end
            D.repeaters[1]=M.user_id
        end

        -- 计算概率
        local repChance=.005*(1-#mes/62)+math.min(D.messageCharge*.0001,.026)+D.repMesCount*.062

        -- 好消息
        for _,word in next,goodWords do
            if mes:find(word) then
                repChance=repChance+.026
                break
            end
        end

        -- print("messageCharge: "..D.messageCharge)
        -- print("lastmes: "..D.lastmes)
        -- print("repMesCount: "..D.repMesCount)
        -- print(string.format("%.2f%%",repChance*100))

        if MATH.roll(repChance) then
            D.messageCharge=0
            D.repMesCount=-1 -- Mark current round as repeated
            S:lock('repeater_cooldown',26)
            S:delaySend(MATH.rand(2.6,6.2),mes)
        end
        return true
    end,
}
