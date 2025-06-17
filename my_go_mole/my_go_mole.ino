// ESP32 Firmware for My Go Mole Project

// Note:
// - Replace "YOUR_WIFI_SSID" and "YOUR_WIFI_PASSWORD" with your actual Wi-Fi credentials.
// - Adjust gmtOffset_sec and daylightOffset_sec according to your timezone.
// - The 400kHz frequency is intended for a transducer capable of operating at this frequency.
//   Standard audible buzzers typically operate at much lower frequencies (e.g., 2-4kHz) and will not work effectively at 400kHz.
//   Ensure the connected hardware is a transducer designed for the 400kHz range.

#include <WiFi.h>
#include "time.h" // For RTC functionality
#include <WebServer.h>
#include <ArduinoJson.h>

// --- Configuration ---
const char *ssid = "YOUR_WIFI_SSID";
const char *password = "YOUR_WIFI_PASSWORD";
const char *esp_hostname = "my-go-mole"; // Define your desired hostname here

// Transducer Configuration
const int transducerPin = 25;       // GPIO pin for the transducer
const int pwmChannel = 0;           // LEDC PWM channel (0-15)
const double pwmFrequency = 400000; // Target frequency in Hz (400 kHz)
const int pwmResolution = 8;        // PWM resolution in bits (1-16). 8-bit gives 0-255 duty cycle range.

// RTC Configuration
const char *ntpServer = "pool.ntp.org";
long gmtOffset_sec = 0;              // Your GMT offset in seconds (e.g., for GMT+1, use 3600) - Can be updated by app
int daylightOffset_sec = 3600; // Daylight saving offset in seconds (e.g., 3600 for 1 hour) - Can be updated by app

// Deterrent Timing
const unsigned long buzzDuration = 1000;     // Transducer ON for 1 second
const unsigned long silenceDuration = 10000; // Silence for 10 seconds
unsigned long lastActivationTime = 0;
bool isBuzzing = false;

// Web Server
WebServer server(80);

// Schedule Configuration
bool scheduleEnabled = false;
int scheduleOnHour = -1;
int scheduleOnMinute = -1;
int scheduleOffHour = -1;
int scheduleOffMinute = -1;

void setup()
{
    Serial.begin(115200);
    while (!Serial)
        ; // Wait for serial monitor to open (optional)

    Serial.println("\nMy Go Mole - ESP32 Firmware");

    // --- Setup Transducer PWM ---
    Serial.printf("Setting up PWM for Transducer: Channel %d, Freq %.0f Hz, Resolution %d bits\n", pwmChannel, pwmFrequency, pwmResolution);
    ledcSetup(pwmChannel, pwmFrequency, pwmResolution);
    ledcAttachPin(transducerPin, pwmChannel);
    ledcWrite(pwmChannel, 0); // Start with transducer off
    Serial.println("PWM setup complete.");

    // --- Connect to Wi-Fi ---
    Serial.print("Connecting to Wi-Fi: ");
    Serial.println(ssid);
    WiFi.setHostname(esp_hostname); // Set the hostname before connecting
    Serial.print("Setting hostname to: ");
    Serial.println(esp_hostname);
    Serial.println(ssid);
    WiFi.begin(ssid, password);
    int wifiConnectAttempts = 0;
    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
        wifiConnectAttempts++;
        if (wifiConnectAttempts > 20)
        { // Timeout after 10 seconds
            Serial.println("\nFailed to connect to Wi-Fi. Please check credentials or network.");
            // You might want to implement a fallback or error state here
            return; // Or ESP.restart();
        }
    }
    Serial.println("\nWi-Fi connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());

    // --- Initialize RTC ---
    Serial.println("Initializing RTC with NTP server...");
    configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
    struct tm timeinfo;
    if (!getLocalTime(&timeinfo))
    {
        Serial.println("Failed to obtain time from NTP server.");
    }
    else
    {
        Serial.println("RTC initialized.");
        printLocalTime();
    }

    // --- Setup Web Server ---
    server.on("/set-schedule", HTTP_POST, handleSetSchedule);
    server.begin();
    Serial.println("HTTP server started");
    Serial.print("Open /set-schedule endpoint with POST request to configure schedule.");

    lastActivationTime = millis(); // Initialize timer for deterrent logic
}

