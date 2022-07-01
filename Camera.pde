public class Camera {
  Capture video;
  PApplet parent;
  
  int captureSize = 2;
  int capturePosX, capturePosY;
  int w,h;

  int [] capturedValues;

  Camera(PApplet _parent) {
    // null
    parent = _parent;
  }
  
  void init() {
    String[] cameras = Capture.list();
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
      video = new Capture(parent, cameras[1]);
      video.start();
    }
    w = video.width;
    h = video.height;
    capturePosX = w/2-captureSize/2;
    capturePosY = h/2-captureSize/2;
    println("[Camera] video size", w, h);
  }  

  void update () {
    setCenterValues(ammountReadingPoints);
  }


  void display() {

    float scale = float(height) / video.width;
    float prop = video.width/video.height;
    float video_w = height;
    float video_h =  video_w / prop;

    tint(255, 0, 0);
    imageMode(CENTER);
    pushMatrix(); // remember current drawing matrix)
    translate(width/2, height/2);
    rotate(radians(270));
    image(video, 0, 0, video_w, video_h);
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
  }

  int getCenterValue () {
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
    int interval = 10;
    int [] values = new int[ammount];
    for(int y = capturePosY; y < capturePosY+captureSize; y++) {
      for(int x = capturePosX; x < capturePosX+captureSize; x++) {
        for (int i = 0; i < ammount; i++) {
          int ix = i-ammount/2;
          int fx = x+(ix*unitPixelSize);
          int index = fx+y*w;
          float b = red(video.pixels[index]);
          values[i] = floor(b);
        }
      }  
    }
    capturedValues = values;
  }

  int [] getCenterValues () {
    return capturedValues;
  }
}
