-- 【需要预加载】

local ins,rem,concat=table.insert,table.remove,table.concat

local function reloadZict()
    ---@type Map<Zict.Entry>
    Config.extraData._zict=FILE.load('task/zictionary_data.lua','-lua')
end
reloadZict()

assert(Config.extraData._zict,"Dict data not found")

---@type Task_raw
return {
    init=function(_,D)
        D.lastDetailEntry=false
        D.ADlist={}
        D.ad_mes_cooldown=6
    end,
    message=function(S,M,D)
        ---@cast M OneBot.Event.PrivateMessage|OneBot.Event.GroupMessage

        local mes=STRING.trim(RawStr(M.raw_message))
        local noobQuestion
        if not mes:find('#') then
            local _mes=mes:gsub("%?$",""):gsub("？$","")
            noobQuestion=_mes:match("^(.+)是什么$") or _mes:match("^(.+)是啥$") or _mes:match("^什么是(.+)$")
            if noobQuestion and #noobQuestion<=26 then mes="#"..noobQuestion end
        end

        if not mes:find('#') or mes:find('/#') then return false end

        local zict=Config.extraData._zict

        -- Detail of last entry
        if mes=='##' then
            if S:getLock('zict_detailedEntry') then
                if D.lastDetailEntry.title then
                    S:send("##"..D.lastDetailEntry.title.." (续)\n"..D.lastDetailEntry.detail)
                else
                    S:send("(续)"..D.lastDetailEntry.detail)
                end
                D.lastDetailEntry=false
                S:unlock('zict_detailedEntry')
            else
                if S:forceLock('zict_doubleSharp',26) then S:send("最近没查过含有补充信息的词条喵~") end
            end
            return true
        end

        -- Daily
        local daily
        if mes=='#' then
            if S:lock('zict_daily',626) then
                math.randomseed(tonumber(os.date('%Y%m%d')) or 26)
                for _=1,26 do math.random() end
                for _=1,26 do
                    daily=TABLE.getRandom(zict.entryList)
                    if daily.title then break end
                end
            end
        elseif mes=="#reload" then
            if Bot.isAdmin(M.user_id) then
                local oldSet,newSet={},{}
                for k in next,zict do oldSet[k]=true end
                reloadZict()
                for k in next,zict do newSet[k]=true end

                local deletion,addition={},{}
                for k in next,oldSet do if not newSet[k] then ins(deletion,k) end end
                for k in next,newSet do if not oldSet[k] then ins(addition,k) end end
                local buf=STRING.newBuf()
                if #deletion>0 then buf:put("[-] "..concat(deletion,";").."\n") end
                if #addition>0 then buf:put("[+] "..concat(addition,";").."\n") end
                local wordCnt,entryCnt=TABLE.getSize(zict)-1,#zict.entryList
                buf:put("小z的知识库更新了！现在有"..wordCnt.."个关键词和"..entryCnt.."个词条喵")
                S:send(buf)
            elseif S:forceLock('zict_no_permission',26) then
                S:delaySend(nil,"你不许reload")
            end
            return true
        end

        -- Get entry from dict data
        ---@type Zict.Entry
        local entry=daily
        local showDetail

        if not entry then
            -- Get searching phrase
            local queryPhrase=mes:match('#.+')
            if not queryPhrase then return false end

            -- Remove '#'
            if queryPhrase:sub(1,2)=='##' then
                queryPhrase=queryPhrase:sub(3)
                showDetail=true
            else
                queryPhrase=queryPhrase:sub(2)
            end

            local words=STRING.split(queryPhrase:lower(),'%s+',true)
            if not words[1] then return false end
            while #words>0 and #words[#words]>26 do rem(words) end
            if not words[1] then return false end
            for i=1,#words do if #words[i]>26 then return false end end
            while words[1] do
                entry=zict[concat(words,'')]
                if entry then break end
                rem(words)
            end
            if not entry then
                if not noobQuestion then
                    Bot.reactMessage(M.message_id,Emoji.white_question_mark)
                end
                return false
            end
        end

        -- Response
        local result={} ---@type string[]
        if daily then ins(result,"【今日词条】") end
        if entry.title then
            ins(result,(entry.detail and "##" or "#")..entry.title)
        end
        if daily and entry.title then
            result[1]=result[1]..rem(result)
        end
        if entry.text then
            ins(result,type(entry.text)=='function' and entry.text(S) or entry.text)
        end
        if entry.detail then
            S:forceLock('zict_detailedEntry',420)
            if showDetail then
                ins(result,entry.detail)
            else
                D.lastDetailEntry=entry
            end
        end
        if entry.link then
            local link=entry.link
            if link:find("store.steampowered.com/app/",1,true) then link=link.."?utm_source=zita" end
            ins(result,"相关链接: "..link)
        end
        -- Advertise
        D.ad_mes_cooldown=D.ad_mes_cooldown-1
        if (Config.extraData.main or NONE)[S.uid] and D.ad_mes_cooldown<=0 and not S:forceLock('zict_ad_chokeLaunch',620) and S:lock('zict_ad_time_cooldown',2600) then
            if not D.ADlist[1] then TABLE.append(D.ADlist,Config.extraData.ad) end
            ins(result,"【广告】"..TABLE.popRandom(D.ADlist))
            D.ad_mes_cooldown=6
        end
        local resultStr=concat(result,'\n')

        if S.group and not AdminMsg(M) and not Config.extraData.family[S.uid] then
            S:update()
            local chargeNeed=94.2+#resultStr/4.2
            if S.charge<math.min(94.2,chargeNeed) then
                if S:forceLock('zict_dictCharge',26) then S:send("词典能量耗尽！请稍后再试喵") end
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