bool isWithinScheduledTime() {
    if (!scheduleEnabled || scheduleOnHour == -1 || scheduleOffHour == -1) {
        return true; // If schedule is not enabled or not fully set, consider it always within time
    }

    struct tm timeinfo;
    if (!getLocalTime(&timeinfo)) {
        Serial.println("Failed to obtain time for schedule check");
        return false; // Or true, depending on desired fallback behavior
    }

    int currentTimeInMinutes = timeinfo.tm_hour * 60 + timeinfo.tm_min;
    int onTimeInMinutes = scheduleOnHour * 60 + scheduleOnMinute;
    int offTimeInMinutes = scheduleOffHour * 60 + scheduleOffMinute;

    if (onTimeInMinutes <= offTimeInMinutes) {
        // Normal schedule (e.g., 08:00 to 20:00)
        return currentTimeInMinutes >= onTimeInMinutes && currentTimeInMinutes < offTimeInMinutes;
    } else {
        // Overnight schedule (e.g., 22:00 to 06:00)
        return currentTimeInMinutes >= onTimeInMinutes || currentTimeInMinutes < offTimeInMinutes;
    }
}

void handleSetSchedule() {
    if (!server.hasArg("plain")) {
        String errorResponse = "{\"responses\":{\"status\":\"error\", \"message\":\"Missing POST body\", \"esp32_ip\":\"" + WiFi.localIP().toString() + "\"}}";
        server.send(400, "application/json", errorResponse);
        return;
    }

    String body = server.arg("plain");
    DynamicJsonDocument doc(256); // Adjust size if necessary
    DeserializationError error = deserializeJson(doc, body);
    
    if (error) {
        Serial.print("deserializeJson() failed: ");
        Serial.println(error.c_str());
        String errorResponse = "{\"responses\":{\"status\":\"error\", \"message\":\"Invalid JSON\", \"esp32_ip\":\"" + WiFi.localIP().toString() + "\"}}";
        server.send(400, "application/json", errorResponse);
        return;
    }
    
    if (!doc.containsKey("control")) {
        String errorResponse = "{\"responses\":{\"status\":\"error\", \"message\":\"Missing 'control' object\", \"esp32_ip\":\"" + WiFi.localIP().toString() + "\"}}";
        server.send(400, "application/json", errorResponse);
        return;
    }

    JsonObject control = doc["control"];

    if (control.containsKey("schedule_enabled")) {
        scheduleEnabled = control["schedule_enabled"];
    } else {
        String errorResponse = "{\"responses\":{\"status\":\"error\", \"message\":\"Missing 'schedule_enabled' field in 'control' object\", \"esp32_ip\":\"" + WiFi.localIP().toString() + "\"}}";
        server.send(400, "application/json", errorResponse);
        return;
    }

    if (scheduleEnabled) {
        if (!control.containsKey("on_time") || !control.containsKey("off_time")) {
            String errorResponse = "{\"responses\":{\"status\":\"error\", \"message\":\"Missing 'on_time' or 'off_time' for enabled schedule\", \"esp32_ip\":\"" + WiFi.localIP().toString() + "\"}}";
            server.send(400, "application/json", errorResponse);
            return;
        }
        const char* on_time_str = control["on_time"];
        const char* off_time_str = control["off_time"];

        if (sscanf(on_time_str, "%d:%d", &scheduleOnHour, &scheduleOnMinute) != 2 ||
            sscanf(off_time_str, "%d:%d", &scheduleOffHour, &scheduleOffMinute) != 2) {
            String errorResponse = "{\"responses\":{\"status\":\"error\", \"message\":\"Invalid time format. Use HH:MM\", \"esp32_ip\":\"" + WiFi.localIP().toString() + "\"}}";
            server.send(400, "application/json", errorResponse);
            scheduleEnabled = false; // Disable schedule if times are invalid
            scheduleOnHour = scheduleOnMinute = scheduleOffHour = scheduleOffMinute = -1; // Reset times
            return;
        }
    } else {
        scheduleOnHour = -1; // Reset times if schedule is disabled
        scheduleOnMinute = -1;
        scheduleOffHour = -1;
        scheduleOffMinute = -1;
        Serial.println("Schedule disabled.");
    }

    bool rtcReconfigured = false;
    if (control.containsKey("gmtOffset_sec")) {
        long newGmtOffset = control["gmtOffset_sec"];
        if (newGmtOffset != gmtOffset_sec) {
            gmtOffset_sec = newGmtOffset;
            Serial.printf("GMT Offset updated by app to: %ld seconds.\n", gmtOffset_sec);
            rtcReconfigured = true;
        }
    }

    if (control.containsKey("daylightOffset_sec")) {
        int newDaylightOffset = control["daylightOffset_sec"];
        if (newDaylightOffset != daylightOffset_sec) {
            daylightOffset_sec = newDaylightOffset;
            Serial.printf("Daylight Offset updated by app to: %d seconds.\n", daylightOffset_sec);
            rtcReconfigured = true;
        }
    }

    if (rtcReconfigured) {
        Serial.println("Re-configuring RTC due to offset change.");
        configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
        // Optionally, print new time to confirm
        struct tm timeinfo;
        if (getLocalTime(&timeinfo, 5000)) { // Wait up to 5s for time
            Serial.print("New current time after offset update: ");
            printLocalTime();
        } else {
            Serial.println("Failed to obtain time immediately after offset update.");
        }
    }

    Serial.printf("Schedule updated: Enabled=%s, On=%02d:%02d, Off=%02d:%02d, GMT Offset=%ld, Daylight Offset=%d\n",
                  scheduleEnabled ? "true" : "false", scheduleOnHour, scheduleOnMinute, scheduleOffHour, scheduleOffMinute, gmtOffset_sec, daylightOffset_sec);

    // Construct success JSON response including ESP32 IP
    String successResponse = "{\"responses\":{\"status\":\"success\", \"message\":\"Schedule updated\", \"esp32_ip\":\"" + WiFi.localIP().toString() + "\"}}";
    server.send(200, "application/json", successResponse);
}

