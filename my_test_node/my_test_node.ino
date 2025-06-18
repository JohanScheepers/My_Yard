// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

#include <WiFi.h>
#include <ESPmDNS.h> // Added for mDNS
#include <ArduinoJson.h>
#include <Preferences.h>

// Configuration for the Access Point (when no client credentials are set)
const char *ssid = "SOIOT-ESP32-Test";
const char *password = "123456789"; // Use NULL for an open network, or a secure password

// Define the desired hostname for the device
const char *DEVICE_HOSTNAME = "mytest";

WiFiServer server(80); // Server will listen on port 80
Preferences preferences;

const char *PREF_NAMESPACE = "wifi-config";
const char *PREF_KEY_SSID = "ssid";
const char *PREF_KEY_PASSWORD = "password";

enum DeviceMode
{
  MODE_AP_CONFIG,
  MODE_CLIENT_OPERATIONAL
};
DeviceMode currentMode;

void startAPMode()
{
  Serial.println("Setting up Access Point Mode...");
  // Set hostname for AP mode first
  WiFi.softAPsetHostname(DEVICE_HOSTNAME);
  // Using default values for channel (1), hidden (0), max_connections (4), ftm_responder (false)
  WiFi.softAP(ssid, password, 1, 0, 4, false); // Call softAP without the hostname argument
  Serial.print("AP Hostname: ");
  Serial.println(DEVICE_HOSTNAME); // WiFi.softAPSSID() is the SSID, hostname is set separately
  IPAddress apIP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(apIP);
  server.begin();
  Serial.println("HTTP server started on AP. Waiting for client to send credentials via JSON on port 80...");

  if (MDNS.begin(DEVICE_HOSTNAME)) { // Start mDNS with the hostname
    Serial.println("MDNS responder started for AP mode");
    MDNS.addService("http", "tcp", 80); // Announce HTTP service on port 80
  } else {
    Serial.println("Error setting up MDNS responder!");
  }
  currentMode = MODE_AP_CONFIG;
}

void connectToWiFi(const String &ssid_param, const String &password_param)
{ // Renamed parameters to avoid conflict
  Serial.print("Attempting to connect to WiFi SSID: ");
  Serial.println(ssid_param);

  // Set hostname for STA mode
  WiFi.setHostname(DEVICE_HOSTNAME);
  Serial.print("STA Hostname set to: ");
  Serial.println(DEVICE_HOSTNAME);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid_param.c_str(), password_param.c_str());

  int attempts = 0;
  const int maxAttempts = 20; // Try for about 10 seconds
  while (WiFi.status() != WL_CONNECTED && attempts < maxAttempts)
  {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED)
  {
    Serial.println("\nSuccessfully connected to WiFi!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    Serial.print("Hostname: ");
    Serial.println(WiFi.getHostname()); // Confirm hostname in STA mode

    if (MDNS.begin(DEVICE_HOSTNAME)) { // Start mDNS with the hostname
      Serial.println("MDNS responder started for STA mode");
      MDNS.addService("http", "tcp", 80); // Announce HTTP service on port 80
    } else {
      Serial.println("Error setting up MDNS responder!");
    }
    currentMode = MODE_CLIENT_OPERATIONAL;
  }
  else
  {
    Serial.println("\nFailed to connect to the specified WiFi network.");
    WiFi.disconnect(true); // Disconnect and clear any previous STA settings
    WiFi.mode(WIFI_OFF);   // Turn off WiFi before setting up AP
    delay(100);

    // Clear stored preferences if connection failed, to avoid retrying bad creds
    // and fall back to AP mode.
    preferences.begin(PREF_NAMESPACE, false); // R/W mode
    preferences.remove(PREF_KEY_SSID);
    preferences.remove(PREF_KEY_PASSWORD);
    preferences.end();
    Serial.println("Cleared stored WiFi credentials due to connection failure.");

    startAPMode(); // Fallback to AP mode
  }
}

void setup()
{
  Serial.begin(115200);
  while (!Serial)
  {
    delay(10); // wait for serial port to connect. Needed for native USB
  }
  Serial.println("\nESP32 Booting...");

  preferences.begin(PREF_NAMESPACE, true); // Start preferences in read-only mode
  String storedSsid = preferences.getString(PREF_KEY_SSID, "");
  String storedPassword = preferences.getString(PREF_KEY_PASSWORD, "");
  preferences.end();

  if (storedSsid.length() > 0 && storedPassword.length() > 0)
  {
    Serial.println("Found stored WiFi credentials. Attempting to connect as client...");
    connectToWiFi(storedSsid, storedPassword);
  }
  else
  {
    Serial.println("No stored WiFi credentials found or credentials invalid.");
    startAPMode();
  }
}

void loop()
{
  if (currentMode == MODE_AP_CONFIG)
  {
    WiFiClient client = server.available();
    if (client)
    {
      Serial.println("New client connected to AP.");
      String jsonData = "";
      unsigned long startTime = millis();
      bool dataReceived = false;

      // Wait for data from client with a timeout
      while (client.connected() && (millis() - startTime < 5000))
      { // 5-second timeout
        if (client.available())
        {
          jsonData = client.readString(); // Read all available data at once
          dataReceived = true;
          break;
        }
        delay(10); // Small delay to allow data to arrive
      }

      if (dataReceived && jsonData.length() > 0)
      {
        Serial.print("Received JSON data: ");
        Serial.println(jsonData);

        StaticJsonDocument<256> doc; // Adjust size if your JSON is larger
        DeserializationError error = deserializeJson(doc, jsonData);

        if (error)
        {
          Serial.print(F("deserializeJson() failed: "));
          Serial.println(error.f_str());
          client.println("HTTP/1.1 400 Bad Request\r\nContent-Type: text/plain\r\n\r\nInvalid JSON format.");
        }
        else
        {
          const char *newSsid = doc["ssid"];
          const char *newPassword = doc["password"];

          if (newSsid && newPassword)
          {
            preferences.begin(PREF_NAMESPACE, false); // Open for writing
            preferences.putString(PREF_KEY_SSID, newSsid);
            preferences.putString(PREF_KEY_PASSWORD, newPassword);
            preferences.end();

            Serial.println("New WiFi credentials saved:");
            Serial.print("SSID: ");
            Serial.println(newSsid);
            // Serial.print("Password: "); Serial.println(newPassword); // Avoid printing password
            Serial.println("Rebooting to connect as client...");

            client.println("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nCredentials received. ESP32 will reboot.");
            delay(100); // Allow time for client to receive response
            client.stop();
            ESP.restart();
          }
          else
          {
            Serial.println(F("JSON missing 'ssid' or 'password' fields."));
            client.println("HTTP/1.1 400 Bad Request\r\nContent-Type: text/plain\r\n\r\nJSON must contain 'ssid' and 'password' fields.");
          }
        }
      }
      else if (!dataReceived)
      {
        Serial.println("No data received from client or connection timed out.");
      }

      client.stop();
      Serial.println("Client disconnected from AP.");
    }
  }
  else if (currentMode == MODE_CLIENT_OPERATIONAL)
  {
    // ESP32 is connected as a client. Add your main application logic here.
    // For example, print a message periodically.
    Serial.println("Operating in WiFi Client Mode. IP: " + WiFi.localIP().toString() + ", Hostname: " + WiFi.getHostname());
    delay(10000); // Do something every 10 seconds
  }
}
