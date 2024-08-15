--[[
    word是每个词条的查询关键词，多个名称用分号分隔，目前访问词条必须完全匹配其中的一个（不过英文字母大小写和空格会被忽略，例如a b c和ABC视为同一个东西）。
    title是词条第一行内容
    text是词条的正文
    link可选，如果有的话会在最后一行显示为“相关链接：xxx.com”
]]
local data={
    -- # 元
    {
        word="help;帮助",
        title="help",
        text="小Z词典-Revive 堂堂复活！\n遇到萌新有问题的时候发送#[词条标题]就可以召唤出Techmino中小Z词典的内容\n目前只支持标题全字匹配，仅能忽略大小写和空格差异，术语优先使用看起来比较正常的中文译法（否则保留原文，比如b2b）\n技术还在试验阶段，随时可能停机，对不起喵！",
    },
    {
        word="新人;萌新",
        title="新人学习/练习路线",
        text="以下是关于提升真正打块能力的指引，如果在以下任何项目练习过程中感到有困难，可以适当回去玩玩自己喜欢的项目。别忘了你是来 “玩” 游戏的，兴趣最重要。\n以下给出几个新手时期的主线任务树，前期主要就应该练习以下内容，学定式和T-Spin什么的对实力帮助很小（我们不认为靠定式对战秒其他萌新是有效实力）：\n（注意，三段应当同时进行，不是A→B→C）\nA. 堆叠能力练习方法\n\tA1. 手上的块可以放的时候先别急着放，看看下一块有没有地方，如果放不下去就看看手上的能不能换个地方\n\tA2. 尝试把地形尽量控制得平整，因为大多数情况比较平的地形来啥块都比较容易放得下去\n\tA3. 允许hold的时候可以多想想手里和hold的块和后续几块应该怎么安排顺序，长远地使地形平整\nB. 操作效率与速度练习方法\n\tB1. 不要每一块都拿影子去对形状对位置，要自己想象这个块转一下是什么方向，想好了再开始按按键\n\tB2. 学习双旋，能逆时针转一次就不要顺时针转三次，费手\n\tB3. 学习极简，刚开始不用管速度，保证正确率最重要，养成良好习惯以后再提速快得很\nC. 堆叠能力考核\n\tC1. 稳定完成40行不死（可以用hold）\n\tC2. 稳定完成40行不死（不能用hold）\n\tC3. 稳定全程消四完成40行（可以用hold）\n\tC4. 稳定全程消四完成40行（不能用hold）\n以上都是根据社区和个人经验总结的模糊方法与目标，所以C的考核可以根据自身情况调整严格程度（例如 “稳定” 的具体成功率）。\n注：完成C的考核后，需要在未来一直注意没有上限的A1，这是方块的根本元素之一，强大的读next能力可以让你快速上手任何变种玩法。",
    },
    {
        word="学习tspin",
        title="关于T-spin学习",
        text="首先指出：要能熟练做出各种T-spin并不是只看着T-spin的那一小部分地形就可以玩好的，对玩家堆叠能力和计算next能力同样也有较高的要求。\n\n如果不只是出于娱乐、随便玩玩的目的，是真的想不断提升T-spin能力变强，请在基础能力达到一定要求前不要刻意去学习太多的T-spin，而先把重点放在堆叠等基本功上。\n\n参考学T门槛水平：40L达到60s以内（可以视个人情况调整为40~120s）、能够轻松完成全程消四的40L、不使用Hold不降太多速度的前提下比较轻松完成全程消四的40L（培养看next的意识和算力）。",
    },
    {
        word="灰机;huiji;灰机wiki",
        title="灰机Wiki",
        text="俄罗斯方块中文维基，由一群来自俄罗斯方块研究群及下属群的方块同好建立的关于俄罗斯方块的中文百科全书。\n\n目前其大部分页面翻译和参考来自Hard Drop Wiki和Tetris Wiki",
        link="https://tetris.huijiwiki.com",
    },
    {
        word="harddrop wiki",
        title="HardDrop Wiki",
        text="（英文）位于Hard Drop全球俄罗斯方块社区的Wiki百科",
        link="https://harddrop.com/wiki/Tetris_Wiki",
    },
    {
        word="tetris wiki",
        title="Tetris Wiki",
        text="（英文）一个专注于创建俄罗斯方块相关内容的Wiki百科，由Myndzi在 2015创办。年复一年，上千玩家贡献了一系列的官块和自制块的说明，游戏的隐藏机制，和提升游戏体验的教程",
        link="https://tetris.wiki",
    },
    {
        word="tetris wiki fandom",
        title="Tetris Wiki Fandom",
        text="（英文）一个俄罗斯方块维基",
        link="https://tetris.fandom.com/wiki/Tetris_Wiki",
    },
    {
        word="fumen",
        title="Fumen",
        text="一个方块版面编辑器，可以用于分享定式，PC解法等，用处很多。设置里可以启用英文版。",
        link="http://fumen.zui.jp  https://knewjade.github.io/fumen-for-mobile",
    },
    {
        word="github",
        title="GitHub",
        text="Techmino的GitHub仓库地址，欢迎Star",
        link="https://github.com/26F-Studio/Techmino",
    },
    -- # 游戏（题库）
    {
        word="ttt",
        title="TTT",
        text="全称Tetris Trainer Très-Bien (by こな)。现代方块特殊操作手把手教程（只能键盘操作）\n\t推荐能纯消四完成40L挑战的人学习\n\t内含T-spin、极简、SRS、部分对战定式介绍等教程\n注：提供的链接是翻译后挂在茶服的版本",
        link="https://teatube.cn/ttt",
    },
    {
        word="ttpc",
        title="TTPC",
        text="全称TETRIS Perfect Clear Challenge (by chokotia)。SRS+Bag7方块游戏Perfect Clear Opener教程（只能键盘操作）。推荐完成了TTT的人学习（必须先学会SRS）\n\n注：提供的链接是翻译后挂在茶服的版本。",
        link="https://teatube.cn/ttpc",
    },
    {
        word="nazo",
        title="NAZO",
        text="各类SRS试题\n\t推荐能通过TTT的玩家尝试。\n\t内含各种T-spin/All spin题目，简单到极难题目都有。\n\n注：提供的链接是翻译后挂在茶服的版本。",
        link="https://teatube.cn/nazo",
    },
    {
        word="tpo",
        title="TPO",
        text="全称Tetris Puzzle O。由TCV100制作的题库网站，内含nazo的部分题库。",
        link="http://47.92.33.38/tpo",
    },
    -- # 游戏（网页）
    {
        word="kos;king of stackers",
        title="King of Stackers",
        text="网页游戏 | 多人 | 支持移动端\n简称KoS。网页版回合制对战方块点击即玩（可能很卡），主要规则为：以7块为一个回合，双方轮流在自己场地中放置方块，任何的攻击只在对方回合放一块不消行后生效，策略性很强。有不同的伤害表设置。",
        link="https://kingofstackers.com/games.php",
    },
    {
        word="屁块;tetr.js",
        title="Tetr.js",
        text="网页游戏 | 单机 | 支持移动端\n简称屁块（因为作者网名叫Farter）。设置内容足够专业，模式很多，但画面很简单，几乎没有动画，而且移动端只有几套固定的按键组合（不能自由拖放）。",
        link="http://farter.cn/t",
    },
    {
        word="tl;tetra legends",
        title="Tetra Legends",
        text="网页游戏 | 单机 | [服务器在国外可能卡]\n简称TL。单机模式比较丰富，有两个隐藏的节奏模式，并且将一些其他游戏中不可见的机制进行了可视化，动效也很多。在2020年12月，基本确定由于各种原因不再继续开发。",
        link="https://tetralegends.app",
    },
    {
        word="asc;ascension",
        title="Ascension",
        text="网页游戏 | 单机/多人 | [服务器在国外可能卡]\n简称ASC，使用自己的ASC旋转系统，有不少单机模式（Techmino的堆积模式就来自ASC），对战模式目前处在测试阶段（2022/04/16）",
        link="https://asc.winternebs.com",
    },
    {
        word="js;jstris",
        title="Jstris",
        text="网页游戏 | 单机/多人 | 支持移动端 | [服务器在国外可能卡]\n简称JS，有常用的科研向单机模式和自定义各种参数的功能，允许拖放固定尺寸的正方形虚拟按键，没有任何动画效果",
        link="https://jstris.jezevec10.com",
    },
    {
        word="io;tetrio;tetr.io",
        title="TETR.IO",
        text="网页游戏 | 单机/多人 | [服务器在国外可能卡]\n简称IO，有排位系统和功能全面的自定义模式，单机模式只有三个。有电脑客户端下载（优化性能，无广告）。\n[Safari浏览器似乎打不开]",
        link="https://tetr.io",
    },
    {
        word="nuke;nuketris",
        title="Nuketris",
        text="网页游戏 | 单机/多人 | [服务器在国外可能卡]\n有几个基础单机模式和1V1排位。",
        link="https://nuketris.com",
    },
    {
        word="wwc;worldwide combos",
        title="Worldwide Combos",
        text="网页游戏 | 单机/多人 | [服务器在国外可能卡]\n简称WWC，全世界匹配制1V1。特色：有录像战，匹配的对手可以不是真人；几种不同风格的大规则；炸弹垃圾行对战。",
        link="https://worldwidecombos.com",
    },
    {
        word="tf;tetris friends",
        title="Tetris Friends",
        text="网页游戏 | 单机/多人\n简称TF，已经关服了的网页版方块。以前人比较多，后来官服倒闭了热度下去了，不过现在有人架了私服还可以体验到。",
        link="https://notrisfoes.com",
    },
    {
        word="tetris.com",
        title="tetris.com",
        text="网页游戏 | 单机 | 支持移动端\ntetris.com官网上的俄罗斯方块，只有马拉松一种模式，特色是支持基于鼠标指针位置的智能控制。",
    },
    {
        word="tetris gems",
        title="Tetris Gems",
        text="网页游戏 | 单机\ntetris.com官网上的俄罗斯方块，限时1分钟挖掘，有重力机制。\n有三种消除后可以获得不同功能的宝石方块。",
    },
    {
        word="tetris mind bender",
        title="Tetris Mind Bender",
        text="网页游戏 | 单机\ntetris.com官网上的俄罗斯方块，在马拉松基础上添加了技能，场地上会随机冒出技能方块，消除后会得到各种各样或好或坏的技能。",
    },
    -- # 游戏（跨平台）
    {
        word="tech;techmino;铁壳;铁壳米诺",
        title="Techmino",
        text="跨平台 | 单机/多人\n简称Tech，使用LÖVE引擎开发的一款方块游戏，单机模式和各种设置都很齐全，联机正在逐渐开发中。",
        link="http://studio26f.org",
    },
    {
        word="falling lightblocks",
        title="Falling Lightblocks",
        text="网页游戏/iOS/Android | 单机/多人\n一个全平台块，横竖屏，有延迟并且不可调。手机支持自定义键位，主要玩法基于NES块设计，也有现代模式。对战为半即时半回合制，无攻击缓冲不可抵消。",
    },
    {
        word="剑桥;cambridge",
        title="Cambridge",
        text="跨平台 | 单机\n使用LÖVE引擎开发的一款方块游戏，致力于创建一个轻松高度自定义新模式的方块平台。最初由Joe Zeng开发，于2020/10/08的0.1.5版开始Milla接管了开发。 — Tetris Wiki.",
    },
    {
        word="nanamino",
        title="Nanamino",
        text="Windows/Android | 单机\n块圈玩家自制方块，正在开发中，有一个原创旋转系统。",
    },
    -- # 游戏（街机/类街机）
    {
        word="tgm;tetris the grand master;tetris grand master",
        title="TGM",
        text="Windows | 单机/本地双人\n全称Tetris The Grand Master，一个街机方块系列（有修改过的版本可以在大多数Windows电脑运行），S13/GM等称号都出自该作。\n\n其中TGM3目前玩得最普遍，部分模式说明：\n\nMaster：大师模式，有段位评价，拿到更高段位点的要求：非消一的连击和消四，字幕战中消除和通关，每100的前70小于【标准时间，上一个0~70秒数+2】中小的一个，每100总用时不能超过限定值（不然取消上一个方法的加分并反扣点数）；到500若没有进标准时间会强制结束游戏（称为铁门）；字幕战有两个难度，半隐和全隐，后者必须拿到几乎全部的段位点才能进，消除奖励的段位点也更多。\n\nShirase：死亡模式，类似于techmino中的20G-极限，开局就是高速20G，500和1000有铁门，500开始底下开始涨垃圾行，1000开始出现骨块，1300通关进入大方块字幕战；段位结算：每通100加1段从S1到S13，如果通关了字幕战就会有金色的S13\n\n更多内容详见链接",
        link="https://teatube.cn/TGMGUIDE",
    },
    {
        word="dtet",
        title="DTET",
        text="Windows | 单机\n单机方块游戏，基于经典规则加入了20G和一个强大的旋转系统，但是除了键位其他参数都不可自定义。有点难找到，而且找到后可能还要自己补齐缺的DLL文件。",
    },
    {
        word="hebo;heboris",
        title="Heboris",
        text="Windows | 单机\n一个仿街机方块游戏，可以模拟多个方块游戏的部分模式。",
    },
    {
        word="texmaster",
        title="Texmaster",
        text="Windows | 单机\n简称Tex，包含TGM的所有模式，可以用来练习TGM，但World规则不完全一样（如软降到底无锁延，踢墙表有细节不同等）。",
    },
    -- # 游戏（其他）
    {
        word="tec;tetris effect;tetris effect connected",
        title="Tetris Effect: Connected",
        text="PS/Oculus Quest/Xbox/NS/Windows | 单机/多人\n简称TEC，特效方块游戏。\n相比早期的Tetris Effect单机游戏，TEC增加了联网对战，包含Boss战、Zone对战、经典块对战和分数对战四个模式。",
    },
    {
        word="t99;tetris 99",
        title="Tetris 99",
        text="NS | 单机/多人\n简称T99，主玩99人混战的吃鸡模式，战术比重比较大，胜率不只由玩家在平时1V1时的水平决定。\n也有一些常用单机模式如马拉松等。",
    },
    {
        word="ppt;puyo puyo tetris",
        title="Puyo Puyo Tetris",
        text="PS/NS/Xbox/Windows | 单机/多人\n简称PPT，将方块和 Puyo Puyo 两个下落消除游戏放到一个游戏里，二者可以对战，联机单机模式都很多。另有一拓展版本Puyo Puyo Tetris 2。\n[Steam PC版相对NS版手感和网络等都不太好]",
    },
    {
        word="to;top;toj;tos;tetris online",
        title="Tetris Online",
        text="Windows | 单机/多人\n简称TO，主要用来6人内对战/单挑/刷每日40L榜/挖掘模式/打机器人。支持自定义DAS/ARR但都不能到0。\n现在还开着的服务器有：\nTO-P（波兰服，服务器在波兰，可能会卡顿）\nTO-S（研究服，研究群群友自己开的服，很稳定，需要进群注册）",
    },
    {
        word="tetra online",
        title="Tetra Online",
        text="Windows/macOS/Linux | 单机/多人\n简称TO，由Dr Ocelot和Mine两人开发\n故意设计为延迟较多，平时玩无延迟方块的玩家可能会不习惯。\n2020年12月9日收到来自TTC的DMCA警告信于是被迫停止开发，在一段时间后关服并下架Steam。\n现在在GitHub上面还可以下到Windows的Offline Build。\n[UI部分模仿了PPT，音乐不错，攻击特效好看。]",
        link="https://github.com/Juan-Cartes/Tetra-Offline/releases/tag/1.0",
    },
    {
        word="c2;cultris2;cultris ii",
        title="Cultris II",
        text="Windows/OS X | 单机/多人\n简称C2，设计基于经典规则出发，支持自定义DAS/ARR，对战的主要玩法是基于时间的连击，考验玩家速度/Wide打法/挖掘。",
    },
    {
        word="np;nullpomino",
        title="Nullpomino",
        text="Windows/macOS/Linux | 单机/多人\n简称NP，整个游戏自定义程度极高，几乎任何参数都可以自己设置，是一个专业级方块。\n[不过UI风格比较老，需要全键盘操作，刚开始可能不习惯。macOS Monterey貌似无法运行。]",
    },
    {
        word="misamino",
        title="Misamino",
        text="Windows | 单机\n块圈玩家自制方块，单机1v1，主玩回合制模式，可以自定义AI（自己写的话需要了解接口）。",
    },
    {
        word="touhoumino",
        title="Touhoumino",
        text="Windows | 单机\n块圈玩家自制方块，一个Nullpomino的自带资源包的改版，将东方Project元素与俄罗斯方块结合。马拉松模式结合了东方Project里的 “符卡” 机制，需要在一定时间内达成目标分数才能击破。\n[难度较大，适合有方块基础并且各项能力都较强的玩家游玩（不然都不知道自己怎么死的）。]",
    },
    {
        word="tetris blitz",
        title="Tetris Blitz",
        text="iOS/Android | 单机/多人\n简称闪电战，EA代理的一款移动端方块，有重力连锁机制，限时2分钟，游戏开始会掉下一堆小方块；持续消行会进入Frenzy模式（场地下方会不断冒出垃圾行，帮助玩家制造大连锁，如果多次落块没有消行会强制结束Frenzy）。有非常多的道具。\n当新出现的方块与场地现有方块重叠时，场地最上方的几行会被自动清除，游戏不结束。已于2020年4月下架。",
    },
    {
        word="tetris ea",
        title="Tetris (EA)",
        text="iOS/Android | 单机/多人?\nEA代理的一款宇宙主题的移动端方块。有滑动操控和单点触控两种操作模式；除经典的马拉松外还有一个星系模式（地图挖掘），有重力连锁机制，目标是在限定块数内消除所有地图块。\n已于2020年4月下架。",
    },
    {
        word="tetris beat",
        title="Tetris Beat",
        text="iOS | 单机\nN3TWORK代理的一款移动端方块。除了马拉松以外游戏还有一个 “Beat” 模式，但只需根据BGM的节奏落块就可以得到额外分数。\n[特效比较瞎眼，不支持自定义键位，而且默认的按钮也很小导致控制也不是很舒服]",
    },
    {
        word="tetris n3twork;tetris n3t",
        title="Tetris (N3TWORK)",
        text="iOS/Android | 单机/多人\nN3TWORK代理的一款移动端方块，有马拉松、3分钟限时打分和Royale（最多100人对战）模式。\n[UI设计比较不错，但不支持自定义键位，而且默认的按钮也很小导致控制也不是很舒服]",
    },
    {
        word="环游记;俄罗斯方块环游记;journey;tetris journey",
        title="俄罗斯方块环游记",
        text="iOS/Android | 单机/多人\n简称环游记，国内第一款正版授权手游方块。有闯关模式、对战模式和几个单机模式。闯关模式有各种各样有趣规则大多数有重力连锁，对战规则同现代方块，可以自定义虚拟按键的大小和位置，但是不能自定义DAS/ARR。已于2023年2月15日停服。",
    },
    {
        word="jj;jj块",
        title="JJ块",
        text="Android | 单机/多人\nJJ棋牌平台下一个休闲游戏，Android端百度 “JJ比赛” 官网下载平台后可以找到（找不到的原因是iOS系统或者没在官网下载或者被限制不可直接访问游戏）。竖屏，输入延迟很小，可自定义DAS/ARR/20G软降，简单自定义键位，无Hold，没有B2B，无攻击缓冲不可抵消，每次攻击上限为4，连击较强，其他同现代方块。",
    },
    {
        word="火拼;火拼俄罗斯",
        title="火拼俄罗斯",
        text="Windows | 多人\n腾讯游戏大厅的方块，场地12列，打字的 DAS 和 ARR，1 Next无 Hold，攻击途径只有消4打3、 消3打2，垃圾行为国际象棋棋盘式，几乎不可能挖掘。",
    },
    -- # 术语（缩写）
    {
        word="lpm;bpm;ppm;pps",
        title="速度",
        text="Line Per Minute：行每分，体现玩家下块速度。\nBlock/Piece Per Minute/Second：块每分/秒，体现玩家下块速度。\n注：不同游戏中的“LPM”含义可能不同，虽然写的是行数但可能实际用的是块数/2.5，以此忽略掉对战模式中垃圾行带来的干扰",
    },
    {
        word="kpm",
        title="KPM",
        text="Key Per Minute\n按键每分，体现玩家按键速度。",
    },
    {
        word="kpp",
        title="KPP",
        text="Key Per Piece\n按键每块，体现玩家操作是否繁琐。\n学会极简提升操作效率以降低此数字。",
    },
    {
        word="apm;spm",
        title="攻击",
        text="Attack Per Minute：攻击每分。\nSent per minute：送出每分\n一定程度体现玩家攻击力。其中Sent指送出的垃圾行，如果对手先打来垃圾行自己抵消时就不计入Sent，但仍然计Attack。",
    },
    {
        word="dpm",
        title="DPM",
        text="Dig Per Minute\n挖掘每分，玩家每分钟向下挖掘的垃圾行数。\n一定程度体现玩家生存能力。",
    },
    {
        word="adpm;vs",
        title="ADPM",
        text="Atk & Dig Per Minute\n攻击+挖掘每分，用于在同一局游戏内对比玩家间水平差距，比APM更准确一些。在TETR.IO中叫 “VS” 的数据就是ADPM（调整过比例，具体是Atk & Dig per 100s）",
    },
    {
        word="apl;效率",
        title="APL",
        text="Attack Per Line\n攻击每行（效率通常指此），体现玩家攻击的行利用率。例如消四（4行4攻）和T旋（2行4攻）的效率就比消二（2行1攻）和消三（3行2攻）高。",
    },
    -- # 术语（消除名）
    {
        word="quad;techrash;消四",
        title="消四",
        text="一次消除四行。\nTetris中的消四有特殊的名称Tetris，非官方游戏中有的考虑到版权问题抛弃了这个习惯称其为Quad，也有一些游戏保留了这个传统，会给消四安排一个特殊的名称，例如在Techmino称消四为Techrash。",
    },
    {
        word="tetris",
        title="Tetris",
        text="商标，Tetris游戏名，同时也是“消四行”的名字。\n含义是Tetra（古希腊语, 四 <τέτταρες>）+ Tennis（网球 游戏原作者喜欢的运动）。\n现在版权在TTC（The Tetris Company）手上，任天堂和世嘉开发游戏是 TTC 授权的， 它们自己并没有Tetris的版权。\n另见 #消四",
    },
    {
        word="全消;全清;ac;pc;all clear;perfect clear",
        title="All Clear",
        text="消除场地上所有的方块。\n也叫Perfect Clear，全消，或全清。",
    },
    {
        word="半全消;半全清;hc;hpc;half clear",
        title="Half Clear",
        text="Techmino限定，All Clear的外延\n“下方有剩余方块” 的全消（特别地，如果只消1行则必须不剩余玩家放置的方块），能打出一些攻击和防御（）。\n另见 #Color Clear",
    },
    {
        word="color clear;颜色消除;颜色清除",
        title="Color Clear",
        text="TETR.IO限定，All Clear的外延\n消除场地上所有彩色的方块（垃圾行通常是灰色的）。\n另见 #Half Clear",
    },
    -- # 术语（旋转相关）
    {
        word="spin;tspin;t-spin",
        title="Spin",
        text="使用旋转将方块卡进一些不能直接移动进入的位置（根据具体语境，可能会指同时消除行），具体判定规则不同游戏不一样，通常会有额外的分数/攻击加成。\n在官方规则中，当T方块在锁定前的最后一个操作是旋转，并且锁定后旋转中心对应的四个斜角位置有三个不是空气，那么这就是一个T-spin。\n另见 #Mini #All Spin",
    },
    {
        word="mini",
        title="Mini Spin",
        text="一些游戏会使用Mini标签来对部分Spin进行弱化。\n不同游戏的判定差异很大且通常很复杂，建议只记住常见形状即可。",
    },
    {
        word="all spin",
        title="All Spin",
        text="规则名，指用所有方块进行Spin消除都能获得奖励，而不是通常仅T-spin才能打出攻击（T-Spin Only）。",
    },
    {
        word="tss;tsd;tst",
        title="TSS/TSD/TST",
        text="T-Spin Single/Double/Triple：使用T方块Spin并消除1/2/3行，也称T1/T2/T3。其中T3需要旋转系统支持才可能打出。",
    },
    {
        word="ospin;o-spin",
        title="O-spin",
        text="由于O方块旋转后形状不变，只能左右移动，所以经常被卡住，于是就有了O-spin这个梗：\n后来有个人做了T99/TF中的O块变形的特效视频广为流传；\nT-ex设计的旋转系统可以用spin使O传送进坑；\nTech设计的变形系统中可以旋转O来变形/传送进入一些特定形状的洞。",
    },
    {
        word="旋转系统;rs;rotation system",
        title="旋转系统",
        text="现代方块游戏中，方块能绕着旋转中心（Techmino中可见）旋转（部分游戏没有固定中心），如果旋转后和场地或墙壁有重合，会根据<从哪个方向转到哪个方向>进行一些偏移测试（这个偏移称为踢墙），不会卡住转不动，同时也可以让方块钻进入一些特定形状的洞。不同的旋转系统偏移位置顺序都不一样，具体数据去各大Wiki上查，一堆数字这里就不放了",
    },
    {
        word="朝向;方块朝向;direction",
        title="方块朝向",
        text="在SRS或者类SRS的旋转系统中需要说明方块朝向的时候，“朝下” “竖着” 等词描述太模糊。\nSRS中每种方块的初始状态固定，所以我们使用0（原位）、R（右，即顺时针转一次）、2（转两下，即180°）、L（左，即逆时针转一次）四个字符表示方块的四种状态，从原位（0）开始顺时针转一圈四个状态是0R2L。\n最早见于SRS踢墙表的行首，0→L表示原位逆时针转一次到L状态，0→R表示原位顺时针转一次到R状态，2→R代表从180°状态逆时针转一次到R状态。",
    },
    {
        word="arika rs",
        title="ARS",
        text="Arika Rotation System，TGM系列使用的旋转系统（3代中的C模式）\n或者\nAtari Rotation System，一个左上对齐旋转系统。",
    },
    {
        word="asc rs;ascension rs",
        title="ASC RS",
        text="ASC Rotation System\nASC块使用的旋转系统，所有块所有形状只根据旋转方向（顺时针和逆时针）使用两个对称的表，踢墙范围大概是±2, ±2。",
    },
    {
        word="brs;bps rs",
        title="BRS",
        text="BPS Rotation System\nBPS块使用的旋转系统。",
    },
    {
        word="birs;bias rs",
        title="BiRS",
        text="Bias Rotation System\nTechmino原创旋转系统，基于XRS和SRS设计。\n当左/右/下（软降）被按下并且那个方向顶住了墙，会在旋转时添加一个额外偏移（三个键朝各自方向加1格），和基础踢墙表叠加（额外偏移和叠加偏移的水平方向不能相反，且叠加偏移的位移大小不能超过√5）。如果失败，会取消向左右的偏移然后重试，还不行就取消向下的偏移。\nBiRS相比XRS只使用一个踢墙表更容易记忆，并且保留了SRS翻越地形的功能。",
    },
    {
        word="c2rs;cultris2 rs",
        title="C2RS",
        text="Cultris II Rotation System\nCultris II原创的旋转系统，所有旋转共用一个表，顺序是：\n左1→右1→下1→左下→右下→左2→右2\n注意，左优先于右。",
    },
    {
        word="drs;dtet rs",
        title="DRS",
        text="DTET Rotation System.",
    },
    {
        word="nrs;nes rs;nitendo rs",
        title="NRS",
        text="Nintendo Rotation System，NES和GB块使用的旋转系统。NRS有两个互为镜像的版本，左旋版用于GB，右旋版用于NES。",
    },
    {
        word="srs;super rs;super rotation system",
        title="SRS",
        text="Super Rotation System\n现代方块最常用的旋转系统，也是不少自制旋转系统的设计模板。\n对于SRS，每个方块有四个方向，可以朝两边转（180°不算，最开始没有这个设计），所以总共8种，对应8个偏移表，具体数据去Wiki上查，这里就不放了。",
        link="https://tetris.wiki/Super_Rotation_System",
    },
    {
        word="srs plus;srs+",
        title="SRS+",
        text="SRS的拓展版，添加了180°转的踢墙表。",
    },
    {
        word="trs;tech rs;techmino rs",
        title="TRS",
        text="Techmino Rotation System\nTechmino原创旋转系统，基于SRS设计，修补了一些常见SZ卡死的地形，增加了不少实用踢墙。\n每个五连块也基本按照SRS的Spin逻辑单独设计了踢墙表。\n更有神奇O-spin等你探索！",
    },
    {
        word="xrs",
        title="XRS",
        text="X Rotation System\nT-ex原创旋转系统，引入了 “按住方向键换一套踢墙表” 的设定（在对应的方向需要顶住墙），让 “想去哪” 能被游戏捕获从而转到玩家希望到达的位置。\n\n其他旋转系统无论踢墙表怎么设计，块处在某个位置时旋转后最终只能按固定顺序测试，这导致不同的踢墙是竞争的，若存在两个可能想去的位置就只能二选一，XRS解决了这个问题。",
    },
    -- # 术语（其他）
    {
        word="b2b;back to back",
        title="B2B",
        text="Back to Back\n连续打出两次特殊消行（Spin或消四），中间不夹杂普通消行，可以提供额外的攻击（在Techmino中B2B为满贯，大满贯是B3B）。连续PC/HPC在Techmino中也算B2B/B3B。",
    },
    {
        word="b2b2b;b3b;back to back to back",
        title="B2B2B",
        text="Back to Back to Back\nB2B的加强版，缩写B3B，大量B2B后连续B2B会变成B2B2B，提供更强的攻击（仅Techmino中有）。",
    },
    {
        word="fin;neo;iso;特殊t2;可移动t2",
        title="Fin/Neo/Iso",
        text="三类特殊T2的名字，受不同具体规则影响，在不同的游戏内的效果可能不一样，通常没有实战价值。",
    },
    {
        word="现代块;现代方块；modern tetris",
        title="现代方块",
        text="现代方块是一个模糊的概念，这里列出一部分 “标准” 规则，满足大部分的都可以认为是现代方块：\n1.可见场地大小是10×20，不过上方空间也是存在的，上限可以自己定，一些游戏用的是40；\n2.七种方块从顶部正中间出现（奇数宽方块偏左，高度可以是方块底部或顶部贴着场地顶），同一种方块的朝向（一般是平的面朝下）和颜色都一致；\n3.一个合适的随机出块机制（常见的详见Bag7词条和His词条）；\n4.一个合适的的旋转系统（至少有双旋，详见双旋词条）（最好是SRS或类SRS，详见SRS词条）；\n5.一个合适的锁定延迟系统，详见锁定延迟词条；\n6.一个合适的死亡判定，详见死亡判定词条；\n7.有Next功能（一般是3~6个，也有1个的），详见Next词条，并且方向和出现时候的方向一致；\n8.有Hold功能，详见Hold词条；\n9.有DAS系统负责精密并且快速的左右移动，详见DAS词条；\n10.如果有出块延迟和消行延迟，那么需要有提前旋转/Hold系统，详见IRS和IHS词条，IMS是Techmino特有。",
    },
    {
        word="tetrimino;tetromino;tetramino;四连块;四联块;形状;方块形状",
        title="四连块",
        text="在公认的“标准方块游戏”中，用到的形状是所有的 “四连块”，即四个正方形共用边连接成的形状。\n在不允许翻转，只允许旋转的情况下，四连块一共有七种，根据它们的形状一般分别叫做Z、S、J、L、T、O、I。",
    },
    {
        word="配色;颜色;方块颜色;标准配色;方块配色",
        title="方块配色",
        text="在公认的“标准方块游戏”中，七种块的颜色会使用同一套彩虹配色：\nZ：红 S：绿 J：蓝 L：橙 T：紫 O：黄 I：青",
    },
    {
        word="预输入;buffered input;提前旋转;提前暂存;提前移动;irs;ihs;ims",
        title="预输入",
        text="Buffered Input 预输入 / Initial ** System 提前**系统\n优秀的操作密集型游戏通常会考虑给控制系统加入预输入的功能，当一些操作哪怕在无法执行时按键动作最终也会被执行出来（比如在方块还没有出现的时候就按旋转键，方块会在出现后立刻旋转），降低了对玩家操作准确度的要求，扩大了“完美操作”的输入窗口，设计得当时可以显著提升游戏的手感。",
    },
    {
        word="预览;下一个;next",
        title="预览",
        text="指示后边几个块的顺序。\n提前思考手上这块怎么摆可以让后面轻松是玩家提升的必需技能。\n\n关于玩家玩的时候到底看了几个Next：这个数字并不固定，不同玩家、不同模式、不同局面，计算next的数量都不一样，通过调整可见Next数量打40L比较时间等方式测得的数据并不准确。\n\n具体例如，一个比较熟练的玩家几乎永远会提前算好一个Next，不然不会锁定手里的块；场地上将要出现或可以构造消四洞（T坑）的时候会找最近的I（T）什么时候来，如果太远了就会直接挖掉放弃本次攻击以防被对手偷袭。这两种情况并不独立，有很多介于中间的情况。所以，一个玩家看的Next数量是时刻在变的，“某人看几个Next” 没有精确答案，必须在指明情况的时候数字才能作为参考。",
    },
    {
        word="暂存;交换;hold",
        title="暂存",
        text="将手里的方块和Hold槽中的交换，用来调整块序，更容易摆出你想要的形状。（一般不允许连续使用）\n用不用Hold各有好处，不用的话看到序列是什么就是什么，减少了思考量；并且减少了按键的种类，操作简单容易提升KPS，有些人的40L记录就是不用Hold打出的。用Hold可以灵活地调整序列，减少高重力等规则带来的难度，算力足够的情况下可以达成更复杂的目标，甚至反过来显著减少总按键数。",
    },
    {
        word="深降;deepdrop",
        title="深降",
        text="开启该规则后，允许方块向下穿越地形进入地下的空洞\n该规则较偏向技术研究，对于AI来说有了它可以完全不用再考虑旋转系统，只要形状能容得下的地方就一定能到达。",
    },
    {
        word="md;misdrop;mishold",
        title="Misdrop",
        text="误放，就是不小心放错了地方。简称MD。\n另有Mishold（误hold），指不小心按到Hold导致失去PC机会甚至直接导致游戏结束。",
    },
    {
        word="捐赠;donate;donation",
        title="捐赠",
        text="指刻意临时堵住（可以消四的）洞做T-spin，打出T-spin后就会解开，是比较进阶的保持/提升火力的技巧。\n不标准用法：有时候只要堵住了个坑，即使不是消四洞也会用这个词。",
    },
    {
        word="攻击;进攻;防守;防御;攻防",
        title="对战攻防",
        text="攻击指通过消除给对手发送垃圾行；\n防御（相杀）指别人打过来攻击之后用攻击抵消；\n反击指抵消/吃下所有攻击后打出攻击。",
    },
    {
        word="连击;combo;ren",
        title="连击",
        text="连续的消除从第二次起称为 1 Combo，攻击数取决于具体哪一款游戏。“REN” 这个名称来源于日语中的 “連”（れん）。",
    },
    {
        word="spike",
        title="Spike",
        text="爆发攻击\n指短时间内打出大量的攻击，Techmino和TETR.IO中有Spike计数器，可以看到自己短时间内打出了多少攻击。",
    },
    {
        word="s1w",
        title="S1W",
        text="Side 1 Wide\n旁边空1列，是传统方块游戏里常见的消四打法。\n在现代方块对战中新手可以使用，短时间能打出大量攻击，但在高手场出场率不高，因为效率低，容易被对面一波打死，故只在极少数情况合适的时候用。",
    },
    {
        word="s2w",
        title="S2W",
        text="Side 2 Wide\n旁边空2列，是常见的连击打法。\n难度很低，现代方块对战中新手可以使用，结合Hold可以很轻松地打出大连击。高手场使用不多，因为准备时间太长，会被对面提前打进垃圾行，导致连击数减少或者直接Top Out，效率也没有特别高，故一套打完也不一定能杀人。",
    },
    {
        word="s3w",
        title="S3W",
        text="Side 3 Wide\n旁边空3列，比2w少见一些的连击打法。能打出的连击数比2w多，但是难度略大容易断连。",
    },
    {
        word="s4w",
        title="S4W",
        text="Side 4 Wide\n旁边空4列，一种特殊的连击打法，能打出很高的连击（需要熟练旋转系统，否则会大幅降低连击成功概率），并且准备时间比别的Wide打法短，故动作快的话可以抢在对手打进垃圾之前堆很高然后打出超大连击。\n（因为可能会被提前打死，风险挺大，所以没有c4w那么不平衡）。",
    },
    {
        word="c1w",
        title="C1W",
        text="Center 1 Wide\n中间空1列，一种实战里消4同时辅助打TSD的打法，需要玩家理解<平衡法>，熟练之后可以轻松消四+T2输出。",
    },
    {
        word="c2w;c3w",
        title="C2W/C3W",
        text="Center 2/3 Wide\n中间空2列，一种可能的连击打法（不常见）。",
    },
    {
        word="c4w;吃四碗",
        title="C4W",
        text="Center 4 Wide\n中间空四列，一种连击打法，能打出很高的连击，利用了大多数专业对战方块游戏的死亡判定机制，可以放心堆高不担心被顶死，然后开始连击。是一种利用游戏机制的不平衡策略（尤其在开局时），观赏性不是很强还可以以弱胜强，成本太低所以成为了部分游戏中约定的类似 “禁招” 的东西，请在了解情况后再使用，不然可能会被别人骂。\nTechmino中虑到了平衡问题，所以c4w的强度没有别的游戏那么夸张。\n另见 #N-Res",
    },
    {
        word="n-res",
        title="N-Res",
        text="N-Residual\nN-剩余，指4w连击楼底部留几个方格，常用的是3-Res和6-Res。\n3-Res路线少比较好学，成功率也很高，实战完全够用\n6-Res路线多更难用，但是计算力很强的话比3-Res更稳，也可以用来完成特殊挑战（比如Techmino的c4w练习要求100连击通关）。\n\n注：优先使用6-Res，然后是3-res和5-Res，最后是4-Res",
    },
    {
        word="63;63堆;63堆叠;6–3堆叠",
        title="6–3堆叠法",
        text="指左边6列右边3列的堆叠方式。在玩家有足够的计算能力后可以减少堆叠所用的按键数（反之可能甚至会增加），是主流的用于减少操作数的高端40L堆叠方式，原理跟出块位置是中间偏左有关。",
    },
    {
        word="block out;lock out;top out;死亡;死亡判定",
        title="死亡判定",
        text="现代方块普遍使用的死亡判定：\n1. 新出现的方块和场地方块有重叠（窒息，Block Out）（c4w比s4w强的原因，因为被打进18行都不会窒息）；\n2. 方块锁定时完全在场地的外面（Lock Out）；\n3. 场地内现存方块总高度大于40。（超高，Top Out）\n\n注：Techmino使用的死亡判定默认不开启第二、三条。",
    },
    {
        word="缓冲区",
        title="缓冲区",
        text="（不是所有游戏都有这个概念）指10×20可见场地之上的21~40行。因为垃圾行顶起后两边堆高的方块可能会超出屏幕，消行后这些方块要重新回到场地内所以需要保存下来，由于程序上要求场地尺寸有限（部分游戏可以无限），故设定为40，一般都够用。\n另见 #消失区",
    },
    {
        word="消失区",
        title="消失区",
        text="在缓冲区的基础上，指比40行缓冲区还高的区域。\n标准的死亡判定涉及了这个概念，在垃圾行升起后如果场地上有任何方块超出了40高的缓冲区（也就是达到了消失区）时游戏直接结束。\n但事实上这块区域在不同游戏中表现不同，甚至有设计者考虑不周导致方块挪到40行以上，但是程序没考虑导致方块接触消失区直接报错闪退的游戏。通常出现在玩家堆了c4w然后被打入大量垃圾行时才会考虑这个概念。其他游戏中方块进入消失区可能直接导致游戏结束，也有可能会出现一些奇怪的bug（附带链接是ppt的复制40行无限Ren视频）。\n\n另，Jstris中22行及以上可以理解为消失区，锁定在21行之外的格子会消失。",
        link="https://www.bilibili.com/video/BV1ZE411Y7GD",
    },
    {
        word="等级;下落速度;重力;gravity",
        title="下落速度",
        text="一般用*G表示方块的下落速度，意思是每一帧方块往下移动多少格，一秒下落一格就是1/60G（默认60fps），可以看出G是一个很大的单位。因为场地就20格，所以一般认为20G即为上限，详见20G词条。\n在Techmino中描述重力的方式是 “每过多少帧下落一格”，例如一秒落一格就对应60（默认60fps）",
    },
    {
        word="20g",
        title="20G",
        text="现代方块的最高下落速度，表观就是方块瞬间到底，不存在中间的下落过程，可能会让方块无法跨越壕沟/从山谷爬出。\n20G一般指的其实是 “无限下落速度” ，就算场地不止20格，“20G” 也会让方块瞬间到底。\nTechmino（和部分其他游戏，推荐这么设计）中20G的优先级比其他玩家操作都高，即使是0arr的水平方向 “瞬间移动” 中途也会受到20G的影响。",
    },
    {
        word="锁定延迟;lock delay",
        title="锁定延迟",
        text="方块<碰到地面到锁定>之间的时间。经典块仅方块下落一格时刷新倒计时，而现代方块中往往任何操作都将重置该倒计时（但是方块本身必须可以移动/旋转），所以连续移动和操作可以让方块不马上锁定，拖一会时间（Techmino和部分游戏重置次数有限，一般是15）。",
    },
    {
        word="生成延迟;spawn delay;are",
        title="生成延迟",
        text="ARE。方块<锁定完成到下一个方块出现>之间的时间。",
    },
    {
        word="消行延迟;clear delay;line clear delay;line are",
        title="消行延迟",
        text="Line ARE。方块<锁定完成能消行时的消行动画>占据的时间。",
    },
    {
        word="极简;finesse;极简操作",
        title="极简操作",
        text="用最少的按键数将方块移到想去的位置的技术（大多数时候只考虑纯硬降的落点），节约时间和减少Misdrop。\n\n该技能学习越早越好，建议先去找教程视频，看懂了然后自己多练习，开始以准确率第一，速度快慢不重要，熟练后自然就快了。\n\n注：一般说的极简不考虑带软降/高重力/场地很高的情况，仅研究空中移动/旋转后硬降。绝对理想的“极简”建议使用“最少按键数/操作数”表达。",
    },
    {
        word="科研",
        title="科研",
        text="指在低重力（或无重力）的单人模式里慢速思考如何构造各种T-spin，是一种练习方法。",
    },
    {
        word="键位",
        title="键位设置原则参考",
        text="1.不要让一个手指管两个可能同时按的键，通常只有几个旋转键不需要同时按，其他功能推荐都单独给一个手指\n2.除非已经在别的游戏里锻炼过小拇指，最好不要用，一般食指和中指最灵活，自己觉得舒服为准\n3.没必要参考别人的键位设置，每个人都不一样，只要不违反前几条规则，就几乎不会对成绩产生影响。",
    },
    {
        word="手感",
        title="手感",
        text="决定手感的几个主要因素：\n1. 输入延迟受设备配置或者设备状况影响。可以重启/换设备解决；\n2. 程序运行稳定性程序设计或.实现）得不好，时不时会卡一下。把设置画面效果拉低可能可以缓解；\n3. 游戏设计故意的。自己适应；\n4. 参数设置设置不当。去改设置；\n5. 游玩姿势姿势不当。不便用力，换个姿势；\n6. 换键位或者换设备后不适应，操作不习惯。多习惯习惯，改改设置；\n7. 肌肉疲劳反应和协调能力下降。睡一觉或者做点体育运动，过段时间（也可能要几天）再来玩。",
    },
    {
        word="das通俗;asd通俗",
        title="ASD通俗",
        text="打字时按住o，你会看到：ooooooooooo…\n在时间轴上：o—————o-o-o-o-o-o-o-o-o…\n—————就是asd（自动移动延迟），-就是asp（自动移动间隔）。\n另见 #ASD/ASP",
    },
    {
        word="asd;asp;asd/asp;das;arr",
        title="ASD/ASP",
        text="ASD（Auto-Shift-Delay，自动移动延迟，曾叫DAS）指从<按下移动键时动了一格>到<开始自动移动>之间的时间。\nASP（Auto-Shift-Period，自动移动间隔，曾叫ARR），指<每次自动移动>之间的时间\n单位都是f（帧，1帧=1/60秒）\n别的游戏里用的单位可能是ms（毫秒），乘16.7就可得出大约的对应数值，例如4f≈67ms。",
    },
    {
        word="asd设置引导;asd设置;asd引导;asd教程;asd调节",
        title="ASD设置引导",
        text="对于不是刚入门的并且了解极简操作的玩家来说推荐ASP=0，ASD=4~6（具体看个人手部协调性，只要能控制区别就不大）。\n新人如果实在觉得太快可以适当增加一点ASD，ASP要改的话强烈建议不要超过2\n\n最佳调整方法：ASD越小越好，小到依然能准确区分单点/长按为止；ASP能0就0，游戏不允许的话就能拉多小拉多小。",
    },
    {
        word="asd打断;das打断;dcd;das cut",
        title="ASD打断",
        text="Techmino中指玩家的操作焦点转移到新方块的瞬间，此时减小（重置）ASD计时器，让自动移动不会立刻生效，减少 “移动键松开晚了导致下一块一出来就立即开始移动” 的情况\n注：不同游戏中的具体机制可能不同，会在不同的时机影响ASD计时器，本词条仅供示意。",
    },
    {
        word="误硬降打断",
        title="误硬降打断",
        text="此机制是为了防止玩家硬降时当前方块早已锁定，导致下一块出现就被立刻硬降导致严重md。\n一种规则可以是方块自然锁定之后几帧内硬降键无效。\n注：不同游戏中的具体机制可能不同，本词条仅供示意。",
    },
    {
        word="sdf;软降倍率",
        title="软降倍率",
        text="Soft Drop Factor，软降速度倍率\n几乎所有官块和TETR.IO中，“软降”的实际效果是当软降键被按住时，方块受到的重力变为原来的若干倍，SDF就是这个变大的倍数。",
    },
    {
        word="7bag;bag7",
        title="7-Bag出块",
        text="一种出块方式，现代方块普遍使用该规则，开局起每7个块是7种形状各出现一次，避免了很久不出某个块和某个块来得特别多，是一些现代方块战术的基础。\n\n例如：\nZSJLTOI OTSLZIJ LTISZOJ",
    },
    {
        word="his;his4;h4r6",
        title="History出块",
        text="一种的出块方式，例如His4 Roll6 （h4r6）就是在随机生成新的 Next 的时候，随机一个跟最后4次生成的Next中有一样的，就重新随机，直到已经尝试6次或和那4个都不一样。\nTechmino的His序列模式中最大Roll次数为序列长度的一半（向上取整）\n\n是纯随机出块的一大改进，大大减小了连续出几个SZ（洪水）的概率。",
    },
    {
        word="hispool",
        title="HisPool出块",
        text="一种出块方式，History Pool，his算法的分支，比较复杂，这里只提供大概的说明：\n在His的基础上添加了一个Pool（池），在取块的时候his是直接随机和历史序列（最后4次生成的next）比较，而HisPool是从Pool里面随机取（然后补充一个最旱的块增加他的概率）然后和历史序列比较。\n\n这个算法让序列更稳定，介于His和Bag之间，在理论上保证了干旱时间不会无限长。",
    },
    {
        word="c2出块;cultris2出块",
        title="C2出块",
        text="（七个块初始权重设为0）把七个块的权重都除以2然后加上0~1的随机数，哪个权重最大就出哪个块，然后将其权重除以3.5\n循环。",
        -- _comment: 原Lua文件中包含此注释："Discovered by zxc"
    },
    {
        word="hypertap;超连点",
        title="Hypertap",
        text="快速震动手指，实现比长按更快速+灵活的高速单点移动，主要在经典块的高难度下（因为ASD不可调而且特别慢，高速下很容易md导致失败，此时手动连点就比自动移动更快）或者受特殊情况限制不适合用自动移动时使用。会使用这个技术的人称为 “Hypertapper”。",
    },
    {
        word="rolling;轮指",
        title="Rolling",
        text="另一种快速连点方法，用于ASD/ASP设置非常慢时的高重力（1G左右）模式。\n先把手柄（键盘……可能也行吧）悬空摆好，比如架在腿上，要连点某个键的时候一只手虚按按键，另外一只手的几根手指轮流敲打手柄背面， “反向按键” 实现连点。这种控制方法可以让玩家更轻松地获得比直接抖动手指的Hypertap（详见超连点词条）更快的控制速度。\n此方法最先由Cheez-fish发明，他本人则使用Rolling达到过超过20Hz的点击频率。",
    },
    {
        word="堆叠;stacl",
        title="堆叠",
        text="将方块无缝隙地堆起来，需要玩家有预读Next的能力，可以通过不使用Hold并且用十个消四完成40L模式进行练习。\n这项能力从入坑到封神都是非常重要的。",
    },
    {
        word="双旋",
        title="双旋",
        text="指能够使用顺时针+逆时针两个旋转键的技术，原来要转三下的情况可以反向转一下就够，减少烦琐操作。\n同时双旋也是学习Finesse的必要前提。\n另见 #三旋",
    },
    {
        word="三旋",
        title="三旋",
        text="指能够使用顺+逆时针+180°旋转三个旋转键的技术，任何方块放哪只需要旋转一次即可（Spin不算）。\n但由于只有部分游戏有180°旋转所以改操作并不通用，而且对速度提升的效果不如从单旋转双旋显著，不追求极限速度的玩家可不学。\n另见 #双旋",
    },
    {
        word="干旱;drought",
        title="干旱",
        text="经典块术语，指长时间不来I方块（长条）。现代方块使用的Bag7出块规则下平均7块就会有一个I，理论极限两个I最远中间隔12块，严重的干旱不可能出现。",
    },
    {
        word="骨块;bone;bone block",
        title="骨块",
        text="最早的方块游戏使用的方块样式。\n很久以前的电脑没有可以显示复杂图案的屏幕，只能往上打字，所以一格方块用两个方括号[　]表示，长得像骨头所以叫骨块。\n基于骨块的特点，Techmino把骨块重新定义为“低亮度+边缘不清晰”的不利于玩家辨识方块形状的贴图。",
    },
    {
        word="半隐",
        title="半隐",
        text="指方块锁定经过一段时间后会变隐形的规则\n注：从锁定开始到消失的具体时长不定，可以描述为 “过几秒种后消失”。",
    },
    {
        word="全隐;invis;invisible",
        title="全隐",
        text="指方块锁定后会马上完全隐藏\n注：锁定时有消失动画的话也可以叫全隐，但其实难度会小一点，故Techmino中没有动画的隐形模式叫瞬隐。",
    },
    {
        word="场地重力",
        title="场地重力",
        text="（由于 “重力” 有歧义所以本词典里称为场地重力，也有重力连锁等叫法。）\n部分游戏的部分模式可能包含此规则。此规则下玩家的四格方块四个方向有连接关系，连起来的几个格整体会受到重力影响，悬空了会往下落。在这个规则下可以构造复杂的连锁消除，一个主打连锁消除对战的游戏是Qudra（老游戏，现在基本没人玩）。",
    },
    {
        word="mph",
        title="MPH",
        text="一个游戏模式：\nMemoryless，Previewless，Holdless\n纯随机块序+无Next+无Hold完成40L，一个非常考验玩家反应速度的模式。",
    },
    {
        word="输入延迟",
        title="输入延迟",
        text="用任何设备玩任何游戏时，所有的操作（按键盘，点鼠标等）都会晚一点点（很短，几毫秒到几十毫秒）才到达游戏，如果过长就会很影响游戏手感，作用效果类似于你拿QQ远程控制打FPS游戏\nTOP、TE等游戏比较明显\n这个延迟一般由硬件性能，硬件状态影响，通常来说不可设置，开启性能模式（或者关闭节能模式）可能会好一点。",
    },
    {
        word="秘密段位;secret grade",
        title="秘密段位",
        text="出自TGM系列的彩蛋玩法。不按照TGM的一般目标去玩，而是去拼图拼出 “每行仅有一个洞的大于号” 图形（不能是小于号），拼得越多获得的秘密段位越高（没特殊功能，只是好玩），最高目标是完成19行并封顶\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=Secret_Grade_Techniques",
    },
    {
        word="cold clear",
        title="Cold Clear",
        text="一个AI的名字\n由MinusKelvin开发，原用于PPT。",
    },
    {
        word="zzzbot",
        title="ZZZbot",
        text="一个AI的名字\n由研究群群友zzz（奏之章）开发，重新调参后在各个游戏平台上的表现都很不错。",
    },
    -- # 定式
    {
        word="开局定式",
        title="开局定式",
        text="开局定式，定式一般指开局定式这个概念。\n指开局后可以使用的套路摆法。局中情况合适的时候也可以摆出同样的形状，但是和摆法开局一般都不一样。\n\n能称为定式的摆法要尽量满足以下至少2~3条：\n能适应大多数块序\n输出高，尽量不浪费T块\n很多方块无需软降，极简操作数少\n有明确后续，分支尽量少。\n\n注：绝大多数定式基于bag7，序列规律性强才有发明定式的可能。",
    },
    {
        word="dt炮",
        title="DT炮",
        text="Double-Triple Cannon。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=dt",
    },
    {
        word="dtpc",
        title="DTPC",
        text="DT炮一个能接PC的分支。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=dt",
    },
    {
        word="bt炮",
        title="BT炮",
        text="β炮（Beta炮）。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=bt_cannon",
    },
    {
        word="btpc",
        title="BTPC",
        text="BT炮一个能接PC的分支。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=bt_cannon",
    },
    {
        word="ddpc",
        title="DDPC",
        text="开局TSD的一个能接Double-Double-PC的分支。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=TKI_3_Perfect_Clear",
    },
    {
        word="qt炮",
        title="QT炮",
        text="一种能以更高的概率搭出开局DT Attack的类似DT炮的定式。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=dt",
    },
    {
        word="mt",
        title="MT",
        text="Mini-Triple\n一个TSM+TST的结构。",
        link="https://harddrop.com/wiki?search=mt",
    },
    {
        word="trinity",
        title="Trinity",
        text="Trinity\n一个TSD+TSD+TSD或TSM+TST+TSD的结构。",
        link="https://harddrop.com/wiki?search=trinity",
    },
    {
        word="狼月炮",
        title="狼月炮",
        text="狼月炮。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=wolfmoon_cannon",
    },
    {
        word="sewer",
        title="Sewer",
        text="Sewer开局。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=sewer",
    },
    {
        word="tki",
        title="TKI",
        text="TKI-3开局\n有两种解释，一个是TSD开局的TKI-3，另一个是TST开局的TKI堆积（C-Spin）。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=TKI_3_Opening",
    },
    {
        word="god spin",
        title="God Spin",
        text="God Spin\nwindkey发明的一个观赏性很强但实战没啥用的炫酷特殊T2+T3开局定式。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=godspin",
    },
    {
        word="信天翁",
        title="信天翁",
        text="一种高观赏性几乎不浪费T的快节奏强力T2-T3-T2-PC开局。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=Albatross_Special",
    },
    {
        word="鹈鹕",
        title="鹈鹕",
        text="一种类似信天翁的定式，在块序不能信天翁的时候可以用。",
        link="https://harddrop.com/wiki?search=Pelican",
    },
    {
        word="全清开局",
        title="全清开局",
        text="Perfect Clear Opener，一种极大概率能摆出来，有概率（hold I约84.6%，不hold I约61.2%）能做到PC的定式，Techmino中的pc练习中空出不规则区域的那个就是PCO。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=Perfect_Clear_Opener",
    },
    {
        word="六巧板",
        title="六巧板",
        text="Grace System，大约有88.57%概率能做到PC的定式，Techmino中的PC练习中空出4×4方形区域就是六巧板。",
    },
    {
        word="dpc",
        title="DPC",
        text="在场地空白，7bag还剩一块的情况下，能在很多情况下达到100%搭建率的TSD+PC的定式。更多信息见tetristemplate.info",
        link="https://tetristemplate.info/dpc",
    },
    -- # 形状
    {
        word="中局定式",
        title="中局定式",
        text="指一些特定的能打出较高伤害的常见典型形状，是中局输出的途径之一，部分也可以在开局做不过不是很有必要，主要见于中局\n另见 #开局定式",
    },
    {
        word="c-spin",
        title="C-Spin",
        text="也被称为TKI堆积，TD-Attack。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=c-spin",
    },
    {
        word="stsd",
        title="STSD",
        text="Super T-spin Double\n一种能做两个T2的形状。\n如果垃圾行正好空在STSD正下方会暴毙。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=stsd",
    },
    {
        word="stmb",
        title="STMB",
        text="STMB cave\n在3宽坑架SZ捐一个T2的形状。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=stmb_cave",
    },
    {
        word="双刃剑",
        title="双刃剑",
        text="两个T2形状叠在一起。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=Fractal",
    },
    {
        word="lst堆叠",
        title="LST堆叠",
        text="一种不断b2b一直做T2的堆叠方法。",
        link="https://www.bilibili.com/read/cv7946210",
    },
    {
        word="汉堡包",
        title="汉堡包",
        text="一种边缘捐T不影响消四的堆叠法。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=hamburger",
    },
    {
        word="皇家十字",
        title="皇家十字",
        text="在一个十字形洞口盖屋檐后可以做两个T2的形状。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=imperial_cross",
    },
    {
        word="阶梯捐",
        title="阶梯捐",
        text="一种在看起来像阶梯的洞口捐一个T2的形状。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=kaidan",
    },
    {
        word="社畜train",
        title="社畜train",
        text="一种在常见T3屋檐上捐两个T2的形状。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=Shachiku_Train",
    },
    {
        word="千鸟格子",
        title="千鸟格子",
        text="一种在小洞上捐一个T2后还能做一个T2的形状。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=Cut_copy",
    },
    {
        word="绯红之王",
        title="绯红之王",
        text="在STSD上叠若干个T3的形状。\n更多内容见Hard Drop Wiki。",
        link="https://harddrop.com/wiki?search=King_Crimson",
    },
    {
        word="连续pc",
        title="连续PC",
        text="研究群群友加加编写的一份连续PC教程",
        link="https://docs.qq.com/sheet/DRmxvWmt3SWxwS2tV",
    },
    -- # 英文
    {
        word="tas",
        title="TAS",
        text="Tool-Assisted Speedrun（Supergaming）\n使用特殊工具在仅仅不破坏游戏规则（游戏程序层面的规则）的条件下进行游戏。\n一般用于冲击理论值或者达成各种有趣的目标用来观赏。",
    },
    {
        word="timing",
        title="Timing",
        text="Time作动词时的动名词形式，意为抓时机。在方块中往往指根据双方形势选择打出攻击的时机，和要不要故意吃下对手的攻击防止抵消，然后再把自己的攻击打过去。可以一定程度上提高对战的优势，但对于新人来说连自己场地都看不明白还看啥对面，有时间分析形势不如提速提效来得更好。",
    },
    {
        word="sub",
        title="sub",
        text="在……之下\n用于表示成绩，单位一般可不写，比如40L成绩Sub 30是秒，1000行Sub 15是分钟，不写项目默认是40L\n\n例：39.95s是Sub 40，40.###s不是Sub 40。\n请不要使用Sub 62之类的词，因为sub本身就是表示大约， 一分钟左右的成绩精确到5~10s就可以了，一般30s以内的成绩用sub## 的时候才会精确到1s。",
    },
    {
        word="freestyle",
        title="Freestyle",
        text="自由发挥，常用于freestyle TSD（T2），指不用固定的堆叠方式而是随机应变完成20TSD。比用LST或者垃圾分类完成的20 TSD的难度要大，成绩也更能代表实战水平。",
    },
    -- # 整活
    {
        word="小z;mrz;z酱",
        title="喵？",
    },
}
local function simpStr(s) return s:gsub('%s',''):lower() end

local dict={}
for _,entry in next,data do
    for _,word in next,STRING.split(entry.word,";") do
        word=simpStr(word)
        if dict[word] then
            print("重复关键字："..word)
        else
            dict[word]=entry
        end
    end
end
return dict
