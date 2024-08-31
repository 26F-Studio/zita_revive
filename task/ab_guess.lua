local cooldown=2600
local cooldownSkip={
    win=2600,
    lose=1200,
    giveup=1620,
} for k,v in next,cooldownSkip do cooldownSkip[k]=cooldown-v end
local text={
    help="AB猜方块：有一组四个不同的方块，玩家猜测后会回答几A几B，A同wordle的绿色，B是猜测的块中有几个在答案里但位置不正确，猜对了有奖励哦（？）",
    start={
        easy="我想好了四个方块，开始猜吧喵！",
        hard="四个方块想好了喵！不会变的喵！",
    },
    remain={
        easy="剩余机会：",
        hard="[HD]剩余机会：",
    },
    guessed="这组方块猜过了喵",
    notFinished="上一局还没结束喵",
    win="猜对了喵！答案是",
    lose={
        easy="机会用完了喵…答案是",
        hard="机会用完了喵…答案好像是$1还是$2来着？不过那不重要啦喵~",
    },
    forfeit="认输了喵？答案是",
}
local pieces=STRING.split("Z S J L T O I"," ")
local ins=table.insert
local copy=TABLE.copy
local function randomGuess()
    local l=TABLE.copy(pieces)
    local g={}
    for _=1,4 do ins(g,TABLE.popRandom(l)) end
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
            D.lastInterectTime=Time()-cooldownSkip.giveup
            S:send(text.forfeit..(D.mode=='easy' and table.concat(D.answer) or table.concat(D.answer[1])))
        elseif mes=='#ab' or mes=='#abhard' then
            if D.playing and Time()-D.lastInterectTime<600 then
                if S:lock('ab_help',62) then
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
            D.chances=D.mode=='easy' and 6 or 7
            if D.mode=='easy' then
                D.answer=randomGuess()
            else
                for a=1,7 do for b=1,7 do for c=1,7 do for d=1,7 do
                    if a~=b and a~=c and a~=d and b~=c and b~=d and c~=d then
                        ins(D.answer,{pieces[a],pieces[b],pieces[c],pieces[d]})
                    end
                end end end end
            end
            guess(D,randomGuess())
            S:send(text.start[D.mode].."\n"..D.textHis.."\n"..text.remain[D.mode]..D.chances)
            D.lastInterectTime=Time()
            return true
        elseif D.playing then
            if mes:sub(1,3)=='#ab' then mes=mes:sub(4) end
            mes=mes:upper()
            if not mes:match('^[ZSJLTOI][ZSJLTOI][ZSJLTOI][ZSJLTOI]$') then return false end
            local res=guess(D,{mes:sub(1,1),mes:sub(2,2),mes:sub(3,3),mes:sub(4,4)})
            if res=='duplicate' then
                if S:lock('ab_help',12.6) then
                    S:send(text.guessed)
                end
                D.lastInterectTime=Time()
            elseif res=='win' then
                D.playing=false
                S:send(D.textHis.."\n"..text.win..mes)
                S:unlock('ab_help')
                D.lastInterectTime=Time()-cooldownSkip.win
                if Config.extraData.family[S.uid] then
                    local bonus=""
                    for _=1,D.mode=='easy' and 1 or 2 do
                        bonus=bonus..CQpic(Config.extraData.touhouPath..TABLE.getRandom(Config.extraData.touhouImages))
                    end
                    S:send(bonus)
                end
            elseif D.chances>0 then
                S:send(D.textHis.."\n"..text.remain[D.mode]..D.chances)
                D.lastInterectTime=Time()
            else
                D.playing=false
                local t=D.textHis.."\n"
                if D.mode=='easy' then
                    t=t..text.lose.easy..table.concat(D.answer)
                elseif #D.answer==1 then
                    t=t..text.lose.easy..table.concat(D.answer[1])
                else
                    local ans1,ans2=table.concat(TABLE.popRandom(D.answer)),table.concat(TABLE.popRandom(D.answer))
                    t=t..STRING.repD(text.lose.hard,ans1,ans2)
                end
                S:send(t)
                S:unlock('ab_help')
                D.lastInterectTime=Time()-cooldownSkip.lose
            end
            return true
        end
        return false
    end,
}
