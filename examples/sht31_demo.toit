// Copyright (C) 2021 Harsh Chaudhary. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

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