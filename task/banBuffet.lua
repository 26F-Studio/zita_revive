local response={
    goodNight={
        "晚安喵",
        "好梦喵",
        "祝好梦喵",
        "多休息喵",
        "好好休息喵",
        "多睡觉身体好喵",
    },
    normal={
        "这是坏的",
        "这很坏喵",
        "这好吗",
        "这不好喵",
        "文明用语喵",
        "讲文明树新风喵",
        "Z酱可爱喵",
    },
}

local find,count=string.find,STRING.count
---@type Task_raw
return {
    func=function(S,M)
        if Bot.isAdmin(M.user_id) or not Config.groupManaging[S.id] then return false end
        local mes=STRING.trim(RawStr(M.raw_message)):lower()
        if #mes>260 then return false end

        mes=mes:gsub("m.?.?.?r.?.?.?z","Z")
        mes=mes:gsub("z.?.?.?酱","Z")
        mes=mes:gsub("zj","Z")

        mes=mes:gsub("f.?.?.?k","F")
        mes=mes:gsub("日","F")

        mes=mes:gsub("ddd","DDM")
        mes=mes:gsub("丁","D")
        mes=mes:gsub("叮","D")
        mes=mes:gsub("钉","D")
        mes=mes:gsub("盯","D")
        mes=mes:gsub("ding","D")
        mes=mes:gsub("动","M")
        mes=mes:gsub("咚","M")
        mes=mes:gsub("冻","D")
        mes=mes:gsub("洞","M")
        mes=mes:gsub("dong","M")

        local pattern1=find(mes,"F.?.?.?.?.?.?Z")
        local pattern2=find(mes,"Z.?.?.?D.?.?.?M") or find(mes,"D.?.?.?D.?.?.?M")
        if not (pattern1 or pattern2) then return false end

        local banTime=6

        if pattern1 then banTime=banTime+count(mes,"Z")*12 end
        if pattern2 then banTime=banTime+count(mes,"Z")*6+count(mes,"D")*4 end

        if find(mes,"hso") then banTime=banTime+26 end

        if pattern1 then banTime=banTime*(1+count(mes,"F")*0.26) end
        if pattern2 then banTime=banTime*(1+count(mes,"M")*0.26) end

        if find(mes,"晚安") or find(mes,"睡") then banTime=banTime*26 end

        if banTime>=62.6 then
            if MATH.roll(0.626) then
                if     math.abs(banTime-86)<=10  then banTime=86
                elseif math.abs(banTime-126)<=16 then banTime=126
                elseif math.abs(banTime-235)<=26 then banTime=235
                elseif math.abs(banTime-386)<=26 then banTime=386
                end
            end
            if banTime>420 then banTime=420+(banTime-420)^0.872 end
            if find(mes,"晚安") or find(mes,"睡") or banTime>360 then
                S:send(TABLE.getRandom(response.goodNight))
            elseif MATH.roll(banTime/872) then
                if pattern1 and MATH.roll(0.026) then
                    S:send(CQpic(Config.extraData.imgPath.."flan.png"))
                else
                    S:send(TABLE.getRandom(response.normal))
                end
            end

            if S.group and S.id==742357905 then banTime=banTime/24 end
            banTime=math.floor(banTime)+(MATH.roll(banTime%1) and 1 or 0)
            Bot.ban(S.id,M.user_id,banTime*60)
        end

        return true
    end,
}
