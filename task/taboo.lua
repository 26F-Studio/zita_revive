local banWords=STRING.split(Config.extraData.banWords or "^废物 弱智","%s+",true)
local banWords_weak=Config.extraData.banWords_weak or {["比"]="逼"}
LOG('info',"Taboo: "..#banWords.."/"..TABLE.count(banWords_weak).." bad/weak words loaded")

local rec=FILE.load('taboo_track.luaon','luaon') or {}
local function save() FILE.save(rec,'taboo_track.luaon','-luaon') end
local function delaySave()
    TASK.yieldT(620)
    save()
end

setmetatable(rec,{
    __index=function(t,k)
        t[k]={
            id=k,
            lastTime=0,
            history={},
        }
        return t[k]
    end,
})

---@type Task_raw
return {
    message=function(S,M)
        local mes=M.raw_message
        if rawget(rec,M.user_id) and #rec[M.user_id].history>2.6 then
            for k,v in next,banWords_weak do
                mes=mes:gsub(k,v)
            end
        end
        local needSave
        for j=1,#banWords do
            if mes:find(banWords[j]) then
                local date=os.date("%Y-%m-%d %H:%M:%S")
                local user=rec[M.user_id]
                if Bot.isManaging(S.id) then
                    S:delayDelete(MATH.rand(6,12),M.message_id)
                    Bot.ban(S.id,M.user_id,MATH.clampInterpolate(
                        2600,26*(#user.history)^2,
                        2.6*86400,0,
                        os.time()-user.lastTime
                    ))
                    LOG('warn',date.." "..S.id.." Del: "..M.user_id.."-"..M.raw_message)
                    Bot.reactMessage(M.message_id,Emoji.bomb)
                else
                    LOG('warn',date.." "..S.id.." Match: "..M.user_id.."-"..M.raw_message)
                    Bot.reactMessage(M.message_id,Emoji.red_exclamation_mark)
                end
                user.lastTime=os.time()
                table.insert(user.history,{
                    date=date,
                    mes=M.raw_message,
                })
                needSave=true
                break
            end
        end
        if needSave then
            if TASK.lock('taboo_saveCD',260) then
                save()
            else
                TASK.removeTask_code(delaySave)
                TASK.new(delaySave)
            end
        end
        return false
    end,
}
