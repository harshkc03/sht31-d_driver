// Copyright (C) 2021 Harsh Chaudhary. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import i2c

I2C_ADDRESS ::= 0x44

/**
Driver for SHT31-D Digital Humidity & Temperature Sensor
*/
class Driver:

  static SHT31_MEAS_HIGHREP_STRETCH ::= 0x2C06
  static SHT31_MEAS_MEDREP_STRETC   ::= 0x2C0D
  static SHT31_MEAS_LOWREP_STRETCH  ::= 0x2C10
  static SHT31_MEAS_HIGHREP         ::= 0x2400
  static SHT31_MEAS_MEDREP          ::= 0x240B
  static SHT31_MEAS_LOWREP          ::= 0x2416

  static SHT31_READSTATUS     ::= 0xF32D
  static SHT31_CLEARSTATUS    ::= 0x3041
  static SHT31_SOFTRESET      ::= 0x30A2
  static SHT31_HEATEREN       ::= 0x306D
  static SHT31_HEATERDIS      ::= 0x3066
  static SHT31_REG_HEATER_BIT ::= 0x0d

  stemp/float := 0.00
  shum/float := 0.00

  device_/i2c.Device

  /**
  Constructs driver and checks whether device has initialized properly
  */
  constructor .device_:
    initialize
  
  initialize:
    reset
    stat := read_status != 0xFFFF
    
    if not stat:
      throw "Device failed to initialize"

  /**
  Get current status of the sensor for the STATUS register
  */
  read_status -> int:
    write_command SHT31_READSTATUS

    data := device_.read 3

    stat := data[0]
    stat << 8
    stat |= data[1]

    return stat

  reset:
    write_command SHT31_SOFTRESET
    sleep --ms=10

  read_temperature -> float:
    if not read_temp_hum:
      throw "CRC_CHECK_FAILED"
    
    return stemp
  
  read_humidity -> float:
    if not read_temp_hum:
      throw "CRC_CHECK_FAILED"
    
    return shum

  /**
  Reads temp and humidity value in high accuracy, single-shot mode
  */
  read_temp_hum -> bool:

    write_command SHT31_MEAS_HIGHREP
    sleep --ms=20

    data := device_.read 6
    
    // Validate readings with checksum
    if data[2] != (crc8_ data[0..2]) or data[5] != (crc8_ data[3..5]):
      return  false
    
    //Raw temperature reading
    raw_stemp := data[0]
    raw_stemp <<= 8
    raw_stemp |= data[1]
    
    //Raw to physical temperature value (°C)
    stemp = raw_stemp*175.0
    stemp = stemp / 65535.0
    stemp = -45.0 + stemp
    
    //Raw humidity reading
    raw_shum := data[3]
    raw_shum <<= 8
    raw_shum |= data[4]
    
    //Raw to physical humidity value (%)
    shum = raw_shum*100.0
    shum = shum / 65535.0

    return true

  static crc8_ data/ByteArray -> int:
    crc := 0xff
    data.do:
      crc ^= it;
      8.repeat:
        if crc & 0x80 != 0:
          crc = ((crc << 1) ^ 0x31) & 0xff
        else:
          crc <<= 1;
          crc &= 0xff
    return crc

  /**
  Break the 16-bit command into 8-bit commands and write into device
  */
  write_command command/int:
    cmd/ByteArray := #[0x00, 0x00]

    cmd[0] = command >> 8
    cmd[1] = command & 0xFF

    device_.write cmd
    