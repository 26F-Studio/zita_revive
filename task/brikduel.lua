local min,max=math.min,math.max
local ins,rem=table.insert,table.remove

local repD,trimIndent=STRING.repD,STRING.trimIndent

local echoCnt=26
---@param S Session
local function tempSend(S,str)
    S:send(str,tostring(echoCnt))
    S:delayDelete(Config.groupManaging[S.id] and 260 or 100,tostring(echoCnt))
    echoCnt=echoCnt%2600+1
end

local bag0=STRING.atomize('ZSJLTOI')
local minoId={Z=1,S=2,J=3,L=4,T=5,O=6,I=7}
local minoEmoji={Z="🟥",S="🟩",J="🟦",L="🟧",T="🟪",O="🟨",I="🟫"}
local fullwidthMap={
    A='Ａ',B='Ｂ',C='Ｃ',D='Ｄ',E='Ｅ',F='Ｆ',G='Ｇ',H='Ｈ',I='Ｉ',J='Ｊ',K='Ｋ',L='Ｌ',M='Ｍ',N='Ｎ',O='Ｏ',P='Ｐ',Q='Ｑ',R='Ｒ',S='Ｓ',T='Ｔ',U='Ｕ',V='Ｖ',W='Ｗ',X='Ｘ',Y='Ｙ',Z='Ｚ',
    a='ａ',b='ｂ',c='ｃ',d='ｄ',e='ｅ',f='ｆ',g='ｇ',h='ｈ',i='ｉ',j='ｊ',k='ｋ',l='ｌ',m='ｍ',n='ｎ',o='ｏ',p='ｐ',q='ｑ',r='ｒ',s='ｓ',t='ｔ',u='ｕ',v='ｖ',w='ｗ',x='ｘ',y='ｙ',z='ｚ',
    ['0']='０',['1']='１',['2']='２',['3']='３',['4']='４',['5']='５',['6']='６',['7']='７',['8']='８',['9']='９',
    [' ']='　',
}

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
    norm={[0]="⬜","🟥","🟩","🟦","🟧","🟪","🟨","🟫","⬛️","❌"},
    puyo={[0]="◽","🔴","🟢","🔵","🟠","🟣","🟡","🟤","⚫️","❌"},
    emoji={[0]="◽","🈲","🈯","♿","🈚","💟","🚸","💠","🔲","❌"},
    star={[0]="◽","♈","♎","♐","♊","♒","♌","⛎","🔳","❌"},
    heart={[0]="◽","❤","💚","💙","🧡","💜","💛","🩵","🖤","❌"},
    circ={[0]="　","Ⓩ","Ⓢ","Ⓙ","Ⓛ","Ⓣ","Ⓞ","Ⓘ","⓪","Ｘ"}, -- [0] 1n
    han_x={[0]="　","囜","囡","团","団","囚","回","囬","囗","困"}, -- [0] 1n
    han_y={[0]="　","园","圃","囦","囷","圙","圐","圊","囧","圞"}, -- [0] 1n
}
---@enum (key) BrikDuel.Mark
local marks={
    norm="⬛⬛⬛ ４  ５  ６  ７ ⬛⬛⬛",
    norm2="⬛⬛⬛4⃣5⃣6⃣7⃣⬛⬛⬛",
    emoji="1⃣2⃣3⃣4⃣5⃣6⃣7⃣8⃣9⃣0⃣",
    text="１２３４５６７８９０",
    han_x="一二三四五六七八九〇",
    han_y="壹贰叁肆伍陆柒捌玖零",
}
local texts={
    help=trimIndent[[
        #duel（可略作#dl） 后接：
        (留空) 空房等人   @某人 发起决斗
        solo/AC/10L/[自定序列] 单人
        see 查看场地   stat 个人信息
        rule 规则手册   man 操作手册
        join/query [房号] 进房/查看房间状态
        end 取消/结束   leave 离开（保留房间）
        setm/setc 设置个性块/字符
        sets/setx/setn 设置皮肤/列号/预览样式
    ]],
    rule=trimIndent([[
        方块⚔决斗  规则手册
        控制指令可随意拼接并发送，指令表见操作手册
        当前块的位置信息不保存，必须一次性把块落到位
        SRS，场地十宽∞高，出现20垃圾行判负
        消N打N 卡块*2(不可移动) 连击+1 AC+4
        使用交换预览而非暂存(功能一致)
    ]],true),
    manual=trimIndent([[
        方块⚔决斗  操作手册
        ⌨️传统操作
            q/w:左/右移一格，可追加格数，大写Q/W移动到底
            c/C/f:顺/逆/180°旋转 x:交换预览
            d:硬降,大写软降到底，可追加目标离地高度
        👆快捷操作 [块名][朝向][位置](软降)
            块名(zsjltoi):必须从前两块里选
            朝向(0rfl或0123):旋转到指定朝向
            位置(1~9):将方块最左列置于场地指定列，10写作0
            可选软降(数字):软降到离地指定高度而不自动硬降
            例 ir0=i块竖着在十列硬降 tl90=t块朝左在第九十列软降
        方块不在原位时可用空格代替d硬降
        语法错误时会提示错误信息，不会执行
    ]],true),
    stat=trimIndent[[
        %s %s
        %d局 %d胜 %d负 (%.1f%%)
        %d步 %d块 %d攻 %d超杀(%d爆)
        %d币
        %s
    ]],
    stat_tooFrequent="查询太频繁了喵",
    setm_wrongFormat="个性方块必须是方块名称之一(ZSJLTOI)",
    setm_success="个性方块设置成功喵\n当前组合标识符：$1",
    setc_wizard="个性字符必须是严格的一个UTF8字符但获取到了$1个共$2字节，你需要的是$3($4字节)吗？",
    setc_success="个性字符设置成功喵\n当前组合标识符：$1",
    sets_help=trimIndent[[
        可用皮肤名称：
        norm:🟥🟧🟨🟩🟫🟦🟪⬜⬛️
        puyo:🔴🟠🟡🟢🟤🔵🟣◽⚫️
        emoji:🈲🈚🚸🈯💠♿💟◽🔲
        star:♈♊♌♎⛎♐♒◽🔳
        heart:❤🧡💛💚🩵💙💜◽🖤
        circ:ⓏⓁⓄⓈⒾⒿⓉ　⓪
        han_x:囜団回囡囬团囚　囗
        han_y:园囷圐圃圊囦圙　囧
    ]],
    sets_success="皮肤设置成功喵",
    setx_help=trimIndent[[
        可用列号名称：
        norm: ⬛ ６ 
        norm2: ⬛6⃣
        emoji: 2⃣6⃣
        text: ２６
        han_x: 二六
        han_y: 贰陆
    ]],
    setx_success="列号设置成功喵",
    setn_help="text:文字预览 [皮肤名]:皮肤预览",
    setn_success="预览模式设置成功喵",
    set_collide="你的个性方块+字符的组合和别人重复了喵",
    set_tooFrequent="每十分钟只能设置一次喵",

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
        solo="($1) 单人模式-$2\n$3",
    },
    game_modeName={
        solo="自由",
        ac="全消",
        ['10l']="十行",
    },
    game_moreLine="⤾$1行隐藏",
    game_spin="旋",
    game_clear={'单行','双清','三消','四方','五行','六边','七色','八门','九莲','十面'},
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
        updStat=true,
        autoSave=true,
        disposable=true,
        welcomeText='solo',
        seqType='bag',
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
        solo={
            modeName='solo',
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
---@field drop integer piece dropped
---@field line integer line cleared
---@field atk integer attack sent
---@field spin integer
---@field ac integer
---@field err integer
---@field overkill integer
---@field overkill_max integer
---@field __index BrikDuel.UserStat

---@class BrikDuel.UserSetting
---@field mino string
---@field char string
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
        move=0,drop=0,line=0,atk=0,
        spin=0,ac=0,err=0,
        overkill=0,overkill_max=0,
        __index=nil,
    },
    rec={},
    coin=0,
    set={
        mino="🟥",
        char="㉖",
        skin='norm',
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
            set=setmetatable({
                mino=TABLE.getRandom(TABLE.getValues(minoEmoji)),
                char=STRING.UTF8(math.random(0x1F300,0x1F5FF)),
            },User.set),
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

function User:getPfp()
    return self.set.char..self.set.mino
end

function User:getRec()
    local buf=STRING.newBuf()
    for k,v in next,self.rec do
        buf:put(k:upper()..": "..v.."秒   ")
    end
    return buf:get(#buf-3)
end

---@class BrikDuel.GameStat
---@field move integer
---@field drop integer
---@field line integer
---@field atk integer
---@field spin integer
---@field ac integer
---@field err integer

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
        stat={move=0,drop=0,line=0,atk=0,spin=0,ac=0,err=0},
        startTime=os.time(),
        lastUpdateTime=os.time(),
    },Game)
    return game
