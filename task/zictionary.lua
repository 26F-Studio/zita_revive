local Dict=FILE.load('task/zictionary_data.lua','-lua')
assert(Dict,"Dict data not found")
---@type Task_raw
return {
    init=function(_,D)
        D.lastDetailEntry=false
        D.entries=Dict.entries
        Dict.entries=nil
    end,
    func=function(S,M,D)
        ---@cast M LLOneBot.Event.PrivateMessage|LLOneBot.Event.GroupMessage

        local mes=M.raw_message
        local daily
        mes=STRING.trim(mes)
        if mes=='#' then
            if S:lock('dailyEntry',600) then
                math.randomseed(tonumber(os.date('%Y%m%d')) or 26)
                for _=1,42 do math.random() end
                mes='#'..D.entries[math.random(#D.entries)].word
                if mes:find(';') then mes=mes:match('(.-);') end
                math.randomseed(os.time())
                daily=true
            end
        elseif mes=='##' then
            if S:getLock('detailedEntry') then
                S:send("##"..D.lastDetailEntry.title.." (续)\n"..D.lastDetailEntry.detail)
                D.lastDetailEntry=false
                S:unlock('detailedEntry')
            else
                if S:forceLock('doubleSharp',26) then S:send("最近没查过含有补充信息的词条喵~") end
            end
            return true
        end
        local phrase=mes:match('#.+')
        if not phrase then return false end
        phrase=phrase:lower()

        local showDetail
        if phrase:sub(1,2)=='##' then
            phrase=phrase:sub(3)
            showDetail=true
        else
            phrase=phrase:sub(2)
        end

        local entry
        if mes:find(phrase,1,true)==1 then
            entry=Dict[phrase]
        else
            local words=STRING.split(phrase,'%s+',true)
            while #words[#words]>26 do
                table.remove(words)
                if not words[1] then return false end
            end
            while #words>0 do
                entry=Dict[table.concat(words,'')]
                if entry then break end
                table.remove(words)
            end
        end
        if not entry then return false end

        local result=(daily and "【今日词条】\n" or "")..(entry.detail and "##" or "#")..entry.title
        if entry.text then
            result=result.."\n"..entry.text
        end
        if entry.detail then
            S:lock('detailedEntry',420)
            if showDetail then
                result=result.."\n"..entry.detail
            else
                D.lastDetailEntry=entry
            end
        end
        if entry.link then
            result=result.."\n相关链接: "..entry.link
        end

        if S.group and not (M.sender and (M.sender.role=='owner' or M.sender.role=='admin')) then
            S:update()
            local chargeNeed=62+#result/4.2
            if S.charge<math.min(94.2,chargeNeed) then
                if S:forceLock('dictCharge',26) then S:send("词典能量耗尽！请稍后再试") end
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
