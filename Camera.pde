public class Camera {
  Capture video;

  Camera() {
    // null
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
      video = new Capture(this, cameras[0]);
      video.start();     
    }
  }

  void captureEvent(Capture c) {
    c.read();
  }


  void display() {
    image(video, 0, height - video.height);
    stroke(255, 0, 0);
    noFill();
    rect(capturePosX, capturePosY, captureSize, captureSize); 
  }

  float getCenterValue () {
    float sum = 0;
    video.loadPixels();
    for(int y = capturePosY; y < capturePosY+captureSize; y++) {
      for(int x = capturePosX; x < capturePosX+captureSize; x++) {
        int i = x+y*w;
        float b = red(video.pixels[i]);
        sum+=b;
      }  
    }
    float average = sum/(captureSize*captureSize);
    return average;
  }
}
