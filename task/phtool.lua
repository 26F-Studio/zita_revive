---@type table<string,{help:string, func:fun(args:string[]):string?|string}>
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
    help="旗语转换，qweadzxc表示方向\n/flag zxDC → aZ",
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
    help="字母补集\n/inv aeiou → [辅音字母]",
    func=function(args)
        local res='aeiou bcdfghjklmnpqrstvwxyz'
        for c in args[1]:gmatch('%a') do
            res=res:gsub(c,'')
        end
        return res
    end,
}

local mathEnv=setmetatable({},{__index=math})
tools['/calc']={
    help="计算器\n/calc 1+1 → 2",
    func=function(args)
        local expr=table.concat(args," ")
        if expr:match("while") or expr:match("for") then return "不许捣乱哦~" end
        if expr:match("repeat") or expr:match("function") then return "你想干什么喵？" end
        if expr:match("[\"\']") or expr:match("%[%[") or expr:match("%[=") or expr:match("%.%.") then return "你是坏人。" end
        local f=loadstring('return '..expr) or loadstring(expr)
        if not f then return "算式格式有误！" end
        TABLE.clear(mathEnv)
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
    help="摩斯电码\n/morse .... . .-.. .-.. --- → HELLO",
    func=function(args)
        local res=""
        for i=1,#args do
            res=res..(morseData[args[i]] or '?')
        end
        return res
    end,
}

tools['/ranksim']={
    help="qp2等级模拟（无流失保护）\n/ranksim rank xp [frames=600]",
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

---@type Task_raw
return {
    func=function(S,M)
        -- Log
        local args=STRING.split(STRING.trim(RawStr(M.raw_message)),' ')
        local tool=tools[table.remove(args,1)]
        if tool then
            if #args==0 then
                S:send(tool.help)
            else
                local res=tool.func(args)
                S:send(res and tostring(res) or "[无输出结果]")
            end
        end
        return false
    end,
}
