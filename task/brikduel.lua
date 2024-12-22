local min,max=math.min,math.max
local ins,rem=table.insert,table.remove

local repD,trimIndent=STRING.repD,STRING.trimIndent

local echoCnt=26
local function longSend(S,M,str)
    S:send(str,tostring(echoCnt))
    S:delayDelete(Config.groupManaging[S.id] and 260 or 100,tostring(echoCnt))
    if M then S:delayDelete(62,M.message_id) end
    echoCnt=echoCnt%2600+1
end
local function shortSend(S,M,str)
    S:send(str,tostring(echoCnt))
    S:delayDelete(26,tostring(echoCnt))
    if M then S:delayDelete(26,M.message_id) end
    echoCnt=echoCnt%2600+1
end

local bag0=STRING.atomize('ZSJLTOI')
local minoId={Z=1,S=2,J=3,L=4,T=5,O=6,I=7}

local setLimitTime=26
local maxThinkTime=2*3600
local maxWaitTime=26*3600
local brikData={
    Z={x=4,mat={{0,1,1},{1,1,0}}},
    S={x=4,mat={{2,2,0},{0,2,2}}},
    J={x=4,mat={{3,3,3},{3,0,0}}},
    L={x=4,mat={{4,4,4},{0,0,4}}},
    T={x=4,mat={{5,5,5},{0,5,0}}},
    O={x=5,mat={{6,6},{6,6}}},
    I={x=4,mat={{7,7,7,7}}},
}
local pieceWidth={
    Z={[0]=3,2,3,2},
    S={[0]=3,2,3,2},
    J={[0]=3,2,3,2},
    L={[0]=3,2,3,2},
    T={[0]=3,2,3,2},
    O={[0]=2,2,2,2},
    I={[0]=4,1,4,1},
}
local pieceRotBias={
    Z={
        [01]={1,-1},[10]={-1,1},[12]={-1,0},[21]={1,0},
        [23]={0,0},[32]={0,0},[30]={0,1},[03]={0,-1},
        [02]={0,-1},[20]={0,1},[13]={-1,0},[31]={1,0},
    },S='Z',J='Z',L='Z',T='Z',
    O={
        [01]={0,0},[10]={0,0},[12]={0,0},[21]={0,0},
        [23]={0,0},[32]={0,0},[30]={0,0},[03]={0,0},
        [02]={0,0},[20]={0,0},[13]={0,0},[31]={0,0},
    },
    I={
        [01]={2,-2},[10]={-2,2},[12]={-2,1},[21]={2,-1},
        [23]={1,-1},[32]={-1,1},[30]={-1,2},[03]={1,-2},
        [02]={0,-1},[20]={0,1},[13]={-1,0},[31]={1,0},
    },
} TABLE.reIndex(pieceRotBias)
local RS={
    Z={
        [01]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
        [10]={{0,0},{1,0},{1,-1},{0,2},{1,2}},
        [12]={{0,0},{1,0},{1,-1},{0,2},{1,2}},
        [21]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
        [23]={{0,0},{1,0},{1,1},{0,-2},{1,-2}},
        [32]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2}},
        [30]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2}},
        [03]={{0,0},{1,0},{1,1},{0,-2},{1,-2}},
        [02]={{0,0}},[20]={{0,0}},[13]={{0,0}},[31]={{0,0}},
    },S='Z',J='Z',L='Z',T='Z',
    O={
        [01]={{0,0}},[10]={{0,0}},[12]={{0,0}},[21]={{0,0}},
        [23]={{0,0}},[32]={{0,0}},[30]={{0,0}},[03]={{0,0}},
        [02]={{0,0}},[20]={{0,0}},[13]={{0,0}},[31]={{0,0}},
    },
    I={
        [01]={{0,0},{-2,0},{1,0},{-2,-1},{1,2}},
        [10]={{0,0},{2,0},{-1,0},{2,1},{-1,-2}},
        [12]={{0,0},{-1,0},{2,0},{-1,2},{2,-1}},
        [21]={{0,0},{1,0},{-2,0},{1,-2},{-2,1}},
        [23]={{0,0},{2,0},{-1,0},{2,1},{-1,-2}},
        [32]={{0,0},{-2,0},{1,0},{-2,-1},{1,2}},
        [30]={{0,0},{1,0},{-2,0},{1,-2},{-2,1}},
        [03]={{0,0},{-1,0},{2,0},{-1,2},{2,-1}},
        [02]={{0,0}},[20]={{0,0}},[13]={{0,0}},[31]={{0,0}},
    },
} TABLE.reIndex(RS)
local keyword={
    accept=TABLE.getValueSet{"接受","同意","accept","ok"},
    cancel=TABLE.getValueSet{"算了","不打了","算了不打了","睡了","走了","溜了"},
    forfeit=TABLE.getValueSet{"gg","寄","认输","似了","死了"},
}

