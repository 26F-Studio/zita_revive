---@class Zict.Entry
---@field word string
---@field title? string
---@field text? string|fun(S:Session):string
---@field detail? string
---@field link? string
---@field func? fun(words:string[]):string
---
---@field cat 'game'|nil
---@field shortname? string
---@field tags? string

--[[
    word是每个词条的查询关键词，多个名称用分号分隔，目前访问词条必须完全匹配其中的一个（不过英文字母大小写和空格会被忽略，例如a b c和ABC视为同一个东西）。
    title，第一行内容
    text，正文
    detail，可选，补充内容（用##来查询）
    link，可选，如果有的话会在最后一行显示为“相关链接：xxx.com”
    func，可选，用于实现特殊词条
]]

---@type Zict.Entry[]
local meta={
    {
        word="词典;小z词典;zict;zictionary",
        title="本词典是收集方块游戏相关词汇并加以解释供人检查参考的工具", 
    },
    {
        word="提问",
        text="提问时请尽量完整地描述问题，这样别人才更容易一句话解决问题，而不是不得不反复要求补充更多条件，一个人回答浪费一分钟，群里几百个人浪费几百分钟",
        detail="例：“【问题现象截图】我使用【设备类型】在【游戏名】【版本号】中遇到了【现象】，并且能用【具体操作】反复触发，这是bug吗？”\ngist.github.com/burningtnt/360d2b93452560c0413ac1a6e3515642",
    },
    {
        word="复读",
        text="？竟然对这个感兴趣吗…\n初始概率0.5%，随消息长度逐渐减小到0%\n每条没复读的消息+0.05%（最多二十条），每一条其他人的复读临时+6.26%",
        detail="每次复读26秒后进入冷静期，所有消息无效\n超过62字节和包含坏词的消息视为无效\n包含好词的消息+6.2%\n同一轮复读不会多次参与，多次参与的人也不计数",
    },
    {
        word="新人;萌新",
        text=CQ.img(Config.extraData.imgPath.."新人引导.png"),
    },
    {
        word="推荐;游戏推荐",
        text="对战→io js tec ppt\n单机→tech js tetr tec\n偷玩→tetr tech",
    },
    {
        word="分类",
        text=CQ.img(Config.extraData.imgPath.."方块游戏分类.png"),
    },
    {
        word="表格;游戏表格",
        text=CQ.img(Config.extraData.imgPath.."方块游戏表格.png"),
    },
    {
        word="赞助;打钱",
        text=CQ.img(Config.extraData.imgPath.."pay.png"),
    },
    {
        word="zone22;22zone;impossibilitris",
        text=CQ.img(Config.extraData.imgPath.."zone22教程.jpg"),
    },
    {
        word="zone23;23zone;infinitris",
        text=CQ.img(Config.extraData.imgPath.."zone23教程.png"),
    },
    {
        word="学习tspin;学习t旋",
        title="关于T-Spin学习",
        text="适合开始学T-Spin门槛水平参考：40L达到60s以内（速度够说明堆叠基本功过关）、能够轻松完成全程消四的40L（能稳定平整堆叠）、不使用Hold不降太多速度的前提下比较轻松完成全程消四的40L（有足够的看next的意识和算力）",
        detail="需要指出，要能熟练做出各种T-Spin并不是只看着T-Spin的那一小部分地形就可以玩好的，对玩家堆叠能力和计算next能力同样也有较高的要求。故如果目的主要是提升打块能力、没什么娱乐随便玩玩的成分时，推荐在基础能力没达到上述要求前不用去详细了解具体的T-Spin构造知识，把重点放在前置基本功的练习上就可以了",
    },
    {
        word="wiki;维基;中文wiki;中文维基",
        title="俄罗斯方块中文维基",
        text="俄罗斯方块中文百科全书，由中文玩家建立和维护。\n推荐新人有不懂的知识先查阅百科再提问，也欢迎各位玩家作出编辑贡献\n早期大部分条目译自Hard Drop Wiki和Tetris Wiki",
        link="tetriswiki.cn 或 t-wiki.cn 或 tetris.link",
    },
    {
        word="其他wiki;wiki列表;harddrop wiki;tetris wiki;fandom;wiki fandom;tetris wiki fandom",
        title="一些英文wiki",
        text="harddrop.com/wiki（Hard Drop社区的百科）\nhttps://tetris.wiki（Myndzi在2015年创办）\ntetris.fandom.com",
    },
    {
        word="fumen;方块谱;编辑器;铺面",
        title="Fumen",
        text="一个方块版面编辑器，可以用于分享定式，PC解法等，用处很多。设置里可以启用英文版",
        link="fumen.zui.jp  knewjade.github.io/fumen-for-mobile",
    },
    {
        word="tech仓库;techmino仓库",
        text="github.com/26F-Studio/Techmino\nTechmino的GitHub仓库地址，欢迎Star！",
    },
    {
        word="铁壳ios",
        text="【暂无数据】",
    },
    {
        word="铁壳mac",
        text=CQ.img(Config.extraData.imgPath.."techmino_mac.jpg"),
    },
    {
        word="宝石;宝石迷阵;bejeweled;bej;bej1;bej2;bej3;bejT;bejeweled1;bejeweled2;bejeweled3;bejeweled twist",
        title="Bejeweled Series",
        text="三消系列神作，类比现代块之于经典块的进步，Bej系列每一作都是前无古人后无来者的“现代三消”，BejT和Bej3的三消玩法至今未被超越",
        link="b23.tv/BV1sE421P7dE  b23.tv/BV1TE421A7wG",
    },
    {
        word="气泡;魔法气泡;噗哟;噗哟噗哟;puyo;puyopuyo",
        text="魔法气泡，一款相同颜色连起来就消除的游戏（有请其他群友解释）",
    },
}
---@type Zict.Entry[]
local main={
    -- 缩写
    {
        word="marathon;马拉松;马拉松模式",
        title="马拉松模式",
        text="#Guideline 规定官方Tetris的三个必备模式之一，直接来自于经典块的玩法，考察固定等级/行数内的得分。绝大多数游戏中是15级/150行，等级/重力/倍率逐渐增加",
    },
    {
        word="40l;40line;40lines;sprint;time attack;竞速;竞速模式",
        title="竞速模式/40行模式",
        text="#Guideline 规定官方Tetris的三个必备模式之一，考察消除固定行数的用时。一般是消40行，没有其他限制",
    },
    {
        word="ultra;time trial;限时打分;限时极限;限时打分模式;限时极限模式",
        title="限时打分模式",
        text="#Guideline 规定官方Tetris的三个必备模式之一，考察固定时间内的得分或消行数。一般是2或3分钟，没有其他限制",
    },
    {
        word="blitz;blitz模式",
        title="Blitz模式",
        text="TETR.IO结合马拉松与限时打分两大传统模式的新规则限时打分，考察2分钟内的得分，但是等级/重力/得分倍率逐渐增加\n另见 #Tetris Blitz",
    },
    {
        word="zen;禅;禅模式",
        title="禅模式",
        text="（无尽）休闲模式，灵感很可能来自宝开早年游戏。方块里的此模式都会被设计成没有速度要求，但是否无尽不一定",
    },
    {
        word="mph",
        title="Memoryless-Previewless-Holdless",
        text="一个游戏模式，纯随机块序+无Next+无Hold，目标通常是完成40L，非常考验玩家反应速度",
    },
    {
        word="lpm;bpm;ppm;pps;kpm;kps",
        title="速度",
        text="Line per Min，每分钟消行数\nPiece/Block/Drop per Min/Sec，每分钟/每秒落块数\nKey per Min/Sec，每分钟/每秒按键数",
        detail="不同游戏中的“LPM”含义可能不同，虽然写的是行数但可能实际用的是块数/2.5，以此忽略掉对战模式中垃圾行带来的干扰",
    },
    {
        word="kpp;按键效率",
        title="Key per Piece",
        text="每块按键数，体现玩家按键效率高低，操作是否繁琐。\n与多余操作数量相关但并不完全挂钩，学习 #极简操作 提升操作效率可以降低此数字",
    },
    {
        word="apm;spm",
        title="Attack(Sent) per Min",
        text="每分钟攻击(送出)行数\n对手先打来垃圾行自己抵消时不计入送出，但仍然计攻击",
    },
    {
        word="dpm",
        title="Dig per Min",
        text="每分钟挖掘行数，玩家每分钟向下挖掘的垃圾行数\n另外一些游戏中dpm表示Drop per Min，相当于Piece per Min，每分钟落块数",
    },
    {
        word="adpm;vs",
        title="Atk & Dig per Min",
        text="每分钟攻击+挖掘行数，衡量玩家对战水平的指标，比APM更准确一些。在TETR.IO中叫“VS Score”的数据实质与ADPM相同，只是考虑到数据大小从每分钟调整为每100秒（也就是Atk & Dig per 100s）",
    },
    {
        word="apl;效率",
        title="Attack per Line",
        text="每行攻击数，衡量玩家消行的攻击效率。例如消四的效率就比消二高（消四打4➗4行=1效；消二打1➗2行=0.5效）\n另见 #按键效率",
    },
    {
        word="tas",
        title="Tool-Assisted Speedrun (Supergaming)",
        text="简称tas，使用特殊软件/工具在仅仅不破坏游戏规则（游戏程序层面的规则）的条件下进行游戏\n一般用于冲击理论值或者达成各种有趣的目标用来观赏",
    },
    {
        word="timing",
        title="Timing",
        text="Time作动词时的动名词形式，意为抓时机。在方块中基本是根据双方形势决定自己的策略选择时机攻击，或者故意吃下对手的攻击来给对手输出更多伤害",
        detail="Timing可以一定程度上提高对战的优势，但这是偏后期的内容，有看双方场框分析形势的精力不如把自己的场地看明白，提速提效的收益更大",
    },
    {
        word="sub",
        title="sub",
        text="英语词缀，在……之下\n用于表示成绩，不说项目默认是40L，单位一般可不写，比如40L成绩Sub 30是秒，1000行Sub 15是分钟",
        detail="例：39.95s是Sub 40，40.1s不是Sub 40\n不建议使用Sub 62之类的词，因为sub本身就是表示大约，一分钟左右的成绩精确到5~10s就可以了，大约30s内的成绩用sub表示的时候精确到1s才比较合适",
    },
    {
        word="freestyle;free",
        title="Freestyle",
        text="自由发挥，常用于freestyle TSD (T2)，指不用固定的堆叠方式而是随机应变完成20TSD。比用LST或者垃圾分类完成的20 TSD的难度要大，成绩也更能代表实战水平",
    },
    {
        word="glhf",
        title="Good luck have fun",
        text="“祝好运 玩得开心”，打招呼用语，可以原样回复",
    },
    {
        word="golf",
        title="glhf的整活版本",
    },
    {
        word="gg;ggs",
        title="Good game(s)",
        text="“打得不错”，游戏结束时的常用语，可以原样回复",
    },
    {
        word="ggwp",
        title="Good game(s), well played",
        text="“打得不错”，游戏结束时的常用语，可以原样回复",
    },
    {
        word="eggs",
        title="ggs的整活版本",
    },
    -- 消除名
    {
        word="quad;techrash;消四",
        title="消四",
        text="一次消除四行",
        detail="Tetris中的消四有特殊的名称Tetris，有的非官方游戏考虑到版权问题，使用Quad替换，也有一些游戏保留了这个传统，会给消四安排一个特殊的名称，例如Techmino里的Techrash",
    },
    {
        word="tetris",
        title="Tetris",
        text="商标，Tetris游戏名，同时也是“消四行”的名字\n另见 #消四",
        detail="含义是Tetra（四，古希腊语词根）+Tennis（网球 游戏原作者喜欢的运动）\n现在商标权在TTC (The Tetris Company)手上，任天堂、是获得TTC授权才开发方块游戏的，并不拥有Tetris这一商标",
    },
    {
        word="全消;全清;ac;pc;all clear;perfect clear;bravo",
        title="All Clear",
        text="消除场地上所有的方块，也叫Perfect Clear，全消，或全清\n另见 #Half Clear #Color Clear #全消开局",
    },
    {
        word="半全消;半全清;hc;hpc;half clear",
        title="Half Clear",
        text="Techmino限定，All Clear的外延，“下方有剩余方块”的全消（特别地，如果只消1行则必须不剩余玩家放置的方块），能打出一些攻击和防御（）\n另见 #Color Clear",
    },
    {
        word="color clear;颜色消除;颜色清除",
        title="Color Clear",
        text="TETR.IO限定，All Clear的外延，消除场地上所有彩色的方块（垃圾行通常是灰色的）\n另见 #Half Clear",
    },
    -- 旋转相关
    {
        word="spin;tspin;t-spin",
        title="Spin",
        text="使用旋转将方块卡进一些不能直接移动进入的位置（根据具体语境也可能会指同时消行了的），通常会有额外的分数/攻击加成\n另见 #三角判定 #不可移动判定 #Mini #All-Spin",
        detail="具体判定规则不同游戏不一样，例如一个常见的规则（三角判定）是当T方块在锁定前的最后一个操作是旋转，并且锁定后旋转中心对应的四个斜角位置有三个不是空气，那么这就是一个T-Spin",
    },
    {
        word="tri-corner;三角;三角判定",
        title="三角判定",
        text="Spin的判定方法之一，也是Guideline唯一指定的判定方法\n对于T块，当方块锁定前的最后一次运动是旋转且旋转中心的四个斜角位置有三个不是空气，那么就是Spin",
        detail="除T外的其他方块并不存在像T块那样的四个“角”，但在一些官方游戏的技术细节中可以扒出它们的“角”的位置，应该也是有内部规范的。例如S/Z的四个“角”是S/Z平放时和方块左右侧直接接触的四个点位",
    },
    {
        word="immobile;不可移动;不可移动判定;卡块;卡块判定",
        title="不可移动判定",
        text="Spin的判定方法之一，只要方块锁定时处于不可再平移的位置，那么就是Spin",
    },
    {
        word="mini",
        title="Mini Spin",
        text="一些游戏会使用Mini标签来对部分Spin进行弱化，不同游戏的判定差异很大且通常很复杂，建议只记住常见形状即可",
    },
    {
        word="all spin;all-spin",
        title="All-Spin",
        text="规则名，指用所有方块进行Spin消除都能获得奖励，而不是通常仅T-Spin才能打出攻击(T-Spin Only)\n另见 #All-Mini",
    },
    {
        word="all mini;all-mini",
        title="All-Mini",
        text="IO专有的All-Spin的一个亚种，相比原来的仅T-Spin，其余方块使用不可移动的spin判定不过都视为mini（基础攻击=行数-1，计b2b）。此规则已默认用于TL和QP。",
    },
    {
        word="tss;tsd;tst",
        title="TSS/TSD/TST",
        text="T-Spin Single/Double/Triple，使用T方块Spin并消除1/2/3行，也称T1/T2/T3。其中T3需要旋转系统支持才可能打出",
    },
    {
        word="ospin;o-spin",
        title="O-Spin",
        text="由于O块旋转不变只能左右移所以经常被卡住，于是就有了O-Spin这个梗",
        detail="有人做了T99/TF中的O块变形的特效视频广为流传；\n一些旋转系统允许O块旋进坑；\nTech设计的变形系统中可以旋转O来变形/传送进入一些特定形状的洞\n"..CQ.img(Config.extraData.imgPath.."ospin.gif"),
    },
    {
        word="踢墙;踢墙表;旋转系统;rs;rotation system",
        title="旋转系统",
        text="现代方块游戏中，方块一般能绕着固定的旋转中心旋转："..CQ.img(Config.extraData.imgPath.."旋转中心.gif").."如果旋转后和场地或墙壁有重合，会根据一些规则尝试移动方块到附近的空位来让旋转成立而不是卡住转不动",
        detail="(类)SRS旋转系统通常根据【从哪个方向转到哪个方向】选取一个偏移列表（也叫踢墙表），方块根据这个列表进行位置偏移（这个过程叫踢墙），于是就可以钻进入一些特定形状的洞。不同旋转系统的具体踢墙表可以在各大Wiki查到",
    },
    {
        word="朝向;方块朝向;direction",
        title="方块朝向",
        text="在(类)SRS旋转系统中需要说明方块朝向的时候，“朝下”“竖着”等词描述太模糊，所以使用0-R-2-L来表示方块从原位开始顺时针转一圈的四个状态",
        detail="通常见于SRS踢墙表的行首，0→L表示原位逆时针转一次到L状态，0→R表示原位顺时针转一次到R状态，2→R代表从180°状态逆时针转一次到R状态",
    },
    {
        word="asc rs;ascension rs",
        title="ASC Rotation System",
        text="ASC块使用的旋转系统，所有块所有形状只根据旋转方向（顺时针和逆时针）使用两个对称的表，可达范围大致是两个方向±2",
    },
    {
        word="birs;bias rs",
        title="Bias Rotation System",
        text="Techmino原创旋转系统，基于XRS和SRS设计，有“指哪打哪”的特性",
        detail="当左/右/下(软降)被按下并且那个方向顶住了墙，会在旋转时添加一个额外偏移（三个键朝各自方向加1格），和基础踢墙表叠加（额外偏移和叠加偏移的水平方向不能相反，且叠加偏移的位移大小不能超过√5）。如果失败，会取消向左右的偏移然后重试，还不行就取消向下的偏移\nBiRS相比XRS只使用一个踢墙表更容易记忆，并且保留了SRS翻越地形的功能",
    },
    {
        word="c2rs;cultris2 rs",
        title="Cultris II Rotation System",
        text="Cultris II原创的旋转系统，所有旋转共用一个表：左1→右1→下1→左下→右下→左2→右2（注意左永远优先于右）",
    },
    {
        word="srs;super rs;super rotation system",
        title="Super Rotation System",
        text="现代方块最常用的旋转系统，也是不少自制旋转系统的设计模板",
        detail="在SRS中，每个方块有四个朝向，每个朝向时可以向顺逆两个方向旋转（SRS并不包含180°旋转），总共4*2=8种动作对应8个偏移表，方块旋转失败时会根据偏移表的内容尝试移动方块让旋转成立，具体数据可以去各大Wiki查",
        link="tetriswiki.cn/p/Super_Rotation_System",
    },
    {
        word="srs plus;srs+",
        title="SRS+",
        text="SRS的拓展版，添加了180°转的踢墙表",
    },
    {
        word="trs;tech rs;techmino rs",
        title="Techmino Rotation System",
        text="Techmino原创旋转系统，基于SRS增加了不少实用踢墙，还修补了SZ卡死等小问题",
        detail="每个五连块也基本按照SRS的Spin逻辑单独设计了踢墙表，更有神奇O-spin等你探索！",
    },
    {
        word="xrs",
        title="X Rotation System",
        text="T-ex原创旋转系统，引入了“按住方向键换一套踢墙表”的设定（在对应的方向需要顶住墙），让“想去哪”能被游戏捕获从而转到玩家希望到达的位置",
        detail="其他旋转系统无论踢墙表怎么设计，块处在某个位置时旋转后最终只能按固定顺序测试，这导致不同的踢墙是竞争的，若存在两个可能想去的位置就只能二选一，XRS解决了这个问题",
    },
    -- 其他
    {
        word="b2b;back to back",
        title="Back to Back",
        text="简称B2B，连续的消行都是特殊消行（Spin或消四），中间不夹杂普通消行",
    },
    {
        word="fin;neo;iso;特殊t2;可移动t2",
        title="Fin/Neo/Iso",
        text="三类特殊T2的名字，受不同具体规则影响，在不同的游戏内的效果可能不一样，通常没有实战价值",
    },
    {
        word="现代块;现代方块;modern tetris",
        title="现代方块",
        text="“现代方块”并不是一个明确的概念，只要模糊地满足一些“标准”规则就可以称为现代方块了，发送“##”查看细节",
        detail="1.可见场地大小是10×20；\n2.七种块从顶部正中间出现（3格宽的块偏左），同种方块的颜色和朝向一致；\n3.合适的随机出块机制，另见 #7-Bag；\n4.至少有两个旋转键和合适的旋转系统，另见 #SRS；\n5.合适的 #锁定延迟 系统；\n6.合适的 #死亡判定 系统；\n7.有 #Next 和 #Hold 系统",
    },
    {
        word="经典块;经典方块;classical tetris;classic tetris",
        title="经典方块",
        text="“经典方块”是一个模糊的概念，指设计比较简单（通常是因为时间早，所以才称经典）的方块游戏，和“现代方块”对立\n另见 #现代方块",
    },
    {
        word="tetrimino;tetromino;tetramino;四连块;四联块;四连方块;四联方块;形状;方块形状",
        title="四连块",
        text="四个正方形共用边连接成的形状，在不允许翻转的情况下共有七种，根据形状命名为Z S J L T O I"..CQ.img(Config.extraData.imgPath.."七块.jpg"),
    },
    {
        word="pentamino;pentomino;五连块;五联块;五连方块;五联方块",
        title="五连块",
        text="类似四连块但增加到五个正方形，在不允许翻转的情况下共有18种，命名方案不统一，其中一套是S5 Z5 P Q F E T5 U V W X J5 L5 R Y N H I5",
    },
    {
        word="一连块;二连块;三连块;六连块;七连块;八连块;九连块;二十六连块",
        text="别闹",
    },
    {
        word="配色;颜色;方块颜色;标准配色;方块配色",
        title="方块配色",
        text="七种块的颜色通常使用同一套彩虹配色：Z-红 L-橙 O-黄 S-绿 I-青 J-蓝 T-紫\n#Guideline 规则的一部分",
    },
    {
        word="预输入;buffered input;提前旋转;提前暂存;提前移动;irs;ihs;ims",
        title="预输入",
        text="Buffered Input（也叫Initial ** System 提前[动作名称]系统），比如在方块还没有出现的时候就按旋转键，方块会在出现后立刻旋转",
        detail="优秀的操作密集型游戏通常会设计预输入功能，可以降低对玩家操作精度的要求，扩大完美操作的输入窗口，显著提升了游戏手感。甚至增加更多有深度的机制",
    },
    {
        word="预览;下一个;next",
        title="预览",
        text="场地旁边的一个区域，显示了后边几个即将出现的块",
    },
    {
        word="暂存;交换;hold",
        title="暂存",
        text="将手上的方块丢入Hold槽中，否则和已有的方块交换。用来调整块序，更容易摆出你想要的形状",
    },
    {
        word="硬降;软降;瞬降",
        title="软降 & 硬降",
        text="方块下移的操作有几种：\n硬降：将方块立刻下移到底并锁定\n软降：将方块下移但不锁定\n瞬降：软降的变种，将方块瞬间下移到底但不锁定",
    },
    {
        word="深降;deepdrop",
        title="深降",
        text="允许方块向下穿越地形进入地下的空洞",
    },
    {
        word="md;misdrop;mishold",
        title="Misdrop",
        text="误放，由于各种原因导致不小心把块放错了地方，简称MD",
    },
    {
        word="捐赠;donate;donation",
        title="捐赠",
        text="指刻意临时堵住（可以消四的）洞做T-Spin，打出T-Spin后就会解开，是比较进阶的保持/提升火力的技巧\n有时候只要堵住了个坑，即使不是消四的洞也会用这个词",
    },
    {
        word="削减;skim;skimming",
        title="削减",
        text="指有意识地通过特定的普通消行改善地形，例如消四堆叠时用普通消行整地等待I块、对战时用特定技巧把地形削成T-Spin形状",
    },
    {
        word="攻击;进攻;防守;防御;攻防",
        title="对战攻防",
        text="攻击：通过消除给对手发送垃圾行；\n防御（相杀）：用攻击抵消别人送来但还没上涨的垃圾行；\n反击：故意吃下对手的攻击（不抵消）然后再进行反击",
    },
    {
        word="连击;combo;ren",
        title="连击",
        text="连续落块并完成消除。从第二次起称为 1 Combo，攻击数取决于具体游戏。\n“REN”的说法来源于日语的“連”(れん)",
    },
    {
        word="spike",
        title="Spike",
        text="爆发攻击，指短时间内打出大量的攻击，一些游戏有Spike计数器，可以看到自己短时间内打出了多少攻击",
    },
    {
        word="s1w;90堆叠;09堆叠",
        title="Side 1 Wide",
        text="旁边空1列，是传统方块游戏里常见的消四打法",
        detail="在现代方块对战中新手可以使用，是基础的达到1apl的方法，不过在高手场出场率不高，因为效率低，容易被对面一波打死，故只在极少数情况合适的时候用",
    },
    {
        word="s2w",
        title="Side 2 Wide",
        text="旁边空2列，是常见的连击打法",
        detail="难度很低，现代方块对战中新手可以使用，结合Hold可以很轻松地打出大连击。高手场使用不多，因为准备时间太长，会被对面提前打进垃圾行，导致连击数减少或者暴毙，效率也没有特别高，故一套打完也不一定能杀人",
    },
    {
        word="s3w",
        title="Side 3 Wide",
        text="旁边空3列，比2w少见一些的连击打法",
        detail="能打出的连击数比2w多，但是难度略大容易断连",
    },
    {
        word="s4w",
        title="Side 4 Wide",
        text="旁边空4列，比较特殊的连击方法",
        detail="因为空得特别多所以能打出很高的连击，每多堆一行就能多连击一次从而实现接近20连击，不过需要游戏拥有比较强大的 #旋转系统，否则会大幅降低连击成功概率。\n另见 #N-Res",
    },
    {
        word="c1w",
        title="Center 1 Wide",
        text="中间空1列，一种实战里消4同时辅助打TSD的打法，需要玩家理解“平衡法”，熟练之后可以轻松消四+T2输出",
    },
    {
        word="平衡法",
        title="平衡法",
        text="（可能不准确）普通T2槽需要两侧同高，平衡法指玩家控制空列两侧高度使其一致（平衡），以便构造T旋的方法",
    },
    {
        word="c2w;c3w",
        title="Center 2/3 Wide",
        text="中间空2/3列，一种可能的连击打法（通常不单独使用）",
    },
    {
        word="c4w;吃四碗",
        title="Center 4 Wide",
        text="中间空四列，比s4w在对战中有更大的优势",
        detail="在 #s4w 的基础上利用了 #死亡判定 机制，可以更放心堆高而不用太担心被瞬间顶死。属于稍不平衡策略（尤其在开局时），打多了千篇一律还容易以弱胜强，所以c4w成为了部分游戏中约定的“禁招”，滥用容易招致批评\n另见 #N-Res",
    },
    {
        word="n-res",
        title="N-Residual",
        text="N-剩余，指4w连击楼底部留几个方格，常用的是3-Res和6-Res",
        detail="3-Res路线少比较好学，成功率也很高，实战完全够用，6-Res路线多更难用，但是计算力很强的话比3-Res更稳\n如果不用3/6-Res，次选是5-Res，最后才是4-Res",
    },
    {
        word="63;63堆;63堆叠;36;36堆;36堆叠",
        title="6–3堆叠",
        text="指左边6列右边3列的堆叠方式。在玩家有足够的计算能力后可以减少堆叠所用的按键数（反之可能甚至会增加），是主流的用于减少操作数的高端40L堆叠方式，左6右3的原因与出块位置是中间偏左有关。",
    },
    {
        word="72;72堆;72堆叠;27;27堆;27堆叠",
        title="7-2堆叠",
        text="左边七列右边两列的堆叠方式。最常见的7-2堆叠是用来打20TSD的LST。",
    },
    {
        word="81;81堆;81堆叠;18;18堆;18堆叠;8-1 stacking;1-8 stacking",
        title="8-1堆叠",
        text="左边八列右边一列的堆叠方式。在对战中，这是所有空一列(1w)堆叠策略中最难维持 B2B 的一种。\nTETR.IO有一项挑战性成就，就是使用8-1或1-8堆叠进行10次消四，完成40行。",
    },
    {
        word="54;54堆;54堆叠;45;45堆;45堆叠",
        title="5-4堆叠",
        text="左边五列右边四列的堆叠方式，#c1w 的一种。",
    },
    {
        word="block out;lock out;top out;死亡;死亡判定",
        title="死亡判定",
        text="现代方块普遍使用几条死亡判定：窒息/锁定在外/超高",
        detail="窒息(Block Out)：新出的方块和场地内已有块重叠（c4w对比s4w的优势，被顶18行都不会死）；\n锁定在外(Lock Out)：方块锁定时完全在场地的外面（20行以上）；\n超高(Top Out)：场地内现存方块总高度大于40\n注：窒息几乎在所有游戏中都被使用，其他的就不一定",
    },
    {
        word="缓冲区",
        title="缓冲区",
        text="指10×20可见场地之上的21~40行（如果有）。垃圾行顶起后两侧堆高的方块可能会超出屏幕但并不影响方块生成，还可能会重新消下来，所以场地的实际高度是超过20的，一般为40就够用\n另见 #消失区",
    },
    {
        word="消失区",
        title="消失区",
        text="在缓冲区的基础上，指比40行缓冲区还高的区域\n标准的死亡判定涉及了这个概念，如果场地上有任何方块超出了40高的缓冲区（也就是达到了消失区）时游戏直接结束\nJstris中22行开始就是消失区，超出21行外的格子会立刻消失",
    },
    {
        word="等级;下落速度;重力;gravity",
        title="下落速度",
        text="一般用*G表示方块的下落速度，指方块每帧往下移动多少格，一秒落一格就是1/60G（默认60fps）\n另见 #20G",
    },
    {
        word="20g",
        title="20G",
        text="现代方块的最高下落速度(无限)，瞬间到底、下落过程完全不可见，会让方块无法跨越壕沟或攀爬台阶",
        detail="因为一般场地就是20高，所以20G的意思其实同∞G\n一些游戏中ASP调成0可能可以让方块飞跃山谷，但考虑“高重力”这个项目的玩法，其实不该如此，例如Techmino中20G的优先级比移动高一层，ASP=0的“瞬间移动”中途也会受到20G的影响掉入深坑",
    },
    {
        word="锁定延迟;lock delay",
        title="锁定延迟",
        text="方块“碰到地面”到“锁定”之间的时间。经典块仅方块下落一格时刷新倒计时，而现代方块里往往任何操作都能重置计时器，所以一直操作就可以拖延时间。（重置次数有限，通常不能无限拖下去）",
    },
    {
        word="生成延迟;spawn delay;are",
        title="生成延迟",
        text="“上一个方块锁定完成”到“下一个方块出现”之间的时间。“are”的命名来自日文“あれ”，意思是“那个”（不好描述的东西）",
    },
    {
        word="消行延迟;clear delay;line clear delay;line are",
        title="消行延迟",
        text="方块锁定且消行时，“消行动画”占据的时间",
    },
    {
        word="极简;finesse;极简操作",
        title="极简操作",
        text="用最少的按键数将方块移到想去的位置的技术，能提升操作效率、节约时间、减少Misdrop\n建议学习越早越好，可以先去找教程视频看懂然后自己多练习，刚开始快慢不重要，准确率第一，熟练后自然就快了",
        detail="一般说的极简不考虑带软降/高重力/场地很高的情况，仅研究空中移动/旋转后硬降。绝对理想的“极简”建议使用“最少操作数/按键数”表达",
    },
    {
        word="1kf;一键到位;一键极简",
        title="1kf",
        text="一键到位（One Key Finesse，简称 1kf，直译「一键极简」）是一种特殊的方块控制方式。组合所有10列的水平位置与4种旋转状态，用40个键足以覆盖所有的落块选择，使得把块落在任意位置都只需一次按键"
    },
    {
        word="科研",
        title="科研",
        text="指在低重力（或无重力）的单人模式里慢速思考如何构造各种T-Spin，是一种练习方法",
    },
    {
        word="键位",
        title="键位设置原则参考",
        text="1.不要让一个手指管两个可能同时按的键（一般除了旋转键都要安排一个）\n2.不要用不灵活的手指（比如没锻炼过的小指），所有的操作频率都较高",
        detail="*3.根据2021/8的统计，Jstris的40L前一千名中95%的玩家都用右手（惯用手）控制移动\n*4.没必要照抄别人的键位，只需参考前几条就几乎不会对成绩产生影响，可以放心",
    },
    {
        word="手感",
        title="手感",
        text="决定手感因素的有很多，包括设备/程序bug/设计故意/设置不当/姿势不当/新条件不适应/身体疲劳",
        detail="1. 输入延迟受设备配置或者设备状况影响。可以重启/换设备解决；\n2. 程序运行稳定性程序设计或.实现）得不好，时不时会卡一下。把设置画面效果拉低可能可以缓解；\n3. 游戏设计故意的。自己适应；\n4. 参数设置设置不当。去改设置；\n5. 游玩姿势姿势不当。不便用力，换个姿势；\n6. 换键位或者换设备后不适应，操作不习惯。多习惯习惯，改改设置；\n7. 肌肉疲劳反应和协调能力下降。睡一觉或者做点体育运动，过段时间（也可能要几天）再来玩",
    },
    {
        word="das通俗;asd通俗",
        title="ASD通俗",
        text="打字时按住o，你会看到：oooooooooo…\n在时间轴上：o—————o-o-o-o-o-o-o-o-o…\n其中—————就是asd（自动移动延迟），-就是asp（自动移动间隔）\n另见 #ASD/ASP",
    },
    {
        word="asd;asp;asd/asp;das;arr",
        title="ASD/ASP",
        text="ASD（曾叫DAS）指从“按下移动键时动一格”到“开始自动移动”之间的时间\nASP（曾叫ARR），指“每次自动移动”之间的时间，单位可以是f(帧)或者或者ms(毫秒)，1f≈16.7ms\n另见 #ASD通俗 #ASD设置引导",
        link="tetriswiki.cn/p/DAS",
        detail="Auto-Shift-Delay，自动移动延迟；Auto-Shift-Period，自动移动间隔",
    },
    {
        word="asd设置引导;asd设置;asd引导;asd教程;asd调节;das设置引导;das设置;das引导;das教程;das调节",
        title="ASD设置引导",
        text="学会极简操作后推荐ASP=0，ASD=4~6（具体看自己的手部协调性）\n新人如果实在觉得太快可以适当增加一点ASD，但ASP要改的话强烈建议不要超过2",
        detail="最佳调整方法：ASD越小越好，小到依然能准确区分单点/长按为止；ASP能0就0，游戏不允许的话就能拉多小拉多小",
    },
    {
        word="asd打断;das打断;dcd;das cut;das cut delay",
        title="ASD打断",
        text="不同游戏中的具体机制可能不同，但目的基本都是为了让方块控制不那么容易“滑”",
        detail="此处仅解释Techmino中的机制：当玩家的操作焦点转移到新方块的瞬间，减小（或重置）ASD计时器，让自动移动不立刻开始，以此减少“移动键松开晚了导致下一块刚出来就飞走”的情况。其他游戏可能会在不同的时机影响ASD计时器",
    },
    {
        word="sdf;软降倍率",
        title="软降倍率",
        text="Soft Drop Factor，软降速度倍率\n几乎所有官块和TETR.IO中，“软降”的实际效果是当软降键被按住时，方块受到的重力变为原来的若干倍，SDF就是这个变大的倍数",
    },
    {
        word="7bag;bag7;bag",
        title="7-Bag出块",
        text="一种出块方式，从开局起每7个块是7种形状各一个，避免了很久不出某个块和某个块来得特别多，现代方块普遍使用该规则，是一些战术的基础\n例：ZSJLTOI ZJOLIST",
        link="tetriswiki.cn/p/Bag_Randomizer",
    },
    {
        word="his;his4;h4r6",
        title="History出块",
        text="一种出块方式，例如h4r6 (His4 Roll6)是在随机新块的时候若和最近4次已经生成的Next中有一样的就重新随机，直到和那4个都不一样或者已经随机了6次",
        link="tetriswiki.cn/p/Nintendo_Randomizer",
        detail="这是早期对纯随机出块的一大改进，大大减小了连续出几个SZ(洪水)的概率，但偶尔还是会很久不出现某一块比如I，导致发生干旱",
    },
    {
        word="hispool",
        title="HisPool出块",
        text="一种出块方式，History Pool，his算法一个比较复杂的分支，在理论上保证了干旱时间不会无限长，最终效果介于His和Bag之间",
        link="tetriswiki.cn/p/TGM_Randomizer",
        detail="在His的基础上添加了一个Pool(池)，在取块的时候his是直接随机和历史序列（最后4次生成的next）比较，而HisPool是从Pool里面随机取（然后补充一个最旱的块增加他的概率）然后和历史序列比较",
    },
    {
        word="c2出块;cultris2出块",
        title="C2出块",
        text="（七个块初始权重设为0）把七个块的权重都除以2然后加上0~1的随机数，哪个权重最大就出哪个块，然后将其权重除以3.5\n循环",
    },
    {
        word="hypertap;超连点",
        title="Hypertap",
        text="主要用于NES方块的指法，快速震动手指，实现比长按更快速+灵活的高速单点移动",
        detail="主要在NES方块的高难度下（因为ASD不可调而且特别慢，高速下很容易md导致失败，此时手动连点就比自动移动更快）或者受特殊情况限制不适合用自动移动时使用",
    },
    {
        word="rolling;轮指",
        title="Rolling",
        text="主要用于NES方块的指法，通过轮流敲击手柄完成更快的连点，用于ASD/ASP设置非常慢时的高重力（1G左右）模式",
        detail="先把手柄（键盘……可能也行吧）悬空摆好，比如架在腿上，要连点某个键的时候一只手虚按按键，另外一只手的几根手指轮流敲打手柄背面，“反向按键”实现连点。这种控制方法可以让玩家相对更简单地获得比直接抖动手指的Hypertap（详见超连点词条）更快的控制速度\n此方法最先由CheeZ发明，现在被所有顶级NES方块玩家采用，顶级玩家速度可达30Hz",
    },
    {
        word="堆叠;stack",
        title="堆叠",
        text="一般指将方块无缝隙地堆起来。需要玩家有预读Next的能力，可以练习不使用Hold，十个消四完成40L模式",
    },
    {
        word="双旋",
        title="双旋",
        text="会使用顺时针/逆时针两个旋转键，原来要转三下的情况可以反向转一下就够，减少繁琐操作，这也是学习Finesse的必要前提",
    },
    {
        word="三旋",
        title="三旋",
        text="会使用顺/逆时针/180°旋转三个旋转键，任何方块只需旋转一次即可\n但由于180°旋转并不是所有游戏都有，且对速度提升的效果不如从单旋转双旋显著所以一般不强制要求\n另见 #双旋",
    },
    {
        word="干旱;drought",
        title="干旱",
        text="经典块术语，指长时间不来I方块(长条)。现代方块使用的Bag7出块规则下平均7块就会有一个I，理论极限两个I最远中间隔12块，严重的干旱不可能出现",
    },
    {
        word="骨块;bone;bone block",
        title="骨块",
        text="最早的方块游戏使用的方块样式。早期电脑屏幕不能显示图片只能打字，所以用两个方括号[　]表示一格方块，方括号长得像骨头所以叫骨块",
        detail="基于骨块的特点，Techmino中的骨块被重新定义为“低亮度+边缘不清晰”的，不利于玩家辨识方块形状的贴图",
    },
    {
        word="半隐",
        title="半隐",
        text="指方块锁定经过一段时间后会变隐形的规则\n从锁定开始到消失的具体时长不定，可以描述为“过几秒种后消失”",
    },
    {
        word="全隐;invis;invisible",
        title="全隐",
        text="指方块锁定后会马上完全隐藏\n锁定时有消失动画的话也可以叫全隐，但其实难度会小一点",
    },
    {
        word="场地重力",
        title="场地重力",
        text="（仅小部分游戏可能包含此规则）四格方块每一小格和相邻的格子有连接关系，连起来的几个格整体会受到重力影响，悬空时会往下落，可以像游戏Puyopuyo一样构造复杂的连锁消除",
    },
    {
        word="输入延迟",
        title="输入延迟",
        text="玩家按下键盘到游戏接收到信号其实一定会有几毫秒到几十毫秒不等的延迟，若过大就会很影响游戏手感\n这个延迟会受各种因素影响，若出现临时的增大，可以尝试重启设备/关闭后台城区/接通电源等操作缓解",
    },
    {
        word="秘密段位;大于号;secret grade",
        title="秘密段位",
        text="出自TGM系列的彩蛋玩法。拼图拼出“每行仅有一个洞且排成大于号的图形”。最高目标是完成19行并封口",
    },
    {
        word="cc;cold clear",
        title="Cold Clear",
        text="一个AI的名字\n由MinusKelvin开发，原用于PPT",
    },
    {
        word="zzz(bot);zzzbot;zzztoj",
        title="ZZZ (Bot)",
        text="一个AI的名字\n由研究群群友zzz（奏之章）开发，运行效率极高",
    },
    {
        word="guideline;gl;基准;准则;基准规则;官方规则",
        title="Guideline",
        text="#TTC 内部使用的一套Guideline（基准、准则）手册，详细规定了他们所要求的“Tetris”游戏在技术、营销上的各种细则，包括了场地尺寸、按键布局、方块颜色、出块规则、死亡判定等",
        detail="这套规定保证了21世纪后新出的官方方块游戏都拥有不错的基础游玩体验，再也不是曾经的一款游戏一个规则，跨游戏的经验和手感完全无法通用了。不过代价是所有的官方方块游戏也都被强制要求按照这套手册设计，新的设计不一定会被TTC官方人员认可\n目前所有的专业方块游戏也都依然保留了这套规则中与游戏规则相关的大多数设计",
    },
    {
        word="ttc;the tetris company;官方;俄罗斯方块公司",
        title="俄罗斯方块公司",
        text="The Tetris Company，简称TTC，是拥有游戏版权和Tetris商标的公司",
        detail="如果你想开发以Tetris为大标题的“官方”俄罗斯方块游戏，必须经过他们的同意且支付大额授权费用，这对于个人开发者来说是几乎不可能的",
    },
}
---@type Zict.Entry[]
local pattern={
    {
        word="定式;开局定式",
        title="开局定式",
        text="定式一般指开局定式，是可以在开局时使用的套路堆叠方法，快速做出想要的消行\n一些常用技巧、复合构造和固定堆叠方法则有时可能被称为“中局定式”",
        link="tetriswiki.cn/p/T-Spin_Methods",
        detail="能称为定式的摆法要尽量满足以下至少2~3条：\n能适应大多数块序\n输出高，尽量不浪费T块\n很多方块无需软降，极简操作数少\n有明确后续，分支尽量少\n\n注：7bag随机器极大降低了随机性增强了确定性，才让定式成为可能",
    },
    -- 消歧义
    {
        word="tki",
        title="TKI 消歧义",
        text="tki是发明了多个定式的玩家\n另见 #TD攻击 #开局TKI堆叠 #TKI-3开局",
    },
    -- 复合构造
    {
        word="mt;mt cannon;mini triple;mini triple cannon;mt炮",
        title="MT炮",
        text="一个mini t1接t3的复合构造，形状类似 #STSD 加一行\n另见 #万花筒（另一种mini t1接t3的复合构造）",
        link="tetriswiki.cn/p/MT_Cannon",
    },
    {
        word="kaslideoscope;万花筒",
        title="万花筒",
        text="一个mini t1接t3的复合构造，形状独特\n也有人认为是 #MT炮 的变种",
        link="tetriswiki.cn/p/Kaslideoscope",
    },
    {
        word="sd cannon;single double;single double cannon;sd炮",
        title="SD炮",
        text="一个t1接t2的复合构造\n如果寻找的是t1接t2接8L PC的开局定式，请见 #SDPC",
        link="tetriswiki.cn/p/SD_Cannon",
    },
    {
        word="windsor;windsor sd;温莎;温莎sd",
        title="温莎SD",
        text="一个t1接t2的复合构造，在t2上盖一行用t1消除留下屋檐",
        link="tetriswiki.cn/p/Windsor_SD",
    },
    {
        word="double dagger;fractal;分形;双刃剑;双剑",
        title="双剑",
        text="两个或更多t2纵向对齐在同一列、共享屋檐的复合构造\n双刃剑是错误翻译，不要用",
        link="tetriswiki.cn/p/Double_Dagger",
    },
    {
        word="cut copy;千鳥格子;千鸟;千鸟格子",
        title="千鸟格子",
        text="一个两连t2的复合构造，其中一个t2被切开，另一个t2偏移一列插入中间",
        link="tetriswiki.cn/p/Cut_Copy",
    },
    {
        word="uncut copy",
        title="Uncut Copy",
        text="一个两连t2的复合构造，一个t2偏移一列在另一个t2之上\n也有人认为这只是在一个t2上加一个 #STMB 捐赠",
        link="tetriswiki.cn/p/Uncut_Copy",
    },
    {
        word="stsd;super t-spin double;super tspin double",
        title="STSD",
        text="一个两连t2的复合构造，形状近似于t3",
        link="tetriswiki.cn/p/STSD",
    },
    {
        word="imperial cross;皇十;皇家十字",
        title="皇家十字",
        text="一个两连t2的复合构造，形状为一个十字",
        link="tetriswiki.cn/p/Imperial_Cross",
    },
    {
        word="dt;dt cannon;double triple cannon;dt炮",
        title="DT炮",
        text="一个t2接t3的复合构造，来自极其著名的同名定式 #DT炮开局",
        link="tetriswiki.cn/p/DT_Cannon",
    },
    {
        word="bt;beta;bt炮;beta炮",
        title="BT炮",
        text="一个t2接t3的复合构造，来自同名定式 #BT炮开局",
        link="tetriswiki.cn/p/BT_Cannon",
    },
    {
        word="dt 2;dt cannon 2;double triple cannon 2;dt炮2;dt炮二号",
        title="DT炮二号",
        text="一个t2接t3的复合构造，是 #DT炮 的变种",
        link="tetriswiki.cn/p/DT_Cannon_2",
    },
    {
        word="td;td attack;cspin;c-spin;td攻击",
        title="TD攻击",
        text="一个t3接t2的复合构造，有大量使用该形状的开局定式",
        link="tetriswiki.cn/p/TD_Attack",
    },
    {
        word="tst tower;t3 tower;t3塔;tst塔",
        title="T3塔",
        text="两个或更多t3纵向对齐在同一列、共享屋檐的复合构造\n另见不断重复做t3塔的堆叠模式 #无限T3",
        link="tetriswiki.cn/p/TST_Tower",
    },
    {
        word="polymer;polymer tspin;polymer t-spin;聚合型tspin;聚合型t-spin",
        title="聚合型T-Spin",
        text="多个特殊t2（iso neo fin）的复合构造的统称，包括海藻糖、曲二糖、尤格·索托斯等\n也包括大量开局定式，不过可能仅供观赏",
        link="tetriswiki.cn/p/Polymer_T-Spin",
    },
    {
        word="trinity;三连;三连炮",
        title="Trinity",
        text="一个三连t2的复合构造，形状有两种，都是在t2上搭 #STSD",
        link="tetriswiki.cn/p/Trinity",
    },
    {
        word="dt stsd;dt cannon stsd;dt炮stsd",
        title="DT STSD",
        text="一个三连t2的复合构造，以 #DT炮 的方式切开 #STSD 插入t2",
        link="tetriswiki.cn/p/DT_STSD",
    },
    {
        word="bt stsd;bt cannon stsd;bt炮stsd",
        title="BT STSD",
        text="一个三连t2的复合构造，以 #BT炮 的方式切开 #STSD 插入t2",
        link="tetriswiki.cn/p/BT_STSD",
    },
    {
        word="dt 2 stsd;dt cannon 2 stsd;dt炮二号stsd",
        title="DT 2 STSD",
        text="一个三连t2的复合构造，以 #DT炮二号 的方式切开 #STSD 插入t2",
        link="tetriswiki.cn/p/DT_2_STSD",
    },
    {
        word="impeldown",
        title="Impeldown",
        text="一个三连t2的复合构造，在t2上搭建 #皇家十字",
        link="tetriswiki.cn/p/Impeldown",
    },
    {
        word="black cross;黑色十字",
        title="黑色十字",
        text="一个三连t2的复合构造，把 #双剑 的上层改造成 #皇家十字",
        link="tetriswiki.cn/p/Black_Cross",
    },
    {
        word="nil cross;nil-cross;零号十字",
        title="零号十字",
        text="一个t3接t2接t2的复合构造，在 #皇家十字 上搭建t3",
        link="tetriswiki.cn/p/Nil-Cross",
    },
    {
        word="king crimson;绯红之王",
        title="绯红之王",
        text="一个t3接t2接t2的复合构造，在 #STSD 上搭建t3",
        link="tetriswiki.cn/p/King_Crimson",
    },
    {
        word="st cannon;single triple;st炮;rifle;步枪;dstsd;magic key;魔法钥匙;stsd+;dna;trehalose;海藻糖;kojibiose;曲二糖;iso trelahose;iso-trelahose;iso海藻糖;yog-sothoth;yog sothoth;尤格索托斯",
        text="不常用的复合构造，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    -- 技巧·削减
    {
        word="plowshare;ploughshare;wc plowshare;wc ploughshare;犁刃;锄之刃",
        title="锄之刃",
        text="一个倒扣JL块消一行把t1补成t2的削减技巧",
        link="tetriswiki.cn/p/WC_Ploughshare",
    },
    {
        word="qtk",
        title="QTK",
        text="一个在2*3空地中竖放SZ块做出t2地形的削减技巧",
        link="tetriswiki.cn/p/QTK",
    },
    {
        word="boomerang;回旋镖",
        title="回旋镖",
        text="一个旋入JL块挽救被破坏的 #STSD 的削减技巧",
        link="tetriswiki.cn/p/Boomerang",
    },
    {
        word="super spiral;超螺旋",
        title="超螺旋",
        text="一个旋入JL块制造t3地形的削减技巧，可能偏观赏性",
        link="tetriswiki.cn/p/Super_Spiral",
    },
    {
        word="链锯;shallow grave;浅坟;deja vu;既视感;nuki;枋;横梁;crush;grim grotto;sz passage;sz通道;may;背面t3;背面tst",
        text="不常用的削减技巧，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    -- 技巧·捐赠
    {
        word="stmb;stmb cave",
        title="STMB Cave",
        text="一个在3列宽地形上挂SZ块做凌空t2的捐赠技巧",
        link="tetriswiki.cn/p/STMB_Cave",
    },
    {
        word="st;st捐;st捐赠",
        title="ST捐赠",
        text="一个竖放SZ块做凌空t2的捐赠技巧\n不断重复这一捐赠就是 #ST堆叠",
        link="tetriswiki.cn/p/ST",
    },
    {
        word="kaidan;阶段;阶梯;阶梯捐;阶梯捐赠",
        title="阶梯捐赠",
        text="一个在阶梯状崎岖地形上竖放SZ块做t2的捐赠技巧\n实际上就是 #ST捐赠",
        link="tetriswiki.cn/p/Kaidan",
    },
    {
        word="yoshihiro;yoshihiro sd;yoshihiro堆叠;yoshihiro捐赠",
        title="Yoshihiro",
        text="一个mini t1接t2的常见技巧",
        link="tetriswiki.cn/p/Yoshihiro",
    },
    {
        word="shachiku train;社畜;社畜列车;社畜捐;社畜捐赠",
        title="社畜列车",
        text="一个组合使用SL或JZ块做出两连t2的捐赠技巧",
        link="tetriswiki.cn/p/Shachiku_Train",
    },
    {
        word="blockade;闭塞",
        title="闭塞",
        text="一个组合使用SZ或JL块在t2上凌空搭建t2的捐赠技巧",
        link="tetriswiki.cn/p/Blockade",
    },
    {
        word="anchor;anchor set;锚;锚捐;锚式捐赠",
        title="锚式捐赠",
        text="一个在堆叠不完整的情况下使用JL块完成消四的捐赠技巧",
        link="tetriswiki.cn/p/Anchor_Set",
    },
    {
        word="escalator;escalator loading;电梯;电梯捐;电梯捐赠;tdd;purple rain;紫雨;air;floating;t3斜塔;special triple triple;stt;sky prop;doomerang;毁旋镖",
        text="不常用的捐赠技巧，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    --技巧·思路与持续堆叠
    {
        word="parapet;栏杆",
        title="栏杆",
        text="一种故意把t2改成t1以便打开主洞接后续消四的做法\n可以持续不断进行栏杆t1，例如LT堆叠",
        link="tetriswiki.cn/p/Parapet",
    },
    {
        word="lst;lst stacking;lst堆叠",
        title="LST堆叠",
        text="一种极常见的堆叠模式，维持2-7堆叠地形，组合使用LS块与JZ块不断进行固定方法的t2，技术好的玩家可以近乎无限循环",
        link="tetriswiki.cn/p/LST_Stacking",
    },
    {
        word="st stacking;st堆叠",
        title="ST堆叠",
        text="一种常见的堆叠模式，不断重复做同样的 #ST捐赠 t2，是马拉松等高重力模式下的出色策略，技术好的玩家可以近乎无限循环",
        link="tetriswiki.cn/p/ST_Stacking",
    },
    {
        word="infinite t3;infinite tst;t3永久机关;tst永久机关;永续t3;永续tst;无限t3;无限tst",
        title="无限T3",
        text="一种常见的堆叠模式，不断重复做 #T3塔，是官方游戏常见的刷分策略，技术好的玩家可以近乎无限循环",
        link="tetriswiki.cn/p/Infinite_TST",
    },
    {
        word="hamburger;汉堡;汉堡堆叠",
        title="汉堡堆叠",
        text="一种堆叠模式，不断使用S或Z块做边列捐赠t1，逐渐会留下ST或ZT颜色层层交替的地形类似多层汉堡，适合在PPT中对抗噗哟玩家",
        link="tetriswiki.cn/p/Hamburger",
    },
    {
        word="snake;snaking;蛇行;蛇形;hyper fractal;究极分形;zipper;拉链",
        text="不常用的堆叠模式，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    -- 开局定式·第一包mini
    {
        word="hebomai spin;hbm spin;hebomai炮;fiddlesworth;mtd;mini triple double;joystick;摇杆;nyaspin;xz cannon;xz炮;mdf;mini double fractal",
        text="不常用的mini开局定式，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    -- 开局定式·第一包t1
    {
        word="sailboat;sst ship;帆船",
        title="帆船",
        text="一个开局定式，第一包凌空t1，第二包t1，第三包t2",
        link="tetriswiki.cn/p/Sailboat",
    },
    {
        word="singleyou;sdpc",
        title="SDPC",
        text="一个开局定式，第一包凌空t1，第二包t2，大概率8行PC\n与 #Stickspin #SDPC Spin 非常相似",
        link="tetriswiki.cn/p/SDPC",
    },
    {
        word="stick;stickspin",
        title="Stickspin",
        text="一个开局定式，第一包凌空t1，第二包t2，然后搭建 #TD攻击\n与 #SDPC 非常相似",
        link="tetriswiki.cn/p/Stickspin",
    },
    {
        word="sdspin;sdpc spin",
        title="SDPC Spin",
        text="一个开局定式，第一包凌空t1，第二包t2，然后多种接续\n是 #SDPC 的变体",
        link="tetriswiki.cn/p/SDPC_Spin",
    },
    {
        word="邪炮",
        title="邪炮",
        text="一个开局定式，第一包凌空t1，第二包t2，然后搭建 #TD攻击",
        link="tetriswiki.cn/p/JA_Cannon",
    },
    {
        word="hachispin;hachi cannon;28;28炮;二八炮",
        title="二八炮",
        text="一个开局定式，第一包凌空t1，第二包t3，然后多种接续",
        link="tetriswiki.cn/p/Hachispin",
    },
    {
        word="mr.t-spin;mr tspin;mr.t-spin's std;mr tspin's std;mr.t-spin的std",
        title="Mr.T-Spin的STD",
        text="一个开局定式，第一包凌空t1，第二包t3，第三包t2",
        link="tetriswiki.cn/p/Mr._T-Spin's_STD",
    },
    {
        word="doubleyou;pwn's std;pwn的std;dolphin;海豚;misfire;kermspin;surrealist s;超现实主义s;tenespin;hummingbird;蜂鸟;seagull;海鸥;submarine;潜艇;last;old key;旧钥匙;icebreaker;curveball;弧线球;skim cannon;削减炮;kerr loop;ksd;kvodeth sd;secspin;spachispin;齿磨sd;sure fd;speedboat;快艇;pokemino;pokemino's std;pokemino的std",
        text="不常用的t1开局定式，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    -- 开局定式·第一包t2
    {
        word="tki3;tki-3;开幕tsd;开幕t2;开局tsd;开局t2;tki-3开局",
        title="TKI-3开局",
        text="一个开局定式，I块为底，第一包t2，后续大量接续，极其常用",
        link="tetriswiki.cn/p/TKI-3",
    },
    {
        word="mko;mko stacking;mko堆叠",
        title="MKO堆叠",
        text="一个开局定式，JL块为底，第一包t2，后续大量接续",
        link="tetriswiki.cn/p/MKO",
    },
    {
        word="ajanba t2;ajanba tsd",
        title="Ajanba TSD",
        text="一个开局定式，I块为底，第一包t2，后续大量接续",
        link="tetriswiki.cn/p/Ajanba_TSD",
    },
    {
        word="no1;no.1;number 1;number one;数字1;数字一",
        title="Number One",
        text="一个开局定式，第一包凌空t2，留下数字“1”形状的地形",
        link="tetriswiki.cn/p/Number_One",
    },
    {
        word="flamingo;火烈鸟",
        title="火烈鸟",
        text="一系列开局定式，OS或OZ块为核心，第一包凌空t2",
        link="tetriswiki.cn/p/Flamingo",
    },
    {
        word="ddpc",
        title="DDPC",
        text="若干开局定式的t2接t2接6行PC路线\n有这个路线的定式包括 #TKI-3开局 #Ajanba TSD 等",
        link="tetriswiki.cn/p/DDPC",
    },
    {
        word="albatross;信天翁",
        title="信天翁",
        text="两个开局定式（特别型与TSD），第一包凌空t2，后续接t3接t2（特别型）或接t2接t3（TSD）",
        link="tetriswiki.cn/p/Albatross",
    },
    {
        word="pelican;鹈鹕",
        title="鹈鹕",
        text="一个开局定式，SZ块叠放，第一包凌空t2",
        link="tetriswiki.cn/p/Pelican",
    },
    {
        word="perfect dt;完美dt;glitter brooch;captain;captain stacking;captain堆叠;reliable t2;reliable tsd;rich ddp;dodo;渡渡鸟;dragon;dragon sp;dragon special;龙;龙特别型;coon dragon;coon-dragon;428 cannon;428炮;black tea cannon;红茶炮;mochi's anger;mochi之怒;trustworthy dt",
        text="不常用的t2开局定式，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    -- 开局定式·第一包堆叠第二包t2
    {
        word="gassho;合掌;合掌tsd",
        title="合掌TSD",
        text="一个开局定式，SZ块相对竖放，第一包堆叠，第二包t2，然后多种接续并有较低概率4行PC",
        link="tetriswiki.cn/p/Gassho_TSD",
    },
    {
        word="dt opener;dt cannon opener;dt炮开局",
        title="DT炮开局",
        text="一个开局定式，第一包堆叠，然后搭建 #DT炮 ，非常著名",
        link="tetriswiki.cn/p/DT_Cannon_Opener",
    },
    {
        word="bt opener;beta opener;bt cannon opener;bt炮开局",
        title="BT炮开局",
        text="一个开局定式，第一包堆叠，然后搭建 #BT炮 ，可以五包PC",
        link="tetriswiki.cn/p/BT_Cannon_Opener",
    },
    {
        word="mechanical;mechanical t2;mechanical tsd;机械t2;机械tsd",
        title="机械T2",
        text="一系列每包摆法固定、可以不断做出t2的定式，有v1v2v3v4多个版本，不过高度会不断增高无法永远持续",
        link="tetriswiki.cn/p/Mechanical_TSD",
    },
    {
        word="antifate;antifate tsd;greenwich;greenwich cannon;格林尼治炮;i-rin tsd;I凛TSD;3d cannon;3d炮;over future;超未来;h cannon;hstsd;H炮;qt;qt cannon;qt炮;et;et cannon;et炮;ok cannon;okey cannon;ok炮;szdt;ct;ct scan;ct scan stacking;ct扫描堆叠;claw machine",
        text="不常用的第一包堆叠第二包t2开局定式，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    -- 开局定式·第一包堆叠第二包t3
    {
        word="tki stacking;tki堆叠;开局tki堆叠",
        title="开局TKI堆叠",
        text="一个开局定式，第一包堆叠，然后搭建 #TD攻击。是发明了该形状的定式",
        link="tetriswiki.cn/p/TKI_Stacking",
    },
    {
        word="gamushiro;gamushiro stacking;gamushiro堆叠",
        title="Gamushiro堆叠",
        text="一个开局定式，第一包堆叠，然后搭建 #TD攻击 ，高概率8行PC。最早流行的TDPC定式",
        link="tetriswiki.cn/p/Gamushiro_Stacking",
    },
    {
        word="mountain;mountainous stacking;mountainous stacking 1;mountainous stacking 2;mountainous stacking 3;ms;ms1;ms2;ms3;山岳;山岳堆叠;山岳1;山岳2;山岳3;山岳一;山岳二;山岳三;山岳堆叠一号;山岳堆叠二号;山岳堆叠三号",
        title="山岳堆叠",
        text="一系列开局定式，第一包堆叠，然后搭建 #TD攻击 ，高概率8行PC。有123三种，最常见的是2，在无延迟极为流行的TDPC",
        link="tetriswiki.cn/p/Mountainous_Stacking_2",
    },
    {
        word="hachimitsu;hachimitsu cannon;honey;honey cup;蜂蜜;蜂蜜杯子;蜂蜜炮",
        title="蜂蜜炮",
        text="一个开局定式，第一包堆叠，然后搭建 #TD攻击 ，高概率8行PC。在延迟块性能非常出色的TDPC",
        link="tetriswiki.cn/p/Hachimitsu_Cannon",
    },
    {
        word="stray;stray cannon;迷走;迷走炮",
        title="迷走炮",
        text="一个开局定式，第一包堆叠，然后搭建 #TD攻击 ，高概率8行PC。在延迟块性能非常出色的TDPC",
        link="tetriswiki.cn/p/Stray_Cannon",
    },
    {
        word="satsuki;satsuki stacking;皋月;皋月堆叠",
        title="皋月堆叠",
        text="一个开局定式，第一包堆叠，然后搭建 #TD攻击 ，高概率8行PC。适合延迟块刷分的TDPC",
        link="tetriswiki.cn/p/Satsuki_Stacking",
    },
    {
        word="kisaragi;kisaragi stacking;如月;如月堆叠",
        title="如月堆叠",
        text="一个开局定式，第一包堆叠，然后搭建 #TD攻击 ，高概率8行PC。适合延迟块刷分的TDPC",
        link="tetriswiki.cn/p/Kisaragi_Stacking",
    },
    {
        word="pc-spin;pc spin;pc-spin okey;pc spin okey;pc-spin okey version;pc spin okey version",
        title="PC-Spin",
        text="两个开局定式，第一包堆叠，然后搭建 #TD攻击 ，高概率8行PC。原版性能不够好，最常见的是Okey Version变体，适合延迟块刷分的TDPC",
        link="tetriswiki.cn/p/PC-Spin_(Okey_Version)",
    },
    {
        word="dot;dot cannon;点炮",
        title="点炮",
        text="一个开局定式，第一包堆叠，然后搭建 #TD攻击 ，高概率8行PC。主要特点是前两包100%成功的TDPC",
        link="tetriswiki.cn/p/Dot_Cannon",
    },
    {
        word="bakery;bakery td",
        title="Bakery TD",
        text="一个开局定式，第一包堆叠，然后搭建 #TD攻击 ，高概率8行PC。路线简单且上限高的TDPC",
        link="tetriswiki.cn/p/Bakery_TD",
    },
    {
        word="pancake;pancake stacking;松饼;松饼堆叠;kuromitsu;kuromitsu stacking;黑蜜;黑蜜堆叠;aitch;aitch stacking;aitch堆叠;olive;olive stacking;橄榄;橄榄堆叠;loyal td;yamaha;yamaha stacking;yamaha堆叠;rabbit;rabbit stacking;兔子堆叠;ruby;ruby stacking;红宝石堆叠;atlas;atlas stacking;atlas堆叠;gravity td;重力td;tandoori chicken;tandoori chicken stacking;riif;riif stacking;riif堆叠;(　ﾟдﾟ)ﾎﾟｶｰﾝ;(　ﾟдﾟ)ﾎﾟｶｰﾝ堆叠;dc-spin;dcspin;double c-spin;double cspin;quick tower;快塔;quick tower 2;快塔改;sewer;tzt cannon;tzt炮",
        text="不常用的第一包堆叠第二包t3开局定式，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    -- 开局定式·new tsd
    {
        word="fint;fint cannon;罚金炮",
        title="罚金炮",
        text="一个开局定式，第一包堆叠，第二包fin t2，第三包t3",
        link="tetriswiki.cn/p/FinT_Cannon",
    },
    {
        word="wolfmoon;wolfmoon cannon;wm cannon;狼月;狼月炮",
        title="狼月炮",
        text="一个开局定式，第一包堆叠，第二包fin t2，然后搭建 #Impeldown",
        link="tetriswiki.cn/p/WolfMoon_Cannon",
    },
    {
        word="maospin;intspin;godspin;godless spin;godless-spin;ajanba signature;ajanba签名",
        text="不常用的new tsd开局定式，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    -- 开局定式·不做T
    {
        word="pco;pc opener; perfect clear opener;全消开局;全清开局;开局全消;开局全清",
        title="全消开局",
        text="一个开局定式，约七成概率4行PC。最早的PC开局定式",
        link="tetriswiki.cn/p/PCO",
    },
    {
        word="grace;grace system;六巧板",
        title="六巧板",
        text="一个开局定式，约八成概率4行PC",
        link="tetriswiki.cn/p/Grace_System",
    },
    {
        word="jigsaw;jigsaw pc;jigsaw全消;jigsaw全清",
        title="Jigsaw 全消",
        text="一个开局定式，约七成概率4行PC。高概率做额外的t0可以多得分数",
        link="tetriswiki.cn/p/Jigsaw_PC",
    },
    -- 其他定式·不好分类
    {
        word="dpc",
        title="DPC",
        text="一系列中局定式的统称，使用前一包剩余的一块和两个整包。和8行PC配合可以完成循环",
        link="tetriswiki.cn/p/DPC",
    },
    {
        word="crowbar;sz cross;sz十字;outlogic sd;octupus tea cannon;octupus tea炮;catspin;sbsd",
        text="不常用的开局定式，详见链接",
        link="tetriswiki.cn/p/T-Spin_Methods",
    },
    -- 其他定式·乐
    {
        word="dubble",
        title="Dubble",
        text="一个开局定式，第一包快速做出消二以期断掉对手PC。半娱乐性定式",
        link="tetriswiki.cn/p/Dubble",
    },
    {
        word="最强;最强炮",
        title="最强炮",
        text="一个开局定式，流程长达10包，做出7个不同的T旋。娱乐性定式",
        link="tetriswiki.cn/p/Strongest_Cannon",
    },
    {
        word="horse;horse opener;马;马开局",
        title="马",
        text="一个开局定式，用第一包搭起马的形状。纯观赏娱乐性定式",
        link="tetriswiki.cn/p/Horse",
    },
    {
        word="sus;sus opener;among us;among us opener",
        title="Sus",
        text="一个开局定式，用第一包搭起游戏Among Us主角的形状。纯观赏娱乐性定式",
        link="tetriswiki.cn/p/Sus",
    },
    {
        word="missile;导弹;导弹发射",
        title="导弹发射！",
        text="一个开局定式，用四包搭起巨大的导弹形状。纯观赏娱乐性定式",
        link="tetriswiki.cn/p/Missile",
    },
    {
        word="aoiro;aoiro炮",
        title="Aoiro炮",
        text="一个开局定式，拥有理论上最低的0.12%PC率。娱乐性定式",
        link="tetriswiki.cn/p/Aoiro_Cannon",
    },
}
---@type Zict.Entry[]
local game={
    -- 网页
    {
        cat='game',
        word="kos;king of stackers",
        title="King of Stackers",
        text="简称KoS 非官块 网页 主联机有单机 音画廉价 电脑+手机理论可玩\n主要玩法类似下棋，每个人以7块为一个回合轮流操作，策略性很强",
        link="kingofstackers.com/games.php",
    },
    {
        cat='game',
        word="屁块;tetrjs;tetr.js",
        title="Tetr.js",
        text="简称屁块（作者网名Farter） 非官块 网页 主单机 音画廉价 电脑+手机 键盘可改键触屏不行\n有较多创意模式",
        link="farter.cn/t",
    },
    {
        cat='game',
        word="T-ex",
        title="T-ex",
        text="非官块 要下载 主单机 音画一般 电脑 不可调控制\nFarter早年制作的一个基于flash的仿TGM游戏，包含一个创新旋转系统 #XRS",
    },
    {
        cat='game',
        word="tl;tetra legends",
        title="Tetra Legends",
        text="简称TL 非官块 网页 主单机 音画优秀 电脑\n有两个隐藏的节奏模式，并且将一些其他游戏中不可见的机制进行了可视化，动效也很多。于2020年12月基本确定由于各种原因不再继续开发",
        link="tetralegends.app",
    },
    {
        cat='game',
        word="asc;ascension",
        title="Ascension",
        text="简称ASC 可玩 非官块 网页 主单机 音画廉价 电脑\n有一些创意模式",
        link="asc.winternebs.com",
    },
    {
        cat='game',
        word="io;tetrio;tetr.io",
        title="TETR.IO",
        text="简称IO 非官块 网页但建议下载 主联机有单机 音画优秀 电脑 会员付费 有自定义\n应该是目前全世界在线人数最多的现代块游戏\n另见#io qp2",
        link="tetr.io",
    },
    {
        cat='game',
        word="js;jstris",
        title="Jstris",
        text="简称JS 非官块 网页 单机联机都有 音画廉价 电脑+手机 有自定义 代码可扩展",
        link="jstris.jezevec10.com",
    },
    {
        cat='game',
        word="tetrio.io;tetrioio;ioio",
        title="TETRIO.IO",
        text="网页 主多人 音画一般 电脑 创新\n无hold有next的对战块，但两个玩家在同一个场地的两头拔河，说不太清总之很好玩，有简单的分数系统能匹配对战，或者约好友\n注：本游戏和TETR.IO完全无关",
        link="tetrio.io",
    },
    {
        cat='game',
        word="nuke;nuketris",
        title="Nuketris",
        text="可玩 非官块 网页 主单机有联机 音画廉价 电脑 不可调控制\n有几个基础单机模式和1V1排位",
        link="nuketris.com",
    },
    {
        cat='game',
        word="wwc;worldwide combos",
        title="Worldwide Combos",
        text="简称WWC 可玩 非官块 网页 单机联机都有 音画优秀 电脑\n有几种不同风格的大规则（例如炸弹垃圾行），有录像战（匹配对手不是真人）",
        link="worldwidecombos.com",
    },
    {
        cat='game',
        word="tf;tetris friends;notris;notrisfoes",
        title="Tetris Friends",
        text="简称TF 私服 官块 网页 单机联机都有 音画优秀 电脑 部分改键 半可调控制\n以前人比较多，后来官服倒闭了热度没了",
        link="私服notrisfoes.com",
    },
    {
        cat='game',
        word="tetris.com",
        title="tetris.com",
        text="Tetris官网上的块 官块 网页 主单机 音画优秀 电脑+手机 不可调控制\n只有马拉松一个模式，但有一个智能鼠标控制的玩法",
        link="tetris.com/play-tetris",
    },
    {
        cat='game',
        word="gems;tetris gems",
        title="Tetris Gems",
        text="Tetris官网上的块 可玩 官块 网页 主单机 音画优秀 电脑+手机 不可调控制\n限时1分钟挖掘，有Cascade，有三种消除后可以获得不同功能的宝石方块",
        link="tetris.com/play-tetrisgems",
    },
    {
        cat='game',
        word="mind bender;tetris mind bender",
        title="Tetris Mind Bender",
        text="Tetris官网上的块 官块 网页 主单机 音画优秀 电脑+手机 不可调控制\n在马拉松基础上添加了效果，场地上会随机冒出效果方块，消除后会得到各种各样或好或坏的效果",
        link="tetris.com/play-tetrismindbender",
    },
    {
        cat='game',
        word="ztrix",
        title="Ztrix",
        text="练习工具 网页 主单机 音画廉价 电脑\nTEC的Zone练习用工具游戏，有自定义序列和撤销和出题等功能",
        link="ztrix-game.web.app",
    },
    -- 跨平台
    {
        cat='game',
        word="tech;techmino;铁壳;铁壳米诺",
        title="Techmino",
        text="简称Tech 非官块 要下载 主单机有联机 音画优秀 电脑+手机 有自定义\n大规模缝合了常见现代块内容，可练习可挑战\n目前最新版本0.17.21，可以和约好友联机对战\n苹果用户另见 #铁壳ios #铁壳mac",
        link="studio26f.org",
    },
    {
        cat='game',
        word="Techmino Galaxy;Techmino: Galaxy;TG;铁盖;盖勒克希;铁壳米诺盖勒克希",
        title="Techmino: Galaxy",
        text="一款谜之前端",
    },
    {
        cat='game',
        word="aqm;aquamino",
        title="Aquamino",
        text="可玩 非官块 要下载 主单机 音画优秀 电脑+手机\n除了基础的单机模式外还有冰风暴、多线程、激光、雷暴等创意模式",
        link="aqua6623.itch.io/aquamino",
    },
    {
        cat='game',
        word="fl;falling lightblocks",
        title="Falling Lightblocks",
        text="非官块 网页 单机联机都有 音画廉价 电脑+手机 不可调控制\n主要内容是经典块复刻和半实时对战",
        link="mrstahlfelge.itch.io/lightblocks  html-classic.itch.zone/html/2917030/index.html",
    },
    {
        cat='game',
        word="剑桥;cambridge",
        title="Cambridge",
        text="非官块 要下载 主单机 音画优秀 电脑 代码可扩展\n致力于创建一个轻松高度自定义新模式的方块平台。最初由Joe Zeng开发，于2020年10月8日0.1.5版开始Milla接管了开发。 — Tetris Wiki.",
    },
    -- 街机/类街机
    {
        cat='game',
        word="tgm;tetris the grand master;tetris grand master;tgm3;tgm2;铁门",
        title="Tetris The Grand Master",
        text="简称TGM 官块 要下载 单人 音画优秀 有电脑移植版 不可调控制\n聚焦于高重力快节奏玩法，S13/GM等称号都出自该作，其中TGM3比较普遍，部分模式说明发送“##”查看",
        detail="Master：大师模式，有段位评价，拿到更高段位点的要求：非消一的连击和消四，字幕战中消除和通关，每100分的前70分小于【标准时间，上一个0~70秒数+2】中小的一个，每100总用时不能超过限定值（不然取消上一个方法的加点并反扣点）；到500分和1000分时若超过了时间要求会强制结束游戏（社区称之为铁门）；字幕战有两个难度，半隐和全隐，后者必须拿到几乎全部的段位点才能进，消除奖励的段位点也更多\n\nShirase：死亡模式，类似于techmino中的20G-极限，开局就是高速20G，500分和1000分也有时间要求，500~1000会涨垃圾行，1000~1300为骨块，1300后进入大方块字幕战；段位结算：每通100加1段从S1到S13，若通关了字幕战就会有金色的S13",
        link="teatube.cn/TGMGUIDE",
    },
    {
        cat='game',
        word="dtet",
        title="DTET",
        text="非官块 要下载 主单机有联机 音画优秀 电脑 不可调控制\n基于经典规则添加了20G和强大的人体工学方块控制系统",
    },
    {
        cat='game',
        word="example block game;ebg",
        title="Example Block Game",
        text="非官块 要下载 主单机 音画优秀 电脑 不可调控制 创新\n一个仿TGM的街机方块游戏，有一个不区分szi正反朝向的旋转系统",
    },
    {
        cat='game',
        word="mob;master of block",
        title="Master of Block",
        text="非官块 要下载 主单机 音画一般 电脑 不可调控制\n一个仿街机方块游戏",
    },
    {
        cat='game',
        word="hebo;heboris",
        title="Heboris",
        text="非官块 要下载 主单机 音画优秀 电脑 不可调控制\n一个仿街机方块游戏，可以模拟多个方块游戏的部分模式",
    },
    {
        cat='game',
        word="tex;texmaster",
        title="Texmaster",
        text="非官块 要下载 主单机 音画优秀 电脑 不可调控制\nTGM的社区自制游戏，包含TGM的所有模式，可以用来练习TGM，但World规则不完全一样（如软降到底无锁延，踢墙表有细节不同等）",
    },
    {
        cat='game',
        word="sega;sega tetris",
        title="Sega Tetris",
        text="官块 要下载 主单机 音画优秀 需要模拟器 部分改键 不可调控制\n1999年发行的主机游戏，有1v1道具战，六种不同的消除方式能发送特殊效果",
    },
    -- 其他
    {
        cat='game',
        word="tec;tetris effect;tetris effect connected",
        title="Tetris Effect: Connected",
        text="简称TEC 官块 要下载 单机联机都有 音画优秀 电脑 不可调控制 正版付费\n卖点是沉浸音画体验和基于创新的Zone机制的各种模式（包括多人在线不对称竞技）",
    },
    {
        cat='game',
        word="t99;tetris 99",
        title="Tetris 99",
        text="简称T99 官块 要下载 主联机有单机 音画优秀 主机 部分改键 不可调控制 正版付费\n主打99人混战的吃鸡模式，也有一些常用单机模式如马拉松等\n游戏基础模式有NS Online会员可以免费玩，其他单机模式需要额外购买",
    },
    {
        cat='game',
        word="ppt;puyo puyo tetris",
        title="Puyo Puyo Tetris",
        text="简称PPT 官块 要下载 主联机有单机 音画优秀 电脑 不可调控制 正版付费\n包含Tetris和PuyoPuyo两个下落消除游戏，二者间可以对战\n注：PPT2的手感据很多人说都不行",
    },
    {
        cat='game',
        word="to;top;toj;tos;tetris online",
        title="Tetris Online",
        text="简称TO 私服 官块 要下载 主联机有单机 音画优秀 电脑 半可调控制\n主要用来6人内对战/单挑/刷每日40L榜/挖掘模式/打机器人",
        detail="现在还开着的服务器有：TO-P（波兰服，服务器在波兰，可能会卡顿）；TO-S（研究服，研究群群友自己开的服更稳定）"
    },
    {
        cat='game',
        word="c2;cultris2;cultris ii",
        title="Cultris II",
        text="简称C2 可玩 非官块 要下载 单机联机都有 音画优秀 电脑\n对战的主要玩法是基于时间的连击，考验玩家速度/Wide打法/挖掘，另单人游戏有一大堆创意模式",
    },
    {
        cat='game',
        word="ultimate;tetris ultimate",
        title="Tetris Ultimate",
        text="离线 官块 要下载 单机联机都有 音画优秀 电脑 不可改键 不可调控制 正版付费\n有周期隐形/山体滑坡/双人同版等有趣模式，目前已下架",
    },
    {
        cat='game',
        word="poly;polyform",
        title="Polyform",
        text="可玩 非官块 要下载 主单机 音画优秀 电脑\n有三角形和六边形的单元格",
    },
    {
        cat='game',
        word="sd;spirit drop",
        title="Spirit Drop",
        text="非官块 要下载 主单机有联机 音画优秀 电脑 有自定义\n除了几个主模式外还有一个变革模式包含几十个创意规则可挑战",
        link="rayblastgames.com/spiritdrop.php",
    },
    {
        cat='game',
        word="betrix;chextris",
        title="Betrix & Chextris",
        text="非官块 要下载 主单机 音画优秀 电脑 有自定义 创新\n在方块里加入了音游元素，也有40L等基础模式",
        link="store.steampowered.com/app/2007710\nchemicalex.itch.io/chextris",
    },
    {
        cat='game',
        word="C::Reactris;c4r;c::r;Reactris",
        title="C::Reactris",
        text="非官块 要下载 主单机 音画优秀 电脑+手机 有自定义 创新\n在方块里加入了丰富的Minecraft元素，有大量创意玩法",
        link="b23.tv/BV13u411G75m",
    },
    {
        cat='game',
        word="np;nullpomino",
        title="Nullpomino",
        text="简称NP 非官块 要下载 主单机有联机 音画一般 电脑 有自定义 代码可扩展\n整个游戏自定义程度极高，甚至可以模拟出puyopuyo，但模式资源可能比较难找",
    },
    {
        cat='game',
        word="misa;misamino",
        title="Misamino",
        text="非官块 要下载 主单机 音画优秀 电脑 回合制机器人对战\n比较工具的游戏，与AI进行回合制对战，可以导入外部AI程序",
    },
    {
        cat='game',
        word="four;fourtris;four-tris",
        title="four-tris",
        text="非官块 要下载 主单机 音画廉价 电脑 复盘工具\n单机自由沙盘，可以方便地随时自定义序列、绘制和删除地形、撤销和前进步骤，有截图识别地形功能，有多个练习模式，非常适合进行各种练习、复盘、绘制地形",
    },
    {
        cat='game',
        word="thm;touhoumino",
        title="Touhoumino",
        text="非官块 要下载 主单机 音画优秀 电脑\n一个Nullpomino的mod版，在方块里加入了东方Project元素",
        detail="马拉松模式结合东方Project里的“符卡”机制，需要在一定时间内达成目标分数才能击破。难度较大，适合有方块基础并且各项能力都较强的玩家游玩（不然都不知道自己怎么死的）",
    },
    {
        cat='game',
        word="beat;tetris beat",
        title="Tetris Beat",
        text="官块 要下载 主单机 音画优秀 iOS限定 不可改键 不可调控制 正版付费\nN3TWORK代理的一款移动端方块，除了马拉松外有“Beat模式”，根据BGM的节奏落块得到额外分数，但体验一般，特效还比较瞎眼",
    },
    {
        cat='game',
        word="royale;tetris royale;tetris n3twork;tetris n3t",
        title="Tetris (N3TWORK)",
        text="官块 要下载 单机联机都有 音画优秀 手机限定 不可改键 不可调控制\nN3TWORK开发，现由Play Studio运营",
    },
    {
        cat='game',
        word="jj;jj块",
        title="JJ块",
        text="非官块 要下载 单机联机都有 音画优秀 手机限定\nJJ棋牌平台下的“JJ比赛”app内的一个休闲游戏（看不到可能是因为限制了新玩家不可见）",
        detail="是现代方块但：竖屏，可自定义ASD/ASP，能自定义键位，无Hold，无B2B，无攻击缓冲不可抵消，每次攻击上限为4，连击较强",
    },
    {
        cat='game',
        word="ea;tetris ea",
        title="Tetris (EA)",
        text="离线 官块 要下载 主单机 音画优秀 手机限定 不可改键 不可调控制\nEA代理的一款宇宙主题的移动端方块。有滑动操控和单点触控两种操作模式，已于2020年4月下架",
        detail="除经典的马拉松外还有一个星系模式（地图挖掘），有重力连锁机制，目标是在限定块数内消除所有地图块",
    },
    {
        cat='game',
        word="nes",
        title="Tetris (NES, Nintendo)",
        text="nes平台上的块 官块 主单机 音画优秀 需要模拟器 不可调控制\n最普及的经典俄罗斯方块之一，因各种因素硬抗住了方块现代化的进程活到了现在，CTWC比赛用的就是这个游戏",
    },
    {
        cat='game',
        word="tetris forever;forever;永恒;永恒篇",
        title="Tetris Forever",
        text="主要部分不是游戏 官块 主单机 音画优秀 不可调控制\n俄罗斯方块40周年作，总体上是一个电子展览馆，按Tetris的历史发展排列了一份纪录片和各种图片资料，还内置了模拟器用来体验一些老游戏",
    },
    -- 题库
    {
        cat='game',
        word="ttt",
        title="Tetris Trainer Très-Bien",
        text="(原作者こな)简称TTT 可玩 题库游戏 非官块 网页 主单机 音画廉价 电脑 不可调控制 创新：交互式教程\n现代方块特殊操作手把手教程，推荐能纯消四完成40L挑战的人学习，内含极简、SRS、T-Spin、部分对战定式等内容的教程",
        link="(翻译后挂在茶服的版本) teatube.cn/ttt",
    },
    {
        cat='game',
        word="ttpc",
        title="TETRIS Perfect Clear Challenge",
        text="(原作者chokotia)简称TTPC 可玩 题库游戏 非官块 网页 主单机 音画廉价 电脑 不可调控制\nSRS+Bag7方块游戏全消开局定式的教程（只能键盘操作）。推荐完成了TTT的人学习（必须先学会SRS）",
        link="(翻译后挂在茶服的版本) teatube.cn/ttpc",
    },
    {
        cat='game',
        word="tpo",
        title="Tetris Puzzle O",
        text="简称TPO 可玩 题库游戏 非官块 网页 主单机 音画廉价 电脑+手机 不可调控制\n由TCV100制作的题库网站，内含部分nazo的题",
        link="47.92.33.38/tpo",
    },
    {
        cat='game',
        word="nazo",
        title="NAZO",
        text="可玩 题库游戏 非官块 网页 主单机 音画廉价 电脑 不可调控制\n内含各种T-Spin/All-Spin题目，简单到极难题目都有",
        link="(翻译后挂在茶服的版本) teatube.cn/nazo",
    },
    -- 已逝
    {
        cat='game',
        word="闪电战;tetris blitz",
        title="Tetris Blitz",
        text="离线 官块 要下载 主单机 音画优秀 手机限定 手势控制 不可调控制 内购道具\nEA代理的一款移动端方块，有重力连锁机制，限时2分钟，已于2020年4月下架\n另见 #Blitz模式",
        detail="持续消行会进入Frenzy模式（场地下方会不断冒出垃圾行，帮助玩家制造大连锁，如果多次落块没有消行会强制结束Frenzy）。有非常多的道具\n当新出现的方块与场地现有方块重叠时，场地最上方的几行会被自动清除，游戏不结束",
    },
    {
        cat='game',
        word="tetra online",
        title="Tetra Online",
        text="简称TO 离线 非官块 要下载 单机联机都有 音画优秀 电脑 不可调控制\nUI部分模仿了PPT，音乐不错，攻击特效好看，于2020年12月9日收到来自TTC的DMCA警告信于是被迫停止开发，在一段时间后关服并下架Steam",
        link="离线版本 github.com/Juan-Cartes/Tetra-Offline/releases/tag/1.0",
    },
    {
        cat='game',
        word="环游记;俄罗斯方块环游记;journey;tetris journey",
        title="俄罗斯方块环游记",
        text="简称环游记 寄了 官块 要下载 主单机 音画优秀 手机限定 不可调控制 内购道具\n国内第一款正版授权手游方块。有闯关模式、对战模式和几个单机模式。闯关模式有各种各样有趣规则大多数有重力连锁，已于2023年2月15日停服",
    },
    {
        cat='game',
        word="火拼;火拼俄罗斯",
        title="火拼俄罗斯",
        text="非官块 要下载 主联机有单机 音画廉价 电脑 不可调控制\n腾讯游戏大厅的方块，12宽场地的经典块，攻击方式只有消4打3和消3打2，垃圾行为国际象棋棋盘式，几乎不可能挖掘",
    },
}
---@type Zict.Entry[]
local extra_tetrio={
    {
        word="qp2;io qp2;io s2;爬塔;zenith;zenith tower",
        title="TETR.IO QP2",
        text="随开随打不需要等待的第二代快速游戏，发送攻击升级 #推进器，在 #疲劳时间 前打败对手爬升高度达到天顶之塔的第 #十层 ！\n另见 #Surge #速通模式 #QP2 Mod\n详细规则（非官方）见 github.com/MrZ626/io_qp2_rule",
    },
    {
        word="十层;楼层;f10;floor;floors",
        title="QP2楼层",
        text="十层分别是：初始大厅、酒店(50m)、赌场(150m)、竞技场(300m)、博物馆(450m)、废弃办公楼(650m)、实验室(850m)、核心(1100m)、污染区(1350m)、神之境(1650m)",
    },
    {
        word="surge;surge b2b;b2b charging;b2b charge",
        title="Surge B2B",
        text="充能B2B系统，达到b2b×4然后中断时会打出一发和b2b数同样的超大攻击（分成三节）\n目前TETR.IO的TL第二赛季和QP2都使用此新系统（QP中参数略不同）",
    },
    {
        word="推进器",
        title="QP2 推进器",
        text="爬塔增加高度时有一个倍率的加成，×0.25开始每升一级多0.25，不过等级会随着时间流失，级别越高越快\n每一级的颜色：无/红/橙/黄绿/蓝/紫/亮橙/青绿/青蓝/亮紫/白/白/…\n另见#速通模式",
    },
    {
        word="hyperspeed;速通模式",
        title="QP2 Hyperspeed",
        text="当玩家在1/2/3/4/5层时推进器等级就达到8/8/9/9/10时会进入速通模式，掉到6级时会退出速通模式\n进入速通模式时会出现致敬Bejeweled Twist的动画和专属速通音乐，达到十层时完成速通模式，会获得一个隐藏成就",
    },
    {
        word="疲劳;疲劳时间",
        title="QP2 疲劳时间",
        text="为了防止一局游戏过长，8分钟开始每分钟会多一个共五个负面效果：(8分钟)+2行实心垃圾，(9分钟)+25%受击倍率，(10分钟)+3行实心垃圾，(11分钟)+25%受击倍率，(12分钟)+5行实心垃圾",
        detail="完整文本：\n疲劳开始侵蚀… FATIGUE SETS IN… +2 PERMANENT LINES\n你的身体变得虚弱… YOUR BODY GROWS WEAK… receive 25% more garbage\n所有感官混为一团… ALL SENSES BLUR TOGETHER… +3 PERMANENT LINES\n你的意识开始消逝… YOUR CONSCIOUSNESS FADES… receive 25% more garbage\n结束了。 THIS IS THE END. +5 PERMANENT LINES",
    },
    {
        word="qp2 mod;qp mod;io mod;tarot",
        title="QP2 Mod",
        text="Mod列表：专家(EX)、无暂存(NH)、混乱垃圾行(MS)、高重力(GV)、不稳定垃圾行(VL)、双洞垃圾行(DH)、隐形(IN)、All-Spin(AS)、双人(2P)\n另见 #mod EX/NH/...",
    },
    {
        word="mod EX; expert ; expert mod ; mod expert ; emperor",
        title="QP2 Expert mod",
        text="专家（塔罗牌：皇帝 Emperor）\n各方面都变难一些：垃圾行瞬间出现、增加垃圾混乱度、禁用“危急时降低受击概率”、禁用qp非专家模式里的“非连击消一有1攻击”、禁用消行/抵消加推进器经验",
    },
    {
        word="mod NH; nohold ; nohold mod ; mod nohold ; temperance",
        title="QP2 Nohold mod",
        text="无暂存（塔罗牌：节制 Temperance）\n禁用暂存",
    },
    {
        word="mod MS; messy ; messy mod ; mod messy ; wheel of fortune",
        title="QP2 Messy mod",
        text="混乱垃圾行（塔罗牌：命运之轮 Wheel of Fortune）\n垃圾混乱度显著增加",
    },
    {
        word="mod GV; gravity mod ; mod gravity ; tower ; the tower",
        title="QP2 Gravity mod",
        text="高重力（塔罗牌：塔 The Tower）\n重力显著增加",
    },
    {
        word="mod VL; volatile ; volatile mod ; mod volatile ; strength",
        title="QP2 Volatile mod",
        text="不稳定垃圾行（塔罗牌：力量 Strength）\n升起的垃圾行数量翻倍",
    },
    {
        word="mod DH; doublehole ; doublehole mod ; mod doublehole ; devil ; the devil",
        title="QP2 Doublehole mod",
        text="双洞垃圾行（塔罗牌：恶魔 The Devil）\n垃圾行可能会有两个洞",
    },
    {
        word="mod IN; invisible mod ; mod invisible ; hermit ; the hermit",
        title="QP2 Invisible mod",
        text="隐形（塔罗牌：隐士 The Hermit）\n自己放下的方块会隐形，每5秒全场地闪烁一次",
    },
    {
        word="mod AS; allspin mod ; mod allspin ; magician ; the magician",
        title="QP2 Allspin mod",
        text="All（塔罗牌：魔法师 The Magician）\n非T块spin也有2*消行数的攻击，但“消除文本区”文本变化时若和上次相同，会出现一行实心行，需要做若干次符合条件的消除才能解除",
    },
    {
        word="mod 2P; duo ; duo mod ; mod duo ; lover ; lovers ; the lovers",
        title="QP2 Duo mod",
        text="双人（塔罗牌：恋人 The Lovers）\n会员玩家可以邀请其他人和自己两个人一起玩此模式，两个人发送出去给别人的伤害数值减半，一个人死了后另一个人可以做任务复活队友",
    },
}
---@type Zict.Entry[]
local contributor={
    {
        word="26f studio;26f;26楼;26楼工作室",
        text="是我家喵",
        link="studio26f.org",
    },
    {
        word="T626;626;小z;Zita",
        text="喵喵？是我哦",
    },
    {
        word="T026;026;T26;MrZ;z酱",
        text="T026.MrZ，Techmino的主创、主程、音乐、音效、主美(?)\n也是另一个我喵！",
        link="space.bilibili.com/225238922",
    },
    {
        word="T1080;1080;Particle_G;ParticleG;pg",
        text="T1080.Particle_G，编写了Techmino的CI、主后端、程序",
    },
    {
        word="T114;114;flyz;flaribbit;小飞翔;fxg",
        text="T114.flyz，编写了Techmino的CI、后端",
        link="space.bilibili.com/787096",
    },
    {
        word="T1379;1379;Trebor",
        text="T1379.Trebor，编写和制作了Techmino的CI、后端、程序、音乐",
        link="space.bilibili.com/502473020",
    },
    {
        word="chno;C29H25N3O5;芙兰喵",
        text="制作了Techmino的UI/UX、音乐、周边美术",
    },
    {
        word="T7023;7023;Miya",
        text="T7023，块群吉祥物猫猫，制作了Techmino的插图、配音",
        link="space.bilibili.com/846180",
    },
    {
        word="T0210;T210;Mono",
        text="T0210，制作了Techmino的插图、配音",
    },
    {
        word="T056;flore;風洛霊;風洛霊flore;妈妈",
        text="T056.flore，目前主办各项中文社区方块赛事，主办年度奖项活动，活跃编辑方块中文维基，制作了Techmino的配音",
        link="space.bilibili.com/1223403016",
    },
    {
        word="T283;283;模电;模电283;Electric;Electric283;Modian;Modian283",
        text="T283.模电，上过最强大脑，擅长20G和隐形，在Techmino中有出镜",
        link="space.bilibili.com/17583394",
    },
    {
        word="T0325;T325;幻灭;汉化;io汉化;io汉化插件",
        text="T0325.幻灭，制作了TETR.IO汉化插件",
        link="插件安装教程 b23.tv/BV1Sz4y187Cd\nspace.bilibili.com/8933681",
    },
    {
        word="T0812;T812;scdhh;呵呵",
        text="T0812.呵呵，写了好几个块群bot，编写了Techmino的CI、后端",
        link="space.bilibili.com/266621672",
    },
    {
        word="Z120;渣渣;120;渣渣120",
        text="Z120.渣渣120，写了块群查成绩bot，做了TETR.IO【汉化+Plus+Verge】三合一客户端，和Techmino在线词典",
        link="zhazha120.cn  26f-studio.github.io/techmino-online-dict",
    },
    {
        word="TTTT;Farter;屁;屁爷",
        text="TTTT.屁，创研究群的【写乐Tetr.js(屁块)【哦还有写T-ex的【然并无人玩【【",
        link="space.bilibili.com/132966",
    },
    {
        word="T022;Teatube;茶叶子;茶管;茶;茶娘",
        text="T022.Teatube，前群宠，主办过中文社区方块赛事，写了块群bot，架设了Tetris Online Study研究服",
        link="space.bilibili.com/834903  space.bilibili.com/271332633",
    },
    {
        word="T042;42;思竣;思竣一号;思竣二号;思竣三号;思竣四号",
        text="T042.思竣，找到了Techmino的一万个bug并记住了所在版本号，另外还有一堆铁壳only的世界纪录",
        link="space.bilibili.com/403250559",
    },
    -- {
    --     word="T872;872;Diao;nmdtql;nmdtql030",
    --     text="T872.Diao，写过一些zzzbot的胶水程序",
    -- },
    {
        word="T1069;苏云;苏云云;苏云云云;suyuna",
        text="T1069.苏云，主办过不少中文社区方块赛事和活动",
    },
    {
        word="T043;xb;xb2002b",
        text="T043.xb，曾主办过不少中文社区方块赛事，是中文维基主要的编辑者之一",
    },
    {
        word="T6623;Aqua6623;Aquamarine6623;海兰",
        text="T6623.海兰，Aquamino的作者",
    },
    {
        word="osk",
        text="osk，创立了TETR.IO",
    },
    {
        word="Dr.ocelot;Dr ocelot;ocelot",
        text="Dr.Ocelot，制作了TETR.IO的音频，编写了QP2模式的所有音乐；Tetra Legends的作者",
    },
    {
        word="garbo",
        text="Garbo，设计了TETR.IO的游戏玩法和世界观相关内容",
    },
    {
        word="Minus Kelvin;MinusK",
        text="Minus Kelvin，编写了Cold Clear机器人",
    },
    {
        word="ZZZ;Zou Zhi Zhang",
        text="奏之章，编写了ZZZ机器人",
    },
}

local zict={entryList={}}
local function checkWords(entry)
    if entry.word:find("；") then
        print("Fullwidth semicolon found in entry '"..entry.title.."'")
    end
end
-- os.execute('chcp 65001')
local function loadData(data)
    for _,entry in next,data do
        checkWords(entry)
        for _,word in next,STRING.split(entry.word,";") do
            word=SimpStr(word)
            if zict[word] then
                print("Repeat Keyword: "..word)
            else
                zict[word]=entry
            end
        end
        table.insert(zict.entryList,entry)
    end
end

loadData(meta)
loadData(main)
loadData(pattern)
loadData(game)
loadData(extra_tetrio)
loadData(contributor)

print("Zictionary Data Loaded, total "..#zict.entryList.." entries")

return zict
