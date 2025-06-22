// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

// my_tank_control_basic.ino
// Need to integrate remote control for my_tank_control_basic where you set from the app time on and off

#include <WiFi.h>
#include "time.h" // For time functions

#include <WebServer.h> // For the HTTP Server
#include <ArduinoJson.h> // For JSON parsing and generation
#include <axp20x.h>   // For AXP192 Power Management
#include <U8g2lib.h>  // U8g2 graphics library

// --- Configuration ---

// WiFi credentials
const char *ssid = "######";
const char *password = "#######**"; // Consider security implications for shared code

// --- Network Configuration ---

// Node ID for identification in JSON responses
const char *id = "tank_controller-2"; // Corrected from 'char' to 'const char*'
const char *nodeType = "my_tank_control_basic";

// Web server will run on port 80
WebServer server(80);

// NTP Configuration
const char *ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 2 * 3600; // GMT+2 offset in seconds
const int daylightOffset_sec = 0;    // No daylight saving offset for simplicity.

// Output Pins (Please verify these are free on your TTGO T-Beam v1.1)
// Refer to your board's pinout diagram.
const int led1Pin = 13;    // Changed to GPIO13
const int led2Pin = 14;    // Changed to GPIO14
const int airPumpPin = 25; // Changed to GPIO25

// OLED Display Configuration
#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

// TTGO T-Beam v1.1 typically uses: SDA = GPIO21, SCL = GPIO22
// IMPORTANT: OLED_RESET PIN:
// Your pinout.md notes GPIO25 is sometimes used for OLED_RESET.
// Since airPumpPin is now assigned to GPIO25, ensure your OLED_RESET is NOT on GPIO25.
// This sketch defaults to using GPIO16 for OLED_RESET.
// Common alternatives for OLED_RESET are GPIO4, GPIO16, or U8X8_PIN_NONE (-1) if not used/tied to main reset.
// PLEASE VERIFY AND ADJUST OLED_RESET FOR YOUR SPECIFIC BOARD.
#define OLED_RESET_PIN_U8G2 16 // Defaulting to 16. Change to U8X8_PIN_NONE if not used, or actual pin.

// U8g2 Constructor List: https://github.com/olikraus/u8g2/wiki/u8g2setupcpp
// For SSD1306 128x64 I2C display:
// U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, /* reset=*/ OLED_RESET_PIN_U8G2, /* clock=*/ SCL, /* data=*/ SDA);
// For TTGO T-Beam v1.1, SCL is GPIO22, SDA is GPIO21
U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, /* reset=*/OLED_RESET_PIN_U8G2, /* clock=*/22, /* data=*/21);

AXP20X_Class PMU; // Instance of the AXP192 library

// --- Schedules ---
// LED 1: On 06h00 - Off 20h00
const int led1OnHour = 6;
const int led1OnMin = 0;
const int led1OffHour = 20;
const int led1OffMin = 0;

// LED 2: On 06h30 - Off 20h30
const int led2OnHour = 6;
const int led2OnMin = 30;
const int led2OffHour = 20;
const int led2OffMin = 30;

// Air Pump: On 06h00 - Off 20h30
const int airPumpOnHour = 6;
const int airPumpOnMin = 0;
const int airPumpOffHour = 20;
const int airPumpOffMin = 30;

// --- Global Variables ---
struct tm timeinfo; // Structure to hold time information
bool led1Status = false;
bool led2Status = false;
bool airPumpStatus = false;


// OLED Display State Management
enum DisplayState
{
    WIFI_INFO,
    TANK_STATUS,
    COPYRIGHT_INFO
};
DisplayState currentDisplayState = WIFI_INFO;
unsigned long lastDisplayChangeTime = 0;
const unsigned long wifiInfoDisplayDuration = 5000;      // 5 seconds
const unsigned long tankStatusDisplayDuration = 10000;   // 10 seconds
const unsigned long copyrightInfoDisplayDuration = 3000; // 3 seconds for copyright

// Copyright strings
const char *copyrightLine1a = "Copyright (c) [2025]";
const char *copyrightLine1b = "Johan Scheepers";
const char *copyrightLine2a = "GitHub:";
const char *copyrightLine2b = "https://github.com/";
const char *copyrightLine2c = "JohanScheepers/My_Yard";

