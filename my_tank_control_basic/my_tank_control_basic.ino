// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

// my_tank_control_basic.ino
// Need to integrate remote control for my_tank_control_basic where you set from the app time on and off

#include <WiFi.h>
#include "time.h" // For time functions

#include <Wire.h>    // For I2C communication
#include <axp20x.h>  // For AXP192 Power Management
#include <U8g2lib.h> // U8g2 graphics library

// --- Configuration ---

// WiFi credentials
const char *ssid = "######";
const char *password = "#####**"; // Consider security implications for shared code

// NTP Configuration
const char *ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 2 * 3600; // GMT+2 offset in seconds
const int daylightOffset_sec = 0;    // No daylight saving offset for simplicity.

// Output Pins (Please verify these are free on your TTGO T-Beam v1.1)
// Refer to your board's pinout diagram.
const int led1Pin = 25;    // Example: GPIO25. NOTE: Pinout.md says GPIO25 often OLED_RESET.
const int led2Pin = 27;    // Example: GPIO27
const int airPumpPin = 33; // Example: GPIO33

// OLED Display Configuration
#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

// TTGO T-Beam v1.1 typically uses: SDA = GPIO21, SCL = GPIO22
// IMPORTANT: OLED_RESET PIN:
// Your pinout.md suggests GPIO25 is often OLED_RESET.
// If led1Pin is GPIO25, you have a conflict.
// Common alternatives for OLED_RESET are GPIO16 or -1 if not used/tied to main reset.
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

// LED 2: On 06h00 - Off 20h30
const int led2OnHour = 6;
const int led2OnMin = 0;
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
  u8g2.setFont(u8g2_font_profont12_tf); // A slightly larger, clear font
  // Or use a smaller font like u8g2_font_ncenB08_tr or u8g2_font_5x7_tf for more lines

  int yPos = 0;              // Current Y position for drawing, starts at top
  const int lineHeight = 12; // Approximate height for profont12
  char buffer[24];           // Buffer for formatting strings (increased slightly for safety)

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
  u8g2.setFont(u8g2_font_profont12_tf); // Back to main font for content below time/date

  if (currentDisplayState == WIFI_INFO)
  {
    u8g2.setCursor(0, yPos); // Use setCursor for multi-part lines with u8g2.print()
    u8g2.print("WiFi: ");
    if (WiFi.status() == WL_CONNECTED)
    {
      u8g2.print("Connected");
      yPos += lineHeight;
      u8g2.setCursor(0, yPos);
      u8g2.print("IP: ");
      u8g2.print(WiFi.localIP().toString());
      yPos += lineHeight;
      u8g2.setCursor(0, yPos);
      u8g2.print("RSSI: ");
      u8g2.print(WiFi.RSSI());
      u8g2.print(" dBm");
    }
    else
    {
      u8g2.print("Offline");
      yPos += lineHeight;
      u8g2.setCursor(0, yPos);
      u8g2.print("IP: ---.---.---.---");
      yPos += lineHeight;
      u8g2.setCursor(0, yPos);
      u8g2.print("RSSI: --- dBm");
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
    while (!getLocalTime(&timeinfo, 1000) && attempts < 10)
    { // Wait up to 10s for initial sync
      attempts++;
      if (timeinfo.tm_year < (2016 - 1900))
      { // Check if year is valid (tm_year is years since 1900)
        Serial.println("Waiting for NTP time sync...");
      }
      else
      {
        break;
      }
      delay(1000);
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

  // Ensure all outputs are OFF initially
  digitalWrite(led1Pin, LOW);
  digitalWrite(led2Pin, LOW);
  digitalWrite(airPumpPin, LOW);
  led1Status = false;
  led2Status = false;
  airPumpStatus = false;
  Serial.println("Outputs initialized to OFF.");

  setupWiFi();
  setupTime();

  updateOLED(); // Initial OLED update after setup
  Serial.println("Setup complete. Starting main loop...");
}

/**
 * @brief Checks if the current time is within a given ON/OFF schedule.
 */
bool isTimeWithinSchedule(int currentHour, int currentMin, int onHour, int onMin, int offHour, int offMin)
{
  long currentTimeInMinutes = currentHour * 60 + currentMin;
  long onTimeInMinutes = onHour * 60 + onMin;
  long offTimeInMinutes = offHour * 60 + offMin;

  return (currentTimeInMinutes >= onTimeInMinutes && currentTimeInMinutes < offTimeInMinutes);
}

/**
 * @brief Controls the outputs based on the current time and defined schedules.
 */
void controlOutputs()
{
  if (WiFi.status() != WL_CONNECTED || !getLocalTime(&timeinfo, 50) || timeinfo.tm_year < (2016 - 1900))
  {
    Serial.println("Time not synchronized or WiFi disconnected. Cannot reliably control outputs.");
    // Optionally, set outputs to a default safe state (e.g., OFF)
    // For now, they hold their last state if time was once synced.
    // If time was never synced, they remain OFF from setup.
    return;
  }

  int currentHour = timeinfo.tm_hour;
  int currentMin = timeinfo.tm_min;

  // LED 1 Control
  led1Status = isTimeWithinSchedule(currentHour, currentMin, led1OnHour, led1OnMin, led1OffHour, led1OffMin);
  digitalWrite(led1Pin, led1Status ? HIGH : LOW);

  // LED 2 Control
  led2Status = isTimeWithinSchedule(currentHour, currentMin, led2OnHour, led2OnMin, led2OffHour, led2OffMin);
  digitalWrite(led2Pin, led2Status ? HIGH : LOW);

  // Air Pump Control
  airPumpStatus = isTimeWithinSchedule(currentHour, currentMin, airPumpOnHour, airPumpOnMin, airPumpOffHour, airPumpOffMin);
  digitalWrite(airPumpPin, airPumpStatus ? HIGH : LOW);
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
    while (WiFi.status() != WL_CONNECTED && reconnAttempts < 5)
    {
      delay(500);
      Serial.print(".");
      reconnAttempts++;
    }
    if (WiFi.status() == WL_CONNECTED)
    {
      Serial.println("\nWiFi Reconnected!");
      setupTime(); // Re-synchronize time after reconnection
    }
    else
    {
      Serial.println("\nWiFi Reconnection failed.");
    }
  }

  controlOutputs();

  unsigned long currentTime = millis();

  // OLED Display State Switching Logic
  if (currentDisplayState == WIFI_INFO && (currentTime - lastDisplayChangeTime >= wifiInfoDisplayDuration))
  {
    currentDisplayState = TANK_STATUS;
    lastDisplayChangeTime = currentTime;
    // updateOLED(); // Update will be handled by the regular update below or immediately if needed
  }
  else if (currentDisplayState == TANK_STATUS && (currentTime - lastDisplayChangeTime >= tankStatusDisplayDuration))
  {
    currentDisplayState = COPYRIGHT_INFO;
    lastDisplayChangeTime = currentTime;
    // updateOLED();
  }
  else if (currentDisplayState == COPYRIGHT_INFO && (currentTime - lastDisplayChangeTime >= copyrightInfoDisplayDuration))
  {
    currentDisplayState = WIFI_INFO;
    lastDisplayChangeTime = currentTime;
    // updateOLED();
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
