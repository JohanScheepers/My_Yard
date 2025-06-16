# Readme for my_go_mole_project

## Table of Contents
* [Hardware Components](#hardware-components)
* [JSON Communication](#json-communication)
    * [App to ESP32 (Control Payload)](#app-to-esp32-control-payload)
    * [ESP32 to App (Response Payload)](#esp32-to-app-response-payload)

## Hardware Components

This project utilizes the following hardware components for the mole deterrence system:

*   **Micro-controller:** ESP32
*   **Power Source:**
    *   Solar Panel
    *   Solar Charge Controller
    *   Battery
*   **Enclosure:** 3D Printed Case
*   **Actuator:** Buzzer (to deter moles)

Further details about the project's software, how these components interact, and the overall functionality will follow.

[Back to Top](#readme-for-my_go_mole_project)

## JSON Communication

### App to ESP32 (Control Payload)

The Flutter application sends control commands to the ESP32 for the "My Go Mole" project using the following JSON structure. This payload allows setting the operational schedule and time zone offset for the mole deterrent.


```json
{
     "control": {
                "schedule_enabled": true,
                "on_time": "08:00",
                "off_time": "20:00",
                "gmtOffset_sec": 7200
             }
}
```

[Back to Top](#readme-for-my_go_mole_project)

### ESP32 to App (Response Payload)

After processing a command from the app, the ESP32 sends a JSON response to confirm the action or indicate an error.

**Example Success Response:**
```json
{
    "responses":{
                "status": "success",
                "message": "Schedule updated",
                "esp32_ip": "192.168.1.123"
                 }
}
```

**Example Error Response:**

* Missing POST Body: This error occurs if the ESP32 receives a POST request to /set-schedule but the request body is empty.
```json
{
    "responses":{
                "status": "error",
                "message": "Missing POST body",
                "esp32_ip": "192.168.1.123"
                    }
}
```

* Invalid JSON: This is sent if the ESP32 cannot parse the request body as valid JSON.

```json
{
    "responses":{
                "status": "error",
                "message": "Invalid JSON",
                "esp32_ip": "192.168.1.123"
                    }
}
```

* Missing 'control' Object: The ESP32 expects the main settings to be nested under a "control" key in the JSON. If this key is missing, this error is returned.

```json
{
    "responses":{
                "status": "error",
                "message": "Missing 'control' object",
                "esp32_ip": "192.168.1.123"
                    }
}
```

* Missing 'schedule_enabled' Field: Within the "control" object, the schedule_enabled field (boolean) is mandatory.

```json
{
    "responses":{
                "status": "error",
                "message": "Missing 'schedule_enabled' field",
                "esp32_ip": "192.168.1.123"
                 }
}
```

* Missing 'on_time' or 'off_time' for Enabled Schedule: If schedule_enabled is true, then both on_time and off_time fields must be present.

```json
{
    "responses":{
                "status": "error",
                "message": "Missing 'on_time' or 'off_time' for enabled schedule",
                "esp32_ip": "192.168.1.123"
                    }
}
```
* Invalid Time Format: The on_time and off_time values must be strings in "HH:MM" format (e.g., "08:00").

```json
{
    "responses":{
                "status": "error",
                "message": "Invalid time format. Use HH:MM",
                "esp32_ip": "192.168.1.123"
                    }
}
```

**Note:** The IP address `"192.168.1.123"` is a placeholder in the README and will be replaced by the actual IP of the ESP32 in the live responses.

[Back to Top](#readme-for-my_go_mole_project)
