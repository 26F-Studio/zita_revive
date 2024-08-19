local badWords=STRING.split("& cq: zita z酱 mrz tech 我 傻 逼 菜 弱 典 孝 急 色"," ")
local goodWords=STRING.split("太强了 厉害 牛逼 大神 好玩"," ")
local signs=TABLE.getValueSet(STRING.split([[` ~ ! @ # $ % ^ & * ( ) _ + - = [ ] \ { } | ; ' : " , . / < > ?]]," "))
---@type Task_raw
return {
    init=function(S)
        S.data.repeater={
            messageCharge=0,

            lastmes="",
            repMesCount=0,
        }
    end,
    func=function(S,M)
        -- Filter not-simple messages
        if S.priv or S:getLock('repeater_cooldown') then return false end
        local mes=M.raw_message
        if #mes>62 then return false end
        if signs[mes:sub(1,1)] then return false end
        for _,word in next,badWords do if mes:lower():find(word) then return false end end

        -- Prepare
        local D=S.data.repeater
        D.messageCharge=D.messageCharge+1
        if mes==D.lastmes then
            D.repMesCount=D.repMesCount+1
        else
            D.lastmes=mes
            D.repMesCount=0
        end

        local repChance=
            0.005*(2-#mes/62)
            +math.min(D.messageCharge*0.001,0.005)
            +D.repMesCount*.1

        if repChance>-.01 then
            for _,word in next,goodWords do
                if mes:find(word) then
                    repChance=repChance+.01
                    break
                end
            end
        end

        -- print("messageCharge: "..D.messageCharge)
        -- print("lastmes: "..D.lastmes)
        -- print("repMesCount: "..D.repMesCount)
        -- print(string.format("%.2f%%",repChance*100))

        if repChance>0 and MATH.roll(repChance) then
            D.messageCharge=0
            S:lock('repeater_cooldown',26)
            S:send(mes)
        end
        return true
    end,
}
