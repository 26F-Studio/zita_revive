local ins=table.insert
---@type Map<Zict.Entry>
local zict
local entryList

local function reloadZict()
    zict=FILE.load('task/zictionary_data.lua','-lua')
    entryList=zict.entryList
    zict.entryList=nil
end
reloadZict()

assert(zict,"Dict data not found")

---@type Task_raw
return {
    init=function(_,D)
        D.lastDetailEntry=false
    end,
    message=function(S,M,D)
        ---@cast M OneBot.Event.PrivateMessage|OneBot.Event.GroupMessage

        local mes=STRING.trim(RawStr(M.raw_message))

        -- Detail of last entry
        if mes=='##' then
            if S:getLock('detailedEntry') then
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
            if S:lock('dailyEntry',626) then
                math.randomseed(tonumber(os.date('%Y%m%d')) or 26)
                for _=1,26 do math.random() end
                mes='#'..TABLE.getRandom(entryList).word
                if mes:find(';') then mes=mes:match('(.-);') end
                math.randomseed(os.time())
                daily=true
            end
        elseif mes=="#reload" then
            if Bot.isAdmin(M.user_id) then
                reloadZict()
                S:send("小z的知识库更新了！现在有"..#entryList.."个词条喵")
            else
                if S:forceLock('no_permission',26) then
                    S:delaySend(nil,"你不许reload")
                end
            end
            return true
        end

        -- Get searching phrase
        local queryPhrase=mes:match('#.+')
        if not queryPhrase then return false end

        -- Remove '#'
        local showDetail
        if queryPhrase:sub(1,2)=='##' then
            queryPhrase=queryPhrase:sub(3)
            showDetail=true
        else
            queryPhrase=queryPhrase:sub(2)
        end

        -- Get entry from dict data
        ---@type Zict.Entry
        local entry
        local words=STRING.split(queryPhrase:lower(),'%s+',true)
        for i=#words,1,-1 do
            if #words[i]>26 then table.remove(words,i) end
        end
        while words[1] do
            entry=zict[table.concat(words,'')]
            if entry then break end
            table.remove(words)
        end
        if not entry then return false end

        -- Response
        local result={} ---@type string[]
        if daily then ins(result,"【今日词条】") end
        if entry.title then
            ins(result,(entry.detail and "##" or "#")..entry.title)
        end
        if daily and entry.title then
            result[1]=result[1]..table.remove(result)
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

        if S.group and not AdminMsg(M) and not Config.extraData.family[S.uid] then
            S:update()
            local chargeNeed=94.2+#resultStr/4.2
            if S.charge<math.min(94.2,chargeNeed) then
                if S:forceLock('dictCharge',26) then S:send("词典能量耗尽！请稍后再试喵") end
                return true
            end
            S:useCharge(chargeNeed)
            if S.charge<=196 then
                resultStr=resultStr..STRING.repD("\n能量低($1/$2)，请勿刷屏",math.floor(S.charge),S.maxCharge)
            end
        end

        S:send(resultStr)
        return true
    end,
}
