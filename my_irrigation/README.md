# Readme for my_irrigation_project

## Table of Contents
* [Hardware Components](#hardware-components)
    * [Pump Controller](#pump-controller)
    * [Soil Moisture Sensor System](#soil-moisture-sensor-system)
    * [Weather Station](#weather-station)

## Hardware Components

This project utilizes the following hardware components, broken down by sub-system, for the irrigation system:

### Pump Controller
*   **Microcontroller:** ESP32
*   **Power Source:**
    *   Solar Panel
    *   Solar Charge Controller
    *   Battery
*   **Enclosure:** 3D Printed Case
*   **Control & Sensing:**
    *   Relay (for controlling the pump)
    *   Flow Meter (to measure water usage)
    *    Water Pressure Sensor (to monitor system pressure)
    *   Self Latching Solenoid Valves (for controlling multiple irrigation zones, typically one per zone, controlled via additional relays)
    *   (Optional) Water Level Sensor (e.g., float switch, for tank level monitoring)

[Back to Top](#readme-for-my_irrigation_project)

### Soil Moisture Sensor System
*   **Microcontroller:** ESP32
*   **Power Source:**
    *   Solar Panel
    *   Solar Charge Controller
    *   Battery
*   **Enclosure:** 3D Printed Case
*   **Sensors:**
    *   Soil Moisture Sensor
    *   Temperature Sensor (for soil/ambient temperature)
    *   (Optional) Electrical Conductivity (EC) / Salinity Sensor (for soil nutrient/salt level)
     *   (Optional) Leaf Wetness Sensor (to detect moisture on foliage)

[Back to Top](#readme-for-my_irrigation_project)

### Weather Station
*   **Microcontroller:** ESP32
*   **Power Source:**
    *   Solar Panel
    *   Solar Charge Controller
    *   Battery
*   **Enclosure:** 3D Printed Case
*   **Sensors:**
    *   Temperature Sensor
    *   Humidity Sensor
    *   Anemometer (wind speed)
    *   Wind Vane/Direction Sensor
    *   Lux Meter (light intensity)
    *   Tipping Bucket Rain Gauge
    *   Barometric Pressure Sensor
    *   UV Index Sensor


Further details about the project's software, how these components interact, and the overall functionality will follow.

[Back to Top](#readme-for-my_irrigation_project)