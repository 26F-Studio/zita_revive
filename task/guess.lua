local find=string.find
local ins,rem,concat=table.insert,table.remove,table.concat
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
    del_help=false,
    del_abandon=false,
    del_start=false,
    del_duplicate=false,
    del_normal=false,
    del_win=false,
    del_lose=false,
    del_question=26,
    send_reward=1,
}
local hdWeights={
    {2,5,3},
    {3,5,2},
    {6,3,1},
    {7,3},
    {1},
}
local qdWeights={
    {3,4,5},
    {3,3,3},
    {3,2},
    {1},
}
local basePoint={
    easy=0.26,
    hard=1.26,
    quandle=0.626,
}
local score={
    easy={[0]=0,0.5,1,4,5},
    hard={[0]=1,2,3,5,6},
    quandle={[0]=0.5,1,1.5,2,2.6,4.2,6},
}
local rewardList={
    {98,56,31,10,05,00,00}, -- 1
    {02,42,62,62,50,15,00}, -- 2
    {00,02,06,26,42,80,92}, -- 3
    {00,00,01,02,03,05,08}, -- 1+1
}
-- for point=0,4,0.1 do
--     local sum=0
--     for _=1,1e4 do
--         sum=sum+MATH.randFreq{
--             MATH.lLerp(rewardList[1],point/6),
--             MATH.lLerp(rewardList[2],point/6),
--             MATH.lLerp(rewardList[3],point/6),
--             MATH.lLerp(rewardList[4],point/6),
--         }
--     end
--     sum=sum/1e4
--     print(point,sum)
-- end
local keyword={
    help={
        ['#abhelp']=0,['#about']=0,['#ab帮助']=0,['#ab说明']=0,
        ['#qdhelp']=0,['#qdout']=0,['#qd帮助']=0,['#qd说明']=0,
    },
    start={
        ['#ab']='easy',['#abez']='easy',['#abeasy']='easy',['#ab简单']='easy',
        ['#abhd']='hard',['#abhard']='hard',['#ab困难']='hard',
        ['#qd']='quandle',
    },
}
local text={
    helpAB="AB猜方块：有一组四个不同的方块，玩家猜测后会提示几A几B，A是存在且位置也对，B是存在但位置不对\n#ab普通开始，#abandon放弃，##ab勿扰模式，#abhd困难模式（允许每种块出现两次，ZJJO猜ZJZJ会得到2A2B，数量溢出也给B计数）",
    helpQD="Quandle：有一个单词，玩家猜测后会给出一定的提示，带圈字母表示位置正确，大写存在但位置不对，小写不存在\n#qd开始，#quitom放弃，#qd5指定长度开始（4~10），##qd勿扰模式",
    guessed={"这个已经猜过了喵","已经猜过这个了喵","前面猜过这个了喵"},
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
        quandle={"我想好了一个$1个字母的单词，不会变的喵！"},
    },
    remain={
        easy="剩余机会:$1",
        hard="[HD]剩余机会:$1",
        hardAlmost="[HD]剩余机会:$1!",
        quandle={
            "剩余猜测:$1",
            "剩余猜测*:$1",
            "剩余猜测**:$1",
        },
    },
    win={
        easy={"猜对了喵！答案是","不错喵！答案是$1","可以喵！答案是$1"},
        hard={"很强喵！确实是$1","好强喵！真的是$1"},
        quandle={"好厉害喵！！单词是$1","太厉害了喵！！单词是$1"}, -- "fanyi.baidu.com/?query="
    },
    lose={
        easy="机会用完了喵…答案是$1",
        hard="哼哼，没猜出来喵~刚好我也忘了想的是$1还是$2了 欸嘿($3)",
        hardAlmost="答案是$1，差一点点就猜对了喵~",
        quandle="没猜出来喵~刚好我也忘了想的是$1还是$2了 欸嘿($3)",
        quandleAlmost="单词是$1，差一点点就猜对了喵~",
    },
    forfeit={
        easy="想不出来了喵？答案是$1",
        hard="认输了喵？刚好我也忘了想的是$1还是$2啦($3)",
        hardAlmost="诶？！好吧…答案是$1",
        quandle="放弃了喵？行吧，单词是$1($2)",
    },
    quandleNotWord={
        "喵…这是个单词吗？只能猜我认识的词哦~",
        "好像没见过这个单词喵？换一个吧",
        "是没见过的单词呢喵~要猜我知道的词哦~",
    },
    quandleNotWord2={
        "这个词也没见过喵~",
        "这好像也不是词喵？",
        "这应该也不是单词喵？",
        "没见过喵~再换一个词吧",
        "也没见过喵~再换个词吧",
    },
}
local realWords={JOLT="GRE",LIST="CET4",LOLL="GRE",LOSS="CET4",SILL="GRE",SILT="GRE",SLIT="CET4",SLOT="GRE",SOIL="CET4",SOLO="CET6",SOOT="GRE",TILL="CET4",TILT="CET6",TOIL="GRE",TOLL="GRE",TOOL="CET4",TOSS="CET4",LOLI="【？】"}
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
    { -- 无O
        id=10,
        text="<每一块的长度都不小于三>",
        rule=function(seq) return not find(seq,'O') end,
    },
    { -- SZJL中最多有两个
        id=11,
        text="<不超过两个块能spinPC>",
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
            if count(seq,'[SZO]')*2+count(seq,'[JLT]')*3+i*4<10 then
                return false
            end
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
local fullwidthMap={
    A='Ａ',B='Ｂ',C='Ｃ',D='Ｄ',E='Ｅ',F='Ｆ',G='Ｇ',H='Ｈ',I='Ｉ',J='Ｊ',K='Ｋ',L='Ｌ',M='Ｍ',N='Ｎ',O='Ｏ',P='Ｐ',Q='Ｑ',R='Ｒ',S='Ｓ',T='Ｔ',U='Ｕ',V='Ｖ',W='Ｗ',X='Ｘ',Y='Ｙ',Z='Ｚ',
    a='ａ',b='ｂ',c='ｃ',d='ｄ',e='ｅ',f='ｆ',g='ｇ',h='ｈ',i='ｉ',j='ｊ',k='ｋ',l='ｌ',m='ｍ',n='ｎ',o='ｏ',p='ｐ',q='ｑ',r='ｒ',s='ｓ',t='ｔ',u='ｕ',v='ｖ',w='ｗ',x='ｘ',y='ｙ',z='ｚ',
    ['0']='０',['1']='１',['2']='２',['3']='３',['4']='４',['5']='５',['6']='６',['7']='７',['8']='８',['9']='９',
    [' ']='　',
}
local function toFullwidth(str)
    local res=''
    for c in str:gmatch('.') do
        res=res..(fullwidthMap[c] or c)
    end
    return res
end
local circleMap={
    A="Ⓐ",B="Ⓑ",C="Ⓒ",D="Ⓓ",E="Ⓔ",F="Ⓕ",G="Ⓖ",H="Ⓗ",I="Ⓘ",J="Ⓙ",K="Ⓚ",L="Ⓛ",M="Ⓜ",N="Ⓝ",O="Ⓞ",P="Ⓟ",Q="Ⓠ",R="Ⓡ",S="Ⓢ",T="Ⓣ",U="Ⓤ",V="Ⓥ",W="Ⓦ",X="Ⓧ",Y="Ⓨ",Z="Ⓩ",
    a="ⓐ",b="ⓑ",c="ⓒ",d="ⓓ",e="ⓔ",f="ⓕ",g="ⓖ",h="ⓗ",i="ⓘ",j="ⓙ",k="ⓚ",l="ⓛ",m="ⓜ",n="ⓝ",o="ⓞ",p="ⓟ",q="ⓠ",r="ⓡ",s="ⓢ",t="ⓣ",u="ⓤ",v="ⓥ",w="ⓦ",x="ⓧ",y="ⓨ",z="ⓩ",
    ['0']="⓪",['1']="①",['2']="②",['3']="③",['4']="④",['5']="⑤",['6']="⑥",['7']="⑦",['8']="⑧",['9']="⑨",['10']="⑩",
    ['11']="⑪",['12']="⑫",['13']="⑬",['14']="⑭",['15']="⑮",['16']="⑯",['17']="⑰",['18']="⑱",['19']="⑲",['20']="⑳",
    ['21']="㉑",['22']="㉒",['23']="㉓",['24']="㉔",['25']="㉕",['26']="㉖",['27']="㉗",['28']="㉘",['29']="㉙",['30']="㉚",
    ['31']="㉛",['32']="㉜",['33']="㉝",['34']="㉞",['35']="㉟",['36']="㊱",['37']="㊲",['38']="㊳",['39']="㊴",['40']="㊵",
    ['41']="㊶",['42']="㊷",['43']="㊸",['44']="㊹",['45']="㊺",['46']="㊻",['47']="㊼",['48']="㊽",['49']="㊾",['50']="㊿",
}
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
end
local quandleLib ---@type QuandleLib
local function initQuandleLib()
    local cet4=STRING.split(FILE.load('data/lib_cet4.txt','-string'):upper(),'\r\n')
    local cet6=STRING.split(FILE.load('data/lib_cet6.txt','-string'):upper(),'\r\n')
    local tem8=STRING.split(FILE.load('data/lib_tem8.txt','-string'):upper(),'\r\n')
    local gre =STRING.split(FILE.load('data/lib_gre.txt' ,'-string'):upper(),'\r\n')
    local full=STRING.split(FILE.load('data/lib_full.txt','-string'):upper(),'\r\n')
    local ex  =STRING.split(FILE.load('data/lib_ex.txt'  ,'-string'):upper(),'\r\n')
    ---@class QuandleLib
    quandleLib={
        cet4={},cet6={},tem8={},gre={},
        fullHash=TABLE.getValueSet(full,'RND'), ---@type table<string,string>
    }
    TABLE.update(quandleLib.fullHash,TABLE.getValueSet(ex,'RND'))
    local hash=quandleLib.fullHash
    for _,w in next,gre do hash[w]='GRE' end
    for _,w in next,tem8 do hash[w]='TEM8' end
    for _,w in next,cet6 do hash[w]='CET6' end
    for _,w in next,cet4 do hash[w]='CET4' end
    for i=1,10 do
        quandleLib.cet4[i]={}
        quandleLib.cet6[i]={}
        quandleLib.tem8[i]={}
        quandleLib.gre[i]={}
    end
    for i=1,#cet4 do ins(quandleLib.cet4[#cet4[i]],cet4[i]) end
    for i=1,#cet6 do ins(quandleLib.cet6[#cet6[i]],cet6[i]) end
    for i=1,#tem8 do ins(quandleLib.tem8[#tem8[i]],tem8[i]) end
    for i=1,#gre do ins(quandleLib.gre[#gre[i]],gre[i]) end
    collectgarbage()
    initQuandleLib=NULL
end
if not TABLE.find(arg,'startWithNotice') then
    print('Hard quest lib length: '..#hardLib)
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
---@return string #example: "1A1B"
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
---@return string #example: "20100"
local function compQuandle(ANS,G)
    -- local output=concat(ANS)
    local result=TABLE.new(0,#ANS)
    for i=1,#ANS do
        if ANS[i]==G[i] then
            -- output=output.." ["..i.."] correct"
            result[i]=2
            ANS[i],G[i]=-1,-2
        end
    end
    for i=1,#G do
        local p=TABLE.find(ANS,G[i])
        if p then
            -- output=output.." ["..i.."] fuzzy"
            ANS[p],G[i]=-1,-2
            result[i]=1
        end
    end
    -- print(output)
    return concat(result)
end
local resultSets={}
local function resultSorter(a,b) return #resultSets[a]>#resultSets[b] end
local function guess(D,g)---@return 'duplicate'|'win'|nil
    if TABLE.find(D.guessHis,concat(g)) then return 'duplicate' end
    ins(D.guessHis,concat(g))
    D.chances=D.chances-1

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
    elseif D.mode=='quandle' then
        -- Punish repeating recent 25 words
        local hisList=D.quandleLongHis[D.length]
        local repCount=TABLE.count(hisList,concat(g))
        if #D.guessHis==1 then
            D.stage=math.min(repCount+1,3)
            if D.stage>=2 then
                TABLE.connect(D.answer,quandleLib.tem8[D.length])
                if D.stage>=3 then
                    D.chances=D.chances+1
                    TABLE.connect(D.answer,quandleLib.gre[D.length])
                end
            end
        else
            D.repPoint=D.repPoint+repCount
        end
        ins(hisList,1,concat(g))
        hisList[26]=nil

        resultSets={}
        for _,answer in next,D.answer do
            local r=compQuandle(STRING.atomize(answer),copy(g))
            if not resultSets[r] then resultSets[r]={} end
            ins(resultSets[r],answer)
        end
        local keys=TABLE.getKeys(resultSets)
        TABLE.delete(keys,string.rep('2',D.length))

        -- print("--------------------------")
        -- for _,key in next,keys do
        --     local set=resultSets[key]
        --     if #set<=10 then
        --         local s=""
        --         for _,_4 in next,set do s=s.._4.." " end
        --         print(key,#set,s)
        --     else
        --         print(key,#set)
        --     end
        -- end

        if #keys==0 then
            -- Only one answer left
            res='win'
            for i=1,#g do g[i]=circleMap[g[i]] end
            D.textHis=D.textHis.."\n"..concat(g)
        else
            -- Still has multiple possibilities
            table.sort(keys,resultSorter)
            local r=MATH.randFreq(qdWeights[math.min(#D.guessHis,#qdWeights)])
            while not keys[r] do r=r-1 end
            res=keys[r]
            D.answer=resultSets[res]

            for i=1,#g do
                if res:sub(i,i)=='2' then
                    g[i]=circleMap[g[i]]
                elseif res:sub(i,i)=='1' then
                    g[i]=fullwidthMap[g[i]:upper()]
                else
                    g[i]=fullwidthMap[g[i]:lower()]
                end
            end
            if #D.guessHis>1 then D.textHis=D.textHis.."\n" end
            D.textHis=D.textHis..concat(g)
        end
        return res
    end
    if #D.guessHis>1 then D.textHis=D.textHis..(#D.guessHis%2==0 and "   " or "\n") end
    D.textHis=D.textHis..toFullwidth(concat(g)).." "..res
    if res=='4A0B' then return 'win' end
end
---@param S Session
---@param M LLOneBot.Event.GroupMessage
local function sendMes(S,M,D,mode)
    local t=S.group and "[CQ:at,qq="..M.user_id.."]\n" or ""
    if mode=='notFinished' then
        t=t..getRnd(text.notFinished).."\n"
    elseif mode=='start' then
        t=t..repD(getRnd(text.start[D.mode]),D.length).."\n"
    end
    if #D.textHis>0 then t=t..D.textHis.."\n" end
    if D.privOwner then t=t.."#" end
    if mode=='win' then
        local lastGuess=D.guessHis[#D.guessHis]
        t=t..repD(getRnd(text.win[D.mode]),lastGuess)
        local point=0
        if realWords[lastGuess] then
            t=t.."\n"..repD(getRnd(text.realWord),realWords[lastGuess])
            point=point+1
        end
        if Config.extraData.family[S.uid] then
            point=point+(basePoint[D.mode])*math.random()+(score[D.mode][D.chances] or 2.6)
            if D.mode=='quandle' then
                point=point+D.stage/2-(D.length-2)^.5+1
                point=math.max(point-D.repPoint^.62*.62,0)
            end
            local reward=MATH.randFreq{
                MATH.lLerp(rewardList[1],point/6),
                MATH.lLerp(rewardList[2],point/6),
                MATH.lLerp(rewardList[3],point/6),
                MATH.lLerp(rewardList[4],point/6),
            }
            if reward<=3 then
                for i=1,reward do
                    S:delaySend(i*delays.send_reward,CQpic(getRnd(Config.extraData.touhouImages)))
                end
            else
                S:delaySend(1*delays.send_reward,CQpic(getRnd(Config.extraData.touhouImages)))
                S:delaySend(2*delays.send_reward,CQpic(Config.extraData.imgPath..'z1/'..math.random(26)..'.jpg'))
            end
            t=t.."\n"..("(%.2f/6 | %d)"):format(point,reward)
        end
        S:send(t)
    elseif mode=='lose' then
        if D.mode=='easy' then
            t=t..repD(text.lose.easy,concat(D.answer))
        elseif D.mode=='hard' then
            if #D.answer==1 then
                t=t..repD(text.lose.hardAlmost,concat(D.answer[1]))
                if Config.extraData.family[S.uid] then
                    S:delaySend(delays.send_reward,CQpic(getRnd(Config.extraData.touhouImages)))
                end
            else
                local ans1,ans2=concat(TABLE.popRandom(D.answer)),concat(TABLE.popRandom(D.answer))
                t=t..repD(text.lose.hard,ans1,ans2,#D.answer+2)
            end
        elseif D.mode=='quandle' then
            if #D.answer==1 then
                t=t..repD(text.lose.quandleAlmost,D.answer[1])
                if Config.extraData.family[S.uid] then
                    S:delaySend(delays.send_reward,CQpic(getRnd(Config.extraData.touhouImages)))
                end
            else
                local ans1,ans2=TABLE.popRandom(D.answer),TABLE.popRandom(D.answer)
                t=t..repD(text.lose.quandle,ans1,ans2,#D.answer+2)
            end
        end
        S:send(t)
    else
        local remainText
        if D.mode=='hard' and #D.answer==1 then
            remainText=text.remain.hardAlmost
        elseif D.mode=='quandle' then
            remainText=text.remain.quandle[D.stage]
        else
            remainText=text.remain[D.mode]
        end
        t=t..repD(remainText,D.chances)
        if delays.del_question then
            local mesID='abguess_history_'..math.random(262626,626262)
            S:send(t,mesID)
            ins(D.mesIDList,mesID)
            if D.mesIDList[2] then
                for i=#D.mesIDList-1,1,-1 do
                    S:delayDelete(delays.del_question,D.mesIDList[i])
                    rem(D.mesIDList,i)
                end
            end
        else
            S:send(t)
        end
    end
end

---@type Task_raw
return {
    init=function(_,D)
        D.playing=false
        D.lastInterectTime=-1e99 -- time of last answer, for reset when timeout

        D.mode=false -- 'easy' | 'hard' | 'quandle'
        D.answer={} -- {'1','2','3','4'} for Easy mode, {{'1','2','3','4'},{'5','6','7','8'},...} for Hard mode
        D.guessHis={}
        D.mesIDList={}
        D.textHis=""
        D.chances=26

        D.privOwner=false
        D.playerHis=TABLE.new(false,5)

        D.quandleLongHis={}
        D.length=5
        D.stage=1
        D.repPoint=0
        for i=1,10 do D.quandleLongHis[i]={} end
    end,
    func=function(S,M,D)
        ---@cast M LLOneBot.Event.GroupMessage
        -- Log
        local mes=SimpStr(M.raw_message)
        if #mes>=12.6 then return false end

        local privGame=false
        if mes:sub(1,2)=='##' then
            mes=mes:sub(2)
            privGame=true
        end

        local quandleLength
        if mes:match('^#%D+%d+$') then
            quandleLength=tonumber(mes:match('%d+'))
            mes=mes:match('%D+')
        end

        if keyword.help[mes] then
            if S:lock('guess_help',26) then
                S:send(mes:find('qd') and text.helpQD or text.helpAB)
            end
            if delays.del_help and Config.groupManaging[S.id] then
                S:delayDelete(delays.del_help,M.message_id)
            end
            return true
        elseif mes=='#abandon' or mes=='#quitom' then
            if not D.playing then
                if S:lock('guess_abandon',26) then
                    S:send(getRnd(text.gameNotStarted))
                end
                return true
            end
            if D.privOwner and M.user_id~=D.privOwner then
                if S:lock('guess_priv',12.6) then
                    S:send(getRnd(text.abandonOthers))
                end
                return true
            end
            D.playing=false
            S:lock('guess_abandon',26)
            if D.mode=='easy' then
                S:send(repD(text.forfeit.easy,concat(D.answer)))
            elseif D.mode=='hard' then
                if #D.answer==1 then
                    S:send(repD(text.forfeit.hardAlmost,concat(D.answer[1])))
                    if D.chances>=2 then
                        S:send(CQpic(getRnd(Config.extraData.touhouImages)))
                    end
                else
                    local ans1,ans2=concat(TABLE.popRandom(D.answer)),concat(TABLE.popRandom(D.answer))
                    S:send(repD(text.forfeit.hard,ans1,ans2,#D.answer+2))
                end
            elseif D.mode=='quandle' then
                S:send(repD(text.forfeit.quandle,getRnd(D.answer):lower(),#D.answer))
            end
            S:unlock('guess_help')
            S:unlock('guess_playing')
            S:unlock('guess_cd')
            S:unlock('guess_duplicate')
            D.lastInterectTime=Time()-cooldownSkip.giveup
            if delays.del_abandon and Config.groupManaging[S.id] then
                S:delayDelete(delays.del_abandon,M.message_id)
            end
            return true
        elseif keyword.start[mes] then
            -- Start
            local timeSkip=Time()-D.lastInterectTime
            if D.playing and timeSkip<600 then
                if S:lock('guess_playing',62) then
                    sendMes(S,M,D,'notFinished')
                end
                return true
            end
            if not Config.safeSessionID[S.uid] and S.group and not AdminMsg(M) and timeSkip<cooldown then
                local timeRemain=cooldown-timeSkip+10
                if timeRemain<60 then
                    if S:lock('guess_cd',26) then
                        S:send(repD("再等$1秒就能开局了喵",math.ceil(timeRemain)))
                    end
                else
                    if S:lock('guess_cd',62) then
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
                    if S:lock('guess_privLimit',26) then
                        S:send(getRnd(text.privLimit))
                    end
                    return true
                end
            end
            ins(D.playerHis,1,player)
            D.playerHis[6]=nil

            D.privOwner=player
            D.playing=true
            D.mode=keyword.start[mes]
            D.guessHis={}
            D.textHis=""
            if D.mode=='easy' then
                D.chances=6
                D.answer=randomGuess()
                guess(D,randomGuess(D.mode=='easy' and D.answer))
            elseif D.mode=='hard' then
                D.chances=6
                D.answer=copy(hardLib,0)
                local r=getRnd(rules)
                local newAns={}
                for i=1,#D.answer do
                    if r.rule(concat(D.answer[i])) then
                        ins(newAns,D.answer[i])
                    end
                end
                assert(#newAns>0,"No answer after rule filter "..r.id)
                D.answer=newAns
                D.textHis=r.text.."\n"
                guess(D,getRnd(hardLib))
            elseif D.mode=='quandle' then
                initQuandleLib()
                D.chances=D.length<=6 and 6 or 5
                D.length=MATH.clamp(math.floor(quandleLength or MATH.randFreq({0,0,0,2,6,5,3,2,1,1})),4,10)
                D.repPoint=0
                D.stage=1

                D.answer={}
                TABLE.connect(D.answer,quandleLib.cet4[D.length])
                TABLE.connect(D.answer,quandleLib.cet6[D.length])
            end
            sendMes(S,M,D,'start')
            D.lastInterectTime=Time()
            if delays.del_start and Config.groupManaging[S.id] then
                S:delayDelete(delays.del_start,M.message_id)
            end
            return true
        elseif D.playing then
            mes=mes:upper()
            if D.mode=='easy' or D.mode=='hard' then
                if #mes~=4 or mes:find('[^ZSJLTOI]') then return false end
            elseif D.mode=='quandle' then
                if #mes~=D.length or mes:find('[^A-Z]') then return false end
                if not quandleLib.fullHash[mes] then
                    if S:lock('guess_notWord',12.6) then
                        S:send(getRnd(text.quandleNotWord))
                    else
                        S:send(getRnd(text.quandleNotWord2))
                    end
                    return true
                end
            end
            if D.privOwner and M.user_id~=D.privOwner then
                if S:lock('guess_priv',12.6) then
                    S:send(getRnd(text.privBlocked))
                end
                return true
            end

            local res=guess(D,STRING.atomize(mes))
            if res=='duplicate' then
                -- Duplicate
                local mesID='abguess_duplicate_'..math.random(262626,626262)
                if S:lock('guess_duplicate',12.6) then
                    S:send(getRnd(text.guessed),mesID)
                    D.lastInterectTime=Time()
                    if delays.del_duplicate and Config.groupManaging[S.id] then
                        S:delayDelete(delays.del_duplicate,mesID)
                        S:delayDelete(delays.del_duplicate,M.message_id)
                    end
                end
            else
                -- Available guess
                if res=='win' then
                    -- Win
                    D.playing=false
                    S:lock('guess_abandon',26)
                    sendMes(S,M,D,'win')
                    S:unlock('guess_help')
                    S:unlock('guess_playing')
                    S:unlock('guess_cd')
                    S:unlock('guess_duplicate')
                    D.lastInterectTime=Time()-cooldownSkip.win
                    if delays.del_win and Config.groupManaging[S.id] then
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
                    if delays.del_normal and Config.groupManaging[S.id] then
                        S:delayDelete(delays.del_normal,M.message_id)
                    end
                else
                    -- Lose
                    D.playing=false
                    S:lock('guess_abandon',26)
                    sendMes(S,M,D,'lose')
                    S:unlock('guess_help')
                    S:unlock('guess_playing')
                    S:unlock('guess_cd')
                    S:unlock('guess_duplicate')
                    D.lastInterectTime=Time()-cooldownSkip.lose
                    if delays.del_lose and Config.groupManaging[S.id] then
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
