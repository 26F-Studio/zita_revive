---@type table<string,{help:string, func:fun(args:string[], M:OneBot.Event.Message):any}>
local tools={}

local flagData={}
for i,str in next,STRING.split('xz xa xq xw xe xd xc za zq wd zw ze zd zc aq aw ae ad ac qw qe wc ed ec qd dc',' ') do
    flagData[str]=string.char(96+i)
    flagData[str:reverse()]=string.char(96+i)
    flagData[str:upper()]=string.char(64+i)
    flagData[str:reverse():upper()]=string.char(64+i)
end
flagData['xx'],flagData['XX']=' ',' '
tools['/flag']={
    help="旗语转换，qweadzxc表示方向\n例：/flag zxDC\n→ aZ",
    func=function(args)
        local res=""
        for i=1,#args do
            for ch in args[i]:gmatch('..') do
                res=res..(flagData[ch] or '?')
            end
        end
        return res
    end,
}

tools['/inv']={
    help="字母补集\n例：/inv aeiou\n→ [剩下21个辅音字母]",
    func=function(args)
        local res='aeiou bcdfghjklmnpqrstvwxyz'
        for c in args[1]:gmatch('%a') do
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
tools['/calc']={
    help="计算器\n例：/calc 1+1\n→ 2",
    func=function(args)
        local expr=table.concat(args," ")
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
tools['/morse']={
    help="摩斯电码\n例：/morse .... . .-.. .-.. ---\n→ HELLO",
    func=function(args)
        local res=""
        for i=1,#args do
            res=res..(morseData[args[i]] or '?')
        end
        return res
    end,
}

tools['/ranksim']={
    help="qp2等级模拟（无流失保护）\n例：/ranksim rank xp [frames=600]",
    func=function(args)
        local rank,xp=tonumber(args[1]),tonumber(args[2])
        if not (rank and xp) then return "rank和xp需要数字" end

        local steps=math.min(tonumber(args[3]) or 600, 1000)
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

tools['/react']={
    help="创建一些无法正常发送的emoji回应，部分可收集表情+1两次就会进入“最近使用”\n例：/react 36,💣\n内置表情只支持单个，否则最多五个",
    func=function(args,M)
        local cqFace=args[1]:match('id=(%d+)')
        if cqFace then
            Bot.sendEmojiReact(M.message_id,tonumber(cqFace))
        else
            local list=STRING.split(args[1],',')
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

---@type Task_raw
return {
    message=function(S,M)
        -- Log
        local args=STRING.split(STRING.trim(RawStr(M.raw_message)),' ')
        local tool=tools[table.remove(args,1)]
        if tool then
            if #args==0 then
                S:send(tool.help)
            else
                local res=tool.func(args,M)
                if res then S:send(res) end
            end
        end
        return false
    end,
}
