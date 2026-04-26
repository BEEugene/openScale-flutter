# ARDUINO MCU FIRMWARE

DIY Bluetooth scale adapter — converts non-BLE body scales into openScale-compatible BLE devices.

## OVERVIEW

Single-file Arduino sketch (627 lines) that taps into a scale's 7-segment LCD display, decodes digits, timestamps with RTC, persists to EEPROM, transmits via HM-10 BLE module.

## STRUCTURE

```
arduino_mcu/
├── openScale_MCU/
│   └── openScale_MCU.ino    # Entire firmware (single file)
└── libraries/
    ├── DS3232RTC/            # DS3232/DS3231 Real-Time Clock (I2C addr 0x68)
    ├── I2C_eeprom/           # 24LC256 EEPROM (I2C addr 0x50)
    ├── LowPower/             # ATmega deep sleep modes
    ├── RunningMedian/        # Median filter for noisy segment readings (N=6)
    └── Time/                 # Software timekeeping
```

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Main logic | `openScale_MCU.ino` — everything in one file |
| 7-segment decoding | `decode_seg()` (line ~136) — maps segment patterns to chars |
| Pin assignments | `setup()` — pins 4-11 segment inputs, A0-A3 control, pin 12 UP, pin 3 interrupt |
| Serial protocol | Commands: `'0'` version, `'1'` send data, `'2'` set RTC, `'3'` print time, `'9'` clear EEPROM |
| Data output | `$D$idx,year,month,day,hour,min,weight,fat,water,muscle,checksum` |
| Android handler | `android_app/.../core/bluetooth/scales/CustomOpenScaleHandler.kt` |

## CONVENTIONS

- **Target MCU**: ATmega328P (Arduino Uno/Pro Mini) — direct PORTB/C/D register access
- **BLE module**: HM-10 at 9600 baud via UART, service UUID `0xFFE0`/`0xFFE1`
- **EEPROM**: I2C 24LC256 (address 0x50) for persistent measurement storage
- **RTC**: DS3232/DS3231 (address 0x68) for battery-backed timestamps
- **Checksum**: XOR over all fields for data integrity
- **Sleep**: Deep power-down between measurements via LowPower library, wake on pin 3 interrupt

## ANTI-PATTERNS

- `I2C_eeprom.cpp` has 3 unchecked return values (lines 43, 49, 131) — I2C write failures silently ignored
- `Time.h` uses "ugly hack" for C++ overloaded functions (lines 25, 31) — known Arduino toolchain limitation
- Single 627-line .ino file — no modularization

## NOTES

- Protocol changes require updating BOTH `openScale_MCU.ino` AND `CustomOpenScaleHandler.kt` in sync
- Data format: `ScaleMeasurement(dateTime, weight, fat, water, muscle)` — no bone/LBM/visceral fat
- Capabilities declared to Android: `BODY_COMPOSITION`, `TIME_SYNC`, `HISTORY_READ`, `LIVE_WEIGHT_STREAM`