/**
 * @brief Handles HTTP requests to the root URL and provides status.
 */
void handleRoot()
{
    Serial.println("Received HTTP GET request for status.");

    // Create the response JSON
    JsonDocument responseDoc;
    responseDoc["id"] = id;
    responseDoc["ip"] = WiFi.localIP().toString();
    responseDoc["nodeType"] = nodeType;
    responseDoc["led1Status"] = led1Status;
    responseDoc["led2Status"] = led2Status;
    responseDoc["airPumpStatus"] = airPumpStatus;

    // Add time info if available
    if (getLocalTime(&timeinfo, 50))
    {
        char timeBuffer[20];
        sprintf(timeBuffer, "%02d:%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
        responseDoc["currentTime"] = timeBuffer;
    }
    else
    {
        responseDoc["currentTime"] = "N/A";
    }

    // Serialize the response to a string
    String responseJson;
    serializeJson(responseDoc, responseJson);

    // Send the response
    server.send(200, "application/json", responseJson);
}

void handleNotFound()
{
    server.send(404, "text/plain", "404: Not found");
}

/**
 * @brief Initializes the OLED display.
 */
void setupOLED()
{
    u8g2.begin();
    u8g2.enableUTF8Print(); // Enable UTF8 support for special characters if needed
    Serial.println(F("U8g2 OLED Initialized"));

    u8g2.clearBuffer();                     // clear the internal memory
    u8g2.setFont(u8g2_font_ncenB08_tr);     // choose a suitable font
    u8g2.drawStr(0, 10, "Initializing..."); // write string to the buffer
    u8g2.drawStr(0, 20, copyrightLine1a);   // write string to the buffer
    u8g2.drawStr(0, 30, copyrightLine1b);   // write string to the buffer
    u8g2.sendBuffer();                      // transfer internal memory to the display
    delay(1000);
}

/**
 * @brief Initializes the AXP192 Power Management Unit.
 */
void setupPMU()
{
    // It's good practice to initialize Wire for I2C before PMU or OLED if they share the bus
    // Wire.begin(SDA_PIN, SCL_PIN) // If not using default ESP32 I2C pins (21, 22)
    // However, PMU.begin() and u8g2.begin() usually handle Wire initialization if not done.

    // AXP192 I2C address is 0x34
    if (PMU.begin(Wire, AXP192_SLAVE_ADDRESS) == AXP_FAIL)
    {
        Serial.println("Error initializing AXP192 PMU");
    }
    else
    {
        Serial.println("AXP192 PMU Initialized");
        // You can configure power settings here if needed. For example:
        // PMU.disablePowerOutput(AXP192_LDO2); // Example: Disable LDO2 (check T-Beam schematic first!)
    }
}

/**
 * @brief Updates the OLED display with current status.
 */
void updateOLED()
{
    u8g2.clearBuffer();

    int yPos = 0;    // Current Y position for drawing, starts at top
    char buffer[32]; // Buffer for formatting strings (increased for longer strings like TX/RX counts)

    // Always display Time and Date at the top
    u8g2.setFont(u8g2_font_profont11_tf); // Slightly smaller for time/date
    const int dateTimeLineHeight = 10;
    int currentTimeY = dateTimeLineHeight; // Y position for the time string

    if (getLocalTime(&timeinfo, 50))
    { // 50ms timeout
        // Date: DD/MM/YY
        sprintf(buffer, "%02d/%02d/%02d", timeinfo.tm_mday, timeinfo.tm_mon + 1, (timeinfo.tm_year + 1900) % 100);
        u8g2.drawStr(SCREEN_WIDTH - u8g2.getStrWidth(buffer) - 2, currentTimeY, buffer); // Align date to the right

        // Time: HH:MM:SS
        sprintf(buffer, "%02d:%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
        u8g2.drawStr(0, currentTimeY, buffer); // Align time to the left
    }
    else
    {
        u8g2.drawStr(0, currentTimeY, "Time: Syncing...");
    }
    // Move yPos below the date/time line, with a small gap
    yPos = currentTimeY + 2 + dateTimeLineHeight;

    // --- Content based on currentDisplayState ---
    // Font will be set within each state

    if (currentDisplayState == WIFI_INFO)
    {
        u8g2.setFont(u8g2_font_helvR08_tr); // Smaller font for WiFi details to fit more lines
        const int wifiDetailFontHeight = 8; // Font height for helvR08_tr
        const int wifiLineSpacing = 2;      // Extra space between lines
        char tempStr[40];                   // Local buffer for formatting WiFi info strings

        // Line 1: WiFi Status
        sprintf(tempStr, "WiFi: %s", (WiFi.status() == WL_CONNECTED) ? "Online" : "Offline");
        u8g2.drawStr(0, yPos, tempStr);
        yPos += wifiDetailFontHeight + wifiLineSpacing;

        if (WiFi.status() == WL_CONNECTED)
        {
            // Line 2: IP Address
            sprintf(tempStr, "IP: %s", WiFi.localIP().toString().c_str());
            u8g2.drawStr(0, yPos, tempStr);
            yPos += wifiDetailFontHeight + wifiLineSpacing;

            // Line 3: RSSI
            sprintf(tempStr, "RSSI: %ld dBm", WiFi.RSSI()); // WiFi.RSSI() returns int32_t
            u8g2.drawStr(0, yPos, tempStr);
            yPos += wifiDetailFontHeight + wifiLineSpacing;

            // Line 4: Node ID
            snprintf(tempStr, sizeof(tempStr), "ID: %s", id);
            u8g2.drawStr(0, yPos, tempStr);
            yPos += wifiDetailFontHeight + wifiLineSpacing;

            // Line 5: Node Type
            snprintf(tempStr, sizeof(tempStr), "Type: %s", nodeType);
            u8g2.drawStr(0, yPos, tempStr);
            
        }
        else
        {
            // Line 2: IP Address (placeholder)
            u8g2.drawStr(0, yPos, "IP: ---.---.---.---");
            yPos += wifiDetailFontHeight + wifiLineSpacing;

            // Line 3: RSSI (placeholder)
            u8g2.drawStr(0, yPos, "RSSI: --- dBm");
            yPos += wifiDetailFontHeight + wifiLineSpacing;

            // Line 4: Node ID (placeholder)
            u8g2.drawStr(0, yPos, "ID: ---");
            yPos += wifiDetailFontHeight + wifiLineSpacing;

            // Line 5: Node Type (placeholder)
            u8g2.drawStr(0, yPos, "Type: ---");
        }
    }
    else if (currentDisplayState == TANK_STATUS)
    {
        // Output Statuses
        u8g2.setFont(u8g2_font_profont11_tf); // Slightly smaller for status lines
        const int statusLineHeight = 10;
        // yPos += 2; // Optional: Add a bit more space before tank status if needed

        // Using drawStr for direct x,y positioning of each status line
        char statusBuffer[30];
        sprintf(statusBuffer, "LED 1:    %s", led1Status ? "ON " : "OFF");
        u8g2.drawStr(0, yPos, statusBuffer);
        yPos += statusLineHeight;

        sprintf(statusBuffer, "LED 2:    %s", led2Status ? "ON " : "OFF");
        u8g2.drawStr(0, yPos, statusBuffer);
        yPos += statusLineHeight;

        sprintf(statusBuffer, "Air Pump: %s", airPumpStatus ? "ON " : "OFF");
        u8g2.drawStr(0, yPos, statusBuffer);
    }
    else if (currentDisplayState == COPYRIGHT_INFO)
    {
        u8g2.setFont(u8g2_font_helvR08_tr); // Use a smaller font for copyright lines
        const int copyrightLineHeight = 8;  // Approximate height for helvR08
        // yPos is already set after the time/date display.

        u8g2.drawStr(0, yPos, copyrightLine1a);
        yPos += copyrightLineHeight + 1; // Add 1 for a little extra spacing
        u8g2.drawStr(0, yPos, copyrightLine1b);
        yPos += copyrightLineHeight + 2; // Add 2 for a bit more spacing before GitHub info

        u8g2.drawStr(0, yPos, copyrightLine2a);
        yPos += copyrightLineHeight + 1;
        u8g2.drawStr(0, yPos, copyrightLine2b);
        yPos += copyrightLineHeight + 1;
        u8g2.drawStr(0, yPos, copyrightLine2c);
    }

    u8g2.sendBuffer();
}

/**
 * @brief Prints the current local time to the Serial monitor.
 */
void printLocalTime()
{
    if (!getLocalTime(&timeinfo))
    {
        Serial.println("Failed to obtain time");
        return;
    }
    Serial.println(&timeinfo, "Current Time (GMT+2): %A, %B %d %Y %H:%M:%S");
}

/**
 * @brief Connects to WiFi with a timeout.
 */
void setupWiFi()
{
    Serial.print("Connecting to WiFi: ");
    WiFi.setHostname("MyYardTankControl"); // Set a custom hostname
    Serial.println(ssid);
    WiFi.begin(ssid, password);

    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 20)
    { // Try for ~10 seconds
        delay(500);
        Serial.print(".");
        attempts++;
    }

    if (WiFi.status() == WL_CONNECTED)
    {
        Serial.println("\nWiFi connected successfully!");
        Serial.print("IP Address: ");
        Serial.println(WiFi.localIP());

        updateOLED(); // Update OLED immediately with connection status and IP
    }
    else
    {
        Serial.println("\nFailed to connect to WiFi. Please check credentials/network.");
        Serial.println("System will run without time synchronization if WiFi fails.");
    }
}

/**
 * @brief Configures system time using NTP if WiFi is connected.
 */
void setupTime()
{
    if (WiFi.status() == WL_CONNECTED)
    {
        Serial.println("Configuring time from NTP server...");
        configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);

        int attempts = 0;
        // Wait up to 10s for initial sync, check if year is valid
        while (timeinfo.tm_year < (2016 - 1900) && attempts < 10)
        {
            if (!getLocalTime(&timeinfo, 1000))
            { // Try to get time with 1s timeout
                Serial.println("getLocalTime failed during NTP sync attempt.");
            }
            if (timeinfo.tm_year < (2016 - 1900))
            { // tm_year is years since 1900
                Serial.println("Waiting for NTP time sync...");
            }
            else
            {
                break; // Time is valid
            }
            delay(1000);
            attempts++;
        }

        if (timeinfo.tm_year > (2016 - 1900))
        {
            printLocalTime(); // Print initial synchronized time
        }
        else
        {
            Serial.println("Failed to synchronize time with NTP after multiple attempts.");
        }
    }
    else
    {
        Serial.println("WiFi not connected. Cannot configure time from NTP.");
    }
}

