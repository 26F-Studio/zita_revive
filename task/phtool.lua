local flagData={}
for i,str in next,STRING.split('xz xa xq xw xe xd xc za zq wd zw ze zd zc aq aw ae ad ac qw qe wc ed ec qd dc',' ') do
    flagData[str]=string.char(96+i)
    flagData[str:reverse()]=string.char(96+i)
    flagData[str:upper()]=string.char(64+i)
    flagData[str:reverse():upper()]=string.char(64+i)
end
flagData['xx'],flagData['XX']=' ',' '

---@type table<string,fun(S:Session,args:string[]):string?|string>
local tools={
    ['/flag']=function(args)
        local res=""
        for i=1,#args do
            for ch in args[i]:gmatch('..') do
                res=res..(flagData[ch] or '?')
            end
        end
        return res
    end,['/旗语']="/flag",
}
TABLE.reIndex(tools)
---@type Task_raw
return {
    func=function(S,M)
        -- Log
        local args=STRING.split(STRING.trim(RawStr(M.raw_message)),' ')
        local tool=tools[table.remove(args,1)]
        if tool then
            local res=tool(args)
            S:send(res and tostring(res) or "[无输出结果]")
        end
        return false
    end,
}
