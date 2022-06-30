#include<SPI.h>
#include<LoRa.h>
#include<Wire.h>

#define ss 15
#define rst 16
#define dio0 2

uint8_t soilM = A0;
int reading = 0;
int moisture_percent = -1;
int temp = 100;

void setup() {
  Serial.begin(9600);
  delay(1000);
  
  Serial.println("Starting LoRa...");
  LoRa.setPins(ss, rst, dio0);
  
  while(!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    delay(1000);
  }
  
  Serial.println("LoRa initialized");
  LoRa.setTxPower(20);
}
int i=0;

void loop() {
  reading = analogRead(soilM);
  moisture_percent = (100 - ((reading/1023.00) * 100));
  
  Serial.print("Sending packet: ");
  Serial.println(moisture_percent);
  
  // send packet
  LoRa.beginPacket();
  LoRa.print("soilM:");
  LoRa.println(moisture_percent);
  LoRa.endPacket();

  delay(3000);
}
