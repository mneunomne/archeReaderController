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

// Macro States
static final int MACRO_IDLE               = 0;
static final int RUNNING_WASD_COMMAND     = 1;
static final int READING_UNIT             = 2;
static final int READING_ROW              = 3;
static final int RUNNING_PLATE            = 4;
static final int SENDING_FAKE_DATA        = 5;
int macroState = 0;
int [] macroStates = {"MACRO_IDLE","RUNNING_WASD_COMMAND","READING_UNIT","READING_ROW","RUNNING_PLATE","SENDING_FAKE_DATA"};

// Machine States
static final int MACHINE_IDLE         = 10;
static final int RUNNING_ROW_INVERSE  = 11;
static final int RUNNING_ROW          = 12;
static final int JUMPING_ROW          = 13;
static final int RUNNING_UNIT         = 14;
int machineState = 0;
int [] machineStates = {"MACHINE_IDLE","RUNNING_ROW_INVERSE","RUNNING_ROW","JUMPING_ROW","RUNNING_UNIT"};

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

void wasd_command (char key) {
  machineState = RUNNING_WASD_COMMAND;
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
  }
}

// wasd movement keys
void keyPressed() {
  switch (key) {
    /* Movements */
    case 'w': 
    case 'a': 
    case 's': 
    case 'd': 
    case 'W': 
    case 'A': 
    case 'S': 
    case 'D': wasd_command(key); break;
    /* end movements */
    case 'r': decoder.storeDataPoint(); break;
    case 'f': oscController.sendFinalAudio(); break;
  }
}