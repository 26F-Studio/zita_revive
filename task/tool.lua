---@type table<string,{help:string, func:fun(data:string, M:OneBot.Event.Message):any}>
local tools={}

local flagData={}
for i,str in next,STRING.split('xz xa xq xw xe xd xc za zq wd zw ze zd zc aq aw ae ad ac qw qe wc ed ec qd dc',' ') do
    flagData[str]=string.char(96+i)
    flagData[str:reverse()]=string.char(96+i)
    flagData[str:upper()]=string.char(64+i)
    flagData[str:reverse():upper()]=string.char(64+i)
end
flagData['xx'],flagData['XX']=' ',' '
tools.flag={
    help="旗语转换，qweadzxc表示方向\n例：#flag zxDC\n→ aZ",
    func=function(data)
        local segs=STRING.split(data,' ')
        local res=""
        for i=1,#segs do
            for ch in segs[i]:gmatch('..') do
                res=res..(flagData[ch] or '?')
            end
        end
        return res
    end,
}

local morseData={
    ['.-']='A',
    ['-...']='B',
    ['-.-.']='C',
    ['-..']='D',
    ['.']='E',
    ['..-.']='F',
    ['--.']='G',
    ['....']='H',
    ['..']='I',
    ['.---']='J',
    ['-.-']='K',
    ['.-..']='L',
    ['--']='M',
    ['-.']='N',
    ['---']='O',
    ['.--.']='P',
    ['--.-']='Q',
    ['.-.']='R',
    ['...']='S',
    ['-']='T',
    ['..-']='U',
    ['...-']='V',
    ['.--']='W',
    ['-..-']='X',
    ['-.--']='Y',
    ['--..']='Z',
    ['-----']='0',
    ['.----']='1',
    ['..---']='2',
    ['...--']='3',
    ['....-']='4',
    ['.....']='5',
    ['-....']='6',
    ['--...']='7',
    ['---..']='8',
    ['----.']='9',
    ['.-.-.-']='.',
    ['--..--']=',',
    ['---...']=':',
    ['..--..']='?',
    ['.----.']='\'',
    ['-....-']='-',
    ['-..-.']='/',
    ['-.--.']='(',
    ['-.--.-']=')',
    ['.-...']='&',
    ['---.']='!',
    ['.-.-.']='+',
    ['.-..-.']='"',
    ['.--.-.']='@',
}
tools.morse={
    help="摩斯电码\n例：#morse .... . .-.. .-.. ---\n→ HELLO",
    func=function(data)
        local segs=STRING.split(data,' ')
        local res=""
        for i=1,#segs do
            res=res..(morseData[segs[i]] or '?')
        end
        return res
    end,
}

tools.inv={
    help="字母补集\n例：#inv aeiou\n→ [剩下21个辅音字母]",
    func=function(data)
        local res='aeiou bcdfghjklmnpqrstvwxyz'
        for c in data:gmatch('%a') do
            res=res:gsub(c,'')
        end
        return res
    end,
}

local syntaxError={
    "算式没写对喵",
    "格式有问题喵",
    "你的式子写错了喵",
    "没懂喵？检查一下格式",
}
local banPattern={
    ["function"]={"害怕栈溢出喵…","会写这个就去自己写程序喵！"},
    ["while"]={"害怕无限循环喵…","计算器为什么要循环喵？"},
    ["for"]={"算数还要用到for喵？","你不许for喵"},
    ["repeat"]={"我只听说过while喵","repeat？那是什么喵"},
    ["goto"]={"珍爱生命，远离goto","意大利面不好吃喵！","goto一时爽…"},
    ["[\"\']"]={"计算器只能算数字喵！","你只许算数字喵！","字符串是人家的隐私喵"},
    ["%[%["]={"你是坏人。","盯……是不是多打了一个[呀","盯……是不是多打了一个[呀","盯……是不是多打了一个[呀"},
    ["%[="]={"你是坏人。","等于号不能这么用喵（装傻","等于号不能这么用喵（装傻","等于号不能这么用喵（装傻"},
    ["%.%."]={"你是坏人。","你不许点点","你不许点点","你不许点点"},
}
local mathEnv=setmetatable({},{__index=math})
tools.calc={
    help="计算器\n例：#calc 1+1\n→ 2",
    func=function(expr)
        local f=loadstring('return '..expr) or loadstring(expr)
        if not f then return TABLE.getRandom(syntaxError) end
        for k,v in next,banPattern do if expr:match(k) then return TABLE.getRandom(v) end end
        TABLE.clear(mathEnv)
        mathEnv.math=mathEnv
        setfenv(f,mathEnv)
        local suc,res=pcall(f)
        if not suc then return "计算过程出错: "..(res:match(".+%d:(.+)") or res) end
        return '='..tostring(res)
    end,
}

