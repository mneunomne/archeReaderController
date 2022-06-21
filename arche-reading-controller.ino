#define STEP_PIN_X 2
#define DIR_PIN_X 5

#define STEP_PIN_Y 3
#define DIR_PIN_Y 6
// 88 -> 1mm
#define ENA_PIN 8

int c;
int v=0;

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
  while (Serial.available()) {
    c = Serial.read();
    // handle digits
    if ((c >= '0') && (c <= '9')) {
      v = 10 * v + c - '0';
    }
    // handle delimiter
    else if (c == 'e') {
      Serial.println(v);
      v = 0;
    }
  }
  
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
