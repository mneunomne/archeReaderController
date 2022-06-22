class SerialPort {
  Serial port;  // Create object from Serial class
  String val;     // Data received from the serial port

  SerialPort() {
    // null    
  }

  void init () {
    String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
    println("[SerialPort] SerialList: ", Serial.list());
    port = new Serial(this, portName, 9600);
  }

  void sendMovementCommand (char axis, int dir, int value) {
    // e.g.: +100x
    String s = (dir > 0 ? '+' : '-') + value + axis;
    println("[SerialPort] sending: " + s);
    port.write(s);
  }
}

void listenToSerialEvents () {
    if ( port.available() > 0)  {  // If data is available,
    val = port.readStringUntil('\n');         // read it and store it in val
     if (val.length() > 0) {
      print(val + " "); //print it out in the console
    }
  }  
}