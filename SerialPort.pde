class SerialPort {
  Serial port;  // Create object from Serial class
  String val;     // Data received from the serial port

  SerialPort(PApplet parent) {
    // null
    String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
    println("[SerialPort] SerialList: ", Serial.list());
    port = new Serial(parent, portName, 9600);    
  }

  void init () {
    
  }

  void sendMovementCommand (char dir, int value, char axis) {
    // e.g.: +100x
    String s = dir + String.valueOf(value) + axis;
    println("[SerialPort] sending: " + s);
    port.write(s);
  }
  void listenToSerialEvents () {
    if ( port.available() > 0)  {  // If data is available,
      val = port.readStringUntil('\n');         // read it and store it in val
      if (val.length() > 0) {
        print(val + " "); //print it out in the console
      }
    }  
  }
}