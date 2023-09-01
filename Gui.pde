public class Gui {

  Chart myChart;
  Chart accumulatedChart;
  Chart noiseChart;
  Chart mergedChart;
  Chart lastRowBytesChart;
  
  Chart [] dataCharts = new Chart[ammountReadingPoints];

  ControlP5 cp5;
  int [] last_values = new int [100];

  int cp_width = 200;
  int cp_height = 10;

  int chart_h = 150;
  int chart_w = 200;
  
  int margin = MARGIN;
  int y = margin; 

  Gui (ControlP5 _cp5) {
    cp5 = _cp5;
  }

  void init () {
    cp5.setColorForeground(color(255, 150));
    cp5.setColorBackground(color(0, 150));

    myTextlabelB = new Textlabel(cp5,"Another textlabel, not created through ControlP5 needs to be rendered separately by calling Textlabel.draw(PApplet).",100,100,400,200);

    chart();
    sliders();
    buttons();
    // texts();
    bigCharts();
  }

  void sliders () {
    cp5.addSlider("small_steps_slider")
      .setPosition(margin,y)
      .setSize(cp_width, cp_height)
      .setValue(small_steps_default)
      .setRange(1, 500)
      ;
    y+=cp_height+margin;
    cp5.addSlider("big_steps_slider")
      .setPosition(margin,y)
      .setSize(cp_width, cp_height)
      .setValue(big_steps_default)
      .setRange(1000, 25000)
      ;
    y+=cp_height+margin;
    cp5.addSlider("unit_size")
      .setPosition(margin,y)
      .setSize(cp_width, cp_height)
      .setValue(unit_size_default)
      .setRange(1, 100)
      ;
    y+=cp_height+margin;
    cp5.addSlider("reading_row_interval_slider")
      .setPosition(margin,y)
      .setSize(cp_width, cp_height)
      .setValue(reading_row_interval_default)
      .setRange(1, 20)
      ;
    y+=cp_height+margin;

    cp5.addSlider("real_original_balance_slider")
      .setPosition(margin,y)
      .setSize(cp_width, cp_height)
      .setValue(real_original_balance_default)
      .setRange(0, 1)
      .setLabelVisible(true)
      ;
    y+=chart_h+margin+10;

    /*
    cp5.addSlider("reading_points_slider")
      .setPosition(margin,y)
      .setSize(cp_width, cp_height)
      .setNumberOfTickMarks(4)
      .setValue(reading_points_default)
      .setRange(1, 7)
      ;
    y+=cp_height+margin;
    */
  }

  void buttons () {
    // Group bangButtons = cp5.addGroup("bangButtons").setPosition(width-100-margin,margin).setWidth(100);
    int fx = width - 100 - margin;
    int fy = margin; 
    int button_w = 30;
    int button_h = 15;
    
    cp5.addBang("read_row")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      ;
    fy+= button_h+margin+10;
    
    cp5.addBang("read_row_inverse")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      ;
    fy+= button_h+margin+10;

    cp5.addBang("jump_row")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      ;
    fy+= button_h+margin+10; 
    
    cp5.addBang("read_unit")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      ;
    fy+= button_h+margin+10; 

    cp5.addBang("read_plate")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      ;
    fy+= button_h+margin+10; 
    
    cp5.addBang("stop_machine")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      ;
    fy+= button_h+margin+10;

    cp5.addBang("take_pictures")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      ;
    fy+= button_h+margin+10;

    cp5.addBang("take_one_picture")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      ;
    fy+= button_h+margin+10;

    cp5.addBang("send_accumulated_data")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      ;
    fy+= button_h+margin+10;
/*
    cp5.addToggle("original_data")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      .setValue(false)
      ;
    fy+= button_h+margin+10;
  */
    cp5.addToggle("merge_data")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      .setValue(true)
      ;
    fy+= button_h+margin+10;

    cp5.addToggle("save_frame")
      .setPosition(fx, fy)
      .setSize(button_w, button_h)
      .setValue(false)
      ;
    fy+= button_h+margin+10;
  }

  void chart () {
    // initial values for the chart data
    for (int i = 0; i < last_values.length; i++) {
      last_values[i] = 0;
    }
    for (int i = 0; i < ammountReadingPoints; i++) {
      int fh = chart_h/ammountReadingPoints;
      dataCharts[i] = cp5.addChart("dataflow_" + i)
        .setPosition(margin, margin + (fh * i))
        .setSize(chart_w, chart_h/ammountReadingPoints)
        .setRange(0, 255)
        .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
        .setStrokeWeight(1.5)
        .setColorCaptionLabel(color(255))
        ;
      dataCharts[i].addDataSet("incoming_" + i);
      dataCharts[i].setData("incoming_" + i, new float[100]);
    }

    // threshold slider
    cp5.addSlider("threshold_slider")
      .setPosition(margin+chart_w,y)
      .setSize(cp_height, chart_h)
      .setValue(threshold_default)
      .setRange(0, 255)
      .setLabelVisible(true)
      ;
    y+=chart_h+margin+10;

    chart_h=30;
    
    
    lastRowBytesChart = cp5.addChart("lastRowBytesData")
      .setPosition(margin, y)
      .setSize(chart_w, chart_h)
      .setRange(0, 255)
      .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
      .setStrokeWeight(1.5)
      .setColorCaptionLabel(color(255))
      ;
    //accumulatedChart.addDataSet("accumulatedData");
    y+=chart_h+margin+10;
    
    noiseChart = cp5.addChart("noiseData")
      .setPosition(margin, y)
      .setSize(chart_w, chart_h)
      .setRange(0, 1)
      .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
      .setStrokeWeight(1.5)
      .setColorCaptionLabel(color(255))
      ;
    noiseChart.addDataSet("noiseData");
    // noise scale slider
    /*
    cp5.addSlider("noise_step_slider")
      .setPosition(margin+chart_w,y)
      .setSize(cp_height, chart_h)
      .setValue(noise_step_default)
      .setRange(0.0001, 0.1)
      .setLabelVisible(true)
      ;
      */
    // noise scale slider
    cp5.addSlider("noise_scale_slider")
      .setPosition(margin+chart_w,y)
      .setSize(cp_height, chart_h)
      .setValue(noise_scale_default)
      .setRange(0, 1)
      .setLabelVisible(true)
      ;
    y+=chart_h+margin+10;
    

  }

  void bigCharts () {
    int big_w = width-margin*2;
    int big_h = 150;
    int fy = height-big_h*2-margin*2-20;
    accumulatedChart = cp5.addChart("accumulatedData")
      .setPosition(margin, fy)
      .setSize(big_w, big_h)
      .setRange(0, 255)
      .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
      .setStrokeWeight(1.5)
      // .setColorBackground(color(0, 20))
      .setColorCaptionLabel(color(255))
      ;
    accumulatedChart.addDataSet("accumulatedData");
    fy+=big_h+margin+10;
    mergedChart = cp5.addChart("mergedChart")
      .setPosition(margin, fy)
      .setSize(big_w, big_h)
      .setRange(0, 255)
      .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
      .setStrokeWeight(1.5)
      // .setColorBackground(color(0, 20))
      .setColorCaptionLabel(color(255))
      ;
    mergedChart.addDataSet("mergedData");
  }

  Textlabel myTextlabelA;
  Textlabel myTextlabelB;

  void display () {
    fill(255);
    if (debug) {
      int fy = margin * 2;
      int fx = margin*3+chart_w;
      text("frameRate: " + frameRate, fx,fy);
      fy+=margin+5;
      text("timeElapsed: " + millis()/1000, fx,fy);
      fy+=margin+5;
      text("macroState: " + macroStates[macroState], fx,fy);
      fy+=margin+5;
      text("machineState: " + machineStates[machineState], fx,fy);
      fy+=margin+5;
      text("decoderState: " + decoderStates[decoderState], fx,fy);
      fy+=margin+5;
      text("current_row_index: " + current_row_index, fx,fy);
      fy+=margin+5;
      text("last_direction: " + lastDir, fx,fy);
      fy+=margin+5;
      text("currentReadTime: " + currentReadTime, fx,fy);
      fy+=margin+5;
      text("proportional time: " + float(currentReadTime)/ROW_TIME, fx,fy);
      fy+=margin+5;
    }
    // bits
    int rectSize = chart_w/16;
    noFill();
    int ry = y + margin;
    stroke(0);
    for (int i = 0; i < ammountReadingPoints; i++) {
      ry+=rectSize;
      int rx = margin;
      for (int j = 0; j < 8; j++) {
        fill(lastBits[i][j]*255, lastBits[i][j]*255);
        rect(rx, ry, rectSize, rectSize);
        rx+=rectSize;
      }
      rx+=rectSize;
      fill(lastBytes[i]);
      rect(rx, ry, rectSize, rectSize);
      // text with P5
      text(lastBytes[i], rx+rectSize*2, ry+rectSize-2);
    }
  }

  void hideButtons () {
    cp5.getController("read_row").hide();
    cp5.getController("read_row_inverse").hide();
    cp5.getController("jump_row").hide();
    cp5.getController("read_unit").hide();
    cp5.getController("read_plate").hide();
    cp5.getController("stop_machine").hide();
    cp5.getController("take_pictures").hide();
    cp5.getController("take_one_picture").hide();
    cp5.getController("save_frame").hide();
    cp5.getController("merge_data").hide();
    cp5.getController("send_accumulated_data").hide();
    
  }

  void showDebugElements () {
    showButtons();
  }

  void hideDebugElements () {
    hideButtons();
  }
  
  void showButtons () {
    cp5.getController("read_row").show();
    cp5.getController("read_row_inverse").show();
    cp5.getController("jump_row").show();
    cp5.getController("read_unit").show();
    cp5.getController("read_plate").show();
    cp5.getController("stop_machine").show();
    cp5.getController("take_pictures").show();
    cp5.getController("take_one_picture").show();
    cp5.getController("save_frame").show();
    cp5.getController("merge_data").show();
    cp5.getController("send_accumulated_data").show();

  }

  void updateCharts (int [] values) {
    for (int i = 0; i < values.length; i++) {
      dataCharts[i].push("incoming_"+i, values[i]);
    }
  }

  void updateAccumulatedGraph(float [] samples) {
    float [] values = new float[originalNumbers.length];
    for(int i = 0; i < originalNumbers.length; i++) {
      if (i < samples.length) {
        values[i] = samples[i];
      } else {
        values[i] = 0;
      }
    }
    accumulatedChart.setData("accumulatedData", samples);
  }
  
  void updateNoiseGraph(float [] samples) {
    noiseChart.setData("noiseData", samples);
  }
  
  void updateMergedGraph(float [] samples) {
    mergedChart.setData("mergedData", samples);
  }
  
  void updateLastRowBytesGraph(int value) {
    lastRowBytesChart.push("lastRowBytesData", value);
  }
}
