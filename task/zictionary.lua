local ins=table.insert
---@type Map<ZictEntry>
local zict=FILE.load('task/zictionary_data.lua','-lua')
assert(zict,"Dict data not found")

---@type Task_raw
return {
    init=function(_,D)
        D.lastDetailEntry=false
        D.entries=zict.entries
        zict.entries=nil
    end,
    func=function(S,M,D)
        ---@cast M LLOneBot.Event.PrivateMessage|LLOneBot.Event.GroupMessage

        local mes=STRING.trim(RawStr(M.raw_message))

        -- Detail of last entry
        if mes=='##' then
            if S:getLock('detailedEntry') then
                local res=""
                if D.lastDetailEntry.title then
                    S:send('##'..D.lastDetailEntry.title.." (续)\n"..D.lastDetailEntry.detail)
                else
                    S:send("(续)"..D.lastDetailEntry.detail)
                end
                D.lastDetailEntry=false
                S:unlock('detailedEntry')
            else
                if S:forceLock('doubleSharp',26) then S:send("最近没查过含有补充信息的词条喵~") end
            end
            return true
        end

        -- Daily
        local daily
        if mes=='#' then
            if S:lock('dailyEntry',600) then
                math.randomseed(tonumber(os.date('%Y%m%d')) or 26)
                for _=1,42 do math.random() end
                mes='#'..D.entries[math.random(#D.entries)].word
                if mes:find(';') then mes=mes:match('(.-);') end
                math.randomseed(os.time())
                daily=true
            end
        end

        -- Get searching phrase
        local phrase=mes:match('#.+')
        if not phrase then return false end
        local startPos=mes:find(phrase,1,true)
        phrase=phrase:lower()

        -- Remove '#'
        local showDetail
        if phrase:sub(1,2)=='##' then
            phrase=phrase:sub(3)
            showDetail=true
        else
            phrase=phrase:sub(2)
        end

        -- Get entry from dict data
        ---@type ZictEntry
        local entry
        if startPos==1 then
            entry=zict[SimpStr(phrase)]
        else
            local words=STRING.split(phrase,'%s+',true)
            while #words[#words]>26 do
                table.remove(words)
                if not words[1] then return false end
            end
            while #words>0 do
                entry=zict[table.concat(words,'')]
                if entry then break end
                table.remove(words)
            end
        end
        if not entry then return false end

        -- Response
        local result={} ---@type string[]
        if daily then ins(result,"【今日词条】") end
        if entry.title then
            ins(result,(entry.detail and "##" or "#")..entry.title)
        end
        if entry.text then
            ins(result,type(entry.text)=='function' and entry.text(S) or entry.text)
        end
        if entry.detail then
            S:forceLock('detailedEntry',420)
            if showDetail then
                ins(result,entry.detail)
            else
                D.lastDetailEntry=entry
            end
        end
        if entry.link then
            ins(result,"相关链接: "..entry.link)
        end
        local resultStr=table.concat(result,'\n')

        if S.group and not AdminMsg(M) then
            S:update()
            local chargeNeed=62+#resultStr/2.6
            if S.charge<math.min(94.2,chargeNeed) then
                if S:forceLock('dictCharge',26) then S:send("词典能量耗尽！请稍后再试喵") end
                return true
            end
            S:useCharge(chargeNeed)
            if S.charge<=120 then
                resultStr=resultStr..STRING.repD("\n能量低($1/$2)，请勿刷屏",math.floor(S.charge),S.maxCharge)
            end
        end

        S:send(resultStr)
        return true
    end,
}
