public class Decoder {
  int cols=192;
  int rows=266;
  int length = 51040;
  
  int [] bits = new int[length];
  String bString = "";

  int grid_width=cols;
  int grid_height=rows;

  int currentIndex = 0; 

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
    char bit = currentLiveValue > threshold ? '0' : '1';
    bString = bString + bit;
    currentIndex++;
    // every 8 read signals, send to max
    if (bString.length() >= 8) {
      oscController.sendOscAccumulatedData(getSignalArray(), currentIndex);
    } else {
      // bit string not long enough yet.
      return; 
    }
  }

  int [] getSignalArray () {
    // split into 8 chars
    String[] binaryStrings = bString.split("(?<=\\G........)", -1);
    print("[Decoder] array ");
    printArray(binaryStrings);
    int [] values = new int[binaryStrings.length];
    for (int i = 0; i < binaryStrings.length; i++) {
      if (binaryStrings[i].length() == 8) {
        values[i] = Integer.parseInt(binaryStrings[i], 2);
      }
    }
    return values;
  }

  void update () {
    currentLiveValue = cam.getCenterValue();
    if (sendFakeData) {
      sendTestData();
    }
  }

  void sendTestData () {
    if (frameCount % 5 == 0) {
      if (currentIndex >= originalNumbers.length) {
        currentIndex = 0;
      }
      currentIndex++;
      int [] numbers = new int [currentIndex];
      for (int i = 0; i < currentIndex; i++) {
        numbers[i] = originalNumbers[i];
      }
      oscController.sendOscAccumulatedData(numbers, currentIndex);
    }
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