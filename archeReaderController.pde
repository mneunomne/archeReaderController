/**
 * Arche-Scripttures
 * Processing reading controller
 */

import java.util.*;
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

int UNIT_STEPS = 88;
int ROW_STEPS = 16725;
int COLS_STEPS = 23083;

int PLATE_ROWS = 265;
int PLATE_COLS = 192;

static int MARGIN = 10;

// Macro States
static final int MACRO_IDLE                 = 0;
static final int RUNNING_WASD_COMMAND       = 1;
static final int READING_UNIT               = 2;
static final int READING_ROW                = 3;
static final int READING_ROW_INVERSE        = 4;
static final int READING_PLATE              = 5;
static final int STOP_MACHINE               = 6;
static final int RETURNING_TOP              = 7;
int macroState = 0;
String [] macroStates = {"MACRO_IDLE","RUNNING_WASD_COMMAND","READING_UNIT","READING_ROW","READING_ROW_INVERSE","READING_PLATE", "STOP_MACHINE", "RETURNING_TOP"};

// Machine States
static final int MACHINE_IDLE               = 0;
static final int RUNNING_ROW_INVERSE        = 1;
static final int RUNNING_ROW                = 2;
static final int JUMPING_ROW                = 3;
static final int RUNNING_UNIT               = 4;
static final int RUNNING_WASD               = 5;
int machineState = 0;
String [] machineStates = {"MACHINE_IDLE","RUNNING_ROW_INVERSE","RUNNING_ROW","JUMPING_ROW","RUNNING_UNIT", "RUNNING_WASD"};

// Decoder States
static final int DECODER_IDLE               = 0;
static final int READING_ROW_DATA           = 1;
static final int READING_ROW_DATA_INVERTED  = 2;
static final int SENDING_FAKE_DATA          = 3;
int decoderState = 0;
String [] decoderStates = {"DECODER_IDLE","READING_ROW_DATA","READING_ROW_DATA_INVERTED", "SENDING_FAKE_DATA"};

// Camera States
static final int CAMERA_IDLE                = 0;
static final int READ_CENTER_VALUE          = 1;
static final int READ_MULTIPLE_VALUES       = 2;
int cameraState = 0;
String [] cameraStates = {"CAMERA_IDLE","READ_CENTER_VALUE","READ_MULTIPLE_VALUES"};

int threshold   = 150;
int small_steps = 250;
int big_steps   = 8000;
int current_row_index = 0;

// ArrayList<Integer> currentRowIndexes = new ArrayList<Integer>(); 

int small_steps_default = UNIT_STEPS;
int big_steps_default   = ROW_STEPS;
int reading_points_default = 7; 
int ammountReadingPoints = 7; 
int threshold_default   = 150;
int lastDir = 0; 

/* Debug variables */
boolean sendFakeData = false;

PFont myFont;

void setup() {
  size(800, 600);

  cam = new Camera(this);
  cam.init();

  machineController = new MachineController(this);

  ControlP5 cp5 = new ControlP5(this);
  gui = new Gui(cp5);
  gui.init();

  decoder = new Decoder();

  oscController = new OscController();
  oscController.connect();

  myFont = createFont("PTMono-Regular", 9);
  textFont(myFont);
  // printArray(PFont.list());
}

void captureEvent(Capture c) {
  c.read();
}

void draw() {
  background(0);

  // constantly listening to events from arduino
  machineController.listenToSerialEvents();

  // display camera in interface
  cam.update();
  cam.display();

  // update gui chart with the value from the camera 
  // gui.updateChart(currentCameraValue);
  
  gui.updateCharts(cam.getCenterValues());
  gui.display();

  // display decoding interface
  decoder.update();
  decoder.display();

  // oscController.update();
}

/*
  ControlP5 listeners
*/
void threshold_slider (float value) {
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

void reading_points_slider (float value) {
  ammountReadingPoints = int(value);
}

/*
  ControlP5 Bang Buttons
*/

void read_row_inverse () {
  macroState = READING_ROW_INVERSE;
  machineController.runRowInverse();
}

void read_row () {
  macroState = READING_ROW;
  machineController.runRow();
}

void read_plate () {
  macroState = READING_PLATE;
  machineController.runRow();
}

void stop_machine () {
  macroState = STOP_MACHINE;
}

void wasd_command (char key) {
  macroState = RUNNING_WASD_COMMAND;
  machineState = RUNNING_WASD;
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