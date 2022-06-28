#define STEP_PIN_X 2
#define DIR_PIN_X 5

#define STEP_PIN_Y 3
#define DIR_PIN_Y 6

#define ENA_PIN 8

#define microX1 1
#define microX2 3
#define microX3 4

#define microY1 1
#define microY2 3
#define microY3 4

char c;

void setup() {
  Serial.begin(9600);
  
  pinMode(STEP_PIN_X,OUTPUT);
  pinMode(DIR_PIN_X,OUTPUT);
  pinMode(STEP_PIN_Y,OUTPUT);
  pinMode(DIR_PIN_Y,OUTPUT);
  pinMode(ENA_PIN,OUTPUT);
 
  start();
  
}
void loop() {
  String chars = "";
  if (Serial.available()) {
    String s = Serial.readString();
    // Serial.println("string: " + s);
    // Serial.println("first char: " + s[0]);
    int steps=0;
    int dir=0;
    char axis=' ';

    // get direction
    if (s[0] == '+') {
      dir = 1;
    } else if (s[0] == '-'){
      dir = -1;
    } else {
      return;
    }

    axis = s[max(s.indexOf('y'), s.indexOf('x'))];
    
    // only continue if got dir value
    if (dir != 0) {
      String v = "";
      for (int i = 1; i < max(s.indexOf('y'), s.indexOf('x')); i++) {
        v += s[i];
      }
      steps = v.toInt();
    }
    // send start message to processing
    Serial.println("s");
    // move
    if (axis == 'x') {
      moveX(steps, dir);
    } else if (axis == 'y') {
      moveY(steps, dir);
    } else {
      return;
    }
    // send end message to processing
    Serial.println("e");
  }
}

void start () {
  digitalWrite(ENA_PIN,LOW); // enable motor HIGH -> DISABLE
  digitalWrite(ENA_PIN,LOW); // enable motor HIGH -> DISABLE
  // moveX(100, 1);
}

void moveX (int steps, int dir) {
  if (dir > 0) {
      digitalWrite(DIR_PIN_X,LOW); // enable motor HIGH -> DISABLE
  } else {
      digitalWrite(DIR_PIN_X,HIGH); // enable motor HIGH -> DISABLE
  }
  for (int i = 0; i < steps; i++) {
    digitalWrite(STEP_PIN_X,HIGH);
    delayMicroseconds(1);
    digitalWrite(STEP_PIN_X,LOW);
    delay(1);
  }
}

void moveY (int steps, int dir) {
  if (dir > 0) {
      digitalWrite(DIR_PIN_Y,LOW); // enable motor HIGH -> DISABLE
  } else {
      digitalWrite(DIR_PIN_Y,HIGH); // enable motor HIGH -> DISABLE
  }
  for (int i = 0; i < steps; i++) {
    digitalWrite(STEP_PIN_Y,HIGH);
    delayMicroseconds(1);
    digitalWrite(STEP_PIN_Y,LOW);
    delay(1);
  }
}
