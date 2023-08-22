public class Camera {
  Capture video;
  PApplet parent;
  
  int captureSize = 2;
  int capturePosX, capturePosY;
  int w,h;

  float FPS = 30.0;

  int [] capturedValues;

  PGraphics imageCapture;

  Camera(PApplet _parent) {
    // null
    this.parent = _parent;
  }
  
  void init() {
    String[] cameras = Capture.list();
    int cameraIndex = Arrays.asList(cameras).indexOf("OBS Virtual Camera");
    if (cameras.length == 0) {
      println("[Camera] There are no cameras available for capture.");
      exit();
    } else {
      println("[Camera] Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }
      // The camera can be initialized directly using an 
      // element from the array returned by list():
      if (cameraIndex == -1) {
        println("[Camera] No OBS Virtual Camera camera found, using default one instead");
        video = new Capture(this.parent, cameras[0], 30);
      } else {
        video = new Capture(this.parent, cameras[0], 30);
      }
      video.start();
    }
    w = video.width;
    h = video.height;
    imageCapture = createGraphics(w, h);

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
          println("update");
          video.read();
          imageCapture.image(video, 0, 0);
        }
      imageCapture.endDraw();
  
      setCenterValues(ammountReadingPoints);
  }


  void display() {

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
    stroke(0, 0, 255);
    rect((float(unitPixelSize)/w)*width, (float(unitPixelSize)/h)*height, (float(unitPixelSize)/w)*width, (float(unitPixelSize)/w)*width);

    for(int i = 0; i < capturedValues.length; i++) {
      int fy = capturePosY + (unitPixelSize * (i-ceil(capturedValues.length/2)));
      rect((float(capturePosX)/w)*width, (float(fy)/h)*height, captureSize, captureSize);
    }
    
    image(video, 0, 0, width, height);
  }

  int getCenterValue () {

    // crop image to load pixels only from the center
    PImage img = video.get(capturePosX, capturePosY, captureSize, captureSize); 
    float sum = 0;
    video.loadPixels();
    for(int y = capturePosY; y < capturePosY+captureSize; y++) {
      for(int x = capturePosX; x < capturePosX+captureSize; x++) {
        int i = x+y*w;
        float b = red(video.pixels[i]);
        sum+=b;
      }  
    }
    int average = floor(sum/(captureSize*captureSize));
    return average;
  }

  // only pairs
  void setCenterValues (int ammount) {
    imageCapture.loadPixels();
    int interval = 10;
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
}