/**
 * @brief Sets up the HTTP server routes.
 */
void setupHttpServer()
{
    if (WiFi.status() == WL_CONNECTED)
    {
        server.on("/", HTTP_GET, handleRoot); // Define route for status requests
        server.onNotFound(handleNotFound);
        server.begin();
        Serial.println("HTTP server started.");
    }
}

void setup()
{
    Serial.begin(115200);
    while (!Serial)
        ;
    Serial.println("\n--- Aquarium Tank Control System Initializing ---");

    setupOLED(); // Initialize OLED early for boot messages

    setupPMU(); // Initialize the PMU

    // Initialize output pins
    pinMode(led1Pin, OUTPUT);
    pinMode(led2Pin, OUTPUT);
    pinMode(airPumpPin, OUTPUT);

    // Ensure scheduled outputs are OFF initially (standard logic: LOW means OFF)
    digitalWrite(led1Pin, HIGH);
    digitalWrite(led2Pin, HIGH);
    digitalWrite(airPumpPin, HIGH);

    led1Status = false;
    led2Status = false;
    airPumpStatus = false;

    setupWiFi();
    setupTime();

    setupHttpServer();
    updateOLED(); // Initial OLED update after setup
    Serial.println("Setup complete. Starting main loop...");
}

/**
 * @brief Checks if the current time is within a given ON/OFF schedule.
 * Handles overnight schedules correctly.
 */
