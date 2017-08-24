local module = {}

local count = 0
module.btnPin = 6

local buzzer = 1

local ledB = 2
local ledG = 9
local ledO = 10

local on_click = nil

local function beep(freq, duration)
    pwm.setup(buzzer, freq, 512)  
    pwm.start(buzzer)  
    tmr.delay(duration * 1000)  
    pwm.stop(buzzer)    
end

function module.ledB(level)
    gpio.write(ledB, level)
end

function module.ledG(level)
    gpio.write(ledG, level)
end

function module.ledO(level)
    gpio.write(ledO, level)
end

function module.endCapture(level) -- todo replace on _

    gpio.trig(io.btnPin, "none")

    tmr.stop(3)
    tmr.stop(2) --!

    tmr.alarm(3, 100, tmr.ALARM_SINGLE, function() 

        if on_click ~= nil then
            on_click(count)
            count = 0
            gpio.trig(io.btnPin, "down", io.startCapture)
        end 
        
    end)
end

function module.startCapture(level) -- todo replace on _
    
    gpio.trig(io.btnPin, "none")
    
    tmr.alarm(3, 100, tmr.ALARM_SINGLE, function() 
        gpio.trig(io.btnPin, "up", io.endCapture)
    
        tmr.alarm(2, 10, tmr.ALARM_AUTO, function() 
            count = count + 1
        end)
    end)
end

function module.debug_initialize()

    -- buzzer
    gpio.mode(buzzer, gpio.OUTPUT)
    
    --leds
    gpio.mode(ledB, gpio.OUTPUT)
    gpio.write(ledB, gpio.LOW)

end

function module.initialize()

    io.debug_initialize()

    gpio.mode(ledG, gpio.OUTPUT)
    gpio.write(ledG, gpio.LOW)

    gpio.mode(ledO, gpio.OUTPUT)
    gpio.write(ledO, gpio.LOW)
    
end

function module.on_click_register(callback)
    -- btn
    gpio.mode(io.btnPin, gpio.INT, gpio.PULLUP)
    gpio.trig(io.btnPin, "down", io.startCapture)
    on_click = callback
end

function module.play(sequence)
    if sequence then
        for _, step in ipairs(sequence) do
            print(step[1], step[2])
            if step[1] and step[2] then
                if step[1] == 1 then
                    io.ledO(gpio.LOW)
                    tmr.delay(step[2] * 1000)
                else
                    io.ledO(gpio.HIGH)
                    beep(step[1], step[2])     
                end
            end 
        end
        io.ledO(gpio.LOW)
    end
end

collectgarbage ("collect")

return module
