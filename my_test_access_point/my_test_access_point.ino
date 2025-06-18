// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

// Load Wi-Fi library
#include <WiFi.h>

// Replace with your network credentials
const char *ssid = "SOIOT-ESP32";
const char *password = "123456789";

// Set web server port number to 80
WiFiServer server(80);

void setup()
{
    Serial.begin(115200);

    // Connect to Wi-Fi network with SSID and password
    Serial.print("Setting AP (Access Point)…");
    // Remove the password parameter, if you want the AP (Access Point) to be open
    WiFi.softAP(ssid, password);

    IPAddress IP = WiFi.softAPIP();
    Serial.print("AP IP address: ");
    Serial.println(IP);

    server.begin();
    Serial.println("Server started. Waiting for clients to connect...");
}

void loop()
{
    Serial.println("Ready Waiting for clients to connect...");
    delay(1000);
    WiFiClient client = server.available(); // Listen for incoming clients
     
    if (client)
    { // If a new client connects,
        Serial.print("New Client Connected: ");
        Serial.println(client.remoteIP()); // Print the client's IP address

        // You can add a small delay or a simple message to the client if needed,
        // but for just printing the IP, this is enough.
        // client.println("Hello from ESP32!"); // Optional: send a simple message
        client.println("Hello from ESP32!"); // Send a simple message

        delay(1000); // Add a small delay to ensure message is sent
        // Close the connection
        //client.stop();
        //Serial.println("Client disconnected.");
        //Serial.println("");
    }
}
