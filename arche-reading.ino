#define STEP_PIN_X 2
#define DIR_PIN_X 5

#define STEP_PIN_Y 3
#define DIR_PIN_Y 6
// 88 -> 1mm
#define ENA_PIN 8

void setup() {
  Serial.begin(9600);
  
  pinMode(STEP_PIN_X,OUTPUT);
  pinMode(DIR_PIN_X,OUTPUT);
  pinMode(STEP_PIN_Y,OUTPUT);
  pinMode(DIR_PIN_Y,OUTPUT);
  pinMode(ENA_PIN,OUTPUT);
 
  init();
  
}
void loop() {
  Serial.println("Hello, world!");
  
  // put your main code here, to run repeatedly:
  /*
  digitalWrite(ENA_PIN_X,HIGH); // enable motor HIGH -> DISABLE
  delay(5);
  digitalWrite(ENA_PIN_X,LOW); // enable motor HIGH -> DISABLE
  delay(5);
  */
}

void init () {
  digitalWrite(ENA_PIN,LOW); // enable motor HIGH -> DISABLE
  digitalWrite(ENA_PIN,LOW); // enable motor HIGH -> DISABLE
  Serial.println("start");
}

void moveX (int steps, int dir) {
  if (dir > 0) {
      digitalWrite(DIR_PIN_X,HIGH); // enable motor HIGH -> DISABLE
  } else {
      digitalWrite(DIR_PIN_X,LOW); // enable motor HIGH -> DISABLE
  }
  for (int i = 0; i < steps; i++) {
    digitalWrite(STEP_PIN_Y,HIGH);
    delayMicroseconds(1);
    digitalWrite(STEP_PIN_Y,LOW);
    delay(5);
  }
}

void moveY (int steps, int dir) {
  if (dir > 0) {
      digitalWrite(DIR_PIN_Y,HIGH); // enable motor HIGH -> DISABLE
  } else {
      digitalWrite(DIR_PIN_Y,LOW); // enable motor HIGH -> DISABLE
  }
  for (int i = 0; i < steps; i++) {
    digitalWrite(STEP_PIN_Y,HIGH);
    delayMicroseconds(1);
    digitalWrite(STEP_PIN_Y,LOW);
    delay(5);
  }
}
