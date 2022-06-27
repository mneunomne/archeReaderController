public class Decoder {
  int cols=192;
  int rows=266;
  int length = 51072;
  
  int [] bits = new int[length];
  String bString = "";

  ArrayList<ArrayList<Integer>> rowBytes = new ArrayList<ArrayList<Integer>>();

  int grid_width=cols;
  int grid_height=rows;

  PGraphics pg;

  // original numbers audioloadJSONArray
  JSONArray originalNumbersJSON;
  int [] originalNumbers;

  int currentLiveValue = 0; 

  ArrayList<Integer> currentLiveValues = new ArrayList<Integer>(); 

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

    for (int i = 0; i < ammountReadingPoints;i++) {
      ArrayList<Integer> rowNumbers = new ArrayList<Integer>();
      rowBytes.add(rowNumbers);
    }
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
    // get multiple values at once
    int [] camValues = cam.getCenterValues();
    currentLiveValues.clear();
    for (int i = 0; i < ammountReadingPoints; i++) {
      currentLiveValues.add(camValues[i]);
      rowBytes.get(i).add(camValues[i]);
    }

    // send data to Max as array, not the arrayList 
    oscController.sendLiveDataArray(camValues);
    gui.updateCharts(camValues);

    switch (decoderState) {
      case READING_ROW_DATA:
      case READING_ROW_DATA_INVERTED:
        // store data in rowBytes ArrayList
        for (int i = 0; i < ammountReadingPoints; i++) {
          rowBytes.get(i).add(camValues[i]);
        }
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
    noTint();
    image(pg, width-grid_width-MARGIN, height-grid_height-MARGIN);
  }

  void render_grid () {
    pg.beginDraw();
    pg.background(0, 0);
    int x = 0;
    int y = 0;
    for (int i = 0; i < length; i++) {  
      pg.stroke(bits[i]*255, 55+bits[i]*200);
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
    for (int i = 0; i < ammountReadingPoints;i++) {
      rowBytes.get(i).clear();
    }
    decoderState = READING_ROW_DATA;
  }

  void startReadingRowInverted () {
    for (int i = 0; i < ammountReadingPoints;i++) {
      rowBytes.get(i).clear();
    }
    decoderState = READING_ROW_DATA_INVERTED;
  }

  void endReading (boolean isInverted) {
    for (int r = 0; r < rowBytes.size(); r++) {
      ArrayList<Integer> dataRow = rowBytes.get(r);
      if (isInverted) {
        Collections.reverse(dataRow);
      }
      float interval = float(dataRow.size())/cols;
      float j = 0;
      int index=(current_row_index + r)*cols; 
      // println("[Decoder] endReading", index, interval, dataRow.size()); // FIX
      for (int i = 0; i < cols; i++) { 
        int n = dataRow.get(floor(j));
        int bit = n > threshold ? 0 : 1;
        bits[index+i] = bit;
        j+=interval;
      }
    }
    decoderState = DECODER_IDLE;
  } 

  int [] getFinalAudio () {
    return originalNumbers;
  }

  int getLiveValue () {
    return currentLiveValue;
  }
}