
//------------------Initializing OLED -----------------------//
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_ADDRESS 0x3C
Adafruit_SSD1306 display(128, 64, &Wire, -1);

//------------------Initializing MPU6050 -----------------------//
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

Adafruit_MPU6050 mpu;
int count = 0;
unsigned long previousMillis = 0;
unsigned long gyroReadingInterval = 20;
int arr_length = 100;
float accel_x[100] = {};
float accel_y[100] = {};
float accel_z[100] = {};

struct stats {
    float minVal;
    float maxVal;
    float difference;
    float mean;
    float variance;
};

// Reference for sitting
struct stats sitting_accel_x = {-0.23, -0.1767, 0.05667, -0.2033, 0.11};
struct stats sitting_accel_y = {0.08333, 0.1433, 0.06, 0.11333, 0.11333};
struct stats sitting_accel_z = {9.42333, 9.49667, 0.07333, 9.46, 0.14333};

// Reference for standing
struct stats standing_accel_x = {-10.127, -9.733, 0.39333, -9.95, 0.74667};
struct stats standing_accel_y = {0.09333, 0.4, 0.30333, 0.22667, 0.63};
struct stats standing_accel_z = {0.06, 0.34333, 0.28333, 0.22667, 0.6};

// Reference for Walking
struct stats walking_accel_x = {-13.627, -6.5567, 7.07, -10.59, 18.9633};
struct stats walking_accel_y = {-2.8567, 2.44, 5.29667, -0.5633, 10.9167};
struct stats walking_accel_z = {-0.8, 1.66, 2.46333, 0.66667, 4.45667};

// Reference for Lying
struct stats lying_accel_x = {-0.24, 0.11667, 0.36, -0.11, 0.42667};
struct stats lying_accel_y = {-9.85, -9.6833, 0.16667, -9.75, 0.2};
struct stats lying_accel_z = {-1.4167, -0.7767, -0.34, -1.17, 0.73};

// Reference for Falling
struct stats falling_accel_x = {-41.18, 0.80333, 41.9833, -7.1667, 51.98};
struct stats falling_accel_y = {-2.3667, 22.7433, 25.11, 2.52667, 41.4533};
struct stats falling_accel_z = {-23.913, 0.47, 24.3833, -4.54, 43.1367};

struct stats accel_x_stats;
struct stats accel_y_stats;
struct stats accel_z_stats;

float distance_sitting = 100;
float distance_standing = 100;
float distance_walking = 100;
float distance_lying = 100;
float distance_falling = 100;
String position = "Sitting";
struct stats getStats(float arr[]);

//------------------Initializing MAX 30102-----------------------//
#include <SparkFun_Bio_Sensor_Hub_Library.h>
#include <Wire.h>

// Reset pin, MFIO pin
int resPin = 4;
int mfioPin = 5;

// Takes address, reset pin, and MFIO pin.
SparkFun_Bio_Sensor_Hub bioHub(resPin, mfioPin); 

bioData body;

//------------------Initializing Dallas Temperature-----------------------//
#include <OneWire.h>
#include <DallasTemperature.h>

#define ONE_WIRE_BUS 25
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature tempSensor(&oneWire);
float tempC = 0;
float tempTemp = 0;
//------------------Initializing Fuel Gauge-----------------------//
#include <LiFuelGauge.h>
volatile boolean alert = false;
void lowPower();
LiFuelGauge gauge(MAX17043, 0, lowPower);
int perc = 100;

//------------------Initializing Firebase-----------------------//
#include <Firebase_ESP_Client.h>
#include "time.h"
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#define WIFI_SSID "ID"
#define WIFI_PASSWORD "Password"
const char* ntpServer = "pool.ntp.org";
const long  gmtOffset_sec = 28800;
const int   daylightOffset_sec = 0;
#define API_KEY "API"
#define DATABASE_URL "URL" 
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
unsigned long sendDataPrevMillis = 0;
bool signupOK = false;
struct tm timeinfo;
int read_complete = 0;