---@enum (key) BrikDuel.Skin
local skins={
    image={},

    norm={[0]="⬜","🟥","🟩","🟦","🟧","🟪","🟨","🟫","⬛️","❌"},
    puyo={[0]="◽","🔴","🟢","🔵","🟠","🟣","🟡","🟤","⚫️","❌"},
    emoji={[0]="◽","🈲","🈯","♿","🈚","💟","🚸","💠","🔲","❌"},
    star={[0]="◽","♈","♎","♐","♊","♒","♌","⛎","🔳","❌"},
    heart={[0]="◽","❤","💚","💙","🧡","💜","💛","🩵","🖤","❌"},
    circ={[0]="　","Ⓩ","Ⓢ","Ⓙ","Ⓛ","Ⓣ","Ⓞ","Ⓘ","⓪","Ｘ"}, -- [0] 1n
    chx={[0]="　","囜","囡","团","団","囚","回","囬","囗","困"}, -- [0] 1n
    chy={[0]="　","园","圃","囦","囷","圙","圐","圊","囧","圞"}, -- [0] 1n

    text={_next=true,"Ｚ","Ｓ","Ｊ","Ｌ","Ｔ","Ｏ","Ｉ"},
    mino={_next=true," ▜▖","▗▛ "," ▙▖","▗▟ "," ▟▖"," ▇ "," ▀▀ "},
}
local _skin_help=trimIndent[[
    方块⚔对决 「皮肤列表」
    [图片输出，效果好但延迟高] (image)
    🟥🟧🟨🟩🟫🟦🟪⬜⬛️ (norm)
    🔴🟠🟡🟢🟤🔵🟣◽⚫️ (puyo)
    🈲🈚🚸🈯💠♿💟◽🔲 (emoji)
    ♈♊♌♎⛎♐♒◽🔳 (star)
    ❤🧡💛💚🩵💙💜◽🖤 (heart)
    ⓏⓁⓄⓈⒾⒿⓉ　⓪ (circ)
    囜団回囡囬团囚　囗 (chx)
    园囷圐圃圊囦圙　囧 (chy)
]]
---@enum (key) BrikDuel.Mark
local marks={
    norm={"⬛⬛⬛ ３  ４  ５  ６ ⬛⬛⬛","⬛⬛⬛ ４  ５  ６  ７ ⬛⬛⬛"},
    normoji={"⬛⬛⬛3⃣4⃣5⃣6⃣⬛⬛⬛","⬛⬛⬛4⃣5⃣6⃣7⃣⬛⬛⬛"},
    emoji={"0⃣1⃣2⃣3⃣4⃣5⃣6⃣7⃣8⃣9⃣","1⃣2⃣3⃣4⃣5⃣6⃣7⃣8⃣9⃣0⃣"},
    text={"０１２３４５６７８９","１２３４５６７８９０"},
    chs={"〇一二三四五六七八九","一二三四五六七八九〇"},
    cht={"零壹贰叁肆伍陆柒捌玖","壹贰叁肆伍陆柒捌玖零"},
}
local _mark_help=trimIndent[[
    可用列号名称：
    ⬛ ６  (norm)
    ⬛6⃣ (normoji)
    2⃣6⃣ (emoji)
    ２６ (text)
    二六 (chs)
    贰陆 (cht)
]]
local texts={
    -- (留空) 空房等人   @某人 发起决斗
    -- join/query [房号] 进房/查看房间状态
    help=trimIndent[[
        #duel（可略作#dl） 后接：
        any/AC/10L/gm/[自定序列] 单人模式
        stat 个人信息   see 查看场地
        rule 规则手册   man 操作手册
        end 取消/结束   leave 离开（保留房间）
        setk/sets 设置键位/皮肤
        setx/setn 设置非图片模式下的列号/预览样式
    ]],
    rule=trimIndent([[
        方块⚔对决 「规则手册」
        控制指令可随意拼接并发送，指令表见操作手册
        当前块的位置信息不保存，必须一次性把块落到位
        SRS，场地十宽∞高，出现20垃圾行判负
        消N打N 卡块*2(不可移动) 连击+1 AC+2
        使用交换预览而非暂存(功能一致)
    ]],true),
    manual=trimIndent([[
        方块⚔对决 「操作手册」
        （此处均为默认键位，如要更改见setk命令）
        ⌨️传统操作
            q/w:左右   Q/W:左右到底
            c/C/f:顺逆180°  x:交换预览
            d:硬降  D:软降到底(可追加离地高度)
        👆块捷操作 [块名][朝向][位置](软降)
            块名(zsjltoi):必须从前两块里选
            朝向(0123)
            位置(1234567890):方块最左列置于指定列
            软降(0~9):可选，软降到指定离地高度且不自动硬降
            例 ir0=i块竖着在十列硬降 tl90=t块朝左在第九十列软降
        遇到空格或者指令结束时，如方块不在原位会自动硬降
        语法错误时不会执行而是弹出说明
    ]],true),
    stat=trimIndent[[
        方块⚔对决 「统计」
        %s  %d币
        %d局 %d胜 %d负 (%.1f%%)
        %d步 %d误 %d块 %d旋 %d清
        %d行 %d攻 %d堆 %d爆 %d超杀
        挑战成绩：%s
    ]],
    stat_tooFrequent="查询太频繁了喵",
    setk_help=trimIndent[[
        方块⚔对决 「键位设置」
        左@1 右@2 左到底@3 右到底@4
        顺@5 逆@6 180@7 交换@8 硬降@9 软降@10
        块捷七块@11@12@13@14@15@16@17 朝向@18@19@20@21 起始列@22
        当前配置=$1
        在setk后列出配置即可设置，或者reset重置
        注意有大小写，且不能冲突(不计块捷朝向/起始列)
    ]],
    setk_wrongChar="键位配置不能使用特殊字符喵...",
    setk_wrongFormat="键位配置必须是22个字符",
    setk_conflict="键位配置有冲突",
    setk_base01="块捷起始列只能是0或1",
    setk_reset="键位恢复默认了喵",
    setk_success="键位设置成功了喵",
    setk_current=trimIndent[[
        当前键位： 左右@1@2 到底@3@4
        顺逆180°@5@6@7 换@8 硬@9 软@10
        Z@11 S@12 J@13 L@14 T@15 O@16 I@17
        朝向@18@19@20@21 起始列@22
    ]],
    sets_help=_skin_help,
    sets_success="皮肤设置成功喵",
    setx_help=_mark_help,
    setx_success="列号设置成功喵",
    setn_help="预览模式： text-文字 mino-图形 [皮肤名]-皮肤",
    setn_success="预览模式设置成功喵",
    set_collide="你的个性方块+头像的组合和别人重复了喵",
    set_tooFrequent="修改设置太频繁了喵",

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

    query="房间$1：\n$2 vs $3\n$4",
    query_noRoom="找不到此房间",
    query_tooFrequent="查询太频繁了喵",

    see_noRoom="不在房间中",

    game_start={
        duel="($1) 决斗开始！\n$2\n$3\nvs\n$4\n$5",
        solo="($1)单人模式-$2",
    },
    game_modeName={
        any="自由",
        ac="全消",
        ['10l']="十行",
        gm="盲打",
    },
    game_renderRrror="喵喵喵！渲染失败了：",
    game_moreLine="⤾$1行隐藏",
    game_spin="旋",
    game_clear={
        '单行','双清','三消','四方',
        '五行','六边','七色','八门','九莲','十面',
        '干雷','丰年','参天','谪置','三五',
        '举鼎','毛戴','惊堂','十九','王',
        '甘','田','质','天时','四分','正则'
    },
    game_ac="全消",
    game_acFX={
        "𝖠𝖫𝖫 𝖢𝖫𝖤𝖠𝖱",
        "𝙰𝙻𝙻 𝙲𝙻𝙴𝙰𝚁",
        "𝐀𝐋𝐋 𝐂𝐋𝐄𝐀𝐑",
        "𝘼𝙇𝙇 𝘾𝙇𝙀𝘼𝙍",
        "𝑨𝑳𝑳 𝑪𝑳𝑬𝑨𝑹",
        "𝓐𝓛𝓛 𝓒𝓛𝓔𝓐𝓡",
        "𝕬𝕷𝕷 𝕮𝕷𝕰𝕬𝕽",
        "𝒜𝒯𝒯 𝒟𝒯𝒥𝒜𝒵",
    },
    game_noDisp="##无信号##",
    game_acGraphic="ALL CLEAR",
    game_tarLine="<<",
    game_newRecord="🏆 $1 新纪录！ （原$2）",
    game_notRecord="✅ $1 （最佳成绩$2）",
    game_finish={
        cancel="对局($1)取消",
        norm="对局($1)结束",
        solo="游戏($1)结束",
    },

    notInRoom="你在干什么喵？",
    wrongCmd="用法详见#duel help",
    syntax_error="❌",
}
local ruleLib={
    default={
        modeName='none',
        fieldH=20,
        nextCount=7,
        seqType='bag',
        clearSys='nxt',
        updStat=true,
        autoSave=true,
        disposable=true,
        welcomeText='solo',
        startSeq=false,
        tar=false,
        tarDat=false,
        timeRec=false,
    },
    duel={
        modeName='duel',
        fieldH=40,
        disposable=false,
        welcomeText='duel',
        reward=10,
    },
    solo={
        any={
            modeName='any',
            fieldH=20,
        },
        ac={
            modeName='ac',
            fieldH=13,
            tar='ac',
            tarDat=1,
            timeRec=true,
            reward=2,
        },
        ['10l']={
            modeName='10l',
            fieldH=13,
            tar='line',
            tarDat=10,
            timeRec=true,
            reward=3,
        },
        gm={
            modeName='gm',
            fieldH=20,
            tar='line',
            tarDat=10,
            timeRec=true,
            reward=4,
            noDisp=true,
        },
    }
}

---@type Map<BrikDuel.Duel>
local duelPool

local rng=love.math.newRandomGenerator()

---@type table<integer,BrikDuel.User>
local userLib

---@class BrikDuel.UserStat
---@field game integer
---@field win integer
---@field lose integer
---@field move integer command executed
---@field err integer
---@field drop integer piece dropped
---@field spin integer
---@field ac integer
---@field line integer line cleared
---@field atk integer attack sent
---@field batch integer
---@field spike integer
---@field overkill integer
---@field __index BrikDuel.UserStat

---@class BrikDuel.UserSetting
---@field key string
---@field skin BrikDuel.Skin
---@field mark BrikDuel.Mark
---@field next string
---@field __index BrikDuel.UserSetting

---@class BrikDuel.UserRecord
---@field ac? integer
---@field ['10l']? integer

