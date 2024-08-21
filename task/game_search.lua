local tags="热门 电脑 手机 主机 网页 键盘 触屏 鼠标 单人 多人 快速 慢速 无延迟 延迟 题库 新人"
local tagRedirect={
    ["热"]="热门",
    ["pc"]="电脑",["pe"]="手机",["web"]="网页",
    ["键"]="键盘",["触"]="触屏",["鼠"]="鼠标",
    ["单"]="单人",["多"]="多人",["联"]="多人",
    ["快"]="快速",["慢"]="慢速",
    ["无延"]="无延迟",["延"]="延迟",
    ["题"]="题库",["新"]="新人",

    ["电脑版"]="电脑",["手机版"]="手机",
    ["浏览器"]="网页",["网页版"]="网页",
    ["单机"]="单人",["对战"]="多人",["联机"]="多人",["联网"]="多人",
    ["无延迟块"]="无延迟",["延迟块"]="延迟",
}
local gameData={
    -- 多人（热）
    {name="tech",        tags="热门 电脑 手机 键盘 触屏 单人 多人 快速 无延迟 慢速 延迟块 新人"},
    {name="io",          tags="热门 电脑 网页 单人 多人 键盘 快速 无延迟 新人"},
    {name="js",          tags="热门 电脑 手机 网页 单人 多人 键盘 触屏 快速 无延迟 新人"},
    {name="tec",         tags="热门 电脑 主机 单人 多人 键盘 鼠标 慢速 延迟块 新人"},

    -- 单机（热）
    {name="aqua",        tags="热门 电脑 键盘 单人 快速 无延迟 慢速 延迟块"},
    {name="tetrjs",      tags="热门 电脑 手机 网页 单人 键盘 触屏 快速 无延迟 慢速 延迟块 新人"},
    {name="tgm",         tags="热门 电脑 单人 键盘 快速 延迟"},
    {name="tl",          tags="热门 电脑 网页 单人 键盘 快速 无延迟 慢速 延迟块"},
    {name="asc",         tags="热门 电脑 网页 单人 键盘 快速 无延迟 慢速 延迟块"},
    {name="np",          tags="热门 电脑 单人 键盘 快速 无延迟 慢速 延迟块"},
    {name="misa",        tags="热门 电脑 单人 键盘 慢速 无延迟"},
    {name="touhoumino",  tags="热门 电脑 单人 键盘 慢速 延迟块 快速 无延迟"},
    {name="royale",      tags="热门 手机 单人 触屏 快速 无延迟 慢速 延迟块"},

    -- 主机
    {name="ppt",         tags="热门 电脑 主机 单人 多人 键盘 慢速 延迟块"},
    {name="t99",         tags="热门 主机 单人 多人 慢速 延迟块"},

    -- 单机（冷）
    {name="mind bender", tags="电脑 手机 网页 单人 键盘 触屏 鼠标 慢速 延迟块"},
    {name="gems",        tags="电脑 手机 网页 单人 键盘 触屏 鼠标 慢速 延迟块"},
    {name="tetris.com",  tags="电脑 手机 网页 单人 键盘 触屏 鼠标 慢速 延迟块"},
    {name="dtet",        tags="电脑 单人 键盘 快速 无延迟"},
    {name="cambridge",   tags="电脑 单人 键盘 快速 无延迟 慢速 延迟块"},
    {name="hebo",        tags="电脑 单人 键盘 快速 无延迟"},
    {name="texmaster",   tags="电脑 单人 键盘 快速 无延迟"},
    {name="tetris beat", tags="手机 单人 触屏 快速 无延迟 慢速 延迟块"},

    -- 多人（冷）
    {name="kos",         tags="电脑 手机 网页 单人 多人 键盘 触屏 鼠标 慢速 无延迟"},
    {name="to",          tags="电脑 单人 多人 键盘 快速 无延迟"},
    {name="c2",          tags="电脑 单人 多人 键盘 快速 无延迟"},
    {name="nuke",        tags="电脑 网页 单人 多人 键盘 慢速 延迟块"},
    {name="wwc",         tags="电脑 网页 单人 多人 键盘 快速 无延迟 慢速 延迟块"},
    {name="tf",          tags="电脑 网页 单人 多人 键盘 快速 无延迟 慢速 延迟块"},
    {name="jj",          tags="手机 单人 多人 触屏 快速 无延迟"},
    -- {name="fl",          tags="电脑 手机 网页 键盘 触屏 单人 多人 经典 现代 快速 无延迟 慢速 延迟块"},-- 目前好像上不去

    -- 题库
    {name="ttt",         tags="热门 电脑 网页 单人 键盘 题库"},
    {name="ttpc",        tags="热门 电脑 网页 单人 键盘 题库"},
    {name="tpo",         tags="电脑 网页 单人 键盘 题库"},
    {name="nazo",        tags="电脑 网页 单人 键盘 题库"},
}

---@type Task_raw
return {
    func=function(S,M)
        local words=STRING.split(STRING.trim(RawStr(M.raw_message)),'%s+',true)
        for i=1,#words do
            MSG.new('info',words[i])
        end
        if not (words[1]=="#游戏" or words[1]=="#game") then return false end
        table.remove(words,1)
        if #words==0 then
            if S:lock('game_search_help',26) then
                S:send("发送“#游戏 标签1 标签2…”来寻找你能接受的方块游戏，可用的tag："..tags)
            end
        else
            if not S:lock('game_search',6.26) then return true end
            if not S:costCharge(126) then
                if S:forceLock('searchCharge',26) then S:send("词典能量耗尽！请稍后再试喵") end
                return true
            end

            -- Remove too long words
            for i=#words,1,-1 do
                if #words[i]>=10 then
                    table.remove(words,i)
                elseif tagRedirect[words[i]] then
                    words[i]=tagRedirect[words[i]]
                end
            end

            -- Remove too many words
            while #words>10 do
                table.remove(words)
            end

            -- Remove invalid tags
            local filtered=false
            for i=#words,1,-1 do
                if not tags:find(words[i]) then
                    table.remove(words,i)
                    filtered=true
                end
            end

            if #words==0 then
                S:send("没有有效标签喵，发送“#游戏”查看帮助")
                return true
            end

            local results={}
            for _,game in next,gameData do
                local available=true
                for _,word in next,words do
                    if not game.tags:find(word) then
                        available=false
                        break
                    end
                end
                if available then
                    table.insert(results,game.name)
                end
            end

            if #results==0 then
                S:send("没有符合条件的游戏喵…")
            else
                local count=#results
                if count>10 then
                    results=TABLE.sub(results,1,10)
                end
                local resultStr=STRING.repD("找到了$1个游戏，使用#[名称]查看详细信息：\n$2",count,table.concat(results,", "))
                if count>10 then resultStr="(只显示前十个)"..resultStr end
                if filtered then resultStr="(忽略无效标签)"..resultStr end
                S:send(resultStr)
            end
        end
        return true
    end,
}
