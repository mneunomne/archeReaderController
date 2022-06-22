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

  cam = new Camera();
  cam.init();

  mySerialPort = new SerialPort();

  // cp5 Graphic User Interface
  ControlP5 cp5 = new ControlP5(this);
  gui = new Gui(cp5);
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


/**
 * Handle key presses:
 * 'c' toggles the cheat screen that shows the original image in the corner
 * 'g' grabs an image and saves the frame to a tiff image
 * 'f' and 'F' increase and decrease the font size
 */
void keyPressed() {
  switch (key) {
    case 'w': sendMovementArduino("+500y"); break;
    case 'a': sendMovementArduino("-500x"); break;
    case 's': sendMovementArduino("-500y"); break;
    case 'd': sendMovementArduino("+500x"); break;
  }
}