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

int threshold   = 150;
int small_steps = 250;
int big_steps   = 8000;

int threshold_default   = 150;
int small_steps_default = UNIT_STEPS;
int big_steps_default   = ROW_STEPS;

// for debuging
String [] states = {"IDLE","READING_ROW","READING_ROW_INVERSE","CHANGING_ROW","READING_UNIT"};

/* Debug variables */
boolean sendFakeData = false;

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
  gui.display();
  // constantly listening to events from arduino
  machineController.listenToSerialEvents();

  // display camera in interface
  cam.display();

  // display decoding interface
  decoder.update();
  decoder.display();

  // oscController.update();
}

/*
  ControlP5 listeners
*/
void threshold_slider (float value) {
  // on slider change
  threshold = floor(value);
}

void small_steps_slider (float value) {
  small_steps = floor(value);
  println("small_steps_slider", value, small_steps);
}
void big_steps_slider (float value) {
  big_steps = floor(value);
  println("big_steps_slider", value, big_steps);
}
/*
  ControlP5 Bang Buttons
*/

void read_row () {
  machineController.runRow();
}

// wasd movement keys
void keyPressed() {
  switch (key) {
    /* Movements */
    case 'w': machineController.moveY(small_steps); break;
    case 'a': machineController.moveX(small_steps); break;
    case 's': machineController.moveY(-small_steps); break;
    case 'd': machineController.moveX(-small_steps); break;
    /* big movements */
    case 'W': machineController.moveY(big_steps); break;
    case 'A': machineController.moveX(big_steps); break;
    case 'S': machineController.moveY(-big_steps); break;
    case 'D': machineController.moveX(-big_steps); break;
    /* end movements */
    case 'r': decoder.storeDataPoint(); break;
    case 'f': oscController.sendFinalAudio(); break;
  }
}