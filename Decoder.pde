public class Decoder {
  int cols=192;
  int rows=266;
  int length = 51040;
  
  int [] bits = new int[length];
  String bString = "";

  ArrayList<Integer> rowBytes = new ArrayList<Integer>();

  int grid_width=cols;
  int grid_height=rows;

  PGraphics pg;

  // original numbers audioloadJSONArray
  JSONArray originalNumbersJSON;
  int [] originalNumbers;

  int currentLiveValue = 0; 

  Decoder () {
    pg = createGraphics(width, height);
    //for (int i = 0; i < length; i++) bits[i] = random(100) > 50 ? 1 : 0;
    for (int i = 0; i < length; i++) bits[i] = 0;
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
    // every 8 read signals, send to max
    if (bString.length() >= 8) {
      oscController.sendOscAccumulatedData(getSignalArray(), current_row_index);
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
    switch (decoderState) {
      case READING_ROW_DATA:
      case READING_ROW_DATA_INVERTED:
        // byte b = (byte) currentLiveValue;
        rowBytes.add(currentLiveValue);
        break;
      case SENDING_FAKE_DATA:
        sendTestData();
        break;
    }
  }

  void sendTestData () {
    if (frameCount % 5 == 0) {
      if (current_row_index >= originalNumbers.length) {
        current_row_index = 0;
      }
      current_row_index++;
      int [] numbers = new int [current_row_index];
      for (int i = 0; i < current_row_index; i++) {
        numbers[i] = originalNumbers[i];
      }
      oscController.sendOscAccumulatedData(numbers, current_row_index);
    }
  }

  void display () {
    render_grid();
    image(pg, width-grid_width-MARGIN, height-grid_height-MARGIN);
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

  void startReadingRow () {
    rowBytes.clear();
    decoderState = READING_ROW_DATA;
  }

  void startReadingRowInverted () {
    rowBytes.clear();
    decoderState = READING_ROW_DATA_INVERTED;
  }

  void endReading (boolean isInverted) {
    if (isInverted) Collections.reverse(rowBytes);
    float interval = float(rowBytes.size())/cols;
    float j = 0;
    int index=current_row_index*cols; 
    println("[Decoder] endReading", index, interval, rowBytes.size());
    for (int i = 0; i < cols; i++) { 
      int n = rowBytes.get(floor(j));
      int bit = n > threshold ? 0 : 1;
      bits[index+i] = bit;
      j+=interval;
    }
  } 

  int [] getFinalAudio () {
    return originalNumbers;
  }

  int getLiveValue () {
    return currentLiveValue;
  }
}