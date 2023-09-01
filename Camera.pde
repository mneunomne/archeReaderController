public class Camera {
  Capture video;
  PApplet parent;

  PImage rawImage;
  
  int captureSize = 2;
  int capturePosX, capturePosY;
  int w,h;

  float FPS = 30.0;

  int [] capturedValues;

  PGraphics imageCapture;
  
  int cameraW = 1600;
  int cameraH = 1200;

  PImage cropped;

  String cameraName = "OBS Virtual Camera";

  Camera(PApplet _parent) {
    // null
    this.parent = _parent;
  }
  
  void init() {
    String[] cameras = Capture.list();
    int cameraIndex = Arrays.asList(cameras).indexOf(cameraName);
    if (cameras.length == 0) {
      println("[Camera] There are no cameras available for capture.");
      exit();
    } else {
      println("[Camera] Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(i, cameras[i]);
      }
      // The camera can be initialized directly using an 
      // element from the array returned by list():
      if (cameraIndex == -1) {
        println("[Camera] No OBS Virtual Camera camera found, using default one instead");
        video = new Capture(this.parent, cameras[0], 30);
      } else {
        video = new Capture(this.parent, 1080, 1920, cameras[cameraIndex], 30);
      }
      video.start();
    }
    w = video.width;
    h = video.height;
    imageCapture = createGraphics(w, h, P2D);

    capturePosX = imageCapture.width/2-captureSize/2;
    capturePosY = imageCapture.height/2-captureSize/2;
    println("[Camera] video size", w, h);
  }  

  void update () {
    if (video.available()) {
      video.read();
    }
    setCenterValues(ammountReadingPoints);  
  }


  void display() {
    
    imageCapture.beginDraw();
      imageCapture.imageMode(CENTER);
      imageCapture.translate(imageCapture.width/2, imageCapture.height/2);
      // imageCapture.rotate(radians(270));
      imageCapture.image(video, 0, 0, width, height);
    imageCapture.endDraw();

    float scale = float(height) / video.width;
    float prop = video.width/video.height;
    float video_w = width;
    float video_h =  height;

    tint(255, 0, 0);
    imageMode(CENTER);
    pushMatrix(); // remember current drawing matrix)
      translate(width/2, height/2);
      image(imageCapture, 0, 0, video_w, video_h);
    popMatrix();
    //filter(THRESHOLD, float(threshold)/255);
    // capture
    // unitPixelSize
    if (showCentralSquares) {
      pushStyle();
        rectMode(CENTER);
        noFill();      
        for(int i = 0; i < capturedValues.length; i++) {
          int fy = capturePosY + (unitPixelSize * (i-ceil(capturedValues.length/2)));
          stroke(255-capturedValues[i]);
          rect((float(capturePosX)/w)*width, (float(fy)/h)*height, unitPixelSize, unitPixelSize);
        }
      popStyle();
    }
    if (showCentralCross) {
      pushStyle();
      for(int i = 0; i < capturedValues.length; i++) {
        int y = height/2 + (unitPixelSize * (i-ceil(capturedValues.length/2)));
        int x = width/2;
        stroke(255-capturedValues[i]);
        line(x-unitPixelSize/2, y, x+unitPixelSize/2, y);
        line(x, y-unitPixelSize/2, x, y+unitPixelSize/2);
      }
    }
  }

  // only pairs
  void setCenterValues (int ammount) {
    // PImage cropped = imageCapture.get(width/2-unitPixelSize, height/2-int(float(unitPixelSize*ammount)/2), unitPixelSize*2, unitPixelSize*2 * ammount);
    int [] values = new int[ammount];
    imageCapture.loadPixels();
    for(int y = capturePosY; y < capturePosY+captureSize; y++) {
      for(int x = capturePosX; x < capturePosX+captureSize; x++) {
        for (int i = 0; i < ammount; i++) {
          int ix = i-ammount/2;
          int fy = y+(ix*unitPixelSize);
          int index = x+fy*w;
          float b = red(imageCapture.pixels[index]);
          values[i] = floor(b);
        }
      }  
    }
    capturedValues = values;
  }


  void sendLiveFeed(float perc_x, float perc_y) {
    int feedW = int(w/10);
    int feedH = int(h/10);
    PGraphics liveFeed = createGraphics(int(w/10), int(h/10));
    liveFeed.beginDraw();
    liveFeed.background(255, 0, 0);
    liveFeed.image(video, 0, 0);
    liveFeed.endDraw();
    // image from PGrahics
    // PImage img = liveFeed.get();
    int x = int(perc_x * PLATE_COLS);
    int y = int(perc_y * PLATE_ROWS);
  }

  int [] getCenterValues () {
    return capturedValues;
  }

  void takePicture() {
    // save with current frameCount
    String filename = "photo_"+frameCount+".png";
    imageCapture.save(filename);
  }

  void saveImage(int posX, int posY, int index) {
    String filename = "photos/"+index+"_"+posX+"_"+posY+".png";
    // rawImage.save(filename);
    imageCapture.save(filename);
  }
}
