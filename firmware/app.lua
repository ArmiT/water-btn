local module = {}

local m = nil

local function send(topic, duration)
    io.ledB(gpio.HIGH)
    msg = "{ \"duration\": "..duration.."}";
    
    m:publish(
        topic,
        msg,
        0, 
        0, 
        function(conn)
            io.ledB(gpio.LOW) 
            print("sent")
            collectgarbage ("collect")
        end
    )    
end

function reconnect_and_send(topic, duration)

    setup.init()
    
    tmr.alarm(4, 60000, tmr.ALARM_SEMI, function() 

        if setup.getApStatus() == nil then
            print("attempt...")
            tmr.start(4)
        else
            mqtt_init(function() 
                send(topic, duration)
            end)
        end
    end)
end

local function on_offline(client)
    print ("offline")
end

local function on_message(client, topic, data)
    print(node.heap())
    collectgarbage("collect")
    io.ledB(gpio.HIGH)
    if data ~= nil then

        msg = cjson.decode(data)
        print(msg)
        if msg.cmd and msg.cmd == "play" then
            io.play(msg.data)
        end
        tmr.wdclr()
    end
    io.ledB(gpio.LOW)
    print(node.heap())
end

local function on_connect()
    print("connected")         
    m:subscribe(config.mqtt.sub_topic,0, function(connection)
        print('subscribed') 
    end)
end

local function on_failed(client, reason)
    print("failed reason: "..reason) 
end

function mqtt_init(on_connect_callback)

    io.ledB(gpio.HIGH)
    
    m = mqtt.Client(
        config.mqtt.clientId,
        config.mqtt.keepAlive,
        config.mqtt.username,
        config.mqtt.password
    )

    m:lwt(
        config.mqtt.lwt_topic,
        0,
        0
    )

    m:on("offline", on_offline)
    m:on("message", on_message)

    m:connect(
        config.mqtt.host, 
        config.mqtt.port, 
        0, -- not secure
        1, -- auto reconnect
        function() 
            
            on_connect()
            io.ledB(gpio.LOW)
            if on_connect_callback ~= nil then
                on_connect_callback()
            end
        end, 
        on_failed
    )
    
end

function module.on_click(duration)
    
    print("pressed: "..duration)
    
    if setup.getApStatus() ~= nil then
        send(config.mqtt.publ_topic, duration)
    else
        reconnect_and_send(config.mqtt.publ_topic, duration)
    end
end

function module.start()
    mqtt_init(nil)
end

collectgarbage ("collect")

return module