bool isTimeWithinSchedule(int currentHour, int currentMin, int onHour, int onMin, int offHour, int offMin)
{
    long currentTimeInMinutes = currentHour * 60 + currentMin;
    long onTimeInMinutes = onHour * 60 + onMin;
    long offTimeInMinutes = offHour * 60 + offMin;

    if (onTimeInMinutes <= offTimeInMinutes)
    {
        // Normal schedule (e.g., ON 06:00, OFF 20:00)
        return (currentTimeInMinutes >= onTimeInMinutes && currentTimeInMinutes < offTimeInMinutes);
    }
    else
    {
        // Overnight schedule (e.g., ON 22:00, OFF 05:00)
        // True if current time is after ON time OR before OFF time
        return (currentTimeInMinutes >= onTimeInMinutes || currentTimeInMinutes < offTimeInMinutes);
    }
}

/**
 * @brief Controls the outputs based on the current time and defined schedules.
 */
void controlOutputs()
{
    if (WiFi.status() != WL_CONNECTED || !getLocalTime(&timeinfo, 50) || timeinfo.tm_year < (2016 - 1900))
    {
        // If time is not synced, or WiFi lost, print a message.
        // Outputs will hold their last known correct state or the initial OFF state.
        // Consider if you want to force them OFF here if time sync is critical.
        // For now, we only print a message if time is not available.
        if (timeinfo.tm_year < (2016 - 1900))
        {
            Serial.println("Time not synchronized. Cannot reliably control outputs based on schedule.");
        }
        return;
    }

    int currentHour = timeinfo.tm_hour;
    int currentMin = timeinfo.tm_min;

    // LED 1 Control
    led1Status = isTimeWithinSchedule(currentHour, currentMin, led1OnHour, led1OnMin, led1OffHour, led1OffMin);
    digitalWrite(led1Pin, led1Status ? LOW : HIGH); // Standard: HIGH for ON, LOW for OFF

    // LED 2 Control
    led2Status = isTimeWithinSchedule(currentHour, currentMin, led2OnHour, led2OnMin, led2OffHour, led2OffMin);
    digitalWrite(led2Pin, led2Status ? LOW : HIGH); // Standard: HIGH for ON, LOW for OFF

    // Air Pump Control
    airPumpStatus = isTimeWithinSchedule(currentHour, currentMin, airPumpOnHour, airPumpOnMin, airPumpOffHour, airPumpOffMin);
    digitalWrite(airPumpPin, airPumpStatus ? LOW : HIGH); // Standard: HIGH for ON, LOW for OFF
}

