class MachineController {
  Serial port;  // Create object from Serial class
  String val;     // Data received from the serial port
  int accumulated_x = 0;
  int accumulated_y = 0;
  boolean isRunning;
  String lastMovement;

  int timeStarted=0;

  int nextInterval=500; // in millis

  int readingRowInterval = 5000;

  int timeFinnishedRow=0;

  boolean rowDelay = false; 

  int portIndex = 1;

  int pictureIndex = 0;  

  char nextDir = '+';

  boolean noMachine = false;

  MachineController(PApplet parent, boolean _noMachine) {
    // if no machine, don't connect to serial
    noMachine = _noMachine;
    if (noMachine) return; 
    // Connect to Serial
    print("[MachineController] SerialList: ");
    printArray(Serial.list());
    String portName = Serial.list()[portIndex]; //change the 0 to a 1 or 2 etc. to match your port
    port = new Serial(parent, portName, 9600);    
  }

  void update () {
    // add a delay before reading next row
    if (rowDelay) {
      if (millis() >= timeFinnishedRow+readingRowInterval) {
        jumpRow();
        rowDelay=false;
      }
    }
  }

  void startReading () {
    isRunning = true;
  }

  void setInitialPosition () {
    accumulated_x = 0;
    accumulated_y = 0;
  }

  void goBackToInitialPosition () {
    moveDiagonally(-accumulated_x, -accumulated_y);
  }

  void moveX (int steps) {
    this.accumulated_x = this.accumulated_x+steps;
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
    println("[MachineController] sending: " + s);
    port.write(s);
  }

  void returnToTop () {
    println("returnToTop!");
    machineState = RETURNING_TOP;
    moveY(-UNIT_STEPS*current_row_index);
    current_row_index=0;
  }

  void runRow () {
    lastDir = 1;
    machineState = RUNNING_ROW;
    moveX(ROW_STEPS);
  }
  
  void runRowInverse () {
    lastDir = -1;
    machineState = RUNNING_ROW_INVERSE;
    moveX(-ROW_STEPS);
  }

  void jumpRow () {
    current_row_index+=ammountReadingPoints;
    machineState = JUMPING_ROW;
    moveY(UNIT_STEPS * ammountReadingPoints);
  }

  void runPictureSteps() {
    pictureIndex = 0;
    setInitialPosition();
    machineState = RUNNING_PICTURE_STEPS;
    cam.saveImage(accumulated_x, accumulated_y, pictureIndex);
    moveX(PICTURE_STEPS);
  }

  void runPlate () {
    if (ammountReadingPoints > 1) {
      // need to move the camera down before it starts
    } else {
      setInitialPosition();
      machineState = READING_PLATE;
      moveX(ROW_STEPS);
    }
  }

  void listenToSerialEvents () {
    if ( port.available() > 0)  {  // If data is available,
      val = port.readStringUntil('\n');         // read it and store it in val
      if (val.length() > 0) {
        char c = val.charAt(0);
        println("[MachineController] listenToSerialEvents", c); //print it out in the console
        // start
        switch (c) {
          case 's': // start
            println("[MachineController] movement start", macroStates[macroState]);
            onMovementStart();
            break;
          case 'e': // end
            println("[MachineController] movement over: ", lastMovement);
            if (lastMovement == null) return; // sometimes there is leftover event coming from arduino
            onMovementEnd();
            break;
        }
      }
    }
  }

  void onMovementStart () {
    timeStarted=millis();
    switch (macroState) {
      case READING_ROW:
      case READING_ROW_INVERSE:
      case READING_PLATE:
      switch (machineState) {
        case RUNNING_ROW_INVERSE:
          // interpret signal
          decoder.startReadingRowInverted();
          break;
        case RUNNING_ROW:
          // interpret signal
          decoder.startReadingRow();
          break;
      }
    }
  }

  void onMovementEnd () {
    int timeSpent = millis()-timeStarted;
    timeFinnishedRow = millis();
    switch (macroState) {
      case STOP_MACHINE:
      case RUNNING_WASD_COMMAND:
        // after these events, no reading is involved
        macroState = MACRO_IDLE;
        machineState = MACHINE_IDLE;
        break;
      case READING_ROW:
        // interpret signal and push to database? (or does this happen live)
        macroState = MACRO_IDLE;
        machineState = MACHINE_IDLE;
        decoder.endReading(false);
        break;
      case READING_ROW_INVERSE:
        // interpret signal inverted
        macroState = MACRO_IDLE;
        machineState = MACHINE_IDLE;
        decoder.endReading(true);
        break;
      case READING_PLATE:
        onMovementEndReadingPlate();
        break;
      case TAKE_PICTURES:
        println("accumulated_x: " + accumulated_x + " accumulated_y: " + accumulated_y);
        pictureIndex+=1;
        // wait half a second
        cam.saveImage(abs(accumulated_x), accumulated_y, pictureIndex);
        if (abs(accumulated_x) < ROW_STEPS) {
          if (nextDir == '+') {
            moveX(PICTURE_STEPS);
          } else {
            moveX(-PICTURE_STEPS);
          }
        } else if (accumulated_y < COLS_STEPS){
          accumulated_x=0;
          nextDir = nextDir == '+' ? '-' : '+';
          moveY(int(PICTURE_STEPS/2));
        } else {
          macroState = MACRO_IDLE;
          machineState = MACHINE_IDLE;
        }
        break;
    }
  }

  void onMovementEndReadingPlate () {
    switch (machineState) {
      case RUNNING_ROW_INVERSE:
        // interpret signal
        // jump to next row
        if (current_row_index < PLATE_ROWS-1) {
          //jumpRow();
          rowDelay=true;
        } else {
          returnToTop();
        }
        decoder.endReading(true); // is inverted
        break;
      case RUNNING_ROW:
        // interpret signal
        // jump to next row
        if (current_row_index < PLATE_ROWS) {
          //jumpRow();
          rowDelay=true;
        } else {
          returnToTop();
        }
        decoder.endReading(false); // is inverted
        break;
      case JUMPING_ROW: 
        if (lastDir < 0) {
          runRow();
        } else {
          runRowInverse();
        }
        break;
      case RETURNING_TOP:
        if (lastDir < 0) {
          runRow();
        } else {
          runRowInverse();
        }
        break; 
    }
  }
}
