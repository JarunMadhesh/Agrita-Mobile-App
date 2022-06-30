#include <LoRa.h>
#include <SPI.h>
#include <DHT.h>
#include <WiFi.h>
#include <time.h>
#include <HTTPClient.h>
#include <FirebaseESP32.h>
#include <ArduinoJson.h>

#define ss 5
#define rst 14
#define dio0 2
#define DHTTYPE DHT11
#define DHTPIN 4
#define relay 16

DHT dht(DHTPIN, DHTTYPE); 
HTTPClient http;
FirebaseData firebaseData;

// a string to hold NTP server to request epoch time
const char* ntpServer = "pool.ntp.org";

//WiFi credentials
const char* ssid = "Jarun's phone";
const char* password = "myphone1";

// API keys and URL for Accuweather API
String apiKey = "4gTsKl3rKk2y11MEH1a8jG0p22A6AMwL";
String weatherAPI = "http://dataservice.accuweather.com/forecasts/v1/daily/1day/190803?apikey=" + apiKey + "&details=true&metric=true";
int weatherResponse;
String weatherPayload;

// Firebase credentials
String FIREBASE_HOST = "https://smartirrigation-e152e-default-rtdb.asia-southeast1.firebasedatabase.app/";
String FIREBASE_AUTH = "Da7VhoMY0ujXYMFuZeyPYHpdzihTwO3kaGN7N0WV";

//Sensor value variables
struct dhtReadings {
  int temperature;
  int humidity;
};

int soil_moisture = 100;
struct dhtReadings dhtVAL;

// Weather data
int precepitationProb = 50;
long lastUpdateTime = 0;
int timeOffset = 5.5;

bool motorStatus = false;
int overwrite = 0;

//threshold
int tempThresh = 30;
int humThresh = 70;
int prepThresh = 75;
int soilMThresh = 70;

// Ggets current epoch time
unsigned long Get_Epoch_Time() {
  time_t now;
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time");
    return(0);
  }
  time(&now);
  return now;
}

void initWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi...");
  while(WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }
  Serial.print("\nConnected to ");
  Serial.println(WiFi.localIP());

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
  Firebase.setwriteSizeLimit(firebaseData, "tiny");
}

void onReceive(int packetSize) {
  // received a packet
  Serial.print("Received packet '");
  
  // read packet
  String packet = LoRa.readString();
  Serial.print(packet);

  String val = packet.substring(6, packetSize);
  soil_moisture = val.toInt();

  // print RSSI of packet
//  Serial.print("' with RSSI ");
//  Serial.println(LoRa.packetRssi());
  Serial.print("Soil moisture: ");
  Serial.println(val);
  Serial.println(" ");
}

void initLoRa() {
  LoRa.setPins(ss, rst, dio0);
  Serial.println("LoRa Receiver Callback");

  while (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    delay(1000);
  }
  Serial.println("LoRa Receiver Started");  
  LoRa.onReceive(onReceive);
  LoRa.receive();
}



void readDHT() {
  struct dhtReadings read;
  read.temperature = dht.readTemperature();
  read.humidity = dht.readHumidity();
  if(isnan(read.temperature) && isnan(read.humidity)) {
    Serial.println("Failed to read from DHT sensor");
  } else {
    dhtVAL.temperature = read.temperature;
    dhtVAL.humidity = read.humidity;
    Serial.print("Temperature: ");
    Serial.print(read.temperature);
    Serial.print(" *c   Humidity: ");
    Serial.print(read.humidity);
    Serial.println("%");
  }
}

void getWeatherData() {
  http.begin(weatherAPI.c_str());
  weatherResponse = http.GET();

  weatherPayload = "{}";
  Serial.print("HTTP response code: ");
  Serial.println(weatherResponse);
  if(weatherResponse == 200) {
    weatherPayload = http.getString();
    
    StaticJsonDocument<200> doc;
    DeserializationError error = deserializeJson(doc, weatherPayload);
    if(error) {
      Serial.println("Json Parsing failed");
      return;
    }
    precepitationProb = doc["DailyForecasts"]["Day"]["PrecipitationProbability"]; 
    Serial.print("Probability of precepiation: ");
    Serial.println(precepitationProb);  
    Firebase.RTDB.setInt(&firebaseData, "123/sensrd/rainprob", precepitationProb);
  } else {
    Serial.println("ERROR IN GETTING WEATHER DATA");
  }
}

