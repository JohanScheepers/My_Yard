# TTGO T-Beam v1.1 Pinout

This document provides a pinout list for the TTGO T-Beam v1.1. This board is popular for LoRa projects and integrates an ESP32, a LoRa module (SX1276/SX1278), and a GPS module (often NEO-6M or NEO-M8N).

**Note:** It's always a good idea to double-check with the specific documentation or schematic for your board version, as minor variations can sometimes exist.

## Table of Contents
* [General ESP32 Pins](#general-esp32-pins)
* [LoRa Module (SX1276/SX1278) Connections](#lora-module-sx1276sx1278-connections)
* [GPS Module (e.g., NEO-6M, NEO-M8N) Connections](#gps-module-eg-neo-6m-neo-m8n-connections)
* [Power Management Unit (AXP192)](#power-management-unit-axp192)
* [Other Components](#other-components)
* [Wiring Diagram for `tank_control.ino`](#wiring-diagram-for-tank_controlino)
* Important Considerations

## General ESP32 Pins

*   **GPIO0:** Often used for boot mode selection.
*   **GPIO1 (TXD0):** Serial Transmit
*   **GPIO2:** Often connected to an onboard LED.
*   **GPIO3 (RXD0):** Serial Receive
*   **GPIO4:** User definable, sometimes connected to an SD card.
*   **GPIO5:** User definable.
*   **GPIO12:** User definable, sometimes connected to an SD card. (Also often used for GPS TX)
*   **GPIO13:** User definable (Used for `led1Pin` in `tank_control.ino`)
*   **GPIO14:** User definable (Used for `led2Pin` in `tank_control.ino`)
*   **GPIO15:** User definable, sometimes connected to an SD card. (Also often used for GPS RX)
*   **GPIO16 (RX2):** UART2 Receive (Used for OLED_RESET in `tank_control.ino`)
*   **GPIO17 (TX2):** UART2 Transmit
*   **GPIO18:** LoRa SCK (SPI Clock)
*   **GPIO19:** LoRa MISO (SPI Master In Slave Out)
*   **GPIO21:** I2C SDA (for OLED display, AXP192 PMU)
*   **GPIO22:** I2C SCL (for OLED display, AXP192 PMU)
*   **GPIO23:** LoRa MOSI (SPI Master Out Slave In)
*   **GPIO25:** User definable, sometimes OLED_RESET (Used for `airPumpPin` in `tank_control.ino`)
*   **GPIO26:** LoRa NSS (SPI Chip Select)
*   **GPIO27:** User definable.
*   **GPIO32:** User definable.
*   **GPIO33:** User definable (Used for `gpio33Pin` in `tank_control.ino`, set LOW)
*   **GPIO34 (Input Only):** LoRa DIO1 (Interrupt)
*   **GPIO35 (Input Only):** LoRa DIO2 (Interrupt)
*   **GPIO36 (SVP, Input Only):** Battery Voltage ADC (often via a voltage divider)
*   **GPIO37 (Input Only):** User Button (often labeled PRG or USR)
*   **GPIO38 (Input Only):** GPS PPS (Pulse Per Second)
*   **GPIO39 (SVN, Input Only):** LoRa DIO0 (Interrupt)

Back to Top

## LoRa Module (SX1276/SX1278) Connections

*   **NSS:** `GPIO26`
*   **MOSI:** `GPIO23`
*   **MISO:** `GPIO19`
*   **SCK:** `GPIO18`
*   **RESET (NRESET):** Often connected to ESP32's RST pin or a dedicated GPIO (e.g., `GPIO14` on some variants, but on T-Beam v1.1 it's usually handled by the ESP32's reset or tied high).
*   **DIO0:** `GPIO39`
*   **DIO1:** `GPIO34`
*   **DIO2:** `GPIO35`

Back to Top

## GPS Module (e.g., NEO-6M, NEO-M8N) Connections

*   **TXD (GPS Transmit):** Connected to an ESP32 RX pin.
    *   Commonly `GPIO12` (ESP32 RX for a secondary UART).
    *   Alternatively, `GPIO16` (RX2 of `Serial2`) can be used.
*   **RXD (GPS Receive):** Connected to an ESP32 TX pin.
    *   Commonly `GPIO15` (ESP32 TX for a secondary UART).
    *   Alternatively, `GPIO17` (TX2 of `Serial2`) can be used.
*   **PPS (Pulse Per Second):** `GPIO38`

Back to Top

## Power Management Unit (AXP192)

*   The AXP192 is controlled via I2C:
    *   **SDA:** `GPIO21`
    *   **SCL:** `GPIO22`
*   It manages battery charging, power distribution, and can provide battery voltage readings.

Back to Top

## Other Components

*   **User Button:** Typically connected to `GPIO37` (sometimes labeled PRG or USR).
*   **Onboard LED:** Often connected to `GPIO2` or `GPIO4`.
*   **Battery Connector:** For LiPo battery.
*   **USB Port:** For programming and serial communication.
*   **SMA Connector:** For LoRa antenna.
*   **SMA Connector:** For GPS antenna.

Back to Top

## Wiring Diagram for `tank_control.ino`

This section outlines the connections between the TTGO T-Beam v1.1 (ESP32) and the external components as used in the `tank_control.ino` sketch.

**1. OLED Display (SSD1306 I2C):**

| T-Beam ESP32 Pin | OLED Pin      | Function         | Notes from `tank_control.ino` |
|------------------|---------------|------------------|-------------------------------|
| `GPIO21`         | SDA           | I2C Data         | Standard I2C for OLED         |
| `GPIO22`         | SCL           | I2C Clock        | Standard I2C for OLED         |
| `GPIO16`         | RESET (RST)   | OLED Reset       | `OLED_RESET_PIN_U8G2 16`      |
| 3.3V             | VCC / VDD     | Power            | Connect to a 3.3V output      |
| GND              | GND           | Ground           | Connect to a GND pin          |

*   **Note on OLED Reset:** The `tank_control.ino` sketch defines `OLED_RESET_PIN_U8G2` as `16`. If your OLED module does not have a separate RESET pin, or if it's tied to the main board reset, you might connect the OLED's RESET to the T-Beam's RST pin or leave it unconnected (and set `OLED_RESET_PIN_U8G2` to `U8X8_PIN_NONE` or the equivalent for U8g2). **Verify your specific OLED module's requirements.**
*   The I2C address for the SSD1306 is typically `0x3C`.

**2. Output Devices (LEDs and Air Pump via Relays/Drivers):**

These are controlled by digital output pins. **It is assumed these are connected via suitable driver circuits (like relay modules or transistors)**, as ESP32 GPIO pins cannot directly drive high-current loads like pumps or multiple LEDs.

| T-Beam ESP32 Pin | Device Component      | Function in `tank_control.ino` | Connection Notes                                      |
|------------------|---------------------------|--------------------------------|---------------------------------------------------------|
| `GPIO13`         | Relay/Driver for LED 1    | `led1Pin`                      | ESP32 Pin -> Input of Relay/Driver Circuit (for LED 1)    |
| `GPIO14`         | Relay/Driver for LED 2    | `led2Pin`                      | ESP32 Pin -> Input of Relay/Driver Circuit (for LED 2)    |
| `GPIO25`         | Relay/Driver for Air Pump | `airPumpPin`                   | ESP32 Pin -> Input of Relay/Driver Circuit (for Air Pump) |
| 5V / Ext. Power  | Relay/Driver Module   | -                              | Power input for the relay/driver modules              |
| `GPIO33`         | General Purpose Output    | `gpio33Pin`                    | ESP32 Pin -> Set LOW in setup() and remains LOW           |

*   **Relay/Driver Wiring:**
    *   Connect the chosen ESP32 GPIO pin (e.g., `GPIO25`) to the control input of the respective relay module or driver circuit (e.g., the IN pin of a relay module or the base resistor of a transistor).
    *   The actual LED or Air Pump will be wired to the output side of the relay/driver circuit and powered by a suitable voltage source (e.g., 5V or 12V, depending on the device and relay specifications).
    *   Ensure the relay module/driver circuit itself is powered correctly (often 5V for common relay modules, with its own GND connection).
    *   **Do NOT connect high-current devices directly to ESP32 GPIO pins.**

**3. Power Management Unit (AXP192):**
*   The AXP192 is an internal component on the T-Beam, connected to the ESP32 via I2C (`GPIO21` SDA, `GPIO22` SCL). No external wiring is needed for its basic operation with the ESP32. It manages power from the USB port and the battery.

Back to Top

## Important Considerations

1.  **Board Revisions:**
    *   While this pinout is for v1.1, LilyGO (the manufacturer) sometimes makes small revisions.
    *   Always try to find a schematic specific to your exact board if you encounter issues.

2.  **GPS UART Configuration:**
    *   The UART pins used for the GPS can vary.
    *   Common configurations use `Serial2` (`GPIO16` for RX, `GPIO17` for TX) or a software serial implementation on other pins.
    *   Many T-Beam v1.1 boards/schematics use `GPIO12` for GPS TX (to ESP32 RX) and `GPIO15` for GPS RX (to ESP32 TX).
    *   **Action:** You *must* confirm this for your specific board, often by looking at example code provided by the seller or the board's schematic.

3.  **OLED Display (if present):**
    *   If your T-Beam has an OLED display, it will be connected via I2C (`GPIO21` SDA, `GPIO22` SCL).

4.  **SD Card Slot (if present):**
    *   Some T-Beams have an SD card slot. The pins used for this are typically:
        *   `GPIO4`
        *   `GPIO12`
        *   `GPIO13`
        *   `GPIO15`

Back to Top
