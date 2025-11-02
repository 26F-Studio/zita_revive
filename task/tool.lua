local stepLimit=2e6
local function hook() error('timeout') end
local timeoutError={
    "是不是有个死循环？",
    "资源耗尽算不动了喵",
    "运行超过两百万步了喵",
    "过于昂贵！",
}

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

local mathSyntaxError={
    "算式没写对喵",
    "格式有问题喵",
    "你的式子写错了喵",
    "没懂喵？检查一下格式",
}
local mathBanPattern={
    ["function"]={"害怕栈溢出喵…","会写这个就去自己写程序喵！"},
    -- ["while"]={"害怕无限循环喵…","计算器为什么要循环喵？"},
    -- ["for"]={"算数还要用到for喵？","你不许for喵"},
    -- ["repeat"]={"我只听说过while喵","repeat？那是什么喵"},
    -- ["goto"]={"珍爱生命，远离goto","意大利面不好吃喵！","goto一时爽…"},
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
        if not f then return TABLE.getRandom(mathSyntaxError) end
        for k,v in next,mathBanPattern do if expr:match(k) then return TABLE.getRandom(v) end end
        TABLE.clear(mathEnv)
        mathEnv.math=mathEnv
        setfenv(f,mathEnv)
        jit.off(f)

        local thread=coroutine.create(f)
        debug.sethook(thread,hook,'',stepLimit)
        local suc,res=coroutine.resume(thread)
        debug.sethook()

        return not suc and (
            res:find('timeout') and TABLE.getRandom(timeoutError)
            or "计算过程出错: "..(res:match(".+%d:(.+)") or res)
        ) or "= "..tostring(res)
    end,
}

tools.react={
    help="创建一些无法正常发送的表情回应，部分点击+1即可进入“最近使用”\n例：#react 36,💣\n内置表情只支持单个，否则最多五个",
    func=function(data,M)
        local cqFace=data:match('id=(%d+)')
        if cqFace then
            Bot.reactMessage(M.message_id,tonumber(cqFace))
        else
            local list=STRING.split(data,',')
            local count=1
            for i=1,#list do
                local sec=list[i]
                Bot.reactMessage(M.message_id,tonumber(sec) or STRING.u8byte(sec))
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
    help="序列覆盖率计算\n例：#cover zts & (JOL|LOJ) & ...\n→ 可行序列数/5040 (搭建率, 无暂存序列数)",
    func=function(expr)
        expr=expr:gsub('%s+',''):upper():gsub("[ZSJLTOI]",pieceList)
        local suc,pff=pcall(infixToPostfix,expr)
        if not suc then return pff end

        if not perm7 then
            perm7=STRING.split(FILE.load('data/perm7.txt'),'\n')
            perm7inv=TABLE.inverse(perm7)
        end
        for i=1,#perm7 do validCache[i]=checkConstrain(perm7[i],pff) end
        for i=1,#perm7 do holdableCache[i]=validCache[i] or checkHoldPossibility(perm7[i]) end
        local noholdCnt=TABLE.count(validCache,true)
        local holdCnt=TABLE.count(holdableCache,true)
        return ("%d/%d (%.4g%%, 📵%d)"):format(holdCnt,#perm7, holdCnt/#perm7*100, noholdCnt)
    end,
}

local drawSyntaxError={
    "指令没写对喵",
    "格式有问题喵",
    "你的指令写错了喵",
    "没懂喵？检查一下格式",
}
local drawBanPattern={
    ["function"]="自定义函数有安全风险喵…",
    -- ["while"]="循环有安全风险喵",
    -- ["for"]="循环有安全风险喵",
    -- ["repeat"]="循环有安全风险喵",
    -- ["goto"]="珍爱生命，远离goto",
    ["[\"\']"]="字符串应该是用不到的喵",
    ["%[%["]="你是坏人。",
    ["%[="]="你是坏人。",
    ["%.%."]="你是坏人。",
}
local tempCanvas ---@type love.Canvas
local tempCoord=love.math.newTransform()
local drawBaseEnv={
    清=GC.clear,
    归=function() tempCoord:reset() GC.replaceTransform(tempCoord) end,
    移=function(...) tempCoord:translate(...) GC.replaceTransform(tempCoord) end,
    倍=function(...) tempCoord:scale(...) GC.replaceTransform(tempCoord) end,
    转=function(...) tempCoord:rotate(...) GC.replaceTransform(tempCoord) end,
    色=GC.setColor,
    宽=GC.setLineWidth,
    线=GC.line,
    方=function(...) GC.rectangle('fill',...) end,
    框=function(...) GC.rectangle('line',...) end,
    圆=function(...) GC.circle('fill',...) end,
    圈=function(...) GC.circle('line',...) end,
    形=function(...) GC.polygon('fill',...) end,
    围=function(...) GC.polygon('line',...) end,
    椭圆=function(...) GC.ellipse('fill',...) end,
    椭圈=function(...) GC.ellipse('line',...) end,

    饼=function(...) GC.arc('fill',...) end,
    线饼=function(...) GC.arc('line',...) end,
    弧=function(...) GC.arc('fill','open',...) end,
    线弧=function(...) GC.arc('line','open',...) end,
    弓=function(...) GC.arc('fill','closed',...) end,
    线弓=function(...) GC.arc('line','closed',...) end,
}
TABLE.update(drawBaseEnv,math)
local drawEnv=setmetatable({},{__index=drawBaseEnv})
tools.draw={
    help="指令绘图，500px画布，可用指令：清 归/移/倍/转 色/宽 线 方/框 (椭)圆/圈 形/围 (线)饼/弧/弓，return指定区域（XYWH或者WH）来输出图片\n例：#draw 清(0,0,0) 色(1,0,1) 方(0,0,20,20) 方(20,20,20,20) return 0,0,40,40",
    func=function(expr,M)
        if TASK.getLock('tool_draw') then return Bot.reactMessage(M.message_id,Emoji.snail) end
        local f=loadstring(expr)
        if not f then return TABLE.getRandom(drawSyntaxError) end
        for k,v in next,drawBanPattern do if expr:match(k) then return v end end
        for k in next,drawBaseEnv do drawEnv[k]=nil end
        setfenv(f,drawEnv)
        jit.off(f)

        if not tempCanvas then tempCanvas=GC.newCanvas(500,500) end

        GC.setCanvas(tempCanvas)
        GC.replaceTransform(tempCoord)

        local thread=coroutine.create(f)
        debug.sethook(thread,hook,'',stepLimit)
        local suc,x,y,w,h=coroutine.resume(thread)
        debug.sethook()

        GC.setCanvas()

        if not suc then
            return x:find('timeout') and TABLE.getRandom(timeoutError) or "执行过程出错: "..(x:match(".+%d:(.+)") or x)
        end
        if x then
            TASK.lock('tool_draw',26)
            x=MATH.clamp(tonumber(x) or 0,0,499)
            y=MATH.clamp(tonumber(y) or 0,0,499)
            if w then
                return Bot.canvasToImage(tempCanvas,x,y,MATH.clamp(tonumber(w) or 500,0,500-x),MATH.clamp(tonumber(h) or 500,0,500-y))
            else
                return Bot.canvasToImage(tempCanvas,0,0,x,y)
            end
        else
            return Bot.reactMessage(M.message_id,Emoji.check_mark_button)
        end
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
        if not tool then return false end

        if not data or #data==0 then
            S:send(tool.help)
        elseif tool.func then
            local res=tool.func(data,M)
            if res then S:send(res) end
        end
        return true
    end,
}