end

function Game:supplyNext(count)
    while #self.sequence<count do
        if #self.seqBuffer==0 then
            local bag=TABLE.copy(bag0)
            while bag[1] do
                ins(self.seqBuffer,rem(bag,self:random(#bag)))
            end
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

local cmdMap={
    z='pick',s='pick',j='pick',l='pick',t='pick',o='pick',i='pick',
    Z='pick',S='pick',J='pick',L='pick',T='pick',O='pick',I='pick',
    q='move',w='move',Q='move',W='move',
    c='rotate',C='rotate',f='rotate',
    d='drop',D='drop',
    x='swap',
    [' ']='sep',
}
function Game:parse(str)
    local buf=STRING.newBuf()
    buf:put(str)
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
            ctrl.piece=c:upper()
            c=buf:get(1) ptr=ptr+1
            assertf(c:match('[0123rfl]'),"[%d]快捷操作的朝向字符错误（应为0123rfl之一）",ptr)
            ctrl.dir=c=='0' and 0 or (c=='1' or c=='r') and 1 or (c=='2' or c=='f') and 2 or 3
            c=buf:get(1) ptr=ptr+1
            local posX=tonumber(c)
            assertf(posX and posX>=0 and posX<=9,"[%d]快捷操作的位置字符错误（应为0-9）",ptr)
            ctrl.pos=posX
            if ctrl.pos==0 then ctrl.pos=10 end
            assertf(ctrl.pos+pieceWidth[ctrl.piece][ctrl.dir]-1<=10,"[%d]快捷操作的位置超出场地",ptr)
            c=string.char(buf:ref()[0])
            if tonumber(c) then
                -- 软降不锁定，模拟读取成功
                clean=false
                ctrl.soft=tonumber(c)
                buf:skip(1) ptr=ptr+1
            else
                -- 默认硬降，多余读取
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
                    c=string.char(buf:ref()[0])
                    if tonumber(c) then
                        -- 指定移动格数，模拟读取成功
                        assertf(tonumber(c)~=0,"[%d]移动0格？",ptr)
                        ctrl.dx=ctrl.dx*tonumber(c)
                        buf:skip(1) ptr=ptr+1
                    else
                        -- 普通移动一格，无需调整ctrl.dx
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
                ctrl={act='rotate',dir=c=='c' and 1 or c=='C' and 3 or 2}
            elseif cmd=='drop' then
                if c=='d' then
                    rem(tempSeq,1)
                    clean=true
                    ctrl={act='drop'}
                elseif c=='D' then
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
                else
                    error("WTF")
                end
            elseif cmd=='swap' then
                assertf(#tempSeq>=2,"[%d]交换预览时序列长度不足2",ptr)
                tempSeq[1],tempSeq[2]=tempSeq[2],tempSeq[1]
                clean=true
                ctrl={act='swap'}
            elseif cmd=='sep' then
                if not clean then
                    rem(tempSeq,1)
                    clean=true
                    ctrl={act='drop'}
                end
            end
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
            curX,curY,dir,mat=self:spawnPiece()
            if self:ifoverlap(field,mat,curX,curY) then
                self.dieReason='suffocate'
                break
            end
        end
        self.stat.move=self.stat.move+1
    end
    if self.dieReason then
        self:lockPiece(field,mat,curX,curY)
    end
    -- TODO: ?
    return clears
end

function Game:getSequenceText()
    local buf=STRING.newBuf()
    local user=User.get(self.uid)
    buf:put(user:getPfp()..'  ')
    if user.set.next=='text' then
        for i=1,min(#self.sequence,7) do buf:put(fullwidthMap[self.sequence[i]]) end
    else
        local skin=skins[user.set.next]
        for i=1,min(#self.sequence,7) do buf:put(skin[minoId[self.sequence[i]]]) end
    end
    return tostring(buf)
end

function Game:getFieldText()
    local field=self.field
    local h=#field
    if h>0 then
        local buf=STRING.newBuf()
        local skin=skins[User.get(self.uid).set.skin]
        for y=h,max(h-9,1),-1 do
            if y~=h then buf:put("\n") end
            for x=1,10 do buf:put(skin[field[y][x]]) end
            if self.rule.tar=='line' and y==self.rule.tarDat-self.stat.line then buf:put('<<') end
        end
        if h>10 then buf:put(repD(texts.game_moreLine,h-10)) end
        buf:put("\n"..marks[User.get(self.uid).set.mark])
        return tostring(buf)
    else
        return texts.game_acFX[self.stat.ac<=5 and self.stat.ac or 6+self.stat.ac%3]
    end
end

function Game:getFullStateText()
    return self:getFieldText().."\n"..self:getSequenceText()
end

---@class BrikDuel.Duel
---@field id integer
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
        id=nil,
        sid=sid,
        member={user1,user2},
        game={},
        state=user2 and 'ready' or 'wait',
    },Duel)
    for _=1,10 do
        duel.id=math.random(1000,9999)
        if not duelPool[duel.id] then break end
    end
    if duelPool[duel.id] then return false end
    duelPool[duel.id]=duel
    return duel
end

function Duel:getFile()
    return 'brikduel/game_'..self.id
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
            TABLE.append(game.sequence,rule.startSeq)
        end
        if rule.seqType=='bag' then
            game:supplyNext(game.rule.nextCount)
        end
    end

    if self.autoSave then self:save() end

    if rule.welcomeText=='duel' then
        S:send(repD(texts.game_start.duel,
            self.id,
            CQ.at(self.member[1]),
            self.game[1]:getSequenceText(),
            self.game[2]:getSequenceText(),
            CQ.at(self.member[2])
        ))
    elseif rule.welcomeText=='solo' then
        S:send(repD(texts.game_start.solo,
            self.id,
            texts.game_modeName[rule.modeName] or rule.modeName:upper(),
            self.game[1]:getSequenceText()
        ))
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
        if game.dieReason then
            finish={reason=game.dieReason,id=i}
            break
        else
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
            if game.rule.seqType=='bag' then
                game:supplyNext(7)
            end
            if #game.sequence==0 then
                finish={reason='starve',id=i}
                break
            end
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
    -- Remove link to user
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

    -- Update stat
    local needSave
    for id,game in next,self.game do
        local user=User.get(self.member[id])
        if game.rule.updStat then
            for k,v in next,game.stat do
                user.stat[k]=user.stat[k]+v
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
                user.stat.overkill_max=max(user.stat.overkill_max,atkOverflow)
                if game.rule.reward then
                    user.coin=user.coin+min(math.floor(atkOverflow/5),5)
                end
                needSave=true
            end
        end
    end

    -- Result and dialog
    if info.result=='cancel' then
        self.finishedMes=repD(texts.game_finish.cancel,self.id)
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
            self.finishedMes=repD(texts.game_finish.solo,self.id).."：窒息"
        elseif #self.game==1 then
            self.finishedMes=repD(texts.game_finish.solo,self.id)
        else
            self.finishedMes=repD(texts.game_finish.norm,self.id)
        end
    elseif info.result=='interrupt' then
        self.finishedMes=repD(texts.game_finish.norm,self.id)
    end

    if not info.noOutput and #self.finishedMes>0 then
        S:send(self.finishedMes)
    end

    if needSave then User.save() end

    duelPool[self.id]=nil
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
        local mes=SimpStr(M.raw_message)

        ---@type BrikDuel.Duel
        local curDuel=D.matches[M.user_id]

        if mes:sub(1,1)=='#' then
            -- Convert alias "#duel" to "#dl"
            if mes:sub(1,5)=='#duel' then mes='#dl'..mes:sub(6) end

            if not mes:find('^#dl') then
                return false
            elseif mes:find('^#dlhelp')  then
                if S:lock('brikduel_help',62) then S:send(texts.help) end return true
            elseif mes:find('^#dlrule')  then
                if S:lock('brikduel_rule',62) then S:send(texts.rule) end return true
            elseif mes:find('^#dlman')   then
                if S:lock('brikduel_man',62) then S:send(texts.manual) end return true
            elseif mes:find('^#dlsee')   then
                if not curDuel then
                    if S:lock('brikduel_notInRoom',12) then S:send(texts.notInRoom) end
                else
                    local pid=TABLE.find(curDuel.member,M.user_id)
                    local game=curDuel.game[pid]
                    S:send(game:getFullStateText())
                end
                return true
            elseif mes:find('^#dlstat')  then
                if S:lock('brikduel_stat_'..M.user_id,26) then
                    local user=User.get(M.user_id)
                    local info=STRING.newBuf()
                    info:put(texts.stat:format(
                        user:getPfp(), CQ.at(user.id),
                        user.stat.game, user.stat.win, user.stat.lose, math.ceil(user.stat.win/max(user.stat.win+user.stat.lose,1)*100),
                        user.stat.move, user.stat.drop, user.stat.atk,
                        user.stat.overkill,user.stat.overkill_max,
                        user.coin,
                        user:getRec()
                    ))
                    if curDuel then
                        info:put("\n有一场对局("..D.matches[M.user_id].id..")进行中")
                    end
                    S:send(info)
                else
                    S:send(texts.stat_tooFrequent)
                end
                return true
            elseif mes:find('^#dlquery') then
                if S:lock('brikduel_query',12) then
                    local duel=duelPool[tonumber(mes:match('%d+'))]
                    if not duel then duel=D.matches[M.user_id] end
                    if duel then
                        S:send(repD(texts.query,
                            duel.id,
                            duel.member[1],
                            duel.member[2],
                            table.concat(duel.game[1].sequence," ")
                        ))
                    else
                        if S:lock('brikduel_noRoom',12) then
                            S:send(texts.query_noRoom)
                        end
                    end
                else
                    if S:lock('brikduel_queryTooFrequent',12) then
                        S:send(texts.query_tooFrequent)
                    end
                end
                return true
            elseif mes:find('^#dljoin')  then
                -- Ensure not in duel
                if curDuel then if S:lock('brikduel_inDuel',26) then S:send(texts.new_selfInGame) end return true end

                -- Parse roomID
                local roomID=tonumber(mes:match('%d+'))
                if not roomID then if S:lock('brikduel_wrongRoomID',6) then S:send(texts.join_wrongFormat) end return true end
                if not duelPool[roomID] then if S:lock('brikduel_noRoomID',6) then S:send(texts.join_noRoom) end return true end

                curDuel=duelPool[roomID]
                if curDuel.state~='wait' then if S:lock('brikduel_notWait',26) then S:send(texts.join_notWait) return true end end

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
                    if S:lock('brikduel_notInRoom',26) then S:send(texts.notInRoom) end
                end
                return true
            elseif mes:find('^#dlleave') then
                if curDuel then
                    -- TODO
                else
                    if S:lock('brikduel_notInRoom',26) then S:send(texts.notInRoom) end
                end
                return true
            elseif mes:find('^#dl$')     then
                -- Free room
                if curDuel then if S:lock('brikduel_inDuel',26) then S:send(texts.new_selfInGame) end return true end

                local newDuel=Duel.new(S.id,M.user_id)
                if newDuel then
                    D.matches[M.user_id]=newDuel
                    S:send(repD(texts.new_free,newDuel.id))
                else
                    if S:lock('brikduel_failed',26) then
                        S:send(texts.new_failed)
                    end
                end
                return true
            elseif mes:find('^#dlsetm')  then
                local newMino=minoEmoji[mes:sub(8):upper()]
                local user=User.get(M.user_id)
                if not S:lock('brikduel_setm'..M.user_id,setLimitTime) then
                    if S:lock('brikduel_set',6) then S:send(texts.set_tooFrequent) end
                    return true
                end
                if not newMino then S:send(texts.setm_wrongFormat) return true end
                for _,v in next,userLib do
                    if user.set.char==v.set.char and newMino==v.set.mino and M.user_id~=user.id then
                        S:send(texts.set_collide)
                        return true
                    end
                end
                user.set.mino=newMino
                User.save()
                S:send(repD(texts.setm_success,user:getPfp()))
                return true
            elseif mes:find('^#dlsetc')  then
                local newChar=mes:sub(8)
                local user=User.get(M.user_id)
                if not S:lock('brikduel_setc'..M.user_id,setLimitTime) then
                    if S:lock('brikduel_set',6) then S:send(texts.set_tooFrequent) end
                    return true
                end
                if STRING.u8len(newChar)>1 then
                    local autoClip=newChar:sub(1,STRING.u8offset(newChar,2)-1)
                    S:send(repD(texts.setc_wizard,STRING.u8len(newChar),#newChar,autoClip,#autoClip))
                    return true
                end
                for _,v in next,userLib do
                    if newChar==v.set.char and v.set.mino==v.set.mino and M.user_id~=user.id then
                        S:send(texts.set_collide)
                        return true
                    end
                end
                user.set.char=newChar
                User.save()
                S:send(repD(texts.setc_success,user:getPfp()))
                return true
            elseif mes:find('^#dlsets')  then
                local newSkin=mes:sub(8):lower()
                local user=User.get(M.user_id)
                if skins[newSkin] then
                    if not S:lock('brikduel_sets'..M.user_id,setLimitTime) then
                        if S:lock('brikduel_set',6) then S:send(texts.set_tooFrequent) end
                        return true
                    end
                    user.set.skin=newSkin
                    User.save()
                    S:send(texts.sets_success)
                else
                    S:send(texts.sets_help)
                end
                return true
            elseif mes:find('^#dlsetx')  then
                local newNum=mes:sub(8):lower()
                local user=User.get(M.user_id)
                if marks[newNum] then
                    if not S:lock('brikduel_setx'..M.user_id,setLimitTime) then
                        if S:lock('brikduel_set',6) then S:send(texts.set_tooFrequent) end
                        return true
                    end
                    user.set.mark=newNum
                    User.save()
                    S:send(texts.setx_success)
                else
                    S:send(texts.setx_help)
                end
                return true
            elseif mes:find('^#dlsetn')  then
                local newNext=mes:sub(8):lower()
                local user=User.get(M.user_id)
                if newNext=='text' or skins[newNext] then
                    if not S:lock('brikduel_setn'..M.user_id,setLimitTime) then
                        if S:lock('brikduel_set',6) then S:send(texts.set_tooFrequent) end
                        return true
                    end
                    user.set.next=newNext
                    User.save()
                    S:send(texts.setn_success)
                else
                    S:send(texts.setn_help)
                end
                return true
            else
                local exData=mes:sub(4)
                if ruleLib.solo[exData] or exData:match('^[zsjltoi]+$') then
                    -- Solo modes
                    if curDuel then
                        if curDuel.disposable then
                            curDuel:finish(S,D,{noOutput=true})
                        else
                            if S:lock('brikduel_inDuel',26) then S:send(texts.new_selfInGame) end
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
                            S:send(texts.new_failed)
                        end
                    end
                else
                    -- Versus modes
                    if curDuel then
                        if curDuel.disposable then
                            curDuel:finish(S,D,{noOutput=true})
                        else
                            if S:lock('brikduel_inDuel',26) then S:send(texts.new_selfInGame) end
                            return true
                        end
                    end

                    local opID=tonumber(M.raw_message:match('CQ:at,qq=(%d+)'))
                    if opID then
                        -- Invite mode
                        -- if opID==Config.botID   then if S:lock('brikduel_wrongOp',26)  then S:send(texts.new_botRefuse) end return true end
                        if opID==M.user_id then if S:lock('brikduel_wrongOp',26)  then S:send(texts.new_withSelf) end return true end
                        if D.matches[opID] then if S:lock('brikduel_opInDuel',26) then S:send(texts.new_opInGame) end return true end

                        local newDuel=Duel.new(S.id,M.user_id,opID)
                        if newDuel then
                            D.matches[M.user_id]=newDuel
                            D.matches[opID]=newDuel
                            S:send(repD(texts.new_room,newDuel.id,TABLE.getRandom(TABLE.getKeys(keyword.accept))))
                        else
                            if S:lock('brikduel_failed',26) then
                                S:send(texts.new_failed)
                            end
                        end
                    else
                        if S:lock('brikduel_wrongCmd',26) then
                            S:send(texts.wrongCmd)
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
                local ctrlMes=M.raw_message:match('^[qwQWcCfdDxzsjltoiZSJLTOIr0-9 ]+')
                if not ctrlMes then return false end

                local game=curDuel.game[pid]
                local suc,controls=pcall(game.parse,game,ctrlMes)
                if not suc then
                    game.stat.err=game.stat.err+1
                    tempSend(S,texts.syntax_error..controls:sub((controls:find('%['))))
                    return true
                end

                if #controls==0 then return false end

                -- print(TABLE.dumpDeflate(controls))
                local clears=game:execute(controls)
                curDuel:afterMove(S,D)

                local buf=STRING.newBuf()
                -- buf:put(CQ.at(M.user_id).."\n")
                buf:put(game:getFullStateText())
                for i,clear in next,clears do
                    buf:put(i==1 and "\n" or "  ")
                    if clear.spin then
                        buf:put(clear.piece..texts.game_spin..texts.game_clear[clear.line])
                    else
                        buf:put('('..clear.piece..')'..texts.game_clear[clear.line])
                    end
                    if clear.ac then
                        buf:put(texts.game_ac)
                    end
                end
                if curDuel.finishedMes then
                    buf:put("\n"..curDuel.finishedMes)
                    S:send(buf)
                else
                    tempSend(S,buf)
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

▄▐▌
▀▗▖
　▝▘
▟▙▞▚
▜▛▚▞

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

🔴🟢🔵🟠🟣🟡🟤⚪️⚫️
🟥🟩🟦🟧🟪🟨🟫⬜⬛️ ⛝ 
🈲🈯♿🈚💟🚸💠🔲
♈♎♐♊♒♌⛎🔳
❤💚💙🧡💜💛🩵🤍🖤

💓💕💖💗💘💝💞💟
💔🤎🩷🩶

↵⇙⤾⤦⬃
]]
