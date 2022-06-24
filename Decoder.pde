public class Decoder {
  int cols=192;
  int rows=266;
  int length = 51040;
  
  int [] bits = new int[length];

  int grid_width=cols;
  int grid_height=rows;

  PGraphics pg;

  // original numbers audioloadJSONArray
  JSONArray originalNumbersJSON;
  int [] originalNumbers;

  int currentLiveValue = 0; 

  Decoder () {
    pg = createGraphics(width, height);
    for (int i = 0; i < length; i++) bits[i] = random(100) > 50 ? 1 : 0;
    pg.beginDraw();
    pg.background(100);
    pg.endDraw();
    // load original numbers
    originalNumbersJSON = loadJSONArray("data/data_numbers.json");
    originalNumbers = new int[originalNumbersJSON.size()];
    for (int i = 0; i < originalNumbersJSON.size(); i++) {
      originalNumbers[i] = originalNumbersJSON.getInt(i);
    }
    println("originalNumbers", originalNumbers);
  }

  void storeDataPoint () {
    oscController.sendOscAccumulatedData()
  }

  void interpretSignalArray () {

  }

  void update () {
    currentLiveValue = cam.getCenterValue();
  }

  void display () {
    render_grid();
    image(pg, width-grid_width, height-grid_height);
  }

  void render_grid () {
    pg.beginDraw();
    int x = 0;
    int y = 0;
    for (int i = 0; i < length; i++) {  
      pg.stroke(bits[i]*255);
      pg.point(x, y);
      if (x > cols) {
        x=0;
        y++;
      } else {
        x++;
      }
    }
    pg.endDraw();
  }

  int [] getFinalAudio () {
    return originalNumbers;
  }

  int getLiveValue () {
    return currentLiveValue;
  }
}