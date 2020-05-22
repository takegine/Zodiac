--[[
timerName=Timer( 2,function() return 1 end)--2秒后每1秒执行1次

timerName=Timer(   funciton() return 1 end)--现在执行1次，之后每1秒执行1次

timerName=Timer( 2,function() testPrint() return 1 end)
意思是 在 满足条件 2S 后，执行 testPrint 函数，并且开始每1S执行一次
]]

--要用的时候直接Timer(2, function()做你的事 return 下一次调用的时间 end ) 就可以了

function Timer(delay,callback)
        if callback == nil then
            --省略了为0的delay参数
                callback = delay
                delay = 0
        end

        local timerName = DoUniqueString("timer")

        GameRules.__vTimerNamerTable__ = GameRules.__vTimerNamerTable__ or {}
        GameRules.__vTimerNamerTable__[timerName] = true

        GameRules:GetGameModeEntity():SetContextThink(timerName,function()
                        if GameRules.__vTimerNamerTable__[timerName] then
                                return callback()
                        else
                                return nil
                        end
        end,delay)
        return timerName
end
function RemoveTimer(timerName)
        GameRules.__vTimerNamerTable__[timerName] = nil
end


