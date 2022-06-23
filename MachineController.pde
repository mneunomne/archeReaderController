class MachineController {
  Serial port;  // Create object from Serial class
  String val;     // Data received from the serial port

  int accumulated_x = 0;
  int accumulated_y = 0;

  MachineController(PApplet parent) {
    // null
    String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
    println("[SerialPort] SerialList: ", Serial.list());
    port = new Serial(parent, portName, 9600);    
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
    sendMovementCommand(dir, 500, 'x')
  }

  void moveY (int steps) {
    accumulated_y=+steps;
    char dir = steps > 0 ? '+' : '-';
    sendMovementCommand(dir, 500, 'y')
  }

  void moveDiagonally (int stepsX, int stepsY) {

  }

  void sendMovementCommand (char dir, int value, char axis) {
    // e.g.: +100x
    String s = dir + String.valueOf(value) + axis;
    println("[SerialPort] sending: " + s);
    port.write(s);
  }

  void onMovementOver () {
    // do something
    // how much delay?
  }

  void listenToSerialEvents () {
    if ( port.available() > 0)  {  // If data is available,
      val = port.readStringUntil('\n');         // read it and store it in val
      if (val.length() > 0) {
        println(val); //print it out in the console
        if (val.charAt(0) == "e") {
          // end
          println("movement over!");
          // sendMovementCommand('+', 500, 'y');
        }
      }
    }
  }
}