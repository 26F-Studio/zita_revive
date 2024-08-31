local cooldown=2600
local cooldownSkip={
    win=2600,
    lose=1200,
    giveup=1620,
} for k,v in next,cooldownSkip do cooldownSkip[k]=cooldown-v end
local score={
    easy={[0]=0, 0.5, 1, 6.26},
    hard={[0]=1, 3, 6, 8, 10, 10},
}
local rewardList={
    {98,73,31, 6, 0, 0, 0, 0, 0, 0}, -- 1
    { 2,26,62,50,45,34,15, 4, 2, 0}, -- 2
    { 0, 1, 6,42,52,62,80,90,91,92}, -- 3
    { 0, 0, 1, 2, 3, 4, 5, 6, 7, 8}, -- 1+1
}
local rules={
    -- 顺序无关
    {
        --54%，19/35
        text="包含对称块",
        rule=function(seq) return seq:find('Z') and seq:find('S') or seq:find('J') and seq:find('L') end
    },
    {
        --46%，16/35
        text="不包含对称块",
        rule=function(seq) return not (seq:find('Z') and seq:find('S') or seq:find('J') and seq:find('L')) end
    },
    {
        --60%？，包含T或者有J有L
        text="纵奇偶能平衡",
        rule=function(seq) return seq:find('T') or seq:find('J') and seq:find('L') end
    },
    {
        --60%
        text="有三块颜色在彩虹中连续",
        rule=function(seq)
            return string.find(
                (seq:find('Z') and '1' or '0')..
                (seq:find('L') and '1' or '0')..
                (seq:find('O') and '1' or '0')..
                (seq:find('S') and '1' or '0')..
                (seq:find('I') and '1' or '0')..
                (seq:find('J') and '1' or '0')..
                (seq:find('T') and '1' or '0')..
                (seq:find('Z') and '1' or '0')..
                (seq:find('L') and '1' or '0'),
                '111'
            )
        end
    },
    {
        --40%？，没有I且包含J或L
        text="最多只能普消三",
        rule=function(seq) return not seq:find('I') and (seq:find('J') or seq:find('L')) end
    },
    {
        --71.4%？
        text="总共至少10种朝向状态",
        rule=function(seq)
            local count=0
            if seq:find('Z') then count=count+2 end
            if seq:find('S') then count=count+2 end
            if seq:find('J') then count=count+4 end
            if seq:find('L') then count=count+4 end
            if seq:find('T') then count=count+4 end
            if seq:find('O') then count=count+1 end
            if seq:find('I') then count=count+2 end
            return count>=10
        end
    },
    {
        --57%，4/7，有I
        text="能消四",
        rule=function(seq) return seq:find('I') end
    },
    {
        --43%，3/7，无I
        text="干旱",
        rule=function(seq) return not seq:find('I') end
    },
    {
        --71%，5/7，不同时有T和I
        text="不能b2b",
        rule=function(seq) return not seq:find('T') and seq:find('I') end
    },
    {
        --63%？，SZJL中最多有两个
        text="最多两块能spinPC",
        rule=function(seq)
            local count=0
            if seq:find('S') then count=count+1 end
            if seq:find('Z') then count=count+1 end
            if seq:find('J') then count=count+1 end
            if seq:find('L') then count=count+1 end
            return count<=2
        end
    },
    {
        --86%，6/7，包含S或Z
        text="不都能普通消PC",
        rule=function(seq) return seq:find('S') or seq:find('Z') end
    },
    {
        --63%？，JLT中包含至少两个
        text="不能取两块PC二宽四深井",
        rule=function(seq)
            local count=0
            if seq:find('J') then count=count+1 end
            if seq:find('L') then count=count+1 end
            if seq:find('T') then count=count+1 end
            return count<2
        end
    },

    -- 顺序相关
    {
        --66.66%，2/3
        text="无暂存不用重开",
        rule=function(seq)
            if seq:sub(1,1)=='O' then seq=seq:sub(2) end
            return not seq:sub(1,1)=='S' and not seq:sub(1,1)=='Z'
        end
    },
    {
        --67.6%？
        text="有连续两块是相邻彩虹色",
        rule=function(seq)
            for _,twin in next,{'ZL','LO','OS','SI','IJ','JT','LZ','OL','SO','IS','JI','TJ'} do
                if seq:find(twin) then return true end
            end
        end
    },
    {
        --55.2%？
        text="有连续两块可以无spin消6行",
        rule=function(seq)
            for _,twin in next,{'JL','LJ','IJ','JI','IL','LI','IS','SI','IZ','ZI'} do
                if seq:find(twin) then return true end
            end
        end
    },
}
local text={
    help="AB猜方块：有一组四个不同的方块，玩家猜测后会回答几A几B，A同wordle的绿色，B是猜测的块中有几个在答案里但位置不正确，猜对了有奖励哦（？）",
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
        hard="好厉害！猜对了喵！是",
    },
    lose={
        easy="机会用完了喵…答案是$1",
        hardAlmost="答案是$1，只差一次就能猜出来了喵~",
        hard="没猜出来喵~答案是$1还是$2来着？不过那不重要啦~",
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
        local l=TABLE.copy(pieces)
        for _=1,4 do ins(g,TABLE.popRandom(l)) end
    until not (ans and TABLE.equal(g,ans))
    return g
end
local function comp(ANS,G)
    local aCount,bCount=0,0
    for i=1,4 do
        if ANS[i]==G[i] then
            aCount=aCount+1
            G[i]=false
        end
    end
    if aCount==4 then return '4A0B' end
    for i=1,4 do
        if G[i] then
            if TABLE.find(ANS,G[i]) then
                bCount=bCount+1
            end
        end
    end
    return aCount..'A'..bCount..'B'
end
local function guess(D,g)
    if TABLE.find(D.guessHis,table.concat(g)) then return 'duplicate' end

    D.chances=D.chances-1
    ins(D.guessHis,table.concat(g))

    local win=false
    local res
    if D.mode=='easy' then
        res=comp(copy(D.answer),copy(g))
        win=res=='4A0B'
    elseif D.mode=='hard' then
        local set={}
        for _,answer in next,D.answer do
            local r=comp(copy(answer),copy(g))
            if not set[r] then set[r]={} end
            ins(set[r],answer)
        end
        -- print("--------------------------")
        -- for k,v in next,set do
        --     local s=""
        --     if #v<=10 then
        --         for _,_4 in next,v do s=s..table.concat(_4).." " end
        --     end
        --     print(k,#v,s)
        -- end
        local keys=TABLE.getKeys(set)
        table.sort(keys,function(a,b) return #set[a]>#set[b] or #set[a]==#set[b] and a<b end)
        win=keys[1]=='4A0B'
        local r=math.random(#D.guessHis<=2 and 2 or 1)
        D.answer=set[keys[r]]
        res=keys[r]
    end
    if #D.guessHis>1 then
        D.textHis=D.textHis..(#D.guessHis%2==0 and "    " or "\n")
    end
    D.textHis=D.textHis..table.concat(g).." "..res
    if win then return 'win' end
end

---@type Task_raw
return {
    init=function(_,D)
        D.playing=false
        D.lastInterectTime=-1e99 -- time of last answer, for reset when timeout

        D.mode=false -- 'easy' or 'hard'
        D.answer={} -- {'1','2','3','4'} in Easy mode, {'1234','5678',...} in Hard mode
        D.guessHis={}
        D.textHis=""
        D.chances=26
    end,
    func=function(S,M,D)
        -- Log
        local mes=SimpStr(M.raw_message)
        if #mes>9 then return false end

        if mes=='#abhelp' then
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
    elseif mes=='#ab' or mes=='#abhard' then
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
            else
                for a=1,7 do for b=1,7 do for c=1,7 do for d=1,7 do
                    if a~=b and a~=c and a~=d and b~=c and b~=d and c~=d then
                        ins(D.answer,{pieces[a],pieces[b],pieces[c],pieces[d]})
                    end
                end end end end
            end
            guess(D,randomGuess(D.mode=='easy' and D.answer))
            D.chances=D.mode=='easy' and 4 or 6
            S:send(text.start[D.mode].."\n"..D.textHis.."\n"..text.remain[D.mode]..D.chances)
            D.lastInterectTime=Time()
            return true
        elseif D.playing then
            if mes:sub(1,3)=='#ab' then mes=mes:sub(4) end
            mes=mes:upper()
            if not mes:match('^[ZSJLTOI][ZSJLTOI][ZSJLTOI][ZSJLTOI]$') then return false end
            local res=guess(D,{mes:sub(1,1),mes:sub(2,2),mes:sub(3,3),mes:sub(4,4)})
            if res=='duplicate' then
                if S:lock('ab_duplicate',12.6) then
                    S:send(text.guessed)
                end
                D.lastInterectTime=Time()
            elseif res=='win' then
                D.playing=false
                S:send(D.textHis.."\n"..text.win[D.mode]..mes)
                S:unlock('ab_help')
                S:unlock('ab_playing')
                S:unlock('ab_cd')
                S:unlock('ab_duplicate')
                D.lastInterectTime=Time()-cooldownSkip.win
                if Config.extraData.family[S.uid] then
                    local point=((score[D.mode][D.chances] or 2.6)+(D.mode=='easy' and 1 or 2)*math.random())/10
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
                S:send(D.textHis.."\n"..text.remain[D.mode]..D.chances)
                D.lastInterectTime=Time()
            else
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
            return true
        end
        return false
    end,
}