void getThresh() {
  Firebase.RTDB.getInt(&firebaseData, "123/overwrite");
  
  if(firebaseData.dataType() == "int") {
    overwrite = firebaseData.intData();
  }

  if(overwrite==1) {
    
    Firebase.RTDB.getInt(&firebaseData, "123/motor");
    if(firebaseData.dataType() == "int") {
      int temp = firebaseData.intData();
      if(temp == 1) {
        motorStatus = true;
      } else {
        motorStatus = false;
      }
    }  
  }
  
  Firebase.RTDB.getInt(&firebaseData, "123/thresh/temp");
  if(firebaseData.dataType() == "int") {
    tempThresh = firebaseData.intData();
  }
  Firebase.RTDB.getInt(&firebaseData, "123/thresh/hum");
  if(firebaseData.dataType() == "int") {
    humThresh = firebaseData.intData();
  }
  Firebase.RTDB.getInt(&firebaseData, "123/thresh/rainprob");
  if(firebaseData.dataType() == "int") {
    prepThresh = firebaseData.intData();
  }
  Firebase.RTDB.getInt(&firebaseData, "123/thresh/moist");
  if(firebaseData.dataType() == "int") {
    soilMThresh = firebaseData.intData();
  }
}


void post() {
  Firebase.RTDB.setInt(&firebaseData, "123/sensrd/hum", dhtVAL.humidity);
  Firebase.RTDB.setInt(&firebaseData, "123/sensrd/temp", dhtVAL.temperature);
  Firebase.RTDB.setInt(&firebaseData, "123/sensrd/s1/moist", soil_moisture);
}


boolean checkTimeForFetch() {
  long tempTime = Get_Epoch_Time();
  if(tempTime-lastUpdateTime >= 21600) {
    lastUpdateTime = tempTime;
    return true;
  }
  return false;
}

void control() {
  readDHT();
  
  // user input
  if(overwrite == 1) {
    if(motorStatus){
      digitalWrite(relay, LOW);
    } else {
      digitalWrite(relay, HIGH);
    }
    return;
  }

  if(soil_moisture <= soilMThresh) {
    if(dhtVAL.temperature >= tempThresh && dhtVAL.humidity <= humThresh) {

      // Update weather report only if the last update happened
      // before 6 hours
      if(checkTimeForFetch()) {
        getWeatherData();
      }
      
      if(precepitationProb < prepThresh) {
        if(!motorStatus) {
          Serial.println("Irrigating");
          Firebase.RTDB.setInt(&firebaseData, "123/motor", 1);
          motorStatus = true;
          digitalWrite(relay, LOW);
          Serial.println("Waits for 20 sec");
          delay(20000);
        }        
      } else {
        Serial.println("Rain predicted");
        if(motorStatus) {
          motorStatus = false;
          Firebase.RTDB.setInt(&firebaseData, "123/motor", 0);
          digitalWrite(relay, HIGH);
        } 
      }
      
    } else {
      if(motorStatus) {
        motorStatus = false;
        Firebase.RTDB.setInt(&firebaseData, "123/motor", 0);
        Serial.println("Irrigation turned off");
        digitalWrite(relay, HIGH);
      }
    }
  }
}

void setup() {
  Serial.begin(9600);
  while (!Serial);
  delay(1000);

  configTime(0, 0, ntpServer);
  initWiFi();
  initLoRa();
  pinMode(DHTPIN, INPUT);
  pinMode(relay, OUTPUT);
  digitalWrite(relay, HIGH);
  dht.begin(); 

  getThresh();
  Firebase.RTDB.getInt(&firebaseData, "123/motor");
    if(firebaseData.dataType() == "int") {
      int temp = firebaseData.intData();
      if(temp == 1) {
        motorStatus = true;
      } else {
        motorStatus = false;
      }
    }
}

void loop() {
  getThresh();
  Serial.print("overwrite ");
  Serial.print(overwrite);
  Serial.print(" motor status ");
  Serial.println(motorStatus);
  control();
  post();
  delay(1000);
}




 
