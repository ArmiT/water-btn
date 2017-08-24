local module = {}

module.ID = node.chipid()

module.wifi = {}
module.wifi.ssid = {}

-- you can add few wifi access points
module.wifi.ssid["example_ssid"] = "passsword"

module.mqtt = {}

module.mqtt.host = "example.com"

module.mqtt.port = 19082

module.mqtt.keepAlive = 150

module.mqtt.clientId = "WaterBtn"

module.mqtt.username = "username"

module.mqtt.password = "password"

module.mqtt.publ_topic = "/events/"

module.mqtt.lwt_topic = "/event/disconnect/"

module.mqtt.sub_topic = "/commands/"

return module
