local codeEnv={
    next=next,
    print=print,
    math=math,
    string=string,
    table=table,
    MATH=MATH,
    STRING=STRING,
    TABLE=TABLE,
}
codeEnv.Config=Config
codeEnv.SessionMap=SessionMap

codeEnv.Bot=Bot
codeEnv.Session=Session

---@type Task_raw
return {
    func=function(S,M)
        if not (M.message_type=='private' and Bot.isAdmin(M.user_id) and M.sub_type=='friend') then return false end

        ---@cast M LLOneBot.Event.PrivateMessage

        local mes=M.raw_message
        if mes=='#stop' then
            print('[STOP]')
            S:send("小z紧急停止了喵！")
            Bot.restart()
            return true
        elseif mes=='#disconnect' then
            print('[DISCONNECT]')
            S:send("小z断开了连接了喵！")
            Bot.disconnect()
            return true
        elseif mes=='#log on' then
            print('Log: on')
            S:send("小z开始日志了喵！")
            Config.debugLog_message=true
            return true
        elseif mes=='#log off' then
            print('Log: off')
            S:send("小z停止日志了喵！")
            Config.debugLog_message=false
            return true
        elseif mes=='#stat' then
            local result=STRING.repD(STRING.trimIndent[[
                【统计信息】
                本次运行时间:$1
                本次发消息数:$2

                连接次数:$3
                总运行时间:$4
                总发消息数:$5
            ]],
                STRING.time(love.timer.getTime()-Bot.stat.connectTime),
                Bot.stat.messageSent,
                Bot.stat.connectAttempts,
                STRING.time(love.timer.getTime()-Bot.stat.launchTime),
                Bot.stat.totalMessageSent
            )
            S:send(result)
        elseif mes=='#help' then
            local result=STRING.trimIndent([[
                【管理员帮助】
                #help 帮助
                #stop 急停
                #log on 开启日志
                #log off 关闭日志
                #stat 统计
                ![lua代码] 执行代码
                    Config
                    SessionMap
                    Bot
                    Session
            ]],true)
            S:send(result)
        elseif mes:sub(1,1)=='!' then
            local func,err=loadstring(mes:sub(2))
            local returnMes
            if func then
                setfenv(func,codeEnv)
                local suc,res=pcall(func)
                if suc then
                    returnMes="Done"..(res~=nil and "\n"..tostring(res) or "")
                else
                    returnMes="Runtime Error:\n"..tostring(res)
                end
            elseif err then
                returnMes="Compile Error:\n"..tostring(err)
            end
            S:send(returnMes)
            return true
        end
        return false
    end,
}