tools.react={
    help="创建一些无法正常发送的表情回应，部分点击+1即可进入“最近使用”\n例：#react 36,💣\n内置表情只支持单个，否则最多五个",
    func=function(data,M)
        local cqFace=data:match('id=(%d+)')
        if cqFace then
            Bot.sendEmojiReact(M.message_id,tonumber(cqFace))
        else
            local list=STRING.split(data,',')
            local count=1
            for i=1,#list do
                local sec=list[i]
                Bot.sendEmojiReact(M.message_id,tonumber(sec) or STRING.u8byte(sec))
                if count>=5 then break end
                count=count+1
            end
        end
    end,
}

tools.ranksim={
    help="qp2等级模拟（无流失保护）\n例：#ranksim rank xp [frames=600]",
    func=function(data)
        local params=STRING.split(data,' ')
        local rank,xp=tonumber(params[1]),tonumber(params[2])
        if not (rank and xp) then return "rank和xp需要数字" end

        local steps=math.min(tonumber(params[3]) or 600, 1000)
        for _=1,steps do
            local tr=math.floor(rank)
            xp=xp-3*(tr^2+tr)/3600

            local nextRankXP=4*tr
            local storedXP=4*(tr-1)
            if xp<0 then
                if tr<=1 then
                    xp=0
                else
                    xp=xp+storedXP
                    tr=tr-1
                end
            elseif xp>=nextRankXP then
                xp=xp-nextRankXP
                tr=tr+1
            end
            rank=tr+xp/(4*tr)
        end
        return ("%d帧后为%.2f级%.1f经验"):format(steps,rank,xp)
    end,
}

