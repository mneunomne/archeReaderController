/**
 * Arche-Scripttures
 * Processing reading controller
 */
 
import controlP5.*;
import processing.video.*;
import processing.serial.*;

Gui gui;
Camera cam;
MachineController machineController;
Decoder decoder; 
OscController oscController;

int [] last_values = new int [100];

/* GLOBALS */
String MAX_ADDRESS = "10.10.48.164";
int MAX_PORT = 12000;

void setup() {
  size(640, 480);

  cam = new Camera(this);
  cam.init();

  machineController = new MachineController(this);

  ControlP5 cp5 = new ControlP5(this);
  gui = new Gui(cp5);
  gui.init();

  decoder = new Decoder();

  oscController = new OscController();
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

  // display decoding interface
  decoder.display();
}

// wasd movement keys
void keyPressed() {
  switch (key) {
    case 'w': machineController.moveY(500); break;
    case 'a': machineController.moveX(-500); break;
    case 's': machineController.moveY(-500); break;
    case 'd': machineController.moveX(500); break;
  }
}