void loop()
{
    server.handleClient(); // Handle HTTP client requests

    unsigned long currentTime = millis();

    if (isWithinScheduledTime()) {
        if (isBuzzing)
        {
            if (currentTime - lastActivationTime >= buzzDuration)
            {
                // Stop transducer
                ledcWrite(pwmChannel, 0); // Duty cycle 0%
                isBuzzing = false;
                lastActivationTime = currentTime; // Reset timer for silence duration for transducer
                Serial.print("Transducer OFF (cycle end) at: ");
                printLocalTime();
            }
        }
        else // Not buzzing, check if it's time to start
        {
            if (currentTime - lastActivationTime >= silenceDuration)
            {
                // Start transducer
                // Set duty cycle to 50%. Max duty is (2^resolution) - 1
                uint32_t dutyCycle = (1 << pwmResolution) / 2;
                ledcWrite(pwmChannel, dutyCycle);
                isBuzzing = true; // Indicate transducer is active
                lastActivationTime = currentTime; // Reset timer for buzz duration
                Serial.print("Transducer ON (cycle start) at: ");
                printLocalTime();
            }
        }
    } else { // Outside scheduled time
        if (isBuzzing) { // If it was buzzing, turn it off
            ledcWrite(pwmChannel, 0);
            isBuzzing = false;
            Serial.print("Transducer OFF (outside schedule) at: ");
            printLocalTime();
            lastActivationTime = currentTime; // Reset timer to prevent immediate re-activation if schedule changes
        }
    }

    // You can add other tasks here, like checking for commands over Wi-Fi, etc.
    delay(10); // Small delay to prevent busy-waiting
}
void printLocalTime()
{
    struct tm timeinfo;
    if (!getLocalTime(&timeinfo))
    {
        Serial.println("Failed to obtain time");
        return;
    }
    Serial.println(&timeinfo, "%A, %B %d %Y %H:%M:%S");
}
