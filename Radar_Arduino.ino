#include <Servo.h>

const int trigPin = 11;
const int echoPin = 9;

Servo myServo;

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(9600);
  myServo.attach(12);
}

void loop() {
  for(int i = 15; i <= 165; i++) {
    unsigned long stepStart = millis();
    
    myServo.write(i);
    int distance = calculateDistance();
    
    Serial.print(i);
    Serial.print(",");
    Serial.print(distance);
    Serial.println(".");
    
    unsigned long timeTaken = millis() - stepStart;
    if (timeTaken < 33) {
      delay(33 - timeTaken);
    }
  }
  
  for(int i = 165; i > 15; i--) {
    unsigned long stepStart = millis();
    
    myServo.write(i);
    int distance = calculateDistance();
    
    Serial.print(i);
    Serial.print(",");
    Serial.print(distance);
    Serial.println(".");
    
    unsigned long timeTaken = millis() - stepStart;
    if (timeTaken < 33) {
      delay(33 - timeTaken);
    }
  }
}

int calculateDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(10);
  
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  long duration = pulseIn(echoPin, HIGH, 24000);
  
  if (duration == 0) {
    return 400;
  }
  
  return duration * 0.034 / 2;
}