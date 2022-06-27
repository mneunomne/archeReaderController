public class Decoder {
  int cols=192;
  int rows=266;
  int length = cols*rows;
  
  int [] bits = new int[length];

  String bString = "";

  ArrayList<ArrayList<Integer>> rowBytes = new ArrayList<ArrayList<Integer>>();

  int grid_width=cols;
  int grid_height=rows;

  int lastBitsIndex = 0;

  PGraphics pg;

  // original numbers audioloadJSONArray
  JSONArray originalNumbersJSON;
  int [] originalNumbers;

  int currentLiveValue = 0; 

  ArrayList<Integer> currentLiveValues = new ArrayList<Integer>(); 

  int startReadTime = 0;

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
    int [] booleanValues  = new int [ammountReadingPoints];
    currentLiveValues.clear();
    for (int i = 0; i < ammountReadingPoints; i++) {
      currentLiveValues.add(camValues[i]);
      rowBytes.get(i).add(camValues[i]);
      booleanValues[i] = camValues[i] > threshold ? 0 : 1;
    }

    gui.updateCharts(camValues);

    switch (decoderState) {
      case READING_ROW_DATA:
      case READING_ROW_DATA_INVERTED:
        currentReadTime=(millis()-startReadTime);
        float proportionalTime = currentReadTime/ROW_TIME;



        // every time the reader is at a particular bit step
        int timePerUnit = floor(float(ROW_TIME)/ROW_STEPS);
        if (currentReadTime % timePerUnit == 0) {
          // send individual bits data to Max as array, not the arrayList 
          oscController.sendLiveDataArray(camValues, proportionalTime);
          oscController.sendLiveDataBits(camValues, proportionalTime);
          
          // read bits!
          for (int i = 0; i < ammountReadingPoints; i++) {
            lastBits[i][lastBitsIndex] = booleanValues[i];
          }
          lastBitsIndex++;
          if (lastBitsIndex == 8) { // every 8 bits...
            lastBitsIndex=0;
            processLastBits();
            // clear last bits
            lastBits = new int[ammountReadingPoints][8];
          }
        }

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

  void processLastBits () {
    int [] bytes = new int [ammountReadingPoints];
    for (int i = 0; i < ammountReadingPoints; i++) {
      String byteString = "";
      for (int b = 0; b < 8; b++) {
        byteString += String.valueOf(lastBits[i][b]);
      }
      bytes[i] = Integer.parseInt(byteString, 2);
    }
    oscController.sendLiveDataBytes(bytes);
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
    startReadTime = millis();
    for (int i = 0; i < ammountReadingPoints;i++) {
      rowBytes.get(i).clear();
    }
    decoderState = READING_ROW_DATA;
  }

  void startReadingRowInverted () {
    startReadTime = millis();
    for (int i = 0; i < ammountReadingPoints;i++) {
      rowBytes.get(i).clear();
    }
    decoderState = READING_ROW_DATA_INVERTED;
  }

  void endReading (boolean isInverted) {
    currentReadTime=ROW_TIME;
    int lastIndex = 0;
    for (int r = 0; r < rowBytes.size(); r++) {
      ArrayList<Integer> dataRow = rowBytes.get(r);
      if (isInverted) {
        Collections.reverse(dataRow);
      }
      float interval = float(dataRow.size())/cols;
      println("interval", interval);
      float j = 0;
      int index=(current_row_index + r)*cols; 
      println("[Decoder] endReading", index, interval, dataRow.size());
      for (int i = 0; i < cols; i++) { 
        int n = dataRow.get(floor(j));
        int bit = n > threshold ? 0 : 1;
        bits[index+i] = bit;
        j+=interval;
        lastIndex=index+i;
      }
    }
    // send accumulated data to Max/msp through OSC
    oscController.sendOscAccumulatedData(getAccumulatedData(lastIndex), current_row_index);
    decoderState = DECODER_IDLE;
  } 

  int [] getAccumulatedData (int lastIndex) {
    int [] accumulatedData = new int[lastIndex];
    for (int i = 0; i < lastIndex; i++) {
      accumulatedData[i] = bits[i];
    }
    return accumulatedData;
  }

  int [] getFinalAudio () {
    return originalNumbers;
  }

  int getLiveValue () {
    return currentLiveValue;
  }
}