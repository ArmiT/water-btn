local module = {}

local access_points = {}

local connect_tries = 0

local index = 0

function getNextAp(list)
    local length = #list

  return function() 
       index = index + 1
       if index > length then 
          index = 1
       end
       return list[index] 
    end
end

function check_connection()

    if wifi.sta.getip() ~= nil then
        connect_tries = 0
        tmr.stop(1)
        ssid, password, bssid_set, bssid=wifi.sta.getconfig()
        
        print("\n===")
        print("ESP8266 mode is: "..wifi.getmode())
        print("MAC address is: "..wifi.ap.getmac())
        print("IP is "..wifi.sta.getip())
        print("Station: "..ssid)
        print("===")

        wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("STATION_IDLE") end)
        wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("STATION_CONNECTING") end)
        wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("STATION_WRONG_PASSWORD") end)
        wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("STATION_NO_AP_FOUND") end)
        wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("STATION_CONNECT_FAIL") end)
        wifi.sta.eventMonReg(wifi.STA_GOTIP, function() print("STATION_GOT_IP") end)

        --register callback: use previous state
        wifi.sta.eventMonReg(wifi.STA_CONNECTING, function(previous_State)
            if(previous_State==wifi.STA_GOTIP) then 
                print("Station lost connection with access point\n\tAttempting to reconnect...")
            else
                print("STATION_CONNECTING")
            end
        end)
        wifi.sta.eventMonStart()
        io.on_click_register(app.on_click)
        io.ledO(gpio.LOW)
        io.ledG(gpio.HIGH)
        app.start()
        
    else

        if connect_tries <= 5 then
            connect_tries = connect_tries + 1
            print("Attempt: "..connect_tries)
            tmr.start(1)        
        else
            tmr.stop(1)
            connect_tries = 0
            ssid = getNextAp(access_points)
            connect_to_ap(ssid)    
        end
        
    end
    
end

function connect_to_ap(ssid_name)
    ap = ssid_name()
    print("Possible AP: "..ap)

    if config.wifi.ssid and config.wifi.ssid[ap] then

        wifi.setmode(wifi.STATION)
        wifi.sta.config(ap, config.wifi.ssid[ap])
        wifi.sta.connect()

        print("Connecting to: "..ap.."...")

        tmr.alarm(1, 2500, tmr.ALARM_SEMI, check_connection)
    else
        print("Don't have an access credentials")
        ssid = getNextAp(access_points)
        connect_to_ap(ssid)
    end    
end

local function wifi_connect(list_aps)

    for key, value in pairs(list_aps) do
        table.insert(access_points, key)
    end

    if access_points then
    
        ssid = getNextAp(access_points)
        connect_to_ap(ssid)
        
    else
        print("Error: No Available AP")
    end    
end

function module.init()
    io.ledO(gpio.HIGH)
    print("Configuring Wifi ...")
    wifi.setmode(wifi.STATION)
    wifi.sta.getap(wifi_connect)
end

function module.start()

    gpio.mode(io.btnPin, gpio.INPUT, gpio.PULLUP)
    tries = 0
    tmr.alarm(6, 200, tmr.ALARM_AUTO, function() 

        if gpio.read(io.btnPin) == gpio.LOW then
            tmr.stop(6)
            print("Debug mode...")
            io.debug_initialize()
            module.init()
        else
            tries = tries + 1
            if tries >= 50 then
                tmr.stop(6)
                print("Normal mode...")
                io.initialize()
                module.init()
            end
        end
    end)
end

function module.getApStatus()

    return wifi.sta.getip()
end

collectgarbage ("collect")

return module
