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

*This table need verification* 
|Function	| GPIOs	| Remarks	| Configuration |
| -------| ------| --------| -------------| 
| BUTTON0	| GPIO38	| | low active | 	
| ADC	GPIO0, GPIO2, GPIO4, GPIO13,
GPIO25, GPIO32, GPIO33, GPIO35| | 		ADC Channels| 
| DAC	| GPIO25| 	| 	DAC Channels| 
| PWM_DEV(0)	| GPIO0, GPIO2, GPIO25| 		| PWM Channels| 
| I2C_DEV(0):SDA	| GPIO21	| 	| I2C Interfaces| 
| I2C_DEV(0):SCL| 	GPIO22| 	I2C_SPEED_FAST is used	| I2C Interfaces| 
| SPI_DEV(0):CLK	| GPIO5	| VSPI is used	| SPI Interfaces| 
| SPI_DEV(0):MISO	| GPIO19	| VSPI is used	| SPI Interfaces| 
| SPI_DEV(0):MOSI	| GPIO27	| VSPI is used	| SPI Interfaces| 
| SPI_DEV(0):CS0	| GPIO18	| VSPI is used	| SPI Interfaces| 
| UART_DEV(0):TxD	| GPIO1	| Console (configuration is fixed)	| UART interfaces| 
| UART_DEV(0):RxD	| GPIO3	| Console (configuration is fixed)	| UART interfaces| 
| UART_DEV(1):TxD	| GPIO34	| GPS (configuration is fixed)	| UART interfaces| 
| UART_DEV(1):RxD	| GPIO12	| GPS (configuration is fixed)	| UART interfaces| 

[Back to Top](#table-of-contents)

## LoRa Module (SX1276/SX1278) Connections

| Wire |Pin |
|------|-----|
| MOSI | 27 |
| SCLK | 5 |
| CS | 18 |
| DIO | 26 |
| RST | 14 |
|MISO | 19 |


[Back to Top](#table-of-contents)

## GPS Module (e.g., NEO-6M, NEO-M8N) Connections

| Wire |Pin |
|----|-----|
| TX | 34 |
| RX | 12 |

LED 2 -- GPS working


Back to Top

## Power Management Unit (AXP192)

*   The AXP192 is controlled via I2C:

   | Wire | Pin |
   |------|-----|
   | SDA | 21 |
   | SCL | 22 |

   LED 1 -- Charging Indicator 

*   It manages battery charging, power distribution, and can provide battery voltage readings.

[Back to Top](#table-of-contents)

## Other Components

*   **User Button:** Typically connected to `GPIO37` (sometimes labeled PRG or USR).
*   **Onboard LED:** Often connected to `GPIO2` or `GPIO4`.
*   **Battery Connector:** For LiPo battery.
*   **USB Port:** For programming and serial communication.
*   **SMA Connector:** For LoRa antenna.
*   **SMA Connector:** For GPS antenna.

[Back to Top](#table-of-contents)

## Wiring Diagram for `my_tank_control_basic.ino`

This section outlines the connections between the TTGO T-Beam v1.1 (ESP32) and the external components as used in the `tank_control.ino` sketch.

**1. OLED Display (SSD1306 I2C):**

| T-Beam ESP32 Pin | OLED Pin      | Function         | Notes from `tank_control.ino` |
|------------------|---------------|------------------|-------------------------------|
| `GPIO04`         | SDA           | I2C Data         | Standard I2C for OLED         |
| `GPIO00`         | SCL           | I2C Clock        | Standard I2C for OLED         |
| `GPIO16`         | RESET (RST)   | OLED Reset       | `OLED_RESET_PIN_U8G2 16`      |
| 3.3V             | VCC / VDD     | Power            | Connect to a 3.3V output      |
| GND              | GND           | Ground           | Connect to a GND pin          |

*   **Note on OLED Reset:** The `my_tank_control_basic.ino` sketch defines `OLED_RESET_PIN_U8G2` as `16`. If your OLED module does not have a separate RESET pin, or if it's tied to the main board reset, you might connect the OLED's RESET to the T-Beam's RST pin or leave it unconnected (and set `OLED_RESET_PIN_U8G2` to `U8X8_PIN_NONE` or the equivalent for U8g2). **Verify your specific OLED module's requirements.**
*   The I2C address for the SSD1306 is typically `0x3C`.

**2. Output Devices (LEDs and Air Pump via Relays/Drivers):**

These are controlled by digital output pins. **It is assumed these are connected via suitable driver circuits (like relay modules or transistors)**, as ESP32 GPIO pins cannot directly drive high-current loads like pumps or multiple LEDs.

| T-Beam ESP32 Pin | Device Component               | Function in `tank_control.ino` | Connection Notes                                      |
|------------------|--------------------------------|--------------------------------|---------------------------------------------------------|
| `GPIO13`         | Relay/Driver for LED 1         | `led1Pin`                      | ESP32 Pin -> Input of Relay/Driver Circuit (for LED 1)    |
| `GPIO14`         | Relay/Driver for LED 2         | `led2Pin`                      | ESP32 Pin -> Input of Relay/Driver Circuit (for LED 2)    |
| `GPIO25`         | Relay/Driver for Air Pump      | `airPumpPin`                   | ESP32 Pin -> Input of Relay/Driver Circuit (for Air Pump) |
| 5V / Ext. Power  | Relay/Driver Module            | -                              | Power input for the relay/driver modules              |
| GND | Relay/Driver Module    |        |Ground input for the relay/driver modules | 


*   **Relay/Driver Wiring:**
    *   Connect the chosen ESP32 GPIO pin (e.g., `GPIO25`) to the control input of the respective relay module or driver circuit (e.g., the IN pin of a relay module or the base resistor of a transistor).
    *   The actual LED or Air Pump will be wired to the output side of the relay/driver circuit and powered by a suitable voltage source (e.g., 5V or 12V, depending on the device and relay specifications).
    *   Ensure the relay module/driver circuit itself is powered correctly (often 5V for common relay modules, with its own GND connection).
    *   **Do NOT connect high-current devices directly to ESP32 GPIO pins.**

**3. Power Management Unit (AXP192):**
*   The AXP192 is an internal component on the T-Beam, connected to the ESP32 via I2C (`GPIO21` SDA, `GPIO22` SCL). No external wiring is needed for its basic operation with the ESP32. It manages power from the USB port and the battery.

[Back to Top](#table-of-contents)

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


[Back to Top](#table-of-contents)


```json
{"node":"id"
}
```

```json
{
  "id": "tank_controller-1",
  "ip": "10.0.0.11",
  "nodeType": "my_tank_control_basic"
}
```