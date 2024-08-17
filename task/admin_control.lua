local codeEnv={
    next=next,print=print,
    math=math,string=string,table=table,
    MATH=MATH,STRING=STRING,TABLE=TABLE,
}
codeEnv.Config=Config
codeEnv.GroupMap=GroupMap
codeEnv.Bot=Bot
codeEnv.Group=Group

---@type Task_raw
return {
    filter='friendMes',
    func=function(M)
        ---@cast M LLOneBot.Event.PrivateMessage

        -- Log
        if Config.debugLog_message then
            print(TABLE.dump(M))
            -- TODO
        end

        if not Bot.isAdmin(M.user_id) then return false end
        local uid,mes=M.user_id,M.raw_message
        if mes=='#stop' then
            Bot.removeAllTask()
            Bot.adminNotice("小z紧急停止了喵！")
            return true
        elseif mes=='#log on' then
            print('Log: on')
            Bot.sendMes{user=uid,message="小z开始日志了喵！"}
            Config.debugLog_message=true
            return true
        elseif mes=='#log off' then
            print('Log: off')
            Bot.sendMes{user=uid,message="小z停止日志了喵！"}
            Config.debugLog_message=false
            return true
        elseif mes=='#stat' then
            local result=STRING.repD(STRING.trimIndent[[
                【统计信息】
                连接次数:$1
                总运行时间:$2
                总发消息数:$3

                本次运行时间:$4
                本次发消息数:$5
            ]],
                Bot.stat.connectAttempts,
                STRING.time(love.timer.getTime()-Bot.stat.launchTime),
                Bot.stat.totalSendCount,
                STRING.time(love.timer.getTime()-Bot.stat.connectTime),
                Bot.stat.sendCount
            )
            Bot.sendMes{user=uid,message=result}
        elseif mes=='#help' then
            local result=STRING.trimIndent[[
                【管理员帮助】
                #help 帮助
                #stop 急停
                #log on 开启日志
                #log off 关闭日志
                #stat 统计
                ![lua代码] 执行代码
            ]]
            Bot.sendMes{user=uid,message=result}
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
            Bot.sendMes{user=uid,message=returnMes}
            return true
        end
        return false
    end,
}
