public class Camera {
  Capture video;
  PApplet parent;
  
  int captureSize = 2;
  int capturePosX, capturePosY;
  int w,h;

  int unitPixelSize = 8;

  Camera(PApplet _parent) {
    // null
    parent = _parent;
  }
  
  void init() {
    String[] cameras = Capture.list();
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
      video = new Capture(parent, cameras[1]);
      video.start();
    }

    w = video.width;
    h = video.height;

    println("video size", w, h);
    
    capturePosX = w/2-captureSize/2;
    capturePosY = h/2-captureSize/2;
  }


  void display() {
    image(video, 0, 0, width, height);
    stroke(255, 0, 0);
    noFill();
    // capture
    rect((float(capturePosX)/w)*width, (float(capturePosY)/h)*height, (float(captureSize)/w)*width, (float(captureSize)/w)*width);
    // unitPixelSize
    stroke(0, 0, 255);
    rect((float(unitPixelSize)/w)*width, (float(unitPixelSize)/h)*height, (float(unitPixelSize)/w)*width, (float(unitPixelSize)/w)*width); 
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
  int [] getCenterValues (int ammount) {
    int interval = 10;
    int [] values = new int[ammount];
    for(int y = capturePosY; y < capturePosY+captureSize; y++) {
      for(int x = capturePosX; x < capturePosX+captureSize; x++) {
        for (int i = -ammount/2; i < ammount/2; i++) {
          int fy = y+(i*unitPixelSize);
          int index = x+fy*w;
          float b = red(video.pixels[index]);
        }
      }  
    }
    return matrix;
  }
}
