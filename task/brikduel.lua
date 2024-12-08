local ins,rem=table.insert,table.remove

local repD,trimIndent=STRING.repD,STRING.trimIndent

local cell={
    norm={[0]="       ","🟥","🟩","🟦","🟧","🟪","🟨","🟫"," ⛝ "}, -- [0] 5d2c
    emoji={[0]="　 ","🈲","🈚","🚸","🈯","💠","♿️","💟","🔳"}, -- [0] 1n1h
    hanX={[0]="　","囜","囡","团","団","囚","回","囬","囗"},
    hanY={[0]="　","园","圃","囦","囷","圙","圐","圊","囧"},
}
local keyword={
    accept=TABLE.getValueSet{"接受","同意","accept","ok"},
    cancel=TABLE.getValueSet{"算了","不打了","算了不打了","睡了","走了","溜了"},
    forfeit=TABLE.getValueSet{"gg","寄","认输","似了","死了"},
}
local texts={
    help=trimIndent[[
        #duel help 查看帮助
        #duel rule 查看规则手册
        #duel man 查看操作手册
        #duel @某人 发出决斗邀请
        #duel join [房号] 加入房间
        #duel end 取消/认输/结束
        #duel leave 离开房间（不解散）
        #duel stat 查看个人数据
        (可略作#dl，可略空格)
    ]],
    rule=trimIndent([[
        方块⚔决斗  规则手册
        控制指令可随意拼接并发送，指令表见操作手册
        当前块的位置信息不保存，必须一次性把块落到位
        SRS，场地十宽∞高，出现20垃圾行判负
        消N打N 卡块*2(不可移动) 连击+1 AC+4
        使用交换预览而非暂存(功能一致)
        传统移动撞墙计一步，快捷操作计极简步数
    ]],true),
    manual=trimIndent([[
        方块⚔决斗  操作手册
        ⌨️传统操作
            q/w:左/右移一格，可追加格数，大写Q/W移动到底
            c/C/f:顺/逆/180°旋转 x:交换预览
            d:硬降,大写软降到底，可追加目标离地高度
        👆快捷操作 [块名][朝向][位置](软降)
            块名(zsjltoi):必须从前两块里选
            朝向(0r2l):旋转到指定朝向
            位置(1~9):将方块最左列置于场地指定列，10写作0
            可选软降(数字):软降到离地指定高度而不自动硬降
            例 ir0=i块竖着在十列硬降 tl80=t块朝左软降在八九列
        每两块之间的指令中间可以插入空格作为自动检查；
        不合语法的指令不会真正执行，会提示错误信息；
    ]],true),
    emptyStat="还没有决斗过喵，新账户创建好了",
    new_selfInGame="你有一场正在进行的决斗喵，这样不是很礼貌！",
    new_opInGame="对方正在一场决斗中喵，这样不是很礼貌！",
    new_withSelf="不能和自己决斗喵，一个人玩推荐下载Techmino，发送#tech了解详情",
    new_botRefuse="我不接受喵",
    new_free="对局创建成功喵($1)\n其他人可以发送“#duel join (房间号)”来加入",
    new_room="对局创建成功喵($1)\n被邀请人快发送“$2”来正式开始",
    new_failed="对局创建失败了喵，你的运气不太好",
    join_wrongFormat="房间号格式不对喵，应该是一个数字",
    join_noRoom="不存在这个房间喵",
    join_notWait="这个房间并不在等人喵",
    room_start="对决开始！\n$1\n$2\nvs\n$3\n$4",
    room_cancel="对局($1)已取消",
    quit_nothing="你在干什么喵？",
    wrongCmd="用法详见#duel help",
}

---@type Map<Zita.BrikDuel.Duel>
local duelPool

local rng=love.math.newRandomGenerator()
rng:getState()

---@class Zita.BrikDuel.Game
---@field rngState string
---@field field Mat<number>
---@field sequence string[]
Game={}
Game.__index=Game
---@param seed number
---@return Zita.BrikDuel.Game
function Game.new(seed)
    rng:setSeed(seed)
    local game=setmetatable({
        rngState=rng:getState(),
        field={},
        sequence={},
    },Game)
    return game
end

local bag0=STRING.atomize("ZSJLTOI")
function Game:supplyNext(count)
    while #self.sequence<count do
        local bag=TABLE.copy(bag0)
        while bag[1] do
            ins(self.sequence,rem(bag,self:random(#bag)))
        end
    end
end

---@param i? number
---@param j? number
---@return number
function Game:random(i,j)
    rng:setState(self.rngState)
    local r=rng:random(i,j)
    self.rngState=rng:getState()
    return r
end

local initPosData={
    z={x=4,y=100,dir=0,ctr={x=2,y=1},mat={{0,1,1},{1,1,0}}},
    s={x=4,y=100,dir=0,ctr={x=2,y=1},mat={{1,1,0},{0,1,1}}},
    j={x=4,y=100,dir=0,ctr={x=2,y=1},mat={{1,1,1},{1,0,0}}},
    l={x=4,y=100,dir=0,ctr={x=2,y=1},mat={{1,1,1},{0,0,1}}},
    t={x=4,y=100,dir=0,ctr={x=2,y=1},mat={{1,1,1},{0,1,0}}},
    o={x=5,y=100,dir=0,ctr={x=1.5,y=1.5},mat={{1,1},{1,1}}},
    i={x=4,y=100,dir=0,ctr={x=2.5,y=-0.5},mat={{1,1,1,1}}},
}
local pieceWidth={
    z={[0]=3,2,3,2},
    s={[0]=3,2,3,2},
    j={[0]=3,2,3,2},
    l={[0]=3,2,3,2},
    t={[0]=3,2,3,2},
    o={[0]=2,2,2,2},
    i={[0]=4,1,4,1},
}
local cmdMap={
    z='pick',s='pick',j='pick',l='pick',t='pick',o='pick',i='pick',
    q='move',w='move',Q='move',W='move',
    c='rotate',C='rotate',f='rotate',
    d='drop',D='drop',
    x='swap',
    [' ']='check',
}
local buf=STRING.newBuf()
function Game:parse(str)
    buf:set(str)
    local controls={}
    local clean=true -- Whether current piece is moved
    local ctrl
    local tempSeq=TABLE.copy(self.sequence)
    local c,ptr='',0
    while true do
        c=buf:get(1) ptr=ptr+1
        assertf(tempSeq[1] or c=='','[%d]序列空了后不能有多余的指令',ptr)
        if c=='' then break end

        local cmd=cmdMap[c]
        assertf(cmd,"[%d]字符%s不能作为指令开头",ptr,c)
        if cmd=='pick' then
            -- 快捷操作
            ctrl={act='pick'}
            assertf(clean,"[%d]快捷操作时方块%s必须在初始位置",ptr,c)
            local piece=TABLE.find(tempSeq,c:upper())
            assertf(piece and piece<=2,"[%d]快捷操作时方块%s必须在序列前两个",ptr,c)
            ctrl.pID=piece
            ctrl.piece=c
            c=buf:get(1) ptr=ptr+1
            assertf(c=='0' or c=='r' or c=='2' or c=='l',"[%d]快捷操作的朝向字符错误（应为0r2l之一）",ptr)
            ctrl.dir=c=='0' and 0 or c=='r' and 1 or c=='2' and 2 or 3
            c=buf:get(1) ptr=ptr+1
            local posX=tonumber(c)
            assertf(posX and posX>=0 and posX<=9,"[%d]快捷操作的位置字符错误（应为0-9）",ptr)
            ctrl.pos=posX
            if ctrl.pos==0 then ctrl.pos=10 end
            c=buf:get(1) ptr=ptr+1
            if tonumber(c) then
                -- 软降不锁定
                clean=false
            else
                -- 默认硬降，恢复多余读取
                assertf(ctrl.pos+pieceWidth[ctrl.piece][ctrl.dir]-1<=10,"[%d]快捷操作的位置超出场地",ptr)
                buf:set(c..buf:get()) ptr=ptr-1
                rem(tempSeq,ctrl.pID)
                clean=true
            end
        else
            -- 传统操作
            if cmd=='move' then
                -- 移动
                clean=false
                if c=='q' or c=='w' then
                    ctrl={act='move',dx=c=='q' and -1 or 1}
                    c=buf:get(1) ptr=ptr+1
                    if tonumber(c) then
                        -- 指定移动格数
                        assertf(tonumber(c)~=0,"[%d]移动0格？",ptr)
                        ctrl.dx=ctrl.dx*tonumber(c)
                    else
                        -- 普通移动一格，恢复多余读取
                        buf:set(c..buf:get()) ptr=ptr-1
                    end
                elseif c=='Q' or c=='W' then
                    -- 移动到底
                    ctrl={act='move',dx=c=='Q' and -9 or 9}
                else
                    error("WTF")
                end
            elseif cmd=='rotate' then
                -- 旋转
                clean=false
                ctrl={act='rotate',dir=c=='c' and 1 or c=='C' and 2 or 3}
            elseif cmd=='drop' then
                if c=='d' then
                    rem(tempSeq,1)
                    clean=true
                    ctrl={act='drop'}
                elseif c=='D' then
                    c=buf:get(1) ptr=ptr+1
                    if tonumber(c) then
                        -- 指定软降高度
                        ctrl={act='drop',soft=tonumber(c)}
                    else
                        -- 普通软降到底，恢复多余读取
                        buf:set(c..buf:get()) ptr=ptr-1
                        ctrl={act='drop',soft=0}
                    end
                else
                    error("WTF")
                end
            elseif cmd=='swap' then
                assertf(#tempSeq>=2,"[%d]交换预览时序列长度不足2",ptr)
                tempSeq[1],tempSeq[2]=tempSeq[2],tempSeq[1]
                clean=true
                ctrl={act='swap'}
            elseif cmd=='check' then
                assertf(clean,"[%d]有空格出现在了块的操作和锁定之间",ptr)
            end
        end
        if ctrl then
            ins(controls,ctrl)
            ctrl=false
        end
    end
    assertf(#controls>0,"指令序列为空")
    assertf(clean,"指令结束时有多余操作未硬降确认")
    return controls
end

---@class Zita.BrikDuel.Duel
---@field id number
---@field sid number
---@field member number[]
---@field game Zita.BrikDuel.Game[]
---@field state 'wait'|'ready'|'play'
local Duel={}
Duel.__index=Duel

---@param sid number
---@param user1 number
---@param user2? number
---@return Zita.BrikDuel.Duel|false
function Duel.new(sid,user1,user2)
    local duel=setmetatable({
        id=nil,
        sid=sid,
        member={user1,user2},
        game={},
        state=user2 and 'ready' or 'wait',
    },Duel)
    local r
    for _=1,10 do
        r=math.random(1000,9999)
        if not duelPool[r] then break end
    end
    if duelPool[r] then return false end
    duel.id=r
    duelPool[r]=duel
    return duel
end

---@param S Session
function Duel:start(S)
    for i=1,#self.member do
        self.game[i]=Game.new(math.random(1e26))
        self.game[i]:supplyNext(7)
    end
    self.state='play'
    S:send(repD(texts.room_start,
        CQ.at(self.member[1]),
        table.concat(self.game[1].sequence," "),
        table.concat(self.game[2].sequence," "),
        CQ.at(self.member[2])
    ))
end

function Duel:save()
    FILE.save(self,'brikduel/duel_'..self.id,'-luaon')
end

function Duel:release()
    love.filesystem.remove('brikduel/duel_'..self.id)
end

---@class Zita.BrikDuel.User
---@field id number
---@field stat Zita.BrikDuel.UserStat
---@field coin number

---@class Zita.BrikDuel.UserStat
---@field game number
---@field win number
---@field move number command executed
---@field drop number piece dropped
---@field atk number attack sent
---@field overkill number
---@field overkill_max number

---@type table<number,Zita.BrikDuel.User>
local users

---@return Zita.BrikDuel.User,boolean isNewPlayerCreated?
local function getUser(id)
    if users[id] then return users[id],false end
    local user={
        id=id,
        coin=0,
        stat={
            game=0,
            win=0,
            move=0,
            drop=0,
            atk=0,
            overkill=0,
            overkill_max=0,
        },
    }
    users[id]=user
    FILE.save(users,'brikduel/userdata.luaon','-luaon')
    return user,true
end

---@type Task_raw
return {
    init=function(S,D)
        D.matches={}
        if not FILE.exist('brikduel') then
            love.filesystem.createDirectory('brikduel')
        end
        if not users then
            users=FILE.load('brikduel/userdata.luaon','-canskip') or {}
            duelPool={}
            local l=love.filesystem.getDirectoryItems('brikduel')
            for _,fileName in next,l do
                if fileName:sub(1,5)=='duel_' then
                    ---@type Zita.BrikDuel.Duel
                    local duel=FILE.load('brikduel/'..fileName)
                    setmetatable(duel,Duel)
                    for i=1,#duel.game do
                        setmetatable(duel.game[i],Game)
                    end
                    duelPool[tonumber(fileName:match('%d+'))]=duel
                end
            end
        end
        for _,duel in next,duelPool do
            if duel.sid==S.id then
                for _,uid in next,duel.member do
                    D.matches[uid]=duel
                end
            end
        end
    end,
    func=function(S,M,D)
        local mes=SimpStr(M.raw_message)

        if mes:sub(1,1)=='#' then
            -- Convert alias "#duel" to "#dl"
            if mes:sub(1,5)=='#duel' then mes='#dl'..mes:sub(6) end
            if mes:sub(1,3)~='#dl' then return false end

            if     mes=='#dlhelp' then if S:lock('brikduel_help',62) then S:send(texts.help)   end return true
            elseif mes=='#dlrule' then if S:lock('brikduel_rule',26) then S:send(texts.rule)   end return true
            elseif mes=='#dlman'  then if S:lock('brikduel_man',62)  then S:send(texts.manual) end return true
            elseif mes:sub(1,7)=='#dljoin' then
                -- Ensure not in duel
                local duel=D.matches[M.user_id]
                if duel then if S:lock('brikduel_inDuel',26) then S:send(texts.new_selfInGame) end return true end

                -- Parse roomID
                local roomID=tonumber(mes:match('%d+'))
                if not roomID then if S:lock('brikduel_wrongRoomID',6) then S:send(texts.join_wrongFormat) end return true end
                if not duelPool[roomID] then if S:lock('brikduel_noRoomID',6) then S:send(texts.join_noRoom) end return true end

                duel=duelPool[roomID]
                if duel.state~='wait' then if S:lock('brikduel_notWait',26) then S:send(texts.join_notWait) return true end end

                duel.member[2]=M.user_id
                if #duel.game==0 then
                    duel:start(S)
                else
                    duel.state='play'
                end

                return true
            elseif mes=='#dlend' then
                ---@type Zita.BrikDuel.Duel
                local duel=D.matches[M.user_id]
                if duel then
                    D.matches[M.user_id]=nil
                    duel:release()
                    S:send(repD(texts.room_cancel,duel.id))
                else
                    if S:lock('brikduel_quitNothing',26) then
                        S:send(texts.quit_nothing)
                    end
                end
                return true
            elseif mes=='#dlleave' then
                local duel=D.matches[M.user_id]
                if duel then
                    -- TODO
                else
                    -- TODO
                end
                return true
            elseif mes=='#dlstat' then
                if S:lock('brikduel_stat_'..M.user_id,26) then
                    local user,new=getUser(M.user_id)
                    local info=new and texts.emptyStat.."\n" or ""
                    info=info..(trimIndent[[
                        📊统计 %s
                        %d局 %d胜 %d负 (%.1f%%)
                        %d步 %d块 %d攻 %d超杀(%d爆)
                        %d币
                    ]]):format(
                        CQ.at(user.id),
                        user.stat.game, user.stat.win, user.stat.game-user.stat.win, math.ceil(user.stat.win/math.max(user.stat.game,1)*100),
                        user.stat.move, user.stat.drop, user.stat.atk,
                        user.stat.overkill,user.stat.overkill_max,
                        user.coin
                    )
                    if D.matches[M.user_id] then info="（正有一场正在进行中）\n"..info end
                    S:send(info)
                end
                return true
            else -- #dl (XXX)
                -- New room
                if D.matches[M.user_id] then if S:lock('brikduel_inDuel',26) then S:send(texts.new_selfInGame) end return true end

                local opID=tonumber(M.raw_message:match('CQ:at,qq=(%d+)'))
                if opID then
                    -- Invite mode
                    -- if opID==Config.botID   then if S:lock('brikduel_wrongOp',26)  then S:send(texts.new_botRefuse) end return true end
                    if opID==M.user_id      then if S:lock('brikduel_wrongOp',26)  then S:send(texts.new_withSelf) end return true end
                    if D.matches[opID]      then if S:lock('brikduel_opInDuel',26) then S:send(texts.new_opInGame) end return true end

                    local duel=Duel.new(S.id,M.user_id,opID)
                    if duel then
                        D.matches[M.user_id]=duel
                        D.matches[opID]=duel
                        duel:save()
                        S:send(repD(texts.new_room,duel.id,TABLE.getRandom(TABLE.getKeys(keyword.accept))))
                    else
                        if S:lock('brikduel_failed',26) then
                            S:send(texts.new_failed)
                        end
                    end
                    return true
                elseif mes=='#dl' then
                    -- Free room
                    if D.matches[M.user_id] then if S:lock('brikduel_inDuel',26) then S:send(texts.new_selfInGame) end return true end

                    local duel=Duel.new(S.id,M.user_id)
                    if duel then
                        D.matches[M.user_id]=duel
                        duel:save()
                        S:send(repD(texts.new_free,duel.id))
                    else
                        if S:lock('brikduel_failed',26) then
                            S:send(texts.new_failed)
                        end
                    end
                    return true
                else
                    if S:lock('brikduel_wrongCmd',26) then
                        S:send(texts.wrongCmd)
                    end
                    return true
                end
            end
        elseif D.matches[M.user_id] then
            ---@type Zita.BrikDuel.Duel
            local duel=D.matches[M.user_id]
            local pid=TABLE.find(duel.member,M.user_id)

            if     duel.state=='wait' then
                if keyword.cancel[mes] then
                    D.matches[M.user_id]=nil
                    duel:release()
                    S:send(repD(texts.room_cancel,duel.id))
                    return true
                end
            elseif duel.state=='ready' then
                if keyword.accept[mes] then
                    duel:start(S)
                    duel:save()
                    S:send("对局开始！")
                elseif keyword.cancel[mes] then
                    D.matches[duel.member[1]]=nil
                    D.matches[duel.member[2]]=nil
                    duel:release()
                    S:send(repD(texts.room_cancel,duel.id))
                    return true
                end
            elseif duel.state=='play' then
                local game=duel.game[pid]

                -- TODO: execute game cmd
                -- local suc,res=pcall(game.parse,game,STRING.trim(M.raw_message))
                -- if suc then
                --     S:send("解析结果 "..TABLE.dump(res))
                -- else
                --     S:send("解析错误："..res)
                -- end
            else
                error("WTF")
            end

            -- local game=duel.game[pid]

            return false
        else
            return false
        end
    end,
}

--[[ Space measuring
local data={ -- unit is width of 🟥 in MrZ's Linux NTQQ
    a={" ",0.1013},
    b={" ",0.1034},
    c={" ",0.1182},
    d={" ",0.1416},
    e={" ",0.1579},
    f={" ",0.1855},
    g={" ",0.1818},
    h={" ",0.20618},
    i={" ",0.2364},
    j={" ",0.3548},
    k={" ",0.3548},
    l={" ",0.4545},
    m={" ",0.7093},
    n={"　",0.7097},
}
local attempt={
    {{7,"d"}},
    {{5,"e"},{2,"c"}},
    {{5,"e"},{2,"b"}},
    {{5,"e"},{2,"a"}},
    {{5,"d"},{3,"c"}},
    {{5,"d"},{3,"b"}},
    {{5,"d"},{3,"a"}},
    {{5,"d"},{2,"c"}},
    {{5,"d"},{2,"b"}},
    {{5,"d"},{2,"a"}},
    {{3,"h"},{2,"e"}},
    {{3,"h"},{2,"d"}},
    {{2,"k"},{1,"b"}},
    {{2,"k"},{1,"a"}},
    {{2,"j"},{3,"b"}},
    {{2,"j"},{3,"a"}},
    {{2,"i"},{3,"b"}},
    {{2,"i"},{3,"a"}},
    {{1,"m"},{2,"e"}},
    {{1,"m"},{2,"d"}},
    {{1,"l"},{2,"e"}},
    {{1,"l"},{2,"d"}},
    {{3,"c"},{3,"g"},{1,"b"}},
    {{3,"c"},{3,"g"},{1,"a"}},
    {{3,"c"},{3,"f"},{1,"b"}},
    {{3,"c"},{3,"f"},{1,"a"}},
    {{1,"j"},{1,"k"},{2,"b"}},
    {{1,"j"},{1,"k"},{2,"a"}},
    {{1,"i"},{1,"k"},{2,"b"}},
    {{1,"i"},{1,"k"},{2,"a"}},
}
local res={}
for _,a in next,attempt do
    local sum=0
    local str=""
    local pattern=""
    for _,set in next,a do
        local time=set[1]
        local char=set[2]
        pattern=pattern..time..char
        sum=sum+time*data[char][2]
        str=str..string.rep(data[char][1],time)
    end
    table.insert(res,{len=sum,pat=pattern,res="🟥"..str.."🟥"})
end
table.sort(res,function(a,b) return a.len<b.len end)
local output=STRING.newBuf()
for i=1,#res do
    if i%2==0 then output:put("🟥🟥🟥\n") end
    local r=res[i]
    output:put(r.res..r.pat.." "..r.len.." \n")
end
print(output)
]]
--[[
▄▐▌
▀▗▖
　▝▘
▟▙▞▚
▜▛▚▞
]]
--[[
囜囡团団囚回囬囗
园圃囦囷圙圐圊囧

囙囝四困因囨囲囩
囤囯国囥囵圆図囸固
囫围囼囹图囶囮囻
囿圀圂圄圁圈圉國
圇圌圍圎園圓圕圑
圔團圖圗圚圜圛圝圞
]]