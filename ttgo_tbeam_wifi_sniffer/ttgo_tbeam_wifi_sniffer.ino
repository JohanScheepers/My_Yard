// ttgo_tbeam_wifi_sniffer.ino

// -----------------------------------------------------------------------------
// LEGAL IMPLICATIONS & CAUTIONS - READ CAREFULLY
// -----------------------------------------------------------------------------
// Using this software to scan Wi-Fi networks may have legal implications
// depending on your jurisdiction and how you use it.
// - Only scan networks you own or have explicit permission to scan.
// - Do not attempt to capture, store, or analyze network traffic from networks
//   you do not own without authorization.
// - Misuse of this tool can violate privacy laws and other regulations.
// - You are solely responsible for complying with all applicable laws.
// -----------------------------------------------------------------------------

#include <WiFi.h>
#include <U8g2lib.h> // U8g2 graphics library
#include <Wire.h>    // For I2C communication

// OLED Display Configuration
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET_PIN_U8G2 16 // Verify this pin for your T-Beam
// SCL: GPIO22, SDA: GPIO21 for T-Beam v1.1
U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, /* reset=*/ OLED_RESET_PIN_U8G2, /* clock=*/ 22, /* data=*/ 21);

const int scanInterval = 5000; // Scan every 5 seconds
unsigned long lastScanTime = 0;
int numNetworksFound = 0;
const int maxNetworksToDisplay = 5; // Max networks to show on OLED at once to keep it readable

void setupOLED() {
  u8g2.begin();
  u8g2.enableUTF8Print();
  Serial.println(F("U8g2 OLED Initialized for Sniffer"));
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_ncenB08_tr);
  u8g2.drawStr(0, 10, "WiFi Sniffer");
  u8g2.drawStr(0, 25, "Scanning...");
  u8g2.sendBuffer();
  delay(1000);
}

void displayNetworks() {
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_6x10_tf); // A compact font for listing networks

  char buffer[40]; // Buffer for formatting strings

  // Display header
  sprintf(buffer, "Found: %d", numNetworksFound);
  u8g2.drawStr(0, 8, buffer); // Use drawStr for (x,y) positioning
  u8g2.drawHLine(0, 10, SCREEN_WIDTH); // Horizontal line separator

  int yPos = 20; // Starting Y position for network list
  const int lineHeight = 10;

  if (numNetworksFound > 0) {
    int networksToShow = min(numNetworksFound, maxNetworksToDisplay);
    for (int i = 0; i < networksToShow; ++i) {
      // Format: SSID (RSSI dBm)
      // Truncate SSID if too long to fit
      String ssid = WiFi.SSID(i);
      if (ssid.length() > 15) { // Adjust 15 based on font and desired layout
          ssid = ssid.substring(0, 14) + ".";
      }
      sprintf(buffer, "%s (%lddBm)", ssid.c_str(), WiFi.RSSI(i));
      u8g2.drawStr(0, yPos, buffer);
      yPos += lineHeight;
      if (yPos > SCREEN_HEIGHT - lineHeight) break; // Stop if out of screen space
    }
    if (numNetworksFound > maxNetworksToDisplay) {
        sprintf(buffer, "...and %d more", numNetworksFound - maxNetworksToDisplay);
        u8g2.drawStr(0, yPos, buffer);
    }
  } else {
    u8g2.drawStr(0, yPos, "No networks found");
  }
  u8g2.sendBuffer();
}

void scanWiFiNetworks() {
  Serial.println("Starting WiFi scan...");
  // WiFi.scanNetworks will return the number of networks found
  numNetworksFound = WiFi.scanNetworks(false, true); // async = false, show_hidden = true
  Serial.print(numNetworksFound);
  Serial.println(" networks found.");

  if (numNetworksFound > 0) {
    for (int i = 0; i < numNetworksFound; ++i) {
      Serial.print(i + 1);
      Serial.print(": ");
      Serial.print(WiFi.SSID(i));
      Serial.print(" (");
      Serial.print(WiFi.RSSI(i));
      Serial.print("dBm) Ch: ");
      Serial.print(WiFi.channel(i));
      Serial.print(WiFi.encryptionType(i) == WIFI_AUTH_OPEN ? " Open" : " Encrypted");
      Serial.println();
    }
  }
  Serial.println("Scan complete.");
  displayNetworks(); // Update OLED with new scan results
}

void setup() {
  Serial.begin(115200);
  while (!Serial); // Wait for serial port to connect (optional)

  Serial.println("\nTTGO T-Beam WiFi Sniffer");
  Serial.println("--------------------------------------------------");
  Serial.println("LEGAL & ETHICAL NOTICE:");
  Serial.println("This tool scans for nearby Wi-Fi networks. You are responsible");
  Serial.println("for using this tool in compliance with all applicable local,");
  Serial.println("state, national, and international laws and regulations.");
  Serial.println("Do NOT use this tool for any unauthorized or malicious activities.");
  Serial.println("Respect privacy and only scan networks you own or have explicit");
  Serial.println("permission to analyze.");
  Serial.println("--------------------------------------------------");

  setupOLED();

  // Set WiFi to station mode and disconnect from an AP if it was previously connected
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(100);

  Serial.println("Setup done");
}

void loop() {
  unsigned long currentTime = millis();
  if (currentTime - lastScanTime >= scanInterval) {
    scanWiFiNetworks();
    lastScanTime = currentTime;
  }
  // You can add other tasks here if needed, but keep them short
  // to allow for timely rescans.
  delay(100); // Short delay to prevent tight loop if no other tasks
}
