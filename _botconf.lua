---配置好以下内容后把文件名的下划线删掉才会被读取（botconf.lua）
---@class Config
local conf={
    host='localhost',
    port='3001',
    connectInterval=2.6,
    reconnectInterval=600,

    superAdminID={ -- 超管qq号（最高权限，能利用root任务能执行启停命令和执行任意代码）
        0000000000,
    },
    groupManaging={ -- bot是管理员的群号（没做自动检测）
        000000000,
    },
    privTask={ -- 在私聊中默认启用的任务列表，格式为{任务名, 权重}，权重是任意不重复数字，按从小到大的顺序触发（可以乱序，bot会按照权重重排）
        {'root',      -100},
        {'tool',      1},
        {'zictionary',2},
    },
    groupTask={ -- 在群聊中默认启用的任务列表
        {'root',      -100},
        {'tool',      2},
        {'guess',     3},
        {'zictionary',4},
        {'bilishare', 99},
    },
    extraTask={ -- 要启用的额外任务的会话列表
        g000000000={
            {'brikduel',2.6},
        },
    },
    extraData={ -- 任意额外数据，任务有需要配置的参数时可以从这里存取
    },

    botID=0000000000, -- bot的qq号
    adminName="管理员", -- 对超管的称呼
    maxCharge=620, -- 默认的群能量点数，部分任务会用到这个数值约束使用频率

    -- 沙箱路径，末尾需要斜杠，目前只有“把画布保存为可发送图片”的功能需要
    sandboxRealPath="/home/z/App/napcat/sandbox/", -- 可用的图片文件保存路径
    sandboxPath="http://localhost:3002/sandbox/", -- bot框架能访问到图片的网络路径

    -- debug开关，推荐只用root任务手动修改，设为true后收到消息会在控制台打日志
    debugLog_send=false,
    debugLog_message=false,
    debugLog_notice=false,
    debugLog_request=false,
    debugLog_response=false,
}

return conf
