### Smart button

Developed on ESP8266(07).

![pcb](https://raw.githubusercontent.com/Armit/water-btn/master/hardware/output/pcb-design.png)

#### Get started
* Copy `firmware/config.example.lua` to `firmware/config.lua`.
* Add credentials for you wifi access points and mqtt.
* Upload scripts on board using converter from usb to uart/ttl (for ex. cp2102) and ESPLorer.

##### Cable pinout (see image)
1. DTR
2. TX
3. RX
4. VCC
5. nc (not connected)
6. GND

Additional you should connect RST to the JP1
