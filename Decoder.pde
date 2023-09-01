public class Decoder {
  int total_length = PLATE_COLS*PLATE_ROWS;
  
  int [] bits = new int[total_length];

  String bString = "";

  ArrayList<ArrayList<Integer>> rowBytes = new ArrayList<ArrayList<Integer>>();

  ArrayList<ArrayList<Integer>> rowBits = new ArrayList<ArrayList<Integer>>();
  
  ArrayList<Integer> accumulatedBytes = new ArrayList<Integer>();

  ArrayList<ArrayList<Integer>> lastRowBytes = new ArrayList<ArrayList<Integer>>();

  int lastIndex = 0;

  int grid_width=PLATE_COLS;
  int grid_height=PLATE_ROWS;

  int lastBitsIndex = 0;

  boolean startedTimer = false;

  PGraphics pg;

  int currentLiveValue = 0; 

  ArrayList<Integer> currentLiveValues = new ArrayList<Integer>(); 

  int startReadTime = 0;

  int lastUnitReadTime = 0;

  int leftOverMillis = 0;

  int timePerUnit = floor(float(ROW_TIME)/PLATE_COLS);

  int [][] bit_grid = new int[grid_height][grid_width]; 

  Decoder () {
    pg = createGraphics(grid_width*2, grid_height*2);
    //for (int i = 0; i < total_length; i++) bits[i] = random(100) > 50 ? 1 : 0;
    resetStoredBitData();
    pg.beginDraw();
    pg.background(0, 0);
    pg.endDraw();
    // load original numbers
    originalNumbersJSON = loadJSONArray("data/data_numbers.json");
    originalNumbers = new int[originalNumbersJSON.size()];
    for (int i = 0; i < originalNumbersJSON.size(); i++) {
      originalNumbers[i] = originalNumbersJSON.getInt(i);
    }
    for (int i = 0; i < ammountReadingPoints;i++) {
      ArrayList<Integer> rowNumbers = new ArrayList<Integer>();
      ArrayList<Integer> rowByteNumbers = new ArrayList<Integer>();
      lastRowBytes.add(rowByteNumbers);
      rowBits.add(rowNumbers);
    }
  }

  void resetStoredBitData () {
    for (int i = 0; i < total_length; i++) {
      bits[i] = 0;
      bit_grid[floor(i/PLATE_COLS)][i%PLATE_COLS] = -1;
    }  
  }

  int col_index=0;
  int byte_index=0;
  void update () { 
    // start timer
    if (!startedTimer) {
      startReadTime = millis();
      println("start timer!", startReadTime);
      startedTimer=true;
      lastUnitReadTime = millis() - timePerUnit;
    }
    // get multiple values at once
    int [] camValues = cam.getCenterValues();
    int [] booleanValues  = new int [ammountReadingPoints];
    
    switch (decoderState) {
      case DECODER_IDLE:
        // gui.updateCharts(cam.getCenterValues());
        break;
      case READING_ROW_DATA:
      case READING_ROW_DATA_INVERTED:
        if(current_row_index + ammountReadingPoints > PLATE_ROWS || col_index == PLATE_COLS) {
          // dont read
          return;
        }
        currentLiveValues.clear();  

        // read bits! (everyframe)
        for (int i = 0; i < ammountReadingPoints; i++) {
          currentLiveValues.add(camValues[i]);
          int binaryVal = camValues[i] > threshold ? 0 : 1;
          booleanValues[i] = binaryVal;
          rowBits.get(i).add(binaryVal);
        }
        currentReadTime=(millis()-startReadTime);
        float proportionalTime = float(currentReadTime)/ROW_TIME;
        
        // every time the reader is at a particular bit step
        // position of each square given the time per unit
        int realTimePerUnit = timePerUnit;//floor(timePerUnit-(float(1000)/frameRate)/2);
        // leftOverMillis= 0;
        // println("realTimePerUnit", realTimePerUnit, "timePerUnit", timePerUnit, millis() - lastUnitReadTime);
        if (millis() - lastUnitReadTime >= realTimePerUnit) {
          // draw the bit grid only when we get new values
          // draw_grid();
          leftOverMillis = (millis() - lastUnitReadTime) - realTimePerUnit;
          if (lastUnitReadTime == 0) {
            leftOverMillis = 0;
          } 
          // println("leftOverMillis", leftOverMillis);
          col_index++; // can already go to next col because the camValues are stores
          lastUnitReadTime=millis() - leftOverMillis;
          if (col_index > PLATE_COLS) {
            // no more data reading
            return;
          }
          // send individual bits data to Max as array, not the arrayList 
          oscController.sendLiveDataArray(camValues, proportionalTime);
          oscController.sendLiveDataBits(booleanValues, proportionalTime);
          // read bits!
          for (int i = 0; i < ammountReadingPoints; i++) {
            lastBits[i][lastBitsIndex] = booleanValues[i];
            if (decoderState == READING_ROW_DATA) {
              bit_grid[current_row_index + i][col_index-1] = booleanValues[i];
            } else if (decoderState == READING_ROW_DATA_INVERTED) {
              bit_grid[current_row_index + i][PLATE_COLS-col_index] = booleanValues[i];
            }
          }

          if (decoderState == READING_ROW_DATA) {
            draw_last_bits(lastBits, current_row_index, col_index-1);
          } else if (decoderState == READING_ROW_DATA_INVERTED) {
            draw_last_bits(lastBits, current_row_index, PLATE_COLS-col_index);
          }

          lastBitsIndex++;
          if (lastBitsIndex == 8) { // every 8 bits...
            byte_index++;
            lastBitsIndex=0;
            processLastBits();
            // clear last bits
            lastBits = new int[ammountReadingPoints][8];
          }
        }
        break;
    }
  }

  void processLastBits () {
    for (int i = 0; i < ammountReadingPoints; i++) {
      String byteString = "";
      for (int b = 0; b < 8; b++) {
        byteString += String.valueOf(lastBits[i][b]);
      }
      int byteNumber = Integer.parseInt(byteString, 2);
      lastBytes[i] = byteNumber;
      lastRowBytes.get(i).add(byteNumber);
    }
    gui.updateCharts(lastBytes);
    //gui.updateLastRowBytesGraph()
    oscController.sendLiveDataBytes(lastBytes);
  }
  
  void display () {
    pushStyle();
      noTint();
      imageMode(CORNER);
      image(pg, width-MARGIN-pg.width, MARGIN);
      imageMode(CENTER);
    popStyle();
  }

  void draw_last_bits (int [][] lastBits, int row_index, int col_index) {
    color bit_1 = color(255);
    color bit_0 = color(0, 0);
    pg.beginDraw();
    pg.stroke(0,150);
    for (int i = 0; i < ammountReadingPoints; i++) {
        int val = lastBits[i][lastBitsIndex];
        if (val == 1) {
          pg.fill(bit_1);
        } else {
          pg.noFill();
        }
        pg.rect((col_index)*2, (row_index+i)*2, 2, 2);
    }
    pg.endDraw();
  }

  void startReadingRow () {
    clearLastRows();
    println("startReadingRow", col_index, byte_index);
    decoderState = READING_ROW_DATA;
  }

  void startReadingRowInverted () {
    clearLastRows();
    println("startReadingRowInverted", col_index, byte_index);
    decoderState = READING_ROW_DATA_INVERTED;
  }

  void clearLastRows () {
    if (current_row_index == 0) {
      accumulatedBytes.clear();
      resetStoredBitData();
      pg.beginDraw();
      pg.background(0, 0);
      pg.endDraw();
    }
    startedTimer=false;
    col_index=0;
    byte_index=0;
    for (int i = 0; i < ammountReadingPoints;i++) {
      lastRowBytes.get(i).clear();
    }
  }


  // to do if i want to re-do
  void processRowBits (boolean isInverted) {
    for (int r = 0; r < rowBits.size(); r++) {
      ArrayList<Integer> dataRow = lastRowBytes.get(r);
      if (isInverted) {
        Collections.reverse(dataRow);
      }
    }
  }

  void endReading (boolean isInverted) {
    println("[Decoder] endReading", lastIndex);
    println("currentReadTime", currentReadTime);
    currentReadTime=ROW_TIME;
    for (int r = 0; r < lastRowBytes.size(); r++) {
      ArrayList<Integer> dataRow = lastRowBytes.get(r);
      if (isInverted) {
        Collections.reverse(dataRow);
      }
      for (int i = 0; i < dataRow.size(); i++) { 
        lastIndex++; 
        if (lastIndex >= total_length) {
          break; // avoid last line to break because it is not complete
        }
        int number = dataRow.get(i);
        accumulatedBytes.add(number);
      }
      //render_grid();
    }
    sendAccumulatedData();
    decoderState = DECODER_IDLE; 
  }

  void sendAccumulatedData () {
    // get data 
    int [] realData = getAccumulatedData();
    int [] originalData = getOriginalData();
    float [] noiseArray = generateNoiseArray();
    int [] mergedArray = getMergedDataArray(realData, originalData, noiseArray);
    
    // update GUI
    gui.updateAccumulatedGraph(toFloatArray(realData));
    gui.updateNoiseGraph(noiseArray);
    gui.updateMergedGraph(toFloatArray(mergedArray));
    
    int [] dataPayload;
    if (sendOriginalData) {
      // send original
      dataPayload = originalData;
    } else if (sendMergedData) {
      // send merged array
      dataPayload = mergedArray;
    } else {
      // send accumulated data to Max/msp through OSC
      dataPayload = realData;
    }
    oscController.sendOscAccumulatedData(dataPayload, current_row_index/ammountReadingPoints);
    
  }

  int [] getAccumulatedData () {
    int [] accumulatedData = new int[accumulatedBytes.size()];
    for (int i = 0; i < accumulatedBytes.size(); i++) {
      accumulatedData[i] = accumulatedBytes.get(i);
    }
    return accumulatedData;
  }

  int [] getOriginalData () {
    int [] originalData = new int[min(accumulatedBytes.size(), originalNumbers.length)];
    for (int i = 0; i < originalData.length; i++) {
      originalData[i] = originalNumbers[i];
    }
    return originalData;
  }

  int [] getFinalAudio () {
    return originalNumbers;
  }

  float [] generateNoiseArray () {
    //noiseScale = 0.02;
    float [] noiseArray = new float[accumulatedBytes.size()];
    for (int i=0; i < noiseArray.length; i++) {
      float noiseVal = noise((i)*noiseSteps, 100);
      noiseArray[i] = (((noiseVal*2)-1)*noiseScale)+0.5;
    }
    return noiseArray;
  }

  int [] getMergedDataArray (int [] real_data, int [] original_data, float [] noise_array) {
    int [] mergedData = new int[min(accumulatedBytes.size(), original_data.length)];
    for (int i = 0; i < mergedData.length; i++) {
      float realProp = (noise_array[i]*2)-1; 
      float real_val = real_data[i] * (realProp);
      float original_val = original_data[i] * (1-realProp);
      mergedData[i] = floor(real_val + original_val);
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
