Simple low-performance D-Bus interface for Arduino digital inputs and outputs.

Developed with Arduino Uno (14 pins, 2 reserved for serial IO)

Example (13'th pin is orange LED):

    Start the service for /dev/ttyACM0
    $ ./ardbus.pl

    Set input mode
    $ qdbus org.vi_server.ardbus / org.vi_server.ardbus.PinMode 13 false
    LED is off

    $ qdbus org.vi_server.ardbus / org.vi_server.ardbus.DigitalWrite 13 true
    LED goes dim

    $ qdbus org.vi_server.ardbus / org.vi_server.ardbus.PinMode 13 true
    LED goes bright

    $ qdbus org.vi_server.ardbus / org.vi_server.ardbus.DigitalWrite 13 false
    LED goes off

    $ dbus-monitor
    signal sender=:1.3668 -> dest=(null destination) serial=150997 path=/; interface=org.vi_server.ardbus; member=DigitalInputChanged
       byte 3
       boolean true
    signal sender=:1.3668 -> dest=(null destination) serial=150998 path=/; interface=org.vi_server.ardbus; member=DigitalInputChanged
       byte 2
       boolean false

    $ qdbus org.vi_server.ardbus / org.vi_server.ardbus.AnalogRead 1
    374


Not CPU-efficient, PWM output is not implemented, CPU hog (constantly reading from Arduino). Feel free to improve (send patches/pull requests) or to ask for improvements.