local ins,rem=table.insert,table.remove
local precedence={['|']=1,['&']=2}
local pieceList={Z="1",J="2",T="3",I="4",O="5",L="6",S="7"}
---@param expr string contains letters & | ( )
local function infixToPostfix(expr)
    assert(expr:match('^[1-7|&()]+$'),"检测到未知字符，只能包含：块 & | ( )")
    assert(STRING.count(expr,'%(')==STRING.count(expr,'%)'),"括号数量不匹配")

    local pff,opStack={},{}

    local i=1
    while i<=#expr do
        local token=expr:sub(i,i)
        if token:match('%d') then
            local buffer=expr:match('%d+',i)
            assert(#buffer>=2,"块需要至少两个")
            for j=1,#buffer-1 do ins(pff,buffer:sub(j,j+1)) end
            for _=1,#buffer-2 do ins(pff,'&') end
            i=i+#buffer-1
        elseif token=='|' or token=='&' then
            while #opStack>0 and opStack[#opStack]~='(' and
                precedence[opStack[#opStack]]>=precedence[token] do
                ins(pff,rem(opStack))
            end
            ins(opStack,token)
        elseif token=='(' then
            ins(opStack,token)
        elseif token==')' then
            while #opStack>0 and opStack[#opStack]~='(' do
                ins(pff,rem(opStack))
            end
            rem(opStack) -- pop '('
        end
        i=i+1
    end
    while #opStack>0 do ins(pff,rem(opStack)) end

    return pff
end
local perm7,perm7inv
local validCache={}
local holdableCache={}
local pffb={} -- PostFix Formula Buffer
local stack={}
local function arrMatch(arr,sub)
    return not not arr:find(sub:sub(1,1)..".*"..sub:sub(2))
end
local function checkConstrain(arr,pff)
    TABLE.clear(pffb)
    TABLE.clear(stack)
    pffb=TABLE.append(pffb,pff)
    for i=1,#pffb do
        if #pffb[i]==2 then
            ins(stack,pffb[i])
        elseif pffb[i]=='&' then
            local b=rem(stack)
            local a=rem(stack)
            if a==false or b==false then
                ins(stack,false)
            else
                if type(a)=='string' then a=arrMatch(arr,a) end
                if type(b)=='string' then b=arrMatch(arr,b) end
                ins(stack,a and b)
            end
        elseif pffb[i]=='|' then
            local b=rem(stack)
            local a=rem(stack)
            if a==true or b==true then
                ins(stack,true)
            else
                if type(a)=='string' then a=arrMatch(arr,a) end
                if type(b)=='string' then b=arrMatch(arr,b) end
                ins(stack,a or b)
            end
        end
    end
    if type(stack[1])=='string' then stack[1]=arrMatch(arr,stack[1]) end
    return stack[1]
end
local function checkHoldPossibility(base)
    for j=1,63 do
        local b=base
        if j%0002>=1 then b=b:sub(2,2)..b:sub(1,1)..b:sub(3) end
        if j/02%2>=1 then b=b:sub(1,1)..b:sub(3,3)..b:sub(2,2)..b:sub(4) end
        if j/04%2>=1 then b=b:sub(1,2)..b:sub(4,4)..b:sub(3,3)..b:sub(5) end
        if j/08%2>=1 then b=b:sub(1,3)..b:sub(5,5)..b:sub(4,4)..b:sub(6) end
        if j/16%2>=1 then b=b:sub(1,4)..b:sub(6,6)..b:sub(5,5)..b:sub(7) end
        if j/32%2>=1 then b=b:sub(1,5)..b:sub(7,7)..b:sub(6,6) end
        if validCache[perm7inv[b]] then return true end
    end
end
tools.cover={
    help="序列覆盖率计算\n例：#cover ZTS & (jol|loj) & ...\n→ 可行序列数/5040 (搭建率, 无暂存序列数)",
    func=function(expr)
        expr=expr:gsub('%s+','')
        expr=expr:upper():gsub("[ZSJLTOI]",pieceList)
        local suc,pff=pcall(infixToPostfix,expr)
        if not suc then return pff end

        if not perm7 then
            perm7=STRING.split(FILE.load('data/perm7.txt'),'\n')
            perm7inv=TABLE.inverse(perm7)
        end
        for i=1,#perm7 do validCache[i]=checkConstrain(perm7[i],pff) end
        for i=1,#perm7 do
            holdableCache[i]=validCache[i] or checkHoldPossibility(perm7[i])
        end
        local noholdCnt=TABLE.count(validCache,true)
        local holdCnt=TABLE.count(holdableCache,true)
        return ("%d/%d (%.4g%%, 📵%d)"):format(holdCnt,#perm7, holdCnt/#perm7*100, noholdCnt)
    end,
}

tools.tool={
    help="实用小工具：\n"..table.concat(TABLE.getKeys(tools)," "),
}

---@type Task_raw
return {
    message=function(S,M)
        local cmd,data=RawStr(M.raw_message):match('^#(%S+)%s*(.*)')
        local tool=tools[cmd]
        if tool then
            if not data or #data==0 then
                S:send(tool.help)
            elseif tool.func then
                local res=tool.func(data,M)
                if res then S:send(res) end
            end
        end
        return false
    end,
}
