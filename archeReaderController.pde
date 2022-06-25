/**
 * Arche-Scripttures
 * Processing reading controller
 */
 
import controlP5.*;
import processing.video.*;
import processing.serial.*;
import netP5.*;
import oscP5.*;

Gui gui;
Camera cam;
MachineController machineController;
Decoder decoder; 
OscController oscController;

int [] last_values = new int [100];

/* GLOBALS */
String MAX_ADDRESS = "10.10.48.121";
int MAX_PORT = 12000;

int STEPS_FOR_EACH_POINT = 88;
int ROWS;
int COLS; 

int threshold = 150;

/* Debug variables */
boolean sendFakeData = false 

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
  oscController.connect();
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
  machineController.listenToSerialEvents();

  // display camera in interface
  cam.display();

  // display decoding interface
  decoder.update();
  decoder.display();

  oscController.update();
}

void threshold_slider (float value) {
  // on slider change
  threshold = floor(value);
}

// wasd movement keys
void keyPressed() {
  switch (key) {
    case 'w': machineController.moveY(500); break;
    case 'a': machineController.moveX(-500); break;
    case 's': machineController.moveY(-500); break;
    case 'd': machineController.moveX(500); break;
    case 'r': decoder.storeDataPoint(); break;
    case 'f': oscController.sendFinalAudio(); break;
  }
}