---@class BrikDuel.User
---@field id integer
---@field stat BrikDuel.UserStat
---@field set BrikDuel.UserSetting
---@field rec BrikDuel.UserRecord
---@field coin integer
local User={
    id=-1,
    stat={
        game=0,win=0,lose=0,
        move=0,err=0,drop=0,spin=0,ac=0,
        line=0,atk=0,batch=0,spike=0,overkill=0,
        __index=nil,
    },
    rec={},
    coin=0,
    set={
        key='qwQWcCfxdDzsjltoi01231',
        skin='image',
        mark='norm',
        next='text',
        __index=nil,
    },
}
User.__index=User
User.set.__index=User.set
User.stat.__index=User.stat

---@return BrikDuel.User
function User.get(id)
    if not userLib[id] then
        userLib[id]=setmetatable({
            id=id,
            set=setmetatable({},User.set),
            stat=setmetatable({},User.stat),
            rec={},
        },User)
        User.save()
    end
    return userLib[id]
end

function User.save()
    FILE.save(userLib,'brikduel/userdata.luaon','-luaon')
end

function User:getRec()
    local buf=STRING.newBuf()
    for k,v in next,self.rec do
        buf:put(k:upper().." "..v.."秒   ")
    end
    return buf:get(#buf-3)
end

---@class BrikDuel.GameStat
---@field move integer
---@field err integer
---@field drop integer
---@field spin integer
---@field ac integer
---@field line integer
---@field atk integer
---@field batch integer
---@field spike integer

---@class BrikDuel.Game
---@field uid integer
---@field rngState string
---@field dieReason string|false
---@field field Mat<integer>
---@field sequence string[]
---@field seqBuffer string[]
---@field garbageH integer
---@field rule table
---@field stat BrikDuel.GameStat
---@field startTime integer
---@field lastUpdateTime integer
Game={}
Game.__index=Game

---@param seed number
---@return BrikDuel.Game
function Game.new(uid,seed)
    rng:setSeed(seed)
    for _=1,26 do rng:random() end
    local game=setmetatable({
        uid=uid,
        rngState=rng:getState(),
        dieReason=false,
        field={},
        sequence={},
        seqBuffer={},
        garbageH=0,
        rule={},
        stat={move=0,err=0,drop=0,spin=0,ac=0,line=0,atk=0,batch=0,spike=0},
        startTime=os.time(),
        lastUpdateTime=os.time(),
    },Game)
    return game
end

function Game:supplyNext(count)
    if not count then count=self.rule.nextCount end
    while #self.sequence<count do
        if not self.seqBuffer[1] then
            if self.rule.seqType=='bag' then
                local bag=TABLE.copy(bag0)
                while bag[1] do
                    ins(self.seqBuffer,rem(bag,self:random(#bag)))
                end
            end
            if not self.seqBuffer[1] then return end
        end
        ins(self.sequence,rem(self.seqBuffer))
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

function Game:parse(str)
    local buf=STRING.newBuf()
    buf:put(str)
    local keyMap=' '..self:getUsr().set.key
    local simSeq=TABLE.copy(self.sequence)
    local c,ptr='',0
    local controls={}
    local clean=true -- 当前块是否移动过
    local ctrl
    while true do
        c=buf:get(1) ptr=ptr+1
        assertf(simSeq[1] or c=='','[%d]序列空了后不能有多余的指令',ptr)
        if c=='' then break end

        -- User.set.key='qwQWcCfxdDzsjltoi01231'
        local cmd=keyMap:find(c) or 0
        cmd=cmd-1
        if cmd==0 then
            -- 空格分隔 0
            if not clean then
                rem(simSeq,1)
                clean=true
                ctrl={act='drop'}
            end
        elseif cmd<=4 then
            -- 移动 1 2 3 4
            clean=false
            ctrl={act='move',dx=cmd==1 and -1 or cmd==2 and 1 or cmd==3 and -26 or 26}
        elseif cmd<=7 then
            -- 旋转 5 6 7
            clean=false
            ctrl={act='rotate',dir=cmd==5 and 1 or cmd==6 and 3 or 2}
        elseif cmd==8 then
            -- 交换预览 8
            assertf(#simSeq>=2,"[%d]交换预览时序列长度不足2",ptr)
            simSeq[1],simSeq[2]=simSeq[2],simSeq[1]
            clean=true
            ctrl={act='swap'}
        elseif cmd==9 then
            -- 硬降 9
            rem(simSeq,1)
            clean=true
            ctrl={act='drop'}
        elseif cmd==10 then
            -- 软降 10
            clean=false
            c=string.char(buf:ref()[0])
            if tonumber(c) then
                -- 指定软降高度，模拟读取成功
                ctrl={act='drop',soft=tonumber(c)}
                buf:skip(1) ptr=ptr+1
            else
                -- 普通软降到底
                ctrl={act='drop',soft=0}
            end
        elseif cmd<=17 then
            -- 块捷操作 11 12 13 14 15 16 17
            assertf(clean,"[%d]块捷操作时方块%s必须在初始位置",ptr,c)
            ctrl={act='pick'}
            ctrl.piece=bag0[cmd-10]
            ctrl.pID=TABLE.find(simSeq,ctrl.piece)
            assertf(ctrl.pID and ctrl.pID<=2,"[%d]块捷操作时方块%s必须在序列前两个",ptr,c)
            if ctrl.pID==2 then simSeq[1],simSeq[2]=simSeq[2],simSeq[1] end
            c=buf:get(1) ptr=ptr+1
            if c=='' then c='__eof' end
            local dir=keyMap:sub(-5,-2):find(c)
            assertf(dir,"[%d]块捷操作朝向错误",ptr)
            ctrl.dir=dir-1
            c=buf:get(1) ptr=ptr+1
            if c=='' then c='__eof' end
            ctrl.pos=tonumber(c)
            assertf(ctrl.pos,"[%d]块捷操作位置错误（应为0-9）",ptr)
            ctrl.pos=keyMap:sub(-1)=='0' and ctrl.pos+1 or ctrl.pos==0 and 10 or ctrl.pos -- 0/1基数
            assertf(ctrl.pos+pieceWidth[ctrl.piece][ctrl.dir]-1<=10,"[%d]块捷操作位置超出场地",ptr)
            c=string.char(buf:ref()[0])
            if tonumber(c) then
                -- 软降不锁定，模拟读取成功
                clean=false
                ctrl.soft=tonumber(c)
                buf:skip(1) ptr=ptr+1
            else
                -- 默认硬降，多余读取
                rem(simSeq,1)
                clean=true
            end
        else
            assertf(cmd,"[%d]字符%s不能作为指令开头",ptr,c)
        end
        if ctrl then
            ins(controls,ctrl)
            ctrl=false
        end
    end
    if not clean then
        ins(controls,{act='drop'})
    end
    return controls
end

function Game:spawnPiece()
    local piece=self.sequence[1]
    if not piece then return 0,0,0,NONE end
    local data=brikData[piece]
    return data.x,self.rule.fieldH+1-#data.mat,0,data.mat
end

function Game:ifoverlap(field,piece,cx,cy)
    local w,h=#piece[1],#piece
    if cx<1 or cx+w-1>10 or cy<1 then return true end
    for y=1,h do
        if field[cy+y-1] then
            for x=1,w do
                if piece[y][x]>0 and field[cy+y-1][cx+x-1]>0 then return true end
            end
        end
    end
    return false
end

function Game:lockPiece(field,piece,cx,cy)
    local w,h=#piece[1],#piece
    for y=1,h do
        if not field[cy+y-1] then field[cy+y-1]=TABLE.new(0,10) end
        for x=1,w do if piece[y][x]~=0 then
            field[cy+y-1][cx+x-1]=field[cy+y-1][cx+x-1]==0 and piece[y][x] or 9
        end end
    end
end

function Game:execute(controls)
    self.lastUpdateTime=os.time()
    local clears={}
    local field=self.field
    local curX,curY,dir,mat=self:spawnPiece()
    if self:ifoverlap(field,mat,curX,curY) then
        curY=#field+1
    end
    for i=1,#controls do
        local ctrl=controls[i]
        local dropped
        if ctrl.act=='pick' then
            if ctrl.pID==2 then
                self.sequence[1],self.sequence[2]=self.sequence[2],self.sequence[1]
                curX,curY,dir,mat=self:spawnPiece()
                if self:ifoverlap(field,mat,curX,curY) then
                    self.dieReason='suffocate'
                    break
                end
            end
            curX=ctrl.pos
            dir=ctrl.dir
            mat=TABLE.rotate(mat,ctrl.dir==0 and '0' or dir==1 and 'R' or ctrl.dir==2 and 'F' or 'L')
            curY=min(#field+1,curY)
            while not self:ifoverlap(field,mat,curX,curY-1) do
                curY=curY-1
            end
            if ctrl.soft then
                curY=curY+ctrl.soft
            else
                dropped=true
            end
        elseif ctrl.act=='move' then
            for _=1,math.abs(ctrl.dx) do
                if self:ifoverlap(field,mat,curX+MATH.sign(ctrl.dx),curY) then break end
                curX=curX+MATH.sign(ctrl.dx)
            end
        elseif ctrl.act=='rotate' then
            local newDir=(dir+ctrl.dir)%4
            local bias=pieceRotBias[self.sequence[1]][10*dir+newDir]
            local newX,newY=curX+bias[1],curY+bias[2]
            local newMat=TABLE.rotate(mat,ctrl.dir==1 and 'R' or ctrl.dir==3 and 'L' or 'F')
            local kicks=RS[self.sequence[1]][10*dir+newDir]
            for _,kick in next,kicks do
                local _x,_y=newX+kick[1],newY+kick[2]
                if not self:ifoverlap(field,newMat,_x,_y) then
                    curX,curY,dir,mat=_x,_y,newDir,newMat
                    break
                end
            end
        elseif ctrl.act=='drop' then
            curY=min(#field+1,curY)
            while not self:ifoverlap(field,mat,curX,curY-1) do
                curY=curY-1
            end
            if ctrl.soft then
                curY=curY+ctrl.soft
            else
                dropped=true
            end
        elseif ctrl.act=='swap' then
            self.sequence[1],self.sequence[2]=self.sequence[2],self.sequence[1]
            curX,curY,dir,mat=self:spawnPiece()
            if self:ifoverlap(field,mat,curX,curY) then
                self.dieReason='suffocate'
                break
            end
        end
        if dropped then
            local tuck=self:ifoverlap(field,mat,curX,curY+1)
            self:lockPiece(field,mat,curX,curY)
            local clear=0
            for y=#field,1,-1 do
                if not table.concat(field[y]):find('0') then
                    rem(field,y)
                    clear=clear+1
                end
            end
            if clear>0 then
                ins(clears,{
                    piece=self.sequence[1],
                    spin=tuck,
                    line=clear,
                    ac=#field==0,
                })
            end
            self.stat.drop=self.stat.drop+1
            if tuck then self.stat.spin=self.stat.spin+1 end
            self.stat.line=self.stat.line+clear
            if #field==0 then self.stat.ac=self.stat.ac+1 end

            rem(self.sequence,1)
            if self.sequence[1] then
                curX,curY,dir,mat=self:spawnPiece()
                if self:ifoverlap(field,mat,curX,curY) then
                    self.dieReason='suffocate'
                    break
                end
            end
        end
        self.stat.move=self.stat.move+1
    end
    if self.rule.clearSys=='std' then
        local batch,spike=0,0
        for _,clear in next,clears do
            batch=batch+clear.line
            clear.atk=clear*(clear.spin and 2 or 1)+(clear.ac and 3 or 0)
            spike=spike+clear.atk
            self.stat.atk=self.stat.atk+clear.atk
        end
        self.stat.batch=max(self.stat.batch,batch)
        self.stat.spike=max(self.stat.spike,spike)
    elseif self.rule.clearSys=='nxt' then
        if clears[1] then
            local pieces=""
            local lines=0
            local spinLines=0
            local spinCount=0
            local ac=false
            for _,c in next,clears do
                pieces=pieces..c.piece
                lines=lines+c.line
                if c.spin then
                    spinLines=spinLines+c.line
                    spinCount=spinCount+1
                end
                if c.ac then ac=true end
            end
            if #pieces>4 then pieces="#"..#pieces end
            local atk=math.floor(( (2+lines+spinLines+(ac and 2 or 0)) /3) ^ (2+spinCount/10))
            clears={{
                piece=pieces,
                line=lines,
                spin=spinLines>=lines/2,
                ac=ac,
                atk=atk,
            }}
            self.stat.atk=self.stat.atk+atk
            self.stat.batch=max(self.stat.batch,lines)
            self.stat.spike=max(self.stat.spike,atk)
        end
    end
    self.clears=clears

    if self.dieReason then
        self:lockPiece(field,mat,curX,curY)
    end
end

function Game:getUsr()
    return User.get(self.uid)
end

function Game:getText_seq()
    local skin=skins[self:getUsr().set.next]
    local buf=""
    for i=1,#self.sequence do buf=buf..skin[minoId[self.sequence[i]]] end
    return buf
end

function Game:getText_field()
    if self.rule.noDisp then return texts.game_noDisp end
    local field=self.field
    local h=#field
    if h>0 then
        local buf=STRING.newBuf()
        local skin=skins[self:getUsr().set.skin]
        for y=h,max(h-9,1),-1 do
            if y~=h then buf:put("\n") end
            for x=1,10 do buf:put(skin[field[y][x]]) end
            if self.rule.tar=='line' and y==self.rule.tarDat-self.stat.line then buf:put(texts.game_tarLine) end
        end
        if h>10 then buf:put(repD(texts.game_moreLine,h-10)) end
        local set=self:getUsr().set
        buf:put("\n"..marks[set.mark][set.key:sub(-1)+1])
        return tostring(buf)
    else
        return texts.game_acFX[self.stat.ac<=5 and self.stat.ac or 6+self.stat.ac%3] or ""
    end
end

local boarderW=3
local spawnLineR=1
local gridLineR=2
local cSize=16
local colNumH=16
local nextBound=2
local nextK1,nextK2,nextGap=9,6,2

local fieldW,fieldH=cSize*10,cSize*12
local nextH1,nextH2=nextK1*2+nextBound*2,nextK2*2+nextBound*2
local totalW,totalH=fieldW+2*boarderW,fieldH+colNumH+nextH1+boarderW

GC.setDefaultFilter('nearest','nearest')
local texture={
    canvas=GC.newCanvas(totalW,totalH),
    board=GC.load{w=totalW,h=totalH,
        {'clear',0,0,0},
        {'move',boarderW,fieldH},
        {'setCL',COLOR.L},
        {'fRect',0,0,fieldW,-fieldH},
        {'setCL',COLOR.dL},
        {'fRect',1*cSize-1,0,2,-fieldH},{'fRect',2*cSize-1,0,2,-fieldH},{'fRect',3*cSize-1,0,2,-fieldH},
        {'fRect',4*cSize-1,0,2,-fieldH},{'fRect',5*cSize-1,0,2,-fieldH},{'fRect',6*cSize-1,0,2,-fieldH},
        {'fRect',7*cSize-1,0,2,-fieldH},{'fRect',8*cSize-1,0,2,-fieldH},{'fRect',9*cSize-1,0,2,-fieldH},
        {'fRect',0,-1*cSize-1,fieldW,2},{'fRect',0,-2*cSize-1,fieldW,2},{'fRect',0,-3*cSize-1,fieldW,2},
        {'fRect',0,-4*cSize-1,fieldW,2},{'fRect',0,-5*cSize-1,fieldW,2},{'fRect',0,-6*cSize-1,fieldW,2},
        {'fRect',0,-7*cSize-1,fieldW,2},{'fRect',0,-8*cSize-1,fieldW,2},{'fRect',0,-9*cSize-1,fieldW,2},
        {'fRect',0,-fieldW-1,fieldW,2},{'fRect',0,-11*cSize-1,fieldW,2},{'fRect',0,-cSize*cSize-1,fieldW,2},
        {'setCL',COLOR.lD},
        {'fRect',0,colNumH,4.7*cSize,nextH1},
        {'fRect',4.7*cSize,colNumH+nextH1,6.26*cSize,-nextH2},
    },
    Z=GC.load{w=3,h=2,
        {'setCL',COLOR.lR},
        {'fRect',0,0,1,1},
        {'fRect',1,0,1,1},
        {'fRect',1,1,1,1},
        {'fRect',2,1,1,1},
    },
    S=GC.load{w=3,h=2,
        {'setCL',COLOR.lG},
        {'fRect',1,0,1,1},
        {'fRect',2,0,1,1},
        {'fRect',0,1,1,1},
        {'fRect',1,1,1,1},
    },
    J=GC.load{w=3,h=2,
        {'setCL',COLOR.lB},
        {'fRect',0,0,1,1},
        {'fRect',0,1,1,1},
        {'fRect',1,1,1,1},
        {'fRect',2,1,1,1},
    },
    L=GC.load{w=3,h=2,
        {'setCL',COLOR.lO},
        {'fRect',2,0,1,1},
        {'fRect',0,1,1,1},
        {'fRect',1,1,1,1},
        {'fRect',2,1,1,1},
    },
    T=GC.load{w=3,h=2,
        {'setCL',COLOR.lV},
        {'fRect',1,0,1,1},
        {'fRect',0,1,1,1},
        {'fRect',1,1,1,1},
        {'fRect',2,1,1,1},
    },
    O=GC.load{w=2,h=2,{'clear',COLOR.lY}},
    I=GC.load{w=4,h=1,{'clear',COLOR.LC}},
}
GC.setDefaultFilter('linear','linear')
local cellColor={
    {COLOR.R,COLOR.lR},
    {COLOR.G,COLOR.lG},
    {COLOR.B,COLOR.lB},
    {COLOR.O,COLOR.lO},
    {COLOR.V,COLOR.lV},
    {COLOR.Y,COLOR.lY},
    {COLOR.lC,COLOR.LC},
    {COLOR.lD,COLOR.LD},
    {COLOR.DR,COLOR.dR},
}
local imgCnt=0
function Game:renderImage()
    local field=self.field
    GC.setCanvas(texture.canvas)
    GC.push('transform')
        GC.clear()
        GC.origin()

        -- 模板
        GC.setColor(1,1,1)
        GC.draw(texture.board)

        -- 相机
        local camStartH=max(#field-9,1) -- 从最多看顶部10行的位置开始
        local camEndH=#field==0 and 5 or #field+2 -- 到场地高度+2行结束（全消例外）
        if self.rule.noDisp then
            camStartH,camEndH=1,4
        end

        local imgStartH=cSize*max(0,12-camEndH)

        GC.translate(boarderW,0)

        -- 水印
        FONT.set(15)
        GC.setColor(.7023,.7023,.7023,.26)
        GC.print("BrikDuel",6,imgStartH+1*cSize,-.26)
        GC.print(self.uid,6,imgStartH+2*cSize,-.26)

        GC.translate(0,fieldH)

        -- 场内元素
        GC.translate(0,(camStartH-1)*cSize)
            -- 场地
            if self.rule.noDisp then
                for y=1,4 do for x=0,9 do
                    GC.setColor(0,0,0,math.random())
                    GC.rectangle('fill',x*cSize,-y*cSize,cSize,cSize)
                end end
            elseif #field>0 then
                for y=camStartH,min(#field,camStartH+11) do
                    for x=0,9 do
                        local l0,ld,lu=field[y],field[y-1],field[y+1]
                        local cell=l0[x+1]
                        if cell>0 then
                            GC.setColor(cellColor[cell][2])
                            GC.rectangle('fill',x*cSize,-y*cSize,cSize,cSize)
                            GC.setColor(cellColor[cell][1])
                            if l0[x+1]~=l0[x+2] then           GC.rectangle('fill',x*cSize+cSize,-y*cSize      ,-gridLineR,cSize) end
                            if l0[x+1]~=l0[x] then             GC.rectangle('fill',x*cSize      ,-y*cSize      ,gridLineR,cSize) end
                            if not ld or l0[x+1]~=ld[x+1] then GC.rectangle('fill',x*cSize      ,-y*cSize+cSize,cSize,-gridLineR) end
                            if not lu or l0[x+1]~=lu[x+1] then GC.rectangle('fill',x*cSize      ,-y*cSize      ,cSize,gridLineR) end
                        end
                    end
                end
            elseif self.stat.ac>0 then
                FONT.set(25)
                GC.strokePrint('full',2,COLOR.O,COLOR.lY,texts.game_acGraphic,5*cSize,-cSize*3,'center')
                if self.stat.ac>=2 then
                    FONT.set(20)
                    GC.strokePrint('full',1,COLOR.O,COLOR.lY,"x "..self.stat.ac,8.6*cSize,-cSize*4.2,'right')
                end
            end

            -- 目标线
            if self.rule.tar=='line' then
                local lineH=max(self.rule.tarDat-self.stat.line,0)
                if lineH>=0 then
                    GC.translate(0,-cSize*lineH)
                    GC.setColor(COLOR.D)
                    GC.rectangle('fill',0,-boarderW,fieldW,2*boarderW)
                    GC.setColor(COLOR.L)
                    for x=0,9 do GC.rectangle('fill',cSize*x,0,cSize,x%2==0 and -boarderW+1 or boarderW-1) end
                    GC.translate(0,cSize*lineH)
                end
            end

            -- 出生线
            GC.setColor(COLOR.lD)
            GC.rectangle('fill',0,-cSize*(self.rule.fieldH)-spawnLineR,fieldW,2*spawnLineR)
        GC.translate(0,-(camStartH-1)*cSize)

        -- 影子
        local cur=self.sequence[1]
        if cur then
            local width=pieceWidth[cur][0]
            local shadeStartX=math.floor(6-width/2)
            GC.setColor(cellColor[TABLE.find(bag0,cur)][2])
            for y=0,4 do
                GC.setAlpha(.42-.062*y)
                GC.rectangle('fill',(shadeStartX-1)*cSize,imgStartH-fieldH+y*cSize,width*cSize,cSize)
            end
        end

        -- 隐藏行数
        if camStartH>1 then
            FONT.set(10,'mono')
            GC.setColor(COLOR.D)
            GC.printf("+"..camStartH-1,0,-12,fieldW-2,'right')
        end

        -- 列号
        GC.setColor(COLOR.L)
        FONT.set(15,'mono')
        local base=tonumber(self:getUsr().set.key:sub(-1))
        for x=0,9 do GC.print((x+base)%10,cSize*x+4,0) end

        -- 预览
        GC.translate(nextBound,colNumH+nextH1-nextBound)
        for i=1,min(#self.sequence,self.rule.nextCount) do
            local piece=self.sequence[i]
            local img=texture[piece]
            local k=i<=2 and nextK1 or nextK2
            GC.draw(img,0,0,0,k,k,0,img:getHeight())
            GC.translate(img:getWidth()*k+nextGap,0)
        end
    GC.pop()
    GC.setCanvas()
    local fileName='canvas_'..imgCnt..'.png'
    imgCnt=(imgCnt+1)%6
    GC.saveCanvas(texture.canvas,fileName,'png',0,1,0,imgStartH,totalW,totalH-imgStartH)

    local file=love.filesystem.getSaveDirectory()..'/'..fileName
    os.execute('chmod 644 '..file)
    os.execute('mv '..file..' '..Config.extraData.sandboxRealPath..fileName)
    return CQ.img(Config.extraData.sandboxPath..fileName)
end

---@param withRtn? boolean
function Game:getContent(withRtn)
    if self:getUsr().set.skin~='image' then
        return self:getText_field().."\n"..self:getText_seq()..(withRtn and "\n" or "")
    else
        local suc,res=pcall(self.renderImage,self)
        if suc then return res end
        GC.setCanvas()
        return texts.game_renderRrror..tostring(res)
    end
end

function Game:getText_clear()
    local buf=STRING.newBuf()
    for i,clear in next,self.clears do
        if i>=2 then buf:put("  ") end
        buf:put(clear.piece..(clear.spin and texts.game_spin or "")..texts.game_clear[clear.line])
        if clear.ac then buf:put(texts.game_ac) end
        if clear.atk then buf:put('('..clear.atk..'a)') end
    end
    return tostring(buf)
end

---@class BrikDuel.Duel
---@field uid integer
---@field sid integer Session ID
---@field member integer[]
---@field game BrikDuel.Game[]
---@field autoSave boolean
---@field disposable boolean
---@field state 'wait'|'ready'|'play'|'finish'
---@field finishedMes? string
local Duel={}
Duel.__index=Duel

---@param sid integer
---@param user1 integer
---@param user2? integer
---@return BrikDuel.Duel|false
function Duel.new(sid,user1,user2)
    local duel=setmetatable({
        uid=nil,
        sid=sid,
        member={user1,user2},
        game={},
        state=user2 and 'ready' or 'wait',
    },Duel)
    for _=1,10 do
        duel.uid=math.random(1000,9999)
        if not duelPool[duel.uid] then break end
    end
    if duelPool[duel.uid] then return false end
    duelPool[duel.uid]=duel
    return duel
end

function Duel:getFile()
    return 'brikduel/game_'..self.uid
end

---@param S Session
---@param D table
---@param rule table
function Duel:start(S,D,rule)
    self.state='play'
    math.randomseed(os.time())
    for i=1,#self.member do self.game[i]=Game.new(self.member[i],math.random(2^50)) end

    TABLE.updateMissing(rule,ruleLib.default)

    self.autoSave=rule.autoSave
    self.disposable=rule.disposable

    for _,game in next,self.game do
        game.rule=rule
        if rule.startSeq then
            game.seqBuffer=TABLE.copy(rule.startSeq)
        end
        game:supplyNext()
    end

    if self.autoSave then self:save() end

    if rule.welcomeText=='duel' then
        longSend(S,nil,
            repD(texts.game_start.duel,
                self.uid,
                CQ.at(self.member[1]),
                self.game[1]:getText_seq(),
                self.game[2]:getText_seq(),
                CQ.at(self.member[2])
            )
        )
    elseif rule.welcomeText=='solo' then
        longSend(S,nil,
            repD(texts.game_start.solo,
                self.uid,
                texts.game_modeName[rule.modeName] or rule.modeName:upper()
            )..self.game[1]:getContent(nil)
        )
    else
        error("WTF")
    end
end

---@param S Session
---@param D table
function Duel:afterMove(S,D)
    local finish
    for i=1,#self.game do
        local game=self.game[i]
        if game.rule.tar then
            if game.rule.tar=='ac' then
                if game.stat.ac>=game.rule.tarDat then
                    finish={reason='win',id=i}
                    break
                end
            elseif game.rule.tar=='line' then
                if game.stat.line>=game.rule.tarDat then
                    finish={reason='win',id=i}
                    break
                end
            end
        end
        game:supplyNext()
        if #game.sequence==0 then
            finish={reason='starve',id=i}
            break
        end
        if not finish and game.dieReason then
            finish={reason=game.dieReason,id=i}
            break
        end
    end

    if finish then
        self:finish(S,D,{
            result='finish',
            reason=finish.reason,
            uid=self.member[finish.id],
            noOutput=true,
        })
    elseif self.autoSave then
        self:save()
    end
end

---@return integer winnerID 0: Tie
function Duel:getTimeState()
    return 0

    -- if #self.game<2 then return 0 end

    -- local times={}
    -- for i=1,#self.game do
    --     times[i]=self.game[i].lastUpdateTime
    -- end

    -- local waitTimeOut=os.time()-TABLE.max(times)>maxWaitTime
    -- if waitTimeOut then
    --     return select(2,TABLE.max(times))
    -- else
    --     return 0
    -- end
end

---@param D table
---@param info {result?:'cancel'|'interrupt'|'finish', reason?:string, uid?:number, noOutput:boolean}
function Duel:finish(S,D,info)
    self.finishedMes=""
    -- 删除会话到对局的链接
    for i=1,#self.member do
        D.matches[self.member[i]]=nil
    end

    local survivor
    for id,game in next,self.game do
        if not game.dieReason then
            if survivor==nil then
                survivor=id
            elseif survivor then
                survivor=false
            end
        end
    end

    -- 更新统计
    local needSave
    for id,game in next,self.game do
        local user=User.get(self.member[id])
        if game.rule.updStat then
            for k,v in next,game.stat do
                if k=='batch' or k=='spike' then
                    user.stat[k]=max(user.stat[k],v)
                else
                    user.stat[k]=user.stat[k]+v
                end
            end
            needSave=true
        end
        if id==survivor and not game.dieReason then
            if game.rule.reward then
                user.coin=user.coin+game.rule.reward
                needSave=true
            end
            if #self.game>1 then
                local atkOverflow=max(self.game[survivor%#self.game+1].garbageH-20,0)
                user.stat.overkill=user.stat.overkill+atkOverflow
                if game.rule.reward then
                    user.coin=user.coin+min(math.floor(atkOverflow/5),5)
                end
                needSave=true
            end
        end
    end

    -- 结束消息
    if info.result=='cancel' then
        self.finishedMes=repD(texts.game_finish.cancel,self.uid)
    elseif info.result=='finish' then
        if info.reason=='win' then
            local game=self.game[TABLE.find(self.member,info.uid)]
            assert(game,"WTF")
            if game.rule.timeRec then
                local modeName=game.rule.modeName
                local userRec=User.get(game.uid).rec
                local oldTime=userRec[modeName] or 2600
                local newTime=os.time()-game.startTime
                if newTime<(oldTime) then
                    self.finishedMes=repD(texts.game_newRecord,newTime.."秒",oldTime.."秒")
                    userRec[modeName]=newTime
                    needSave=true
                else
                    self.finishedMes=repD(texts.game_notRecord,newTime.."秒",oldTime.."秒")
                end
            end
        elseif info.reason=='suffocate' then
            self.finishedMes=repD(texts.game_finish.solo,self.uid).."：窒息"
        elseif #self.game==1 then
            self.finishedMes=repD(texts.game_finish.solo,self.uid)
        else
            self.finishedMes=repD(texts.game_finish.norm,self.uid)
        end
    elseif info.result=='interrupt' then
        self.finishedMes=repD(texts.game_finish.norm,self.uid)
    end

    if not info.noOutput and #self.finishedMes>0 then
        S:send(self.finishedMes)
    end

    if needSave then User.save() end

    duelPool[self.uid]=nil
    if FILE.exist(self:getFile()) then
        love.filesystem.remove(self:getFile())
    end
end

function Duel:save()
    FILE.save(self,self:getFile(),'-luaon')
end

---@type Task_raw
return {
    init=function(S,D)
        D.matches={}
        if not FILE.exist('brikduel') then
            love.filesystem.createDirectory('brikduel')
        end
        if not userLib then
            userLib=FILE.load('brikduel/userdata.luaon','-canskip') or {}
            for _,user in next,userLib do
                setmetatable(user,User)
                setmetatable(user.set,User.set)
                setmetatable(user.stat,User.stat)
            end
            duelPool={}
            local l=love.filesystem.getDirectoryItems('brikduel')
            for _,fileName in next,l do
                if fileName:sub(1,5)=='game_' then
                    ---@type BrikDuel.Duel
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
        local mes=STRING.trim(M.raw_message)

        ---@type BrikDuel.Duel
        local curDuel=D.matches[M.user_id]
        local curUser=User.get(M.user_id)

        if mes:sub(1,1)=='#' then
            -- 缩写
            mes=mes:gsub('^#du?e?l *','#dl',1)

            if not mes:find('^#dl') then
                return false
            elseif mes:find('^#dlhelp')  then
                if S:lock('brikduel_help',62) then
                    S:send(texts.help)
                    S:delayDelete(26,M.message_id)
                end
                return true
            elseif mes:find('^#dlrule')  then
                if S:lock('brikduel_rule',62) then
                    S:send(texts.rule)
                    S:delayDelete(26,M.message_id)
                end
                return true
            elseif mes:find('^#dlman')   then
                if S:lock('brikduel_man',62) then
                    S:send(texts.manual)
                    S:delayDelete(26,M.message_id)
                end
                return true
            elseif mes:find('^#dlsee')   then
                if not curDuel then
                    if S:lock('brikduel_notInRoom',12) then shortSend(S,M,texts.notInRoom) end
                else
                    local pid=TABLE.find(curDuel.member,M.user_id)
                    local game=curDuel.game[pid]
                    S:send(game:getContent())
                    S:delayDelete(26,M.message_id)
                end
                return true
            elseif mes:find('^#dlstat')  then
                if S:lock('brikduel_stat_'..M.user_id,26) then
                    local info=STRING.newBuf()
                    info:put(texts.stat:format(
                        CQ.at(curUser.id), curUser.coin,
                        curUser.stat.game, curUser.stat.win, curUser.stat.lose, math.ceil(curUser.stat.win/max(curUser.stat.win+curUser.stat.lose,1)*100),
                        curUser.stat.move, curUser.stat.err, curUser.stat.drop, curUser.stat.spin, curUser.stat.ac,
                        curUser.stat.line, curUser.stat.atk, curUser.stat.batch, curUser.stat.spike, curUser.stat.overkill,
                        curUser:getRec()
                    ))
                    if curDuel then
                        info:put("\n有一场对局("..D.matches[M.user_id].uid..")进行中")
                    end
                    S:send(info)
                else
                    shortSend(S,M,texts.stat_tooFrequent)
                end
                return true
            elseif mes:find('^#dlquery') then
                if S:lock('brikduel_query',12) then
                    local duel=duelPool[tonumber(mes:match('%d+'))]
                    if not duel then duel=D.matches[M.user_id] end
                    if duel then
                        longSend(S,M,repD(texts.query,
                            duel.uid,
                            duel.member[1],
                            duel.member[2],
                            table.concat(duel.game[1].sequence," ")
                        ))
                    else
                        if S:lock('brikduel_noRoom',12) then
                            shortSend(S,M,texts.query_noRoom)
                        end
                    end
                else
                    if S:lock('brikduel_queryTooFrequent',12) then
                        shortSend(S,M,texts.query_tooFrequent)
                    end
                end
                return true
            elseif mes:find('^#dljoin')  then
                -- 确保不在对局中
                if curDuel then if S:lock('brikduel_inDuel',26) then shortSend(S,M,texts.new_selfInGame) end return true end

                -- 解析房间号
                local roomID=tonumber(mes:match('%d+'))
                if not roomID then if S:lock('brikduel_wrongRoomID',6) then shortSend(S,M,texts.join_wrongFormat) end return true end
                if not duelPool[roomID] then if S:lock('brikduel_noRoomID',6) then shortSend(S,M,texts.join_noRoom) end return true end

                curDuel=duelPool[roomID]
                if curDuel.state~='wait' then if S:lock('brikduel_notWait',26) then shortSend(S,M,texts.join_notWait) return true end end

                curDuel.member[2]=M.user_id
                if #curDuel.game==0 then
                    curDuel:start(S,D,ruleLib.duel)
                else
                    curDuel.state='play'
                end

                return true
            elseif mes:find('^#dlend')   then
                if curDuel then
                    curDuel:finish(S,D,{result='interrupt',uid=M.user_id})
                else
                    if S:lock('brikduel_notInRoom',26) then shortSend(S,M,texts.notInRoom) end
                end
                return true
            elseif mes:find('^#dlleave') then
                if curDuel then
                    -- TODO
                else
                    if S:lock('brikduel_notInRoom',26) then shortSend(S,M,texts.notInRoom) end
                end
                return true
            elseif mes:find('^#dl$')     then
                -- 自由房间
                if curDuel then if S:lock('brikduel_inDuel',26) then shortSend(S,M,texts.new_selfInGame) end return true end

                local newDuel=Duel.new(S.id,M.user_id)
                if newDuel then
                    D.matches[M.user_id]=newDuel
                    S:send(repD(texts.new_free,newDuel.uid))
                else
                    if S:lock('brikduel_failed',26) then
                        shortSend(S,M,texts.new_failed)
                    end
                end
                return true
            elseif mes:find('^#dlsetk')  then
                if mes=='#dlsetk' then
                    if S:lock('brikduel_setk_help',26) then
                        local keyMap=curUser.set.key
                        local helpText=texts.setk_help:gsub('@(%d+)',function(n) return keyMap:sub(n,n) end)
                        S:send(repD(helpText,keyMap))
                        S:delayDelete(26,M.message_id)
                    end
                    return true
                else
                    -- if not S:lock('brikduel_setk'..M.user_id,setLimitTime) then
                    --     if S:lock('brikduel_set',6) then shortSend(S,M,texts.set_tooFrequent) end
                    --     return true
                    -- end
                    -- User.set.key='qwQWcCfxdDzsjltoi01231'
                    local newSet=mes:sub(8):lower()
                    if newSet=='reset' then
                        curUser.set.key=User.set.key
                        User.save()
                        shortSend(S,M,texts.setk_reset.."，"..texts.setk_current:gsub('@(%d+)',function(n) return curUser.set.key:sub(n,n) end))
                        return true
                    end
                    if not newSet:find('[a-zA-Z0-9!@#&_={};:,/<>|`~]') then
                        shortSend(S,M,texts.setk_wrongChar)
                        return true
                    elseif #newSet~=22 then
                        shortSend(S,M,texts.setk_wrongFormat)
                        return true
                    elseif newSet:sub(1,17):find('(.).*%1') or newSet:sub(18,21):find('(.).*%1') then
                        shortSend(S,M,texts.setk_conflict)
                        return true
                    elseif not newSet:sub(-1):find('[01]') then
                        shortSend(S,M,texts.setk_base01)
                        return true
                    else
                        -- 终于对了
                        curUser.set.key=newSet
                        User.save()
                        shortSend(S,M,texts.setk_success.."，"..texts.setk_current:gsub('@(%d+)',function(n) return curUser.set.key:sub(n,n) end))
                        return true
                    end
                end
            elseif mes:find('^#dlsets')  then
                local newSkin=mes:sub(8):lower()
                if skins[newSkin] and not skins[newSkin]._next then
                    if not S:lock('brikduel_sets'..M.user_id,setLimitTime) then
                        if S:lock('brikduel_set',6) then shortSend(S,M,texts.set_tooFrequent) end
                        return true
                    end
                    curUser.set.skin=newSkin
                    User.save()
                    shortSend(S,M,texts.sets_success)
                else
                    longSend(S,M,texts.sets_help)
                end
                return true
            elseif mes:find('^#dlsetx')  then
                local newNum=mes:sub(8):lower()
                if marks[newNum] then
                    if not S:lock('brikduel_setx'..M.user_id,setLimitTime) then
                        if S:lock('brikduel_set',6) then shortSend(S,M,texts.set_tooFrequent) end
                        return true
                    end
                    curUser.set.mark=newNum
                    User.save()
                    shortSend(S,M,texts.setx_success)
                else
                    longSend(S,M,texts.setx_help)
                end
                return true
            elseif mes:find('^#dlsetn')  then
                local newNext=mes:sub(8):lower()
                if skins[newNext] then
                    if not S:lock('brikduel_setn'..M.user_id,setLimitTime) then
                        if S:lock('brikduel_set',6) then shortSend(S,M,texts.set_tooFrequent) end
                        return true
                    end
                    curUser.set.next=newNext
                    User.save()
                    shortSend(S,M,texts.setn_success)
                else
                    shortSend(S,M,texts.setn_help)
                end
                return true
            else
                local exData=mes:sub(4)
                if ruleLib.solo[exData] or exData:find('^%s*[zsjltoiZSJLTOI]+$') then
                    -- 单人
                    if curDuel then
                        if curDuel.disposable then
                            curDuel:finish(S,D,{noOutput=true})
                        else
                            if S:lock('brikduel_inDuel',26) then shortSend(S,M,texts.new_selfInGame) end
                            return true
                        end
                    end

                    local newDuel=Duel.new(S.id,M.user_id)
                    if newDuel then
                        D.matches[M.user_id]=newDuel
                        newDuel:start(S,D,ruleLib.solo[exData] or {
                            modeName='custom',
                            updStat=false,
                            seqType='none',
                            startSeq=STRING.atomize(exData:upper()),
                        })
                    else
                        if S:lock('brikduel_failed',26) then
                            shortSend(S,M,texts.new_failed)
                        end
                    end
                else
                    -- 多人
                    if curDuel then
                        if curDuel.disposable then
                            curDuel:finish(S,D,{noOutput=true})
                        else
                            if S:lock('brikduel_inDuel',26) then shortSend(S,M,texts.new_selfInGame) end
                            return true
                        end
                    end

                    local opID=tonumber(M.raw_message:match('CQ:at,qq=(%d+)'))
                    if opID then
                        -- 邀请
                        -- if opID==Config.botID   then if S:lock('brikduel_wrongOp',26)  then shortSend(S,M,texts.new_botRefuse) end return true end
                        if opID==M.user_id then if S:lock('brikduel_wrongOp',26)  then shortSend(S,M,texts.new_withSelf) end return true end
                        if D.matches[opID] then if S:lock('brikduel_opInDuel',26) then shortSend(S,M,texts.new_opInGame) end return true end

                        local newDuel=Duel.new(S.id,M.user_id,opID)
                        if newDuel then
                            D.matches[M.user_id]=newDuel
                            D.matches[opID]=newDuel
                            S:send(repD(texts.new_room,newDuel.uid,TABLE.getRandom(TABLE.getKeys(keyword.accept))))
                        else
                            if S:lock('brikduel_failed',26) then
                                shortSend(S,M,texts.new_failed)
                            end
                        end
                    else
                        if S:lock('brikduel_wrongCmd',26) then
                            shortSend(S,M,texts.wrongCmd)
                        end
                    end
                end
                return true
            end
        elseif curDuel then
            local pid=TABLE.find(curDuel.member,M.user_id)
            if     curDuel.state=='wait' then
                if keyword.cancel[mes] then
                    curDuel:finish(S,D,{result='cancel'})
                    return true
                else
                    return false
                end
            elseif curDuel.state=='ready' then
                if keyword.accept[mes] then
                    curDuel:start(S,D,ruleLib.duel)
                    return true
                elseif keyword.cancel[mes] then
                    curDuel:finish(S,D,{result='cancel'})
                    return true
                else
                    return false
                end
            elseif curDuel.state=='play' then
                if keyword.cancel[mes] then
                    curDuel:finish(S,D,{result='interrupt',uid=M.user_id})
                    return true
                end

                local ctrlMes=M.raw_message:match('^['..curUser.set.key..'0-9 ]+$')
                if not ctrlMes then return false end

                local game=curDuel.game[pid]
                local suc,controls=pcall(game.parse,game,ctrlMes)
                if not suc then
                    game.stat.err=game.stat.err+1
                    longSend(S,nil,texts.syntax_error..controls:sub((controls:find('%['))))
                    return true
                end

                if #controls==0 then return false end
                -- print(TABLE.dumpDeflate(controls))
                local dropCnt,lineCnt=game.stat.drop,game.stat.line
                game:execute(controls)
                dropCnt,lineCnt=game.stat.drop-dropCnt,game.stat.line-lineCnt
                curDuel:afterMove(S,D)

                local buf=STRING.newBuf()
                -- buf:put(CQ.at(M.user_id).."\n")

                buf:put(game:getContent(true))
                buf:put(game:getText_clear())
                if curDuel.finishedMes then
                    local ptr,len=buf:ref()
                    local lastChar=string.char(ptr[len-1])
                    if not lastChar:match("[%]\n]") then buf:put("\n") end
                    buf:put(curDuel.finishedMes)
                    S:send(buf)
                elseif dropCnt<=1 and lineCnt==0 then
                    shortSend(S,nil,buf)
                elseif S:lock('brikduel_speedLim_'..M.user_id,26) then
                    S:send(buf)
                elseif #ctrlMes<=3 then
                    shortSend(S,M,buf)
                else
                    longSend(S,nil,buf)
                end

                return true
            else
                error("WTF")
            end
        else
            return false
        end
    end,
}

--[[ Space measuring
local data={-- unit is width of 🟥 in MrZ's Linux NTQQ
    a={" ",0.1013},
    b={" ",0.1034},
    c={" ",0.1182}, -- good
    d={" ",0.1416}, -- good
    e={" ",0.1579},
    f={" ",0.1855},
    g={" ",0.1818},
    h={" ",0.20618}, -- good
    i={" ",0.2364},
    j={" ",0.3548},
    k={" ",0.3548},
    l={" ",0.4545},
    m={" ",0.7093},
    n={"　",0.7097}, -- good
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

▄▐▌
▀▗▖
　▝▘
▟▙▞▚
▜▛▚▞

𜹑𜹒𜹓𜹔𜹕𜹖𜹗𜹘𜹙𜹚𜹛𜹜𜹝𜹞𜹟𜹠𜹡𜹢𜹣𜹤𜹥𜹦𜹧𜹨𜹩𜹪𜹫𜹬𜹭𜹮𜹯𜹰𜹱𜹲𜹳𜹴𜹵𜹶𜹷𜹸𜹹𜹺𜹻𜹼𜹽𜹾𜹿𜺀𜺁𜺂𜺃𜺄𜺅𜺆𜺇𜺈𜺉𜺊𜺋𜺌𜺍𜺎𜺏
🬀🬁🬂🬃🬄🬅🬆🬇🬈🬉🬊🬋🬌🬍🬎🬏🬐🬑🬒🬓🬔🬕🬖🬗🬘🬙🬚🬛🬜🬝🬞🬟🬠🬡🬢🬣🬤🬥🬦🬧🬨🬩🬪🬫🬬🬭🬮🬯🬰🬱🬲🬳🬴🬵🬶🬷🬸🬹🬺🬻

▝▛
▝▙
▄▌

▜▖
▗▛
▙▖
▗▟
▄▄
█
▟▖

囜囡团団囚回囬囗
园圃囦囷圙圐圊囧

囙囝四困因囨囲囩
囤囯国囥囵圆図囸固
囫围囼囹图囶囮囻
囿圀圂圄圁圈圉國
圇圌圍圎園圓圕圑
圔團圖圗圚圜圛圝圞

ⒶⒷⒸⒹⒺⒻⒼⒽⒾⒿⓀⓁⓂⓃⓄⓅⓆⓇⓈⓉⓊⓋⓌⓍⓎⓏ
ⓐⓑⓒⓓⓔⓕⓖⓗⓘⓙⓚⓛⓜⓝⓞⓟⓠⓡⓢⓣⓤⓥⓦⓧⓨⓩ
⓪①②③④⑤⑥⑦⑧⑨
⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲
⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙
㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴
㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿

◼
🔴🟢🔵🟠🟣🟡🟤⚪️⚫️
🟥🟩🟦🟧🟪🟨🟫⬜⬛️ ⛝ 
🈲🈯♿🈚💟🚸💠🔲
♈♎♐♊♒♌⛎🔳
❤💚💙🧡💜💛🩵🤍🖤

💓💕💖💗💘💝💞💟
💔🤎🩷🩶

↵⇙⤾⤦⬃
]]