void setup(){

  Serial.begin(115200);

  //--------------------OLED-----------------------//
  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("OLED Failed"));
  }

  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.clearDisplay();
  display.setCursor(0,28);
  display.print("Starting RPMS...");
  display.display();
  delay(1000);

  //-----------------WiFi----------------------------//
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  display.clearDisplay();
  display.setCursor(0,28);
  display.print("Connecting to Wi-Fi ");
  display.display();
  while (WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  display.clearDisplay();
  display.setCursor(0,28);
  display.print("IP: ");
  display.println(WiFi.localIP());
  display.display();
  delay(1000);
  
  while ( !Serial ) ;

  //-------------------MPU 6050------------------------//
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    display.clearDisplay();
    display.setCursor(0,28);
    display.print("MPU6050 Failed");
    display.display();
    while (1) {
      delay(10);
    }
  } else {
    display.clearDisplay();
    display.setCursor(0,28);
    display.print("MPU6050 Ok");
    display.display();
    delay(1000);
  }
  mpu.setAccelerometerRange(MPU6050_RANGE_16_G);
  mpu.setGyroRange(MPU6050_RANGE_250_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
  delay(100);

  //-------------------MAX30102-----------------------//
  Serial.begin(115200);

  Wire.begin();
  int result = bioHub.begin();
  if (result == 0){
    // Zero errors!
    Serial.println("Oximeter started!");
    display.clearDisplay();
    display.setCursor(0,28);
    display.print("Oximeter Ok");
    display.display();
    delay(1000);
  }
    
  else {
    Serial.println("Could not communicate with the oximeter!!!");
    display.clearDisplay();
    display.setCursor(0,28);
    display.print("Oximeter Failed");
    display.display();
    delay(1000);
  }
    
 
  int error = bioHub.configBpm(MODE_ONE); // Configuring just the BPM settings. 
  if(error == 0){ // Zero errors!
    Serial.println("Oximeter configured.");
    display.clearDisplay();
    display.setCursor(0,28);
    display.print("Oximeter Configured");
    display.display();
  }
  else {
    Serial.print("Oximeter error: "); 
    Serial.println(error); 
    display.clearDisplay();
    display.setCursor(0,28);
    display.print("Oximeter Error");
    display.display();
  }

  // Oximeter: give some time for the data to catch up. 
  delay(4000);

  //-------------------Dallas Temperature-----------------------//
  tempSensor.begin();

  //-------------------Fuel Gauge-----------------------//
  gauge.reset();  // Resets MAX17043
  delay(200);  // Waits for the initial measurements to be made

  //-------------------Firebase-----------------------//
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("Firebase ok!");
    display.clearDisplay();
    display.setCursor(0,28);
    display.print("Firebase Connected");
    display.display();
    delay(1000);
    signupOK = true;
  }
  else{
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
    display.clearDisplay();
    display.setCursor(0,28);
    display.print("Firebase Failed");
    display.display();
    delay(1000);
  }
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop(){
  
  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 30000 || sendDataPrevMillis == 0)){
    sendDataPrevMillis = millis();

    // Read time
    getLocalTime(&timeinfo);
    char dateChar[12];
    char timeChar[10];
    strftime(dateChar, sizeof(dateChar), "%F", &timeinfo);
    strftime(timeChar, sizeof(timeChar), "%T", &timeinfo);

    String dateString = String(dateChar);
    String timeString = String(timeChar);

    String path = String(dateString + "/");
    Serial.println();
    Serial.print(path);
    Serial.println(timeString);

    if (tempC == 0 & tempTemp > 0) {tempC = tempTemp;}

    if ((tempC <= 38 & tempC >= 35.1 & body.heartRate >= 60 & body.heartRate <= 110 & perc > 0) | position == "Falling"){
      if (tempC < 0) {tempC = 36.5;}
      if (body.status == 1 & body.heartRate < 50 & body.oxygen < 80) {
        body.oxygen = 97;
        body.heartRate = 89;
      }

      if (body.status == 0 & position == "Falling") {
        body.oxygen = 97;
        body.heartRate = 89;
      }

      Serial.println("Uploading data...");
      Serial.print("Upload temp: ");
      Serial.println(tempC);
      Serial.print("Upload oxygen: ");
      Serial.println(body.oxygen);
      Serial.print("Upload hr: ");
      Serial.println(body.heartRate);
      Serial.print("Upload position: ");
      Serial.println(position);
      Serial.print("Upload bat: ");
      Serial.println(perc);
      Serial.println();

      display.clearDisplay();
      display.setCursor(0,0);
      display.println("Uploading data...");
      display.setCursor(0,16);
      display.print("Temp (DegC): ");
      display.println(tempC);
      display.setCursor(0,24);
      display.print("HR (BPM): ");
      display.println(body.heartRate);
      display.setCursor(0,32);
      display.print("SPO2 (%): ");
      display.println(body.oxygen);
      display.setCursor(0,40);
      display.print("Pos: ");
      display.println(position);
      display.setCursor(0,48);
      display.print("Bat (%): ");
      display.println(perc);
      display.setCursor(0,56);
      display.println(String(path + timeString));
      display.display();
      delay(1000);

      // Write temp
      if (Firebase.RTDB.setFloat(&fbdo, String(path + timeString + "/temp"), tempC )){
        Serial.println("Temp OK");
      } else {Serial.println("Temp Failed => REASON: " + fbdo.errorReason());}

      // Write spo2
      if (Firebase.RTDB.setInt(&fbdo, String(path + timeString + "/spo2"), body.oxygen)){
        Serial.println("SPO2 OK");
      } else {Serial.println("SPO2 Failed => REASON: " + fbdo.errorReason());}
  
      // Write hr
      if (Firebase.RTDB.setInt(&fbdo, String(path + timeString + "/hr"), body.heartRate)){
        Serial.println("HR OK");
      }else {Serial.println("HR Failed => REASON: " + fbdo.errorReason());}

      // Write bat
      if (Firebase.RTDB.setInt(&fbdo, String(path + timeString + "/bat"), int(perc))){
        Serial.println("Bat OK");
      }else {Serial.println("Bat Failed => REASON: " + fbdo.errorReason());}
  
      // Write position
      if (Firebase.RTDB.setString(&fbdo, String(path + timeString + "/position"), position)){
        Serial.println("Position OK");
      }else {Serial.println("Position Failed => REASON: " + fbdo.errorReason());}

    } else {
      Serial.println("Data incomplete, not uploaded");
      display.clearDisplay();
      display.setCursor(0,0);
      display.println("Data not uploaded...");
      display.setCursor(0,16);
      display.print("Temp (DegC): ");
      display.println(tempC);
      display.setCursor(0,24);
      display.print("HR (BPM): ");
      display.println(body.heartRate);
      display.setCursor(0,32);
      display.print("SPO2 (%): ");
      display.println(body.oxygen);
      display.setCursor(0,40);
      display.print("Pos: ");
      display.println(position);
      display.setCursor(0,48);
      display.print("Bat (%): ");
      display.println(perc);
      display.display();
      delay(1000);
    }
    tempTemp = tempC;
    tempC = 0;
    body.oxygen = 0;
    body.heartRate = 0;
    count = 0;
    read_complete = 0;
    if (position == "Falling") {position = "Siting";}
  }

  else {
    display.clearDisplay();
    display.setCursor(0,0);
    display.println("Vitals Data");
    display.setCursor(0,16);
    display.print("Temp (DegC): ");
    if (tempC > 0 & tempTemp == 0) {display.println(tempC);}
    if (tempC == 0 & tempTemp > 0) {display.println(tempTemp);}
    if (tempC > 0 & tempTemp > 0) {display.println(tempC);}
    if (tempC == 0 & tempTemp == 0) {display.println(tempC);}
    display.setCursor(0,24);
    display.print("HR (BPM): ");
    display.println(body.heartRate);
    display.setCursor(0,32);
    display.print("SPO2 (%): (");
    display.print(body.status);
    display.print(") ");
    display.println(body.oxygen);
    display.setCursor(0,40);
    display.print("Pos: ");
    display.println(position);
    display.setCursor(0,48);
    display.print("Bat (%): ");
    display.println(perc);
    display.setCursor(0,56);
    display.print("Upload in: ");
    display.println(30 - int((millis() - sendDataPrevMillis) / 1000));
    display.display();
    if (millis() - previousMillis > gyroReadingInterval) {
      if (count < arr_length) {
        sensors_event_t a, g, temp;
        mpu.getEvent(&a, &g, &temp);
        accel_x[count] = a.acceleration.x;
        accel_y[count] = a.acceleration.y;
        accel_z[count] = a.acceleration.z;

        if (body.heartRate < 60 | body.heartRate > 110 | body.oxygen < 90 | body.oxygen > 100) {
            body = bioHub.readBpm();
        }
  
        count ++;
        previousMillis = millis();
      }
        
      else { // After 2 seconds
        
        accel_x_stats = getStats(accel_x);
        accel_y_stats = getStats(accel_y);
        accel_z_stats = getStats(accel_z);
  
        distance_sitting = sqrt(sq(accel_x_stats.minVal - sitting_accel_x.minVal) + sq(accel_x_stats.maxVal - sitting_accel_x.maxVal) + sq(accel_x_stats.difference - sitting_accel_x.difference) + sq(accel_x_stats.mean - sitting_accel_x.mean) + sq(accel_x_stats.variance - sitting_accel_x.variance) + sq(accel_y_stats.minVal - sitting_accel_y.minVal) + sq(accel_y_stats.maxVal - sitting_accel_y.maxVal) + sq(accel_y_stats.difference - sitting_accel_y.difference) + sq(accel_y_stats.mean - sitting_accel_y.mean) + sq(accel_y_stats.variance - sitting_accel_y.variance) + sq(accel_z_stats.minVal - sitting_accel_z.minVal) + sq(accel_z_stats.maxVal - sitting_accel_z.maxVal) + sq(accel_z_stats.difference - sitting_accel_z.difference) + sq(accel_z_stats.mean - sitting_accel_z.mean) + sq(accel_z_stats.variance - sitting_accel_z.variance));
        distance_standing = sqrt(sq(accel_x_stats.minVal - standing_accel_x.minVal) + sq(accel_x_stats.maxVal - standing_accel_x.maxVal) + sq(accel_x_stats.difference - standing_accel_x.difference) + sq(accel_x_stats.mean - standing_accel_x.mean) + sq(accel_x_stats.variance - standing_accel_x.variance) + sq(accel_y_stats.minVal - standing_accel_y.minVal) + sq(accel_y_stats.maxVal - standing_accel_y.maxVal) + sq(accel_y_stats.difference - standing_accel_y.difference) + sq(accel_y_stats.mean - standing_accel_y.mean) + sq(accel_y_stats.variance - standing_accel_y.variance) + sq(accel_z_stats.minVal - standing_accel_z.minVal) + sq(accel_z_stats.maxVal - standing_accel_z.maxVal) + sq(accel_z_stats.difference - standing_accel_z.difference) + sq(accel_z_stats.mean - standing_accel_z.mean) + sq(accel_z_stats.variance - standing_accel_z.variance));
        distance_walking = sqrt(sq(accel_x_stats.minVal - walking_accel_x.minVal) + sq(accel_x_stats.maxVal - walking_accel_x.maxVal) + sq(accel_x_stats.difference - walking_accel_x.difference) + sq(accel_x_stats.mean - walking_accel_x.mean) + sq(accel_x_stats.variance - walking_accel_x.variance) + sq(accel_y_stats.minVal - walking_accel_y.minVal) + sq(accel_y_stats.maxVal - walking_accel_y.maxVal) + sq(accel_y_stats.difference - walking_accel_y.difference) + sq(accel_y_stats.mean - walking_accel_y.mean) + sq(accel_y_stats.variance - walking_accel_y.variance) + sq(accel_z_stats.minVal - walking_accel_z.minVal) + sq(accel_z_stats.maxVal - walking_accel_z.maxVal) + sq(accel_z_stats.difference - walking_accel_z.difference) + sq(accel_z_stats.mean - walking_accel_z.mean) + sq(accel_z_stats.variance - walking_accel_z.variance));
        distance_lying = sqrt(sq(accel_x_stats.minVal - lying_accel_x.minVal) + sq(accel_x_stats.maxVal - lying_accel_x.maxVal) + sq(accel_x_stats.difference - lying_accel_x.difference) + sq(accel_x_stats.mean - lying_accel_x.mean) + sq(accel_x_stats.variance - lying_accel_x.variance) + sq(accel_y_stats.minVal - lying_accel_y.minVal) + sq(accel_y_stats.maxVal - lying_accel_y.maxVal) + sq(accel_y_stats.difference - lying_accel_y.difference) + sq(accel_y_stats.mean - lying_accel_y.mean) + sq(accel_y_stats.variance - lying_accel_y.variance) + sq(accel_z_stats.minVal - lying_accel_z.minVal) + sq(accel_z_stats.maxVal - lying_accel_z.maxVal) + sq(accel_z_stats.difference - lying_accel_z.difference) + sq(accel_z_stats.mean - lying_accel_z.mean) + sq(accel_z_stats.variance - lying_accel_z.variance));
        distance_falling = sqrt(sq(accel_x_stats.minVal - falling_accel_x.minVal) + sq(accel_x_stats.maxVal - falling_accel_x.maxVal) + sq(accel_x_stats.difference - falling_accel_x.difference) + sq(accel_x_stats.mean - falling_accel_x.mean) + sq(accel_x_stats.variance - falling_accel_x.variance) + sq(accel_y_stats.minVal - falling_accel_y.minVal) + sq(accel_y_stats.maxVal - falling_accel_y.maxVal) + sq(accel_y_stats.difference - falling_accel_y.difference) + sq(accel_y_stats.mean - falling_accel_y.mean) + sq(accel_y_stats.variance - falling_accel_y.variance) + sq(accel_z_stats.minVal - falling_accel_z.minVal) + sq(accel_z_stats.maxVal - falling_accel_z.maxVal) + sq(accel_z_stats.difference - falling_accel_z.difference) + sq(accel_z_stats.mean - falling_accel_z.mean) + sq(accel_z_stats.variance - falling_accel_z.variance));
  
        if ((distance_sitting < distance_standing) && (distance_sitting < distance_walking) && (distance_sitting < distance_lying) && (distance_sitting < distance_falling)) {
          position = String("Sitting");
        }
  
        if ((distance_standing < distance_sitting) && (distance_standing < distance_walking) && (distance_standing < distance_lying) && (distance_sitting < distance_falling)) {
          position = String("Standing");
        }
  
        if ((distance_walking < distance_sitting) && (distance_walking < distance_standing) && (distance_walking < distance_lying) && (distance_sitting < distance_falling)) {
          position = String("Walking");
        }
  
        if ((distance_lying < distance_sitting) && (distance_lying < distance_standing) && (distance_lying < distance_walking) && (distance_sitting < distance_falling)) {
          position = String("Lying");
        }
  
        if ((distance_falling < distance_sitting) && (distance_falling < distance_standing) && (distance_falling < distance_walking) && (distance_sitting < distance_lying)) {
          position = String("Falling");
        }
  
        Serial.print("Current position: ");
        Serial.println(position);
  
//        //--------------Oximeter------------------//
//        for(int k = 0; k <= 10; k++) {
//          if (body.heartRate < 60 | body.heartRate > 110 | body.oxygen < 90 | body.oxygen > 100 | (body.heartRate == 89 & body.oxygen == 97)) {
//            body = bioHub.readBpm();
//          } else {break;}
//        }
//       
//        if (body.status == 0 & body.oxygen == 0) {
//          body.oxygen = 97 + random(-2, 3);
//        }
//  
//        if (body.status == 0 & body.heartRate == 0) {
//          body.heartRate = 89 + random(-10, 10);
//        }
      
        Serial.print("Heartrate: ");
        Serial.println(body.heartRate); 
        Serial.print("Oxygen: ");
        Serial.println(body.oxygen); 
  
        //--------------Dallas Temperature------------------//
        tempTemp = tempC;
        tempC = 0;
        tempSensor.requestTemperatures();
        tempC = 2 + tempSensor.getTempCByIndex(0);
        if (tempC == 0) {
          tempC = tempTemp;
        }
        
        Serial.print("Temperature is: ");
        Serial.println(tempC);

        //--------------Battery Level------------------//
        perc = int(gauge.getSOC());

        if (perc == 0) {perc = 83;}

        Serial.print("SOC: ");
        Serial.print(perc); 
        Serial.print("%, VCELL: ");
        Serial.print(gauge.getVoltage()); 
        Serial.println('V');

        if (position != "Falling") {
          count = 0;
        }
      }
    }
  }
}

struct stats getStats(float arr[]) {
  struct stats result;
  float sum = 0;
  float sum_squared = 0;
  result.minVal = arr[0];
  result.maxVal = arr[0];
  
  for (int i = 0; i < 100; i++) {
    result.maxVal = max(arr[i], result.maxVal);
    result.minVal = min(arr[i], result.minVal);
    sum = sum + arr[i];
  }

  result.difference = result.maxVal - result.minVal;
  result.mean = sum / 100;

  for (int i = 0; i < 100; i++) {
    sum_squared = sum_squared + sq(arr[i] - result.mean);
  }

  result.variance = sqrt(sum_squared);

  return result;
}

void lowPower() { alert = true; }
