/**
 * Arche-Scripttures
 * Processing reading controller
 */
 
import controlP5.*;
import processing.video.*;
import processing.serial.*;

Gui gui;
Camera cam;
SerialPort mySerialPort;

int [] last_values = new int [100];

void setup() {
  size(640, 480);

  cam = new Camera(this);
  cam.init();

  mySerialPort = new SerialPort(this);

  // cp5 Graphic User Interface
  ControlP5 cp5 = new ControlP5(this);
  gui = new Gui(cp5);
  gui.init();
}

void captureEvent(Capture c) {
  c.read();
}

void draw() {
  background(0);

  // update gui chart with the value from the camera 
  float currentCameraValue = cam.getCenterValue();
  gui.updateChart(currentCameraValue);

  // constantly listening to events from arduino
  mySerialPort.listenToSerialEvents();

  // display camera in interface
  cam.display();
}

// wasd movement keys
void keyPressed() {
  switch (key) {
    case 'w': mySerialPort.sendMovementCommand('+', 500, 'y'); break;
    case 'a': mySerialPort.sendMovementCommand('-', 500, 'x'); break;
    case 's': mySerialPort.sendMovementCommand('-', 500, 'y'); break;
    case 'd': mySerialPort.sendMovementCommand('+', 500, 'x'); break;
  }
}