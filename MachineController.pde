class MachineController {
  Serial port;  // Create object from Serial class
  String val;     // Data received from the serial port

  int accumulated_x = 0;
  int accumulated_y = 0;

  boolean isRunning;

  int current_row_index = 0;

  String lastMovement;


  int UNIT_STEPS = 88;
  int ROW_STEPS = 16725;
  int COLS_STEPS = 23083;

  MachineController(PApplet parent) {
    // null
    print("[SerialPort] SerialList: ");
    printArray(Serial.list());
    String portName = Serial.list()[6]; //change the 0 to a 1 or 2 etc. to match your port
    port = new Serial(parent, portName, 9600);    
  }

  void startReading () {
    isRunning = true;
  }

  void readRow () {
    // moveX()
  }

  void setInitialPosition () {
    accumulated_x = 0;
    accumulated_y = 0;
  }

  void goBackToInitialPosition () {
    moveDiagonally(-accumulated_x, -accumulated_y);
  }

  void moveX (int steps) {
    accumulated_x=+steps;
    char dir = steps > 0 ? '+' : '-';
    sendMovementCommand(dir, abs(steps), 'x');
  }

  void moveY (int steps) {
    accumulated_y=+steps;
    char dir = steps > 0 ? '+' : '-';
    sendMovementCommand(dir, abs(steps), 'y');
  }

  void moveDiagonally (int stepsX, int stepsY) {}

  void sendMovementCommand (char dir, int value, char axis) {
    // e.g.: +100x
    String s = dir + String.valueOf(value) + axis;
    lastMovement = s; 
    println("[SerialPort] sending: " + s);
    port.write(s);
  }

  void onMovementOver () {
    // do something
    // how much delay?
  }

  void runRow () {
    machineState = RUNNING_ROW;
    moveX(ROW_STEPS);
  }
  
  void runRowInverse () {
    machineState = RUNNING_ROW_INVERSE;
    moveX(-ROW_STEPS);
  }

  void jumpRow () {
    machineState = RUNNING_ROW;
    moveY(UNIT_STEPS);
  }

  void runPlate () {
    machineState = RUNNING_ROW;
    moveX(ROW_STEPS);
  }

  void listenToSerialEvents () {
    if ( port.available() > 0)  {  // If data is available,
      val = port.readStringUntil('\n');         // read it and store it in val
      if (val.length() > 0) {
        println(val); //print it out in the console
        if (val.charAt(0) == 'e') {
          // end
          println("movement over: ", lastMovement);
          // sendMovementCommand('+', 500, 'y');
          onMovementEnd();
        }
      }
    }
  }

  void onMovementEnd () {
    switch (macroState) {
      case RUNNING_WASD_COMMAND:
        macroState = MACRO_IDLE; break;
    }
  }
}