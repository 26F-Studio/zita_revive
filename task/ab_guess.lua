local cooldown=2600
local cooldownSkip={
    win=2600,
    lose=1200,
    giveup=1620,
}
for k,v in next,cooldownSkip do cooldownSkip[k]=cooldown-v end
local hdWeights={
    {2,5,3},
    {3,5,2},
    {6,3,1},
    {7,3},
    {1},
}
local score={
    easy={[0]=0,0.5,1,4,5},
    hard={[0]=1,2,3,5,6},
}
local rewardList={
    {98,73,31,10,5, 0, 0}, -- 1
    {2, 26,62,62,50,15,0}, -- 2
    {0, 1, 6, 26,42,80,92}, -- 3
    {0, 0, 1, 2, 3, 5, 8}, -- 1+1
}
local count=STRING.count
local rules={
    { -- 同时有SZ或者JL
        id=1,
        text="<包含两块镜像对称>",
        rule=function(seq) return seq:find('Z') and seq:find('S') or seq:find('J') and seq:find('L') end,
    },
    { -- 不同时有SZ或者JL
        id=2,
        text="<两两都不镜像对称>",
        rule=function(seq) return not (seq:find('Z') and seq:find('S') or seq:find('J') and seq:find('L')) end,
    },
    { -- 包含T或者JL总数为偶数
        id=3,
        text="<整组块纵奇偶能够平衡>",
        rule=function(seq) return seq:find('T') or count(seq,'[JL]')%2==0 end,
    },
    { -- 包含T或者JL总数为偶数
        id=4,
        text="<整组块斜奇偶平衡>",
        rule=function(seq) return count(seq,'T')%2==0 end,
    },
    { -- SZJLT里至少有三个
        id=5,
        text="<至少三块只能消除三行>",
        rule=function(seq) return count(seq,'[SZJLT]')>=3 end,
    },
    {
        id=6,
        text="<总共至少10种朝向状态>",
        rule=function(seq)
            return
                count(seq,'[ZSI]')*2+
                count(seq,'[JLT]')*4+
                count(seq,'O')
                >=10
        end,
    },
    {
        id=7,
        text="<至少三块包含排成直线的三小格>",
        rule=function(seq)
            return count(seq,'[JLTI]')>=3
        end,
    },
    { -- 有I
        id=8,
        text="<存在能消四行的块>",
        rule=function(seq) return seq:find('I') end,
    },
    { -- 无I
        id=9,
        text="<干旱>",
        rule=function(seq) return not seq:find('I') end,
    },
    { -- SZJL中最多有两个
        id=10,
        text="<能够spinPC的块不超过两个>",
        rule=function(seq) return count(seq,'[SZJL]')<=2 end,
    },
    {
        id=11,
        text="<至少三块能普通消PC>",
        rule=function(seq) return count(seq,'[JLTOI]')>=3 end,
    },
    {
        id=12,
        text="<有连续两块颜色在“红橙黄绿青蓝紫”中相邻>",
        rule=function(seq)
            for _,twin in next,{'ZL','LO','OS','SI','IJ','JT'; 'LZ','OL','SO','IS','JI','TJ'} do
                if seq:find(twin) then return true end
            end
        end,
    },
    {
        id=13,
        text="<有连续两块可以无spin消6行>",
        rule=function(seq)
            for _,twin in next,{'JL','LJ','IJ','JI','IL','LI','IS','SI','IZ','ZI'} do
                if seq:find(twin) then return true end
            end
        end,
    },
    {
        id=26,
        text="<有三块可以拼成3*4盒子>",
        rule=function(seq)
            return
            -- JLS, JLZ
                seq:find('J') and seq:find('L') and seq:find('[SZ]') or
                seq:match('(.).*%1') and (
                -- IJJ, ILL, IOO
                    seq:find('I') and (count(seq,'J')>=2 or count(seq,'L')>=2 or count(seq,'O')>=2) or
                    -- JSJ, LZL
                    seq:find('S') and count(seq,'J')>=2 or
                    seq:find('Z') and count(seq,'L')>=2 or
                    -- OJJ, OLL
                    seq:find('O') and count(seq,'[JL]')>=2 or
                    -- JTT, LTT
                    seq:find('[JL]') and count(seq,'T')>=2
                )
        end,
    },
    {
        id=42,
        text="<这四块开局可以在第二行消除>",
        rule=function(seq)
            local i=count(seq,'I')
            if i==0 then
                -- 杀O[JL]{3}
                return not (seq:find('O') and count(seq,'[JL]')==3)
            elseif i==1 then
                local o=count(seq,'O')
                -- 杀IO[OSZ][JL]，和IOOT
                if seq:find('T') and o==2 then
                    return false
                elseif o>0 and seq:find('[JL]') and (seq:find('[SZ]') or o==2) then
                    return false
                end
                return true
            elseif i==2 then
                -- 有JLT没O活
                return seq:find('[JLT]') and not seq:find('O')
            elseif i==3 then
                -- 虽然目前用不上
                return seq:find('SZOT')
            else
                return false
            end
        end,
    },
}
local text={
    help="AB猜方块：有一组四个不同的方块，玩家猜测后会提示几A几B，A同wordle的绿色，B是猜测的块中有几个在答案里但位置不正确\n注：困难模式中允许每种块出现两次，例如答案是LSST时猜LLSS得到2A2B，其中2A是第1/3块对应，2B是第2/4块不正确但存在于答案中",
    start={
        easy="我想好了四个方块，开始猜吧喵！",
        hard="四个方块想好了！不会变的喵！",
    },
    remain={
        easy="剩余机会:",
        hard="[HD]剩余机会:",
    },
    guessed="这组方块猜过了喵",
    notFinished="上一局还没结束喵",
    win={
        easy="猜对了喵！答案是",
        hard="不错喵！答案是",
    },
    lose={
        easy="机会用完了喵…答案是$1",
        hardAlmost="答案是$1，差一点点就猜对了喵~",
        hard="哼哼，没猜出来喵~哎呀，忘了之前想的是$1还是$2了",
    },
    forfeit="认输了喵？答案是",
}
local pieces=STRING.split("Z S J L T O I"," ")
local ins=table.insert
local copy=TABLE.copy
local function randomGuess(ans)
    local g
    repeat
        g={}
        local l=copy(pieces)
        for _=1,4 do ins(g,TABLE.popRandom(l)) end
    until not (ans and TABLE.equal(g,ans))
    return g
