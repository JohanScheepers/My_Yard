// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

#include <WiFi.h>
#include <HTTPClient.h>

const char *ssid = "SOIOT-ESP32";
const char *password = "123456789";

// Server URL to send the message to
const char *serverBaseUrl = "http://192.168.4.1/message"; // Example endpoint

unsigned long previousMillis = 0;
const long interval = 10000; // 10 seconds (10000 milliseconds)

void setup()
{
    Serial.begin(115200);
    delay(100); // Wait for serial to initialize

    Serial.println();
    Serial.print("Connecting to WiFi: ");
    Serial.println(ssid);

    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }

    Serial.println("");
    Serial.println("WiFi connected!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
}

void loop()
{
    unsigned long currentMillis = millis();
    if (currentMillis - previousMillis >= interval)
    {
        previousMillis = currentMillis; // Update the last time the request was sent

        // Check WiFi connection status
        if (WiFi.status() == WL_CONNECTED)
        {
            HTTPClient http;
            WiFiClient client; 

            String messageText = "Hello World";

            // Construct the full URL with the message as a query parameter
            String url = String(serverBaseUrl) + "?text=" + messageText;

            Serial.print("Sending HTTP GET request to: ");
            Serial.println(url);

            if (http.begin(client, url)) { // HTTP
                Serial.println("HTTP GET request initiated.");
                // Start connection and send HTTP header
                int httpCode = http.GET();

                // httpCode will be negative on error
                if (httpCode > 0) {
                    // HTTP header has been sent and Server response header has been handled
                    Serial.printf("[HTTP] GET... code: %d\n", httpCode);

                    // File found at server
                    if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_MOVED_PERMANENTLY) {
                        String payload = http.getString();
                        Serial.println("[HTTP] Response payload:");
                        Serial.println(payload);
                    }
                } else {
                    Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
                }
                http.end(); // Free the resources
            } else {
                Serial.printf("[HTTP] Unable to connect to %s\n", serverBaseUrl);
            }
        }
        else
        {
            Serial.println("WiFi Disconnected. Trying to reconnect...");
            // Attempt to reconnect
            // WiFi.disconnect(); // Optional: Explicitly disconnect before reconnecting
            WiFi.begin(ssid, password); // Re-initiate connection
        }
    }
}