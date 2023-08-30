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
        video = new Capture(this.parent, cameras[0]);
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
      imageCapture.beginDraw();
        imageCapture.imageMode(CENTER);
        imageCapture.translate(imageCapture.width/2, imageCapture.height/2);
        // imageCapture.rotate(radians(270));
        if (video.available()) {
          video.read();
        }
      imageCapture.endDraw();
  
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
    stroke(255, 0, 0);
    noFill();
    // capture
    // unitPixelSize
    pushStyle();
    rectMode(CENTER);
    // stroke(0, 0, 255, 0);
    noFill();
    // ?
    rect((float(unitPixelSize)/w)*width, (float(unitPixelSize)/h)*height, (float(unitPixelSize)/w)*width, (float(unitPixelSize)/w)*width);
    for(int i = 0; i < capturedValues.length; i++) {
      int fy = capturePosY + (unitPixelSize * (i-ceil(capturedValues.length/2)));
      stroke(255-capturedValues[i]);
      rect((float(capturePosX)/w)*width, (float(fy)/h)*height, unitPixelSize*2-2, unitPixelSize*2-2);
    }
    popStyle();
    
  }

  int getCenterValue () {

    // crop image to load pixels only from the center
    PImage img = video.get(capturePosX, capturePosY, captureSize, captureSize); 
    float sum = 0;
    img.loadPixels();
    for(int y = capturePosY; y < capturePosY+captureSize; y++) {
      for(int x = capturePosX; x < capturePosX+captureSize; x++) {
        int i = x+y*w;
        float b = red(img.pixels[i]);
        sum+=b;
      }  
    }
    int average = floor(sum/(captureSize*captureSize));
    return average;
  }

  // only pairs
  void setCenterValues (int ammount) {
    imageCapture.loadPixels();
    int [] values = new int[ammount];
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