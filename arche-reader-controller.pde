/**
 * Arche-Scripttures
 * Processing reading controller
 */
 
import controlP5.*;
import processing.video.*;
import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port

ControlP5 cp5;

Chart myChart;

Capture video;
boolean cheatScreen;

// All ASCII characters, sorted according to their visual density
String letterOrder =
  " .`-_':,;^=+/\"|)\\<>)iv%xclrs{*}I?!][1taeo7zjLu" +
  "nT#JCwfy325Fp6mqSghVd4EgXPGZbYkOA&8U$@KHDBWNMR0Q";
char[] letters;

float[] bright;
char[] chars;

PFont font;
float fontSize = 1.5;

int captureSize = 2;
int capturePosX, capturePosY;
int w,h;

int [] last_values = new int [100];

float averageBrightness;

void setup() {
  size(640, 480);
  
  String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  println(Serial.list());
  myPort = new Serial(this, portName, 9600);
  
  String[] cameras = Capture.list();
  
  for (int i = 0; i < last_values.length; i++) {
    last_values[i] = 0;
  }
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    video = new Capture(this, cameras[0]);
    video.start();     
  }
  
  w = video.width;
  h = video.height;
  
  capturePosX = w/2-captureSize/2;
  capturePosY = h/2-captureSize/2;
  
  cp5 = new ControlP5(this);
  cp5.setColorForeground(color(255, 80));
  cp5.setColorBackground(color(255, 20));
  
  myChart = cp5.addChart("dataflow")
  .setPosition(0, 0)
  .setSize(200, 100)
  .setRange(0, 255)
  .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
  .setStrokeWeight(1.5)
  .setColorBackground(color(20))
  .setColorForeground(color(255))
  .setColorCaptionLabel(color(255))
  ;
  myChart.addDataSet("incoming");
  myChart.setData("incoming", new float[100]);
}

void captureEvent(Capture c) {
  c.read();
}


void draw() {
  background(0);

  video.loadPixels();
  
  int sum = 0;
  for(int y = capturePosY; y < capturePosY+captureSize; y++) {
    for(int x = capturePosX; x < capturePosX+captureSize; x++) {
      int i = x+y*w;
      float b = red(video.pixels[i]);
      sum+=b;
    }  
  }
  float average = sum/(captureSize*captureSize);
  myChart.push("incoming", average);

  
  image(video, 0, height - video.height);
  
  stroke(255, 0, 0);
  noFill();
  rect(capturePosX, capturePosY, captureSize, captureSize); 
  
  listenToSerialEvents();
}

void listenToSerialEvents () {
    if ( myPort.available() > 0)  {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
     if (val.length() > 0) {
      print(val + " "); //print it out in the console
    }
  } 
  
}


void drawGraph () {
 for (int i = 0; i < last_values.length; i++) {
   
 }
}

void sendMovementArduino (String s) {
  println("now sending: " + s);
  myPort.write(s);
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