end
local hardLib={}
do
    local l,_l={},{}
    for a=1,7 do
        for b=1,7 do
            for c=1,7 do
                for d=1,7 do
                    l[1],l[2],l[3],l[4]=pieces[a],pieces[b],pieces[c],pieces[d]
                    _l[1],_l[2],_l[3],_l[4]=l[1],l[2],l[3],l[4]
                    table.sort(_l)
                    if _l[1]~=_l[3] and _l[2]~=_l[4] then ins(hardLib,copy(l)) end
                end
            end
        end
    end
    print('Hard quest lib length: '..#hardLib)
end
if not TABLE.find(arg,"startWithNotice") then
    for _,r in next,rules do
        local cnt=0
        local cntSimp=0
        for i=1,#hardLib do
            if r.rule(table.concat(hardLib[i])) then
                cnt=cnt+1
                if not table.concat(hardLib[i]):match('(.).*%1') then cntSimp=cntSimp+1 end
            end
        end
        print(r.id,("HD: %.0f%%(%d)"):format(cnt/#hardLib*100,cnt),("EZ: %.0f%%(%d)"):format(cntSimp/840*100,cntSimp))
        if not (MATH.between(cnt/#hardLib,0.26,0.8) and MATH.between(cntSimp/840,0.26,0.8)) then
            print("^Warning: Limitation Too Strong/Weak^")
        end
    end
end
local function comp(ANS,G)
    local aCount,bCount=0,0
    for i=1,4 do
        if ANS[i]==G[i] then
            aCount=aCount+1
            -- ANS[i]=false
            G[i]=false
        end
    end
    if aCount==4 then return '4A0B' end
    for i=1,4 do
        if G[i] then
            local p=TABLE.find(ANS,G[i])
            if p then
                -- ANS[p]=false
                bCount=bCount+1
            end
        end
    end
    return aCount..'A'..bCount..'B'
end
local resultSets={}
local function resultSorter(a,b) return #resultSets[a]>#resultSets[b] end
local function guess(D,g)
    if TABLE.find(D.guessHis,table.concat(g)) then return 'duplicate' end

    D.chances=D.chances-1
    ins(D.guessHis,table.concat(g))

    local res
    if D.mode=='easy' then
        res=comp(copy(D.answer),copy(g))
    elseif D.mode=='hard' then
        resultSets={}
        for _,answer in next,D.answer do
            local r=comp(copy(answer),copy(g))
            if not resultSets[r] then resultSets[r]={} end
            ins(resultSets[r],answer)
        end
        local keys=TABLE.getKeys(resultSets)
        TABLE.delete(keys,'4A0B')
        -- print("--------------------------")
        -- for _,key in next,keys do
        --     local set=resultSets[key]
        --     if #set<=10 then
        --         local s=""
        --         for _,_4 in next,set do s=s..table.concat(_4).." " end
        --         print(key,#set,s)
        --     else
        --         print(key,#set)
        --     end
        -- end
        if #keys==0 then
            -- Only one answer left
            res='4A0B'
        else
            -- Still has multiple possibilities
            table.sort(keys,resultSorter)
            local r=MATH.randFreq(hdWeights[math.min(#D.guessHis,#hdWeights)])
            D.answer=resultSets[keys[r] or keys[#keys]]
            res=keys[r]
        end
    end
    if #D.guessHis>1 then
        D.textHis=D.textHis..(#D.guessHis%2==0 and "    " or "\n")
    end
    D.textHis=D.textHis..table.concat(g).." "..res
    if res=='4A0B' then return 'win' end
end

---@type Task_raw
return {
    init=function(_,D)
        D.playing=false
        D.lastInterectTime=-1e99 -- time of last answer, for reset when timeout

        D.mode=false -- 'easy' or 'hard'
        D.answer={} -- {'1','2','3','4'} for Easy mode, {{'1','2','3','4'},{'5','6','7','8'},...} for Hard mode
        D.guessHis={}
        D.textHis=""
        D.chances=26
    end,
    func=function(S,M,D)
        -- Log
        local mes=SimpStr(M.raw_message)
        if #mes>9 then return false end

        if mes=='#abhelp' or mes=='#about' then
            if S:lock('ab_help',26) then
                S:send(text.help)
            end
            return true
        elseif mes=='#abandon' then
            D.playing=false
            S:send(text.forfeit..(D.mode=='easy' and table.concat(D.answer) or table.concat(D.answer[1])))
            S:unlock('ab_help')
            S:unlock('ab_playing')
            S:unlock('ab_cd')
            S:unlock('ab_duplicate')
            D.lastInterectTime=Time()-cooldownSkip.giveup
        elseif mes=='#ab' or mes=='#abhard' or mes=='#abhd' then
            -- Start
            if D.playing and Time()-D.lastInterectTime<600 then
                if S:lock('ab_playing',62) then
                    S:send(text.notFinished.."\n"..D.textHis.."\n"..text.remain[D.mode]..D.chances)
                end
                return true
            end
            if not Config.safeSessionID[S.uid] and S.group and not AdminMsg(M) and Time()-D.lastInterectTime<cooldown then
                if S:lock('ab_cd',62) then
                    S:send(STRING.repD("开始新游戏还要等$1秒喵",math.ceil(cooldown-(Time()-D.lastInterectTime))))
                end
                return true
            end
            D.playing=true
            D.mode=mes=='#ab' and 'easy' or 'hard'
            D.answer={}
            D.guessHis={}
            D.textHis=""
            if D.mode=='easy' then
                D.answer=randomGuess()
                guess(D,randomGuess(D.mode=='easy' and D.answer))
            else
                D.answer=copy(hardLib,0)
                local r=rules[math.random(#rules)]
                local newAns={}
                for i=1,#D.answer do
                    if r.rule(table.concat(D.answer[i])) then
                        ins(newAns,D.answer[i])
                    end
                end
                assert(#newAns>0,"No answer after rule filter "..r.id)
                D.answer=newAns
                D.textHis=r.text.."\n"
                local g=hardLib[math.random(#hardLib)]
                guess(D,g)
            end
            D.chances=5
            S:send(text.start[D.mode].."\n"..D.textHis.."\n"..text.remain[D.mode]..D.chances,'ab_guess')
            D.lastInterectTime=Time()
            return true
        elseif D.playing then
            if mes:sub(1,3)=='#ab' then mes=mes:sub(4) end
            mes=mes:upper()
            if not mes:match('^[ZSJLTOI][ZSJLTOI][ZSJLTOI][ZSJLTOI]$') then return false end

            local res=guess(D,{mes:sub(1,1),mes:sub(2,2),mes:sub(3,3),mes:sub(4,4)})
            if res=='duplicate' then
                -- Duplicate
                if S:lock('ab_duplicate',12.6) then
                    S:send(text.guessed)
                end
                D.lastInterectTime=Time()
            elseif res=='win' then
                -- Win
                D.playing=false
                S:send(D.textHis.."\n"..text.win[D.mode]..mes)
                S:unlock('ab_help')
                S:unlock('ab_playing')
                S:unlock('ab_cd')
                S:unlock('ab_duplicate')
                D.lastInterectTime=Time()-cooldownSkip.win
                if Config.extraData.family[S.uid] then
                    local point=((score[D.mode][D.chances] or 2.6)+(D.mode=='easy' and 0.26 or 2)*math.random())/10
                    local rewardType=MATH.randFreq{
                        MATH.lLerp(rewardList[1],point),
                        MATH.lLerp(rewardList[2],point),
                        MATH.lLerp(rewardList[3],point),
                        MATH.lLerp(rewardList[4],point),
                    }
                    if rewardType==1 then
                        S:send(CQpic(Config.extraData.touhouPath..TABLE.getRandom(Config.extraData.touhouImages)))
                    elseif rewardType==2 then
                        S:send(
                            CQpic(Config.extraData.touhouPath..TABLE.getRandom(Config.extraData.touhouImages))..
                            CQpic(Config.extraData.touhouPath..TABLE.getRandom(Config.extraData.touhouImages))
                        )
                    elseif rewardType==3 then
                        S:send(
                            CQpic(Config.extraData.touhouPath..TABLE.getRandom(Config.extraData.touhouImages))..
                            CQpic(Config.extraData.touhouPath..TABLE.getRandom(Config.extraData.touhouImages))..
                            CQpic(Config.extraData.touhouPath..TABLE.getRandom(Config.extraData.touhouImages))
                        )
                    elseif rewardType==4 then
                        S:send(
                            CQpic(Config.extraData.touhouPath..TABLE.getRandom(Config.extraData.touhouImages))..
                            CQpic(Config.extraData.imgPath..'z1/'..math.random(26)..'.jpg')
                        )
                    end
                end
            elseif D.chances>0 then
                -- Guess normally
                if #D.guessHis==2 and D.mode=='easy' then
                    local possibleRules={}
                    local ans=table.concat(D.answer)
                    for i=1,#rules do
                        if rules[i].rule(ans) then
                            ins(possibleRules,rules[i])
                        end
                    end
                    if #possibleRules>0 then
                        local r=TABLE.getRandom(possibleRules)
                        D.textHis=D.textHis.."\n"..r.text
                        -- print(table.concat(D.answer))
                        -- for i=1,#possibleRules do
                        --     print(possibleRules[i].text)
                        -- end
                    end
                end
                S:send(D.textHis.."\n"..text.remain[D.mode]..D.chances,'ab_guess')
                D.lastInterectTime=Time()
            else
                -- Lose
                D.playing=false
                local t=D.textHis.."\n"
                if D.mode=='easy' then
                    t=t..STRING.repD(text.lose.easy,table.concat(D.answer))
                elseif #D.answer==1 then
                    t=t..STRING.repD(text.lose.hardAlmost,table.concat(D.answer[1]))
                    if Config.extraData.family[S.uid] then
                        t=t..CQpic(Config.extraData.touhouPath..TABLE.getRandom(Config.extraData.touhouImages))
                    end
                else
                    local ans1,ans2=table.concat(TABLE.popRandom(D.answer)),table.concat(TABLE.popRandom(D.answer))
                    t=t..STRING.repD(text.lose.hard,ans1,ans2)
                end
                S:send(t)
                S:unlock('ab_help')
                S:unlock('ab_playing')
                S:unlock('ab_cd')
                S:unlock('ab_duplicate')
                D.lastInterectTime=Time()-cooldownSkip.lose
            end
            if res~='duplicate' and S.echos.ab_guess and S.echos.ab_guess.message_id then
                Bot.deleteMsg(S.echos.ab_guess.message_id)
                S.echos.ab_guess=nil
            end
            return true
        end
        return false
    end,
}
