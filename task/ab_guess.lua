local find=string.find
local ins,concat=table.insert,table.concat
local count,repD=STRING.count,STRING.repD
local copy,getRnd=TABLE.copy,TABLE.getRandom

local cooldown=2600
local cooldownSkip={}
for k,v in next,{
    win=2600,
    lose=1200,
    giveup=1620,
} do cooldownSkip[k]=cooldown-v end
local delays={
    del_help=2.6,
    del_abandon=6.26,
    del_start=6.26,
    del_duplicate=6.26,
    del_normal=26,
    del_win=26,
    del_lose=26,
    del_question=2.6,
    send_reward=1,
}
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
    {98,66,51,26,05,00,00}, -- 1
    {02,32,42,62,50,15,00}, -- 2
    {00,02,06,10,42,80,92}, -- 3
    {00,00,01,02,03,05,08}, -- 1+1
}
local text={
    help="AB猜方块：有一组四个不同的方块，玩家猜测后会提示几A几B，A是存在且位置也对，B是存在但位置不对\n#ab普通开始，#abandon放弃，##ab勿扰模式，#abhd困难模式（允许每种块出现两次，ZJJO猜ZJZJ会得到2A2B，数量溢出也给B计数）",
    guessed={"这组块已经猜过了喵","已经猜过这个了喵"},
    gameNotStarted={"本来也没在玩喵！","你在干什么喵…"},
    notFinished={"上一局还没结束喵~","上一把还没玩完喵"},
    realWord={"这是一个$1考试里的词汇喵！","这个词是真实的$1考试词汇喵！"},
    abandonOthers={"你是想干什么喵？","请礼貌排队喵~"},
    privBlocked={"这局是勿扰模式，等他打完吧喵~","开了勿扰模式喵，先让他打完吧~"},
    privLimit={"也让给别人玩一会喵~","霸机是坏文明喵~","不要霸机喵~"},
    tooFreq={"休息一会喵！","不要刷屏喵！",""},
    start={
        easy={"我想好了四个方块，开始猜吧喵！","四个方块想好了，可以开始猜了喵！"},
        hard={"四个块想好了！不会变的喵！","四个块想好了！真的想好了喵！"},
    },
    remain={
        easy="剩余机会:$1",
        hard="[HD]剩余机会:$1",
        hardAlmost="[HD]剩余机会:$1!",
    },
    win={
        easy="猜对了喵！答案是",
        hard="不错喵！答案是",
    },
    lose={
        easy="机会用完了喵…答案是$1",
        hard="哼哼，没猜出来喵~刚好我也忘了想的是$1还是$2了 欸嘿($3)",
        hardAlmost="答案是$1，差一点点就猜对了喵~",
    },
    forfeit={
        easy="想不出来了喵？答案是$1",
        hard="认输了喵？刚好我也忘了想的是$1还是$2啦($3)",
        hardAlmost="诶？！好吧…答案是$1",
    },
}
local realWords={JOLT="GRE",LIST="CET4",LOLL="GRE",LOSS="CET4",SILL="GRE",SILT="GRE",SLIT="CET4",SLOT="GRE",SOIL="CET4",SOLO="CET6",SOOT="GRE",TILL="CET4",TILT="CET6",TOIL="GRE",TOLL="GRE",TOOL="CET4",TOSS="CET4"}
local rules={
    { -- 同时有SZ或者JL
        id=1,
        text="<有两块互为镜像对称>",
        rule=function(seq) return find(seq,'Z') and find(seq,'S') or find(seq,'J') and find(seq,'L') end,
    },
    { -- 不同时有SZ或者JL
        id=2,
        text="<两两都不镜像对称>",
        rule=function(seq) return not (find(seq,'Z') and find(seq,'S') or find(seq,'J') and find(seq,'L')) end,
    },
    { -- 包含T或者JL总数为偶数
        id=3,
        text="<整组块纵奇偶能够平衡>",
        rule=function(seq) return find(seq,'T') or count(seq,'[JL]')%2==0 end,
    },
    { -- 包含T或者JL总数为偶数
        id=4,
        text="<整组块斜奇偶平衡>",
        rule=function(seq) return count(seq,'T')%2==0 end,
    },
    { -- SZJLT里至少有三个
        id=5,
        text="<至少三块最多只能消三>",
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
        text="<至少三块包含排成直线的三格>",
        rule=function(seq)
            return count(seq,'[JLTI]')>=3
        end,
    },
    { -- 有I
        id=8,
        text="<存在能消四行的块>",
        rule=function(seq) return find(seq,'I') end,
    },
    { -- 无I
        id=9,
        text="<干旱>",
        rule=function(seq) return not find(seq,'I') end,
    },
    { -- SZJLTI中最多有两个
        id=10,
        text="<每一块的长度都达到了3>",
        rule=function(seq) return not find(seq,'O') end,
    },
    { -- SZJL中最多有两个
        id=11,
        text="<能spinPC的块不超过两个>",
        rule=function(seq) return count(seq,'[SZJL]')<=2 end,
    },
    {
        id=12,
        text="<至少三块能普通消PC>",
        rule=function(seq) return count(seq,'[JLTOI]')>=3 end,
    },
    {
        id=13,
        text="<有连续两块颜色在“红橙黄绿青蓝紫”中相邻>",
        rule=function(seq)
            for _,twin in next,{'ZL','LO','OS','SI','IJ','JT'; 'LZ','OL','SO','IS','JI','TJ'} do
                if find(seq,twin) then return true end
            end
        end,
    },
    {
        id=14,
        text="<有连续两块可以无spin消6行>",
        rule=function(seq)
            for _,twin in next,{'JL','LJ','IJ','JI','IL','LI','IS','SI','IZ','ZI'} do
                if find(seq,twin) then return true end
            end
        end,
    },
    {
        id=26,
        text="<有三块可以拼成3*4盒子>",
        rule=function(seq)
            return
            -- JLS, JLZ
                find(seq,'J') and find(seq,'L') and find(seq,'[SZ]') or
                seq:match('(.).*%1') and (
                -- IJJ, ILL, IOO
                    find(seq,'I') and (count(seq,'J')>=2 or count(seq,'L')>=2 or count(seq,'O')>=2) or
                    -- JSJ, LZL
                    find(seq,'S') and count(seq,'J')>=2 or
                    find(seq,'Z') and count(seq,'L')>=2 or
                    -- OJJ, OLL
                    find(seq,'O') and count(seq,'[JL]')>=2 or
                    -- JTT, LTT
                    find(seq,'[JL]') and count(seq,'T')>=2
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
                return not (find(seq,'O') and count(seq,'[JL]')==3)
            elseif i==1 then
                local o=count(seq,'O')
                -- 杀IO[OSZ][JL]，和IOOT
                if find(seq,'T') and o==2 then
                    return false
                elseif o>0 and find(seq,'[JL]') and (find(seq,'[SZ]') or o==2) then
                    return false
                end
                return true
            elseif i==2 then
                -- 有JLT没O活
                return find(seq,'[JLT]') and not find(seq,'O')
            elseif i==3 then
                -- 虽然目前用不上
                return find(seq,'SZOT')
            else
                return false
            end
        end,
    },
}
local pieces=STRING.atomize('ZSJLTOI')
local piecesFullWidth={
    Z='Ｚ',S='Ｓ',J='Ｊ',L='Ｌ',T='Ｔ',O='Ｏ',I='Ｉ',
    -- ['0']='０',['1']='１',['2']='２',['3']='３',['4']='４',['5']='５',['6']='６',['7']='７',['8']='８',['9']='９',
    -- [' ']='　',A='Ａ',B='Ｂ',
}
local function toFullwidth(str)
    local res=''
    for c in str:gmatch('.') do
        res=res..(piecesFullWidth[c] or c)
    end
    return res
end
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
if not TABLE.find(arg,'startWithNotice') then
    for _,r in next,rules do
        local cnt=0
        local cntSimp=0
        for i=1,#hardLib do
            if r.rule(concat(hardLib[i])) then
                cnt=cnt+1
                if not concat(hardLib[i]):match('(.).*%1') then cntSimp=cntSimp+1 end
            end
        end
        print(r.id,("HD: %.0f%%(%d)"):format(cnt/#hardLib*100,cnt),("EZ: %.0f%%(%d)"):format(cntSimp/840*100,cntSimp))
        if not (MATH.between(cnt/#hardLib,0.26,0.8) and MATH.between(cntSimp/840,0.26,0.8)) then
            print("^Warning: Extreme Limitation^")
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
    if TABLE.find(D.guessHis,concat(g)) then return 'duplicate' end

    D.chances=D.chances-1
    ins(D.guessHis,concat(g))

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
        --         for _,_4 in next,set do s=s..concat(_4).." " end
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
            while not keys[r] do r=r-1 end
            res=keys[r]
            D.answer=resultSets[res]
        end
    end
    if #D.guessHis>1 then
        D.textHis=D.textHis..(#D.guessHis%2==0 and "   " or "\n")
    end
    D.textHis=D.textHis..toFullwidth(concat(g)).." "..res
    if res=='4A0B' then return 'win' end
end
---@param S Session
local function sendMes(S,M,D,mode)
    local t="[CQ:at,qq="..M.user_id.."]\n"
    if mode=='notFinished' then
        t=t..getRnd(text.notFinished).."\n"
    elseif mode=='start' then
        t=t..getRnd(text.start[D.mode]).."\n"
    end
    t=t..D.textHis.."\n"
    if D.privOwner then t=t.."#" end
    t=t..repD(text.remain[D.mode=='hard' and #D.answer==1 and 'hardAlmost' or D.mode],D.chances)
    S:send(t,'abguess')
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

        D.privOwner=false
        D.playerHis=TABLE.new(false,5)
    end,
    func=function(S,M,D)
        -- Log
        local mes=SimpStr(M.raw_message)
        if #mes>=10 then return false end

        local privGame=false
        if mes:sub(1,2)=='##' then
            mes=mes:sub(2)
            privGame=true
        end

        if mes=='#abhelp' or mes=='#about' or mes=='#ab帮助' or mes=='#ab说明' then
            if S:lock('ab_help',26) then
                S:send(text.help)
            end
            if Config.groupManaging[S.id] then
                S:delayDelete(delays.del_help,M.message_id)
            end
            return true
        elseif mes=='#abandon' then
            if not D.playing then
                if S:lock('ab_abandon',26) then
                    S:send(getRnd(text.gameNotStarted))
                end
                return true
            end
            if D.privOwner and M.user_id~=D.privOwner then
                if S:lock('ab_priv',12.6) then
                    S:send(getRnd(text.abandonOthers))
                end
                return true
            end
            D.playing=false
            S:lock('ab_abandon',26)
            if D.mode=='easy' then
                S:send(repD(text.forfeit.easy,concat(D.answer)))
            else
                if #D.answer==1 then
                    S:send(repD(text.forfeit.hardAlmost,concat(D.answer[1])))
                    if D.chances>=2 then
                        S:send(CQpic(Config.extraData.touhouPath..getRnd(Config.extraData.touhouImages)))
                    end
                else
                    local ans1,ans2=concat(TABLE.popRandom(D.answer)),concat(TABLE.popRandom(D.answer))
                    S:send(repD(text.forfeit.hard,ans1,ans2,#D.answer+2))
                end
            end
            S:unlock('ab_help')
            S:unlock('ab_playing')
            S:unlock('ab_cd')
            S:unlock('ab_duplicate')
            D.lastInterectTime=Time()-cooldownSkip.giveup
            if Config.groupManaging[S.id] then
                S:delayDelete(delays.del_abandon,M.message_id)
            end
            return true
        elseif mes=='#ab' or mes=='#abez' or mes=='#abeasy' or mes=='#ab简单' or mes=='#abhd' or mes=='#abhard' or mes=='#ab困难' then
            -- Start
            local timeSkip=Time()-D.lastInterectTime
            if D.playing and timeSkip<600 then
                if S:lock('ab_playing',62) then
                    sendMes(S,M,D,'notFinished')
                end
                return true
            end
            if not Config.safeSessionID[S.uid] and S.group and not AdminMsg(M) and timeSkip<cooldown then
                local timeRemain=cooldown-timeSkip+10
                if timeRemain<60 then
                    if S:lock('ab_cd',26) then
                        S:send(repD("再等$1秒就能开局了喵",math.ceil(timeRemain)))
                    end
                else
                    if S:lock('ab_cd',62) then
                        S:send(repD("$1等$2分钟才能再玩",getRnd(text.tooFreq),math.ceil(timeRemain/60)))
                    end
                end
                return true
            end

            local player
            if not privGame then
                player=false
            else
                local s=TABLE.count(D.playerHis,M.user_id)
                if s<3 then
                    player=M.user_id
                else
                    if S:lock('ab_privLimit',26) then
                        S:send(getRnd(text.privLimit))
                    end
                    return true
                end
            end
            ins(D.playerHis,1,player)
            D.playerHis[6]=nil

            D.privOwner=player
            D.playing=true
            D.mode=(mes:find("h") or mes:find("困"))  and 'hard' or 'easy'
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
                    if r.rule(concat(D.answer[i])) then
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
            sendMes(S,M,D,'start')
            D.lastInterectTime=Time()
            if Config.groupManaging[S.id] then
                S:delayDelete(delays.del_start,M.message_id)
            end
            return true
        elseif D.playing then
            if mes:sub(1,3)=='#ab' then mes=mes:sub(4) end
            mes=mes:upper()
            if not mes:match('^[ZSJLTOI][ZSJLTOI][ZSJLTOI][ZSJLTOI]$') then return false end
            if D.privOwner and M.user_id~=D.privOwner then
                if S:lock('ab_priv',12.6) then
                    S:send(getRnd(text.privBlocked))
                end
                return true
            end

            local res=guess(D,{mes:sub(1,1),mes:sub(2,2),mes:sub(3,3),mes:sub(4,4)})
            if res=='duplicate' then
                -- Duplicate
                local mesID='abguess_duplicate_'..math.random(262626,626262)
                if S:lock('ab_duplicate',12.6) then
                    S:send(getRnd(text.guessed),mesID)
                end
                D.lastInterectTime=Time()
                if Config.groupManaging[S.id] then
                    S:delayDelete(delays.del_duplicate,mesID)
                    S:delayDelete(delays.del_duplicate,M.message_id)
                end
            else
                -- Available guess
                if S.echos.abguess then
                    S:delayDelete(delays.del_question,S.echos.abguess.message_id)
                    S.echos.abguess=nil
                end
                if res=='win' then
                    -- Win
                    D.playing=false
                    S:lock('ab_abandon',26)
                    local t=D.textHis.."\n"..text.win[D.mode]..mes
                    local point=0
                    if realWords[mes] then
                        t=t.."\n"..repD(getRnd(text.realWord),realWords[mes])
                        point=point+1
                    end
                    if Config.extraData.family[S.uid] then
                        point=point+(score[D.mode][D.chances] or 2.6)+(D.mode=='easy' and 0.26 or 1.26)*math.random()
                        local reward=MATH.randFreq{
                            MATH.lLerp(rewardList[1],point),
                            MATH.lLerp(rewardList[2],point),
                            MATH.lLerp(rewardList[3],point),
                            MATH.lLerp(rewardList[4],point),
                        }
                        if reward==1 then
                            S:delaySend(0*delays.send_reward,CQpic(Config.extraData.touhouPath..getRnd(Config.extraData.touhouImages)))
                        elseif reward==2 then
                            S:delaySend(0*delays.send_reward,CQpic(Config.extraData.touhouPath..getRnd(Config.extraData.touhouImages)))
                            S:delaySend(1*delays.send_reward,CQpic(Config.extraData.touhouPath..getRnd(Config.extraData.touhouImages)))
                        elseif reward==3 then
                            S:delaySend(0*delays.send_reward,CQpic(Config.extraData.touhouPath..getRnd(Config.extraData.touhouImages)))
                            S:delaySend(1*delays.send_reward,CQpic(Config.extraData.touhouPath..getRnd(Config.extraData.touhouImages)))
                            S:delaySend(2*delays.send_reward,CQpic(Config.extraData.touhouPath..getRnd(Config.extraData.touhouImages)))
                        elseif reward==4 then
                            S:delaySend(0*delays.send_reward,CQpic(Config.extraData.touhouPath..getRnd(Config.extraData.touhouImages)))
                            S:delaySend(1*delays.send_reward,CQpic(Config.extraData.imgPath..'z1/'..math.random(26)..'.jpg'))
                        end
                        t=t.."\n"..("(%.2f|%d)"):format(point,reward)
                    end
                    S:send(t)
                    S:unlock('ab_help')
                    S:unlock('ab_playing')
                    S:unlock('ab_cd')
                    S:unlock('ab_duplicate')
                    D.lastInterectTime=Time()-cooldownSkip.win
                    if Config.groupManaging[S.id] then
                        S:delayDelete(delays.del_win,M.message_id)
                    end
                elseif D.chances>0 then
                    -- Guess normally
                    if #D.guessHis==2 and D.mode=='easy' then
                        local possibleRules={}
                        local ans=concat(D.answer)
                        for i=1,#rules do
                            if rules[i].rule(ans) then
                                ins(possibleRules,rules[i])
                            end
                        end
                        if #possibleRules>0 then
                            local r=getRnd(possibleRules)
                            D.textHis=D.textHis.."\n"..r.text
                            -- print(concat(D.answer))
                            -- for i=1,#possibleRules do
                            --     print(possibleRules[i].text)
                            -- end
                        end
                    end
                    sendMes(S,M,D,'normal')
                    D.lastInterectTime=Time()
                    if Config.groupManaging[S.id] then
                        S:delayDelete(delays.del_normal,M.message_id)
                    end
                else
                    -- Lose
                    D.playing=false
                    S:lock('ab_abandon',26)
                    local bonus
                    local t=D.textHis.."\n"
                    if D.mode=='easy' then
                        t=t..repD(text.lose.easy,concat(D.answer))
                    elseif #D.answer==1 then
                        t=t..repD(text.lose.hardAlmost,concat(D.answer[1]))
                        if Config.extraData.family[S.uid] then
                            bonus=CQpic(Config.extraData.touhouPath..getRnd(Config.extraData.touhouImages))
                        end
                    else
                        local ans1,ans2=concat(TABLE.popRandom(D.answer)),concat(TABLE.popRandom(D.answer))
                        t=t..repD(text.lose.hard,ans1,ans2,#D.answer+2)
                    end
                    S:send(t)
                    if bonus then
                        S:send(bonus)
                    end
                    S:unlock('ab_help')
                    S:unlock('ab_playing')
                    S:unlock('ab_cd')
                    S:unlock('ab_duplicate')
                    D.lastInterectTime=Time()-cooldownSkip.lose
                    if Config.groupManaging[S.id] then
                        S:delayDelete(delays.del_lose,M.message_id)
                    end
                end
            end
            return true
        else
            return false
        end
    end,
}
