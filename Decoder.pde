public class Decoder {
  int cols=192;
  int rows=266;
  int total_length = cols*rows;
  
  int [] bits = new int[total_length];

  String bString = "";

  ArrayList<ArrayList<Integer>> rowBytes = new ArrayList<ArrayList<Integer>>();
  
  ArrayList<Integer> accumulatedBytes = new ArrayList<Integer>();

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
    //for (int i = 0; i < total_length; i++) bits[i] = random(100) > 50 ? 1 : 0;
    for (int i = 0; i < total_length; i++) bits[i] = 0;
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
    //if (true) return;
    // get multiple values at once
    int [] camValues = cam.getCenterValues();
    int [] booleanValues  = new int [ammountReadingPoints];

    //gui.updateCharts(camValues);

    switch (decoderState) {
      case READING_ROW_DATA:
      case READING_ROW_DATA_INVERTED:
        currentLiveValues.clear();
        for (int i = 0; i < ammountReadingPoints; i++) {
          currentLiveValues.add(camValues[i]);
          rowBytes.get(i).add(camValues[i]);
          booleanValues[i] = camValues[i] > threshold ? 0 : 1;
        }
        currentReadTime=(millis()-startReadTime);
        float proportionalTime = float(currentReadTime)/ROW_TIME;
        // every time the reader is at a particular bit step
        int timePerUnit = floor(float(ROW_TIME)/ROW_STEPS);
        if (currentReadTime % timePerUnit == 0) {
          // send individual bits data to Max as array, not the arrayList 
          oscController.sendLiveDataArray(camValues, proportionalTime);
          oscController.sendLiveDataBits(booleanValues, proportionalTime);
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
    for (int i = 0; i < ammountReadingPoints; i++) {
      String byteString = "";
      for (int b = 0; b < 8; b++) {
        byteString += String.valueOf(lastBits[i][b]);
      }
      lastBytes[i] = Integer.parseInt(byteString, 2);
    }
    oscController.sendLiveDataBytes(lastBytes);
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
    //render_grid();
    noTint();
    image(pg, width-grid_width-MARGIN, height-grid_height-MARGIN);
  }

  void render_grid () {
    pg.beginDraw();
    pg.background(0, 0);
    int x = 0;
    int y = 0;
    for (int i = 0; i < total_length; i++) {  
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
    if (current_row_index == 0) {
      accumulatedBytes.clear();
    }
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
      float j = 0;
      int index=(current_row_index + r)*cols; 
      println("[Decoder] endReading", index, interval, dataRow.size());
      int bitIndex = 0;
      String byteString = "";
      for (int i = 0; i < cols; i++) { 
        int n = dataRow.get(floor(j));
        int bit = n > threshold ? 0 : 1;
        if (index+i >= total_length) {
          break;
        }
        bits[index+i] = bit;
        j+=interval;
        lastIndex=index+i;
        byteString+=bit;
        bitIndex++;
        // every 8 bits ....
        if (bitIndex == 8) {
          int number = Integer.parseInt(byteString, 2);
          println("byteString", byteString);
          accumulatedBytes.add(number);
          byteString="";
          bitIndex=0;
        }
      }
      render_grid();
    }
    // get data 
    int [] realData = getAccumulatedData(lastIndex);
    int [] fakeData = getFakeData(lastIndex);
    float [] noiseArray = generateNoiseArray();
    int [] mergedArray = getMergedDataArray(realData, fakeData, noiseArray);
    
    // update GUI
    gui.updateAccumulatedGraph(toFloatArray(realData));
    gui.updateNoiseGraph(noiseArray);
    gui.updateMergedGraph(toFloatArray(mergedArray));
    
    int [] dataPayload;
    if (sendFakeData) {
      // send fake
      dataPayload = fakeData;
    } else {
      // send accumulated data to Max/msp through OSC
      dataPayload = realData;
    }
    oscController.sendOscAccumulatedData(dataPayload, current_row_index/ammountReadingPoints);
    
    decoderState = DECODER_IDLE; 
  } 

  int [] getAccumulatedData (int lastIndex) {
    int [] accumulatedData = new int[accumulatedBytes.size()];
    for (int i = 0; i < accumulatedBytes.size(); i++) {
      accumulatedData[i] = accumulatedBytes.get(i);
    }
    return accumulatedData;
  }

  int [] getFakeData (int lastIndex) {
    int [] fakeData = new int[min(accumulatedBytes.size(), originalNumbers.length)];
    for (int i = 0; i < fakeData.length; i++) {
      fakeData[i] = originalNumbers[i];
    }
    return fakeData;
  }

  int [] getFinalAudio () {
    return originalNumbers;
  }

  float [] generateNoiseArray () {
    //noiseScale = 0.02;
    float [] noiseArray = new float[accumulatedBytes.size()];
    for (int i=0; i < noiseArray.length; i++) {
      float noiseVal = noise((i)*noiseSteps, noiseSteps);
      noiseArray[i] = ((noiseVal * noiseScale) + 1)/2;
    }
    return noiseArray;
  }

  int [] getMergedDataArray (int [] real_data, int [] fake_data, float [] noise_array) {
    int [] mergedData = new int[accumulatedBytes.size()];
    for (int i = 0; i < mergedData.length; i++) {
      float real_val = real_data[i] * (noise_array[i]);
      float fake_val = fake_data[i] * (1 - noise_array[i]);
      mergedData[i] = floor(real_val + fake_val);
    }
    return mergedData;
  }

  int getLiveValue () {
    return currentLiveValue;
  }
}

float[] toFloatArray(int[] arr) {
  if (arr == null) return null;
  int n = arr.length;
  float[] ret = new float[n];
  for (int i = 0; i < n; i++) {
    ret[i] = (float)arr[i];
  }
  return ret;
}
