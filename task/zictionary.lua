local ins=table.insert
---@type Map<ZictEntry>
local zict=FILE.load('task/zictionary_data.lua','-lua')
assert(zict,"Dict data not found")

local tags="热门 官方 非官 电脑 手机 主机 网页 单人 多人 键盘 触屏 鼠标 快速 慢速 无延 延迟 题库 新人 创新"
local tagRedirect={
    -- 缩
    ["热"]="热门",
    ["官"]="官方",
    ["野"]="非官",
    ["pc"]="电脑",
    ["pe"]="手机",
    ["web"]="网页",
    ["键"]="键盘",
    ["触"]="触屏",
    ["鼠"]="鼠标",
    ["单"]="单人",
    ["多"]="多人",
    ["联"]="多人",
    ["快"]="快速",
    ["慢"]="慢速",
    ["延"]="延迟",
    ["题"]="题库",
    ["新"]="新人",

    -- 其他用词
    ["非官方"]="非官",
    ["电脑版"]="电脑",
    ["手机版"]="手机",
    ["浏览器"]="网页",
    ["网页版"]="网页",
    ["单机"]="单人",
    ["对战"]="多人",
    ["联机"]="多人",
    ["联网"]="多人",
    ["无延迟"]="无延",
    ["无延迟块"]="无延",
    ["延迟块"]="延迟",
}
local gameNames={}
for _,entry in next,zict do
    if entry.cat=='game' and entry.shortname then
        if entry.tags then
            local t=STRING.split(entry.tags,' ')
            for _,tag in next,t do
                if not tags:find(tag) then
                    print("unlisted tag: "..tag.." in "..entry.title)
                end
            end
        end
        gameNames[entry]=true
        if not zict[SimpStr(entry.shortname)] then
            print("cannot find "..entry.shortname.."; "..entry.title)
        end
    end
end
gameNames=TABLE.getKeys(gameNames)
for i=1,#gameNames do
    gameNames[i].detail="[tags: "..gameNames[i].tags.."]"..(gameNames[i].detail or "")
    gameNames[i]=SimpStr(gameNames[i].shortname)
end
table.sort(gameNames)

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

        local words=STRING.split(mes,'%s+',true)

        -- Game Searching
        if words[1]=="#游戏" or words[1]=="#game" then
            table.remove(words,1)
            if #words==0 then
                if S:lock('game_search_help',26) then
                    S:send("发送“#游戏 标签1 标签2…”来寻找你能接受的方块游戏，可用的tag：\n"..tags)
                end
            else
                if not S:lock('game_search',6.26) then return true end
                if not S:costCharge(126) then
                    if S:forceLock('searchCharge',26) then S:send("词典能量耗尽！请稍后再试喵") end
                    return true
                end

                -- Remove too long words
                for i=#words,1,-1 do
                    if #words[i]>=10 then
                        table.remove(words,i)
                    elseif tagRedirect[words[i]] then
                        words[i]=tagRedirect[words[i]]
                    end
                end

                -- Remove too many words
                while #words>10 do
                    table.remove(words)
                end

                -- Remove invalid tags
                local filtered=false
                for i=#words,1,-1 do
                    if not tags:find(words[i]) then
                        table.remove(words,i)
                        filtered=true
                    end
                end

                if #words==0 then
                    S:send("没有有效标签喵，发送“#游戏”查看帮助")
                    return true
                end

                local results={}
                for _,gameName in next,gameNames do
                    local game=zict[SimpStr(gameName)]
                    local available=true
                    for _,word in next,words do
                        if not game.tags:find(word,nil,true) then
                            available=false
                            break
                        end
                    end
                    if available then
                        table.insert(results,gameName)
                    end
                end

                if #results==0 then
                    S:send("没有符合条件的游戏喵…")
                else
                    local count=#results
                    if count>10 then
                        results=TABLE.sub(results,1,10)
                    end
                    local resultStr=STRING.repD("找到了$1个游戏，使用#[名称]查看详细信息：\n$2",count,table.concat(results,", "))
                    if count>10 then resultStr="(只显示前十个)"..resultStr end
                    if filtered then resultStr="(忽略无效标签)"..resultStr end
                    S:send(resultStr)
                end
            end
            return true
        end

        -- Detail of last entry
        if mes=='##' then
            if S:getLock('detailedEntry') then
                S:send("##"..D.lastDetailEntry.title.." (续)\n"..D.lastDetailEntry.detail)
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
        local result={}
        if daily then ins(result,"【今日词条】") end
        if entry.title then
            ins(result,(entry.detail and "##" or "#")..entry.title)
        end
        if entry.text then
            ins(result,entry.text)
        end
        if entry.detail then
            S:lock('detailedEntry',420)
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

        if S.group and not (M.sender and (M.sender.role=='owner' or M.sender.role=='admin')) then
            S:update()
            local chargeNeed=62+#resultStr/4.2
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
