# SHT31-D
Toit driver for the [Adafruit's SHT31-D](https://www.adafruit.com/product/2857) Digital Temperature and Humidity Sensor

## Installation

1. `toit pkg sync`

2. `toit pkg install github.com/harshkc03/sht31-d_driver`

## Usage

```
import i2c
import gpio
import sht31_d_driver.sht31

main:
    bus := i2c.Bus
      --sda=gpio.Pin 21
      --scl=gpio.Pin 22

    device := bus.device sht31.I2C_ADDRESS

    driver := sht31.Driver device

    print "$driver.read_temperature C"
    print "$driver.read_humidity %"
```
