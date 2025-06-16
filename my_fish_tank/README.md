# Readme for my_fish_tank_project

## Table of Contents
* [Hardware Components](#hardware-components)
* [JSON Payload](#json-payload)

## Hardware Components

This project utilizes the following hardware components for the fish tank monitoring and control system:

*   **Micro-controller:** ESP32
*   **Power Source:**
    *   Solar Panel
    *   Solar Charge Controller
    *   Battery
*   **Enclosure:** 3D Printed Case
*   **Sensors:**
    *   Temperature Sensor (for water temperature)
    *   Temperature Sensor (for air temperature)
    *   Water Flow Meter
    *   (Optional) pH Sensor
    *   (Optional) Water Level Sensor (e.g., float switch)
    *   (Optional) EC/TDS Sensor
    *   (Optional) Ambient Light Sensor
*   **Actuators/Control:**
    *   PWM Light Control (for dimmable lights, using dedicated PWM driver modules or direct ESP32 PWM output to compatible lights). This includes:
        *   Tank Illumination Lights (for general viewing)
        *   Grow Lights (specifically for plant health)
    *   (Optional) Relay for Water Heater
    *   (Optional) Relay for Auto Feeder
    *   (Optional) Relay for CO2 Solenoid (for planted tanks)
    *   (Optional) Dosing Pumps (may require additional relays or dedicated control)

Further details about the project's software, how these components interact, and the overall functionality will follow.

[Back to Top](#readme-for-my_fish_tank_project)

## JSON Payload 

### JSON Response (App to ESP32)

Control commands for the fish tank accessories are sent from the Flutter application to the ESP32 as a JSON payload. The following code block shows a comprehensive example of this JSON structure, which the ESP32 will parse to actuate the corresponding hardware.

### Combined Control JSON Payload

```json
{
    "control": {
        "lights": {
              "illumination": {
                              "intensity_pwm": 128, // Target brightness (0-255)
                              "on_time": "08:00",   // HH:MM format
                              "off_time": "20:00",  // HH:MM format
                              "ramp_up_duration_minutes": 30,
                               "ramp_down_duration_minutes": 60
                                  },
              "grow_lights": {
                              "intensity_pwm": 200, // Target brightness (0-255)
                              "on_time": "09:00",
                              "off_time": "19:00",
                              "ramp_up_duration_minutes": 15,
                              "ramp_down_duration_minutes": 30
                                  }
                  },
        "relays": {
                  "water_heater": true,
                  "auto_feeder": false,
                  "co2_solenoid": true
                      },
        "heater": {
          "set_temperature_celsius": 25.5
                      },
        "dosing_pumps": [
                          {"id": 1, "action": "dose", "amount_ml": 5},
                          {"id": 2, "action": "stop"} // Example to stop a pump if it runs continuously
                          ]
                },
    }

```

### JSON Response (ESP32 to App)

The ESP32 communicates its current status and sensor readings back to the Flutter application using a JSON structure. The example below illustrates this comprehensive response, detailing the real-time state of all monitored sensors and controlled devices within the fish tank ecosystem.


```json
{
    "status": {
              "sensors": {
                "water_temp_celsius": 25.2,
                "air_temp_celsius": 26.1,
                "water_flow_lpm": 5.3, // Liters per minute
                "ph_value": 7.1,
                "water_level_status": "OK", // e.g., "OK", "LOW", "HIGH"
                "ec_tds_ppm": 350, // Parts per million
                "ambient_light_lux": 150
              },
              "lights_status": {
                "illumination": {
                  "current_intensity_pwm": 128,
                  "is_on": true, // Reflects if currently within on_time and not ramping down to 0
                  "target_on_time": "08:00",
                  "target_off_time": "20:00"
                },
                "grow_lights": {
                  "current_intensity_pwm": 200,
                  "is_on": true,
                  "target_on_time": "09:00",
                  "target_off_time": "19:00"
                }
              },
              "relays_status": {
                "water_heater": true, // true if ON, false if OFF
                "auto_feeder": false,
                "co2_solenoid": true
              },
              "heater_status": {
                "target_temperature_celsius": 25.5,
                "is_active": true // true if currently heating
              },
              "dosing_pumps_status": [
                {
                  "id": 1,
                  "status": "idle", // e.g., "idle", "dosing"
                  "last_dose_amount_ml": 5,
                  "last_dose_timestamp": "2023-10-27T10:00:00Z"
                },
                {
                  "id": 2,
                  "status": "idle"
                }
              ]
            },
    }

```

### Sensor Data Query JSON Payload (App to ESP32)

To retrieve historical data for specific sensors over a defined time range, the Flutter application sends a query request to the ESP32. The JSON structure below exemplifies such a request. It specifies which sensors to query, the start and end timestamps for the data retrieval, and an optional aggregation interval.


```json
{
  "query": {
            "sensors": [
              {"id": "water_temp_celsius", "name": "Water Temperature"},
              {"id": "air_temp_celsius", "name": "Air Temperature"},
              {"id": "water_flow_lpm", "name": "Water Flow"},
              {"id": "ph_value", "name": "pH Level"},
              {"id": "water_level_status", "name": "Water Level"},
              {"id": "ec_tds_ppm", "name": "EC/TDS"},
              {"id": "ambient_light_lux", "name": "Ambient Light"}
            ],
            "time_period": {
              "start_timestamp_utc": "2025-06-14T00:00:00Z", // ISO 8601 format
              "end_timestamp_utc": "2023-06-14T01:00:00Z"   // ISO 8601 format
            },
                }
}
```

### Historical Data Query Response (ESP32 to App)

When the Flutter application requests historical sensor data using the "Sensor Data Query JSON Payload," the ESP32 processes this request and returns the stored data. The following JSON structure is an example of such a response. It includes the data points for the requested sensors within the specified time frame, reflecting the 5-minute storage interval on the ESP32.

```json
{
  "query_response": {
    "data": [                         
              "values": [
                        {"timestamp": "2025-06-14T00:00:00Z", "water_temp_celsius": 25.0, "ec_tds_ppm": 340, "water_level_status": "OK", "water_flow_lpm": 5.0, "air_temp_celsius": 26.5, "ph_value": 6.8,"ambient_light_lux": 10},
                        {"timestamp": "2025-06-14T00:05:00Z", "water_temp_celsius": 25.1, "ec_tds_ppm": 342, "water_level_status": "OK", "water_flow_lpm": 5.1, "air_temp_celsius": 26.6, "ph_value": 6.9,"ambient_light_lux": 10},
                        {"timestamp": "2025-06-14T00:10:00Z", "water_temp_celsius": 25.0, "ec_tds_ppm": 341, "water_level_status": "OK", "water_flow_lpm": 5.0, "air_temp_celsius": 26.5, "ph_value": 6.8,"ambient_light_lux": 11},
                        {"timestamp": "2025-06-14T00:15:00Z", "water_temp_celsius": 25.1, "ec_tds_ppm": 343, "water_level_status": "OK", "water_flow_lpm": 4.9, "air_temp_celsius": 26.6, "ph_value": 6.9,"ambient_light_lux": 10},
                        {"timestamp": "2025-06-14T00:20:00Z", "water_temp_celsius": 25.2, "ec_tds_ppm": 345, "water_level_status": "OK", "water_flow_lpm": 5.0, "air_temp_celsius": 26.7, "ph_value": 7.0,"ambient_light_lux": 11},
                        {"timestamp": "2025-06-14T00:25:00Z", "water_temp_celsius": 25.1, "ec_tds_ppm": 344, "water_level_status": "OK", "water_flow_lpm": 5.1, "air_temp_celsius": 26.6, "ph_value": 6.9,"ambient_light_lux": 12},
                        {"timestamp": "2025-06-14T00:30:00Z", "water_temp_celsius": 25.0, "ec_tds_ppm": 346, "water_level_status": "LOW", "water_flow_lpm": 5.0, "air_temp_celsius": 26.5, "ph_value": 6.8,"ambient_light_lux": 10},
                        {"timestamp": "2025-06-14T00:35:00Z", "water_temp_celsius": 25.1, "ec_tds_ppm": 345, "water_level_status": "LOW", "water_flow_lpm": 4.9, "air_temp_celsius": 26.6, "ph_value": 6.9,"ambient_light_lux": 11},
                        {"timestamp": "2025-06-14T00:40:00Z", "water_temp_celsius": 25.2, "ec_tds_ppm": 347, "water_level_status": "OK", "water_flow_lpm": 5.0, "air_temp_celsius": 26.7, "ph_value": 7.0,"ambient_light_lux": 12},
                        {"timestamp": "2025-06-14T00:45:00Z", "water_temp_celsius": 25.2, "ec_tds_ppm": 348, "water_level_status": "OK", "water_flow_lpm": 5.1, "air_temp_celsius": 26.7, "ph_value": 7.0,"ambient_light_lux": 11},
                        {"timestamp": "2025-06-14T00:50:00Z", "water_temp_celsius": 25.3, "ec_tds_ppm": 350, "water_level_status": "OK", "water_flow_lpm": 5.0, "air_temp_celsius": 26.8, "ph_value": 7.1,"ambient_light_lux": 10},
                        {"timestamp": "2025-06-14T00:55:00Z", "water_temp_celsius": 25.2, "ec_tds_ppm": 349, "water_level_status": "OK", "water_flow_lpm": 4.9, "air_temp_celsius": 26.7, "ph_value": 7.0,"ambient_light_lux": 12},
                        {"timestamp": "2025-06-14T01:00:00Z", "water_temp_celsius": 25.3, "ec_tds_ppm": 351, "water_level_status": "OK", "water_flow_lpm": 5.0, "air_temp_celsius": 26.8, "ph_value": 7.1,"ambient_light_lux": 10}
                          ]
            ],
                },
    
}
```
