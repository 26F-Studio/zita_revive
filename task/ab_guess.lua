local cooldown=2600
local cooldownSkip={
    win=2600,
    lose=1200,
    giveup=1620,
}
for k,v in next,cooldownSkip do cooldownSkip[k]=cooldown-v end
local score={
    easy={[0]=0,0.5,1,4,5},
    hard={[0]=1,2,3,5,6},
}
local rewardList={
    {98,73,31,10, 5, 0, 0}, -- 1
    { 2,26,62,62,50,15, 0}, -- 2
    { 0, 1, 6,26,42,80,92}, -- 3
    { 0, 0, 1, 2, 3, 5, 8}, -- 1+1
}
local rules={
    -- 顺序无关
    {
        -- 54%，19/35
        id=0,
        rate=54,
        text="【包含镜像对称的块】",
        rule=function(seq) return seq:find('Z') and seq:find('S') or seq:find('J') and seq:find('L') end,
    },
    {
        -- 46%，16/35
        id=1,
        rate=46,
        text="【不包含镜像对称的块】",
        rule=function(seq) return not (seq:find('Z') and seq:find('S') or seq:find('J') and seq:find('L')) end,
    },
    {
        -- 约60%，包含T或者JL总数为偶数
        id=2,
        rate=60,
        text="【纵奇偶能够平衡】",
        rule=function(seq)
            if seq:find('T') then return true end
            return STRING.count(seq,'[JL]')%2==0
        end,
    },
    {
        -- 60%
        id=3,
        rate=60,
        text="【有三块颜色在循环彩虹七色中连续】",
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
        end,
    },
    {
        -- 约40%，没有I且包含J或L
        id=4,
        rate=40,
        text="【任取一块最多只能普通消除三行】",
        rule=function(seq) return not seq:find('I') and (seq:find('J') or seq:find('L')) end,
    },
    {
        -- 约71.4%
        id=5,
        rate=71,
        text="【总共至少10种朝向状态】",
        rule=function(seq)
            return
                STRING.count(seq,'[ZSI]')*2+
                STRING.count(seq,'[JLT]')*4+
                STRING.count(seq,'O')
                >=10
        end,
    },
    {
        -- 43%，3/7，O和I要么都有要么都没
        id=6,
        rate=43,
        text="【总共最多能消刚好12行】",
        rule=function(seq)
            local count=0
            for c in string.gmatch(seq,'.') do
                if c=='Z' then
                    count=count+3
                elseif c=='S' then
                    count=count+3
                elseif c=='J' then
                    count=count+3
                elseif c=='L' then
                    count=count+3
                elseif c=='T' then
                    count=count+3
                elseif c=='O' then
                    count=count+2
                elseif c=='I' then
                    count=count+4
                end
            end
            return count>=10
        end,
    },
    {
        -- 57%，4/7，有I
        id=7,
        rate=57,
        text="【有一块能够消四行】",
        rule=function(seq) return seq:find('I') end,
    },
    {
        -- 43%，3/7，无I
        id=8,
        rate=43,
        text="【干旱】",
        rule=function(seq) return not seq:find('I') end,
    },
    {
        -- 约63%，SZJL中最多有两个
        id=9,
        rate=63,
        text="【最多两块能够spinPC】",
        rule=function(seq)
            local count=0
            for c in string.gmatch(seq,'.') do
                if c=='Z' then
                    count=count+1
                elseif c=='S' then
                    count=count+1
                elseif c=='J' then
                    count=count+1
                elseif c=='L' then
                    count=count+1
                end
            end
            return count<=2
        end,
    },
    {
        -- 86%，6/7，包含S或Z
        id=10,
        rate=86,
        text="【不全都能普通消PC】",
        rule=function(seq) return seq:find('S') or seq:find('Z') end,
    },
    {
        -- 约63%，JLT中包含至少两个
        id=11,
        rate=63,
        text="【任取两块不能PC二宽四深井】",
        rule=function(seq)
            local count=0
            if seq:find('J') then count=count+1 end
            if seq:find('L') then count=count+1 end
            if seq:find('T') then count=count+1 end
            return count<2
        end,
    },

    -- 顺序相关
    {
        -- 67%，2/3
        id=12,
        rate=67,
        text="【无暂存这个开局序列不用重开】",
        rule=function(seq)
            local s=seq:sub(1,1)=='O' and 2 or 1
            return seq:sub(s,s)~='S' and seq:sub(s,s)~='Z'
        end,
    },
    {
        -- 约67.6%
        id=13,
        rate=67,
        text="【有连续两块在循环彩虹七色中相邻】",
        rule=function(seq)
            for _,twin in next,{'ZL','LO','OS','SI','IJ','JT','TZ'; 'LZ','OL','SO','IS','JI','TJ','ZT'} do
                if seq:find(twin) then return true end
            end
        end,
    },
    {
        -- 约55.2%
        id=14,
        rate=55,
        text="【有连续两块可以无spin消6行】",
        rule=function(seq)
            for _,twin in next,{'JL','LJ','IJ','JI','IL','LI','IS','SI','IZ','ZI'} do
                if seq:find(twin) then return true end
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
        local l=copy(pieces)
        for _=1,4 do ins(g,TABLE.popRandom(l)) end
    until not (ans and TABLE.equal(g,ans))
    return g
end
local hardLib={} do
    local l,_l={},{}
    for a=1,7 do for b=1,7 do for c=1,7 do for d=1,7 do
        l[1],l[2],l[3],l[4]=pieces[a],pieces[b],pieces[c],pieces[d]
        _l[1],_l[2],_l[3],_l[4]=l[1],l[2],l[3],l[4]
        table.sort(_l)
        if _l[1]~=_l[3] and _l[2]~=_l[4] then ins(hardLib,copy(l)) end
    end end end end
    print('Hard quest lib length: '..#hardLib)
end
for _,r in next,rules do
    local count=0
    for i=1,#hardLib do
        if r.rule(table.concat(hardLib[i])) then count=count+1 end
    end
    if count<=626 then
        print("Warning: Rule "..r.id.." only has "..count.." answers")
    end
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
    -- print(D.mode,table.concat(g),res)
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