unsigned long lastOledUpdateTime = 0;
const unsigned long oledUpdateInterval = 2000; // Update OLED every 2 seconds

void loop()
{
    // Attempt to reconnect WiFi if disconnected
    if (WiFi.status() != WL_CONNECTED)
    {
        Serial.println("WiFi connection lost. Attempting to reconnect...");
        // Non-blocking attempt or limited blocking:
        WiFi.begin(ssid, password);
        int reconnAttempts = 0;
        while (WiFi.status() != WL_CONNECTED && reconnAttempts < 5) // Try for ~2.5 seconds
        {
            delay(500);
            Serial.print(".");
            reconnAttempts++;
        }
        if (WiFi.status() == WL_CONNECTED)
        {
            Serial.println("\nWiFi Reconnected!");
            setupTime(); // Re-synchronize time after reconnection
            server.begin(); // Restart the server
        }
        else
        {
            Serial.println("\nWiFi Reconnection failed.");
        }
    }
    else
    {
        server.handleClient(); // Handle incoming HTTP requests
    }

    controlOutputs();

    unsigned long currentTime = millis();

    // OLED Display State Switching Logic
    if (currentDisplayState == WIFI_INFO && (currentTime - lastDisplayChangeTime >= wifiInfoDisplayDuration))
    {
        currentDisplayState = TANK_STATUS;
        lastDisplayChangeTime = currentTime;
    }
    else if (currentDisplayState == TANK_STATUS && (currentTime - lastDisplayChangeTime >= tankStatusDisplayDuration))
    {
        currentDisplayState = COPYRIGHT_INFO;
        lastDisplayChangeTime = currentTime;
    }
    else if (currentDisplayState == COPYRIGHT_INFO && (currentTime - lastDisplayChangeTime >= copyrightInfoDisplayDuration))
    {
        currentDisplayState = WIFI_INFO;
        lastDisplayChangeTime = currentTime;
    }

    // Regular OLED update
    if (currentTime - lastOledUpdateTime >= oledUpdateInterval)
    {
        updateOLED();
        lastOledUpdateTime = currentTime;
    }
    // Main loop delay. Shorter delay allows more responsive OLED updates if needed.
    delay(1000); // Check schedules and update outputs roughly every second.
}
