public class Gui {

  Chart myChart;
  
  Chart [] dataCharts = new Chart[ammountReadingPoints];

  ControlP5 cp5;
  int [] last_values = new int [100];

  int cp_width = 200;
  int cp_height = 10;

  int chart_h = 200;
  int chart_w = 200;
  
  int margin = MARGIN;
  int y = margin; 

  Gui (ControlP5 _cp5) {
    cp5 = _cp5;
  }

  void init () {
    cp5.setColorForeground(color(255, 150));
    cp5.setColorBackground(color(0, 150));

    chart();
    sliders();
    buttons();
    // texts();
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
    cp5.addSlider("reading_points_slider")
      .setPosition(margin,y)
      .setSize(cp_width, cp_height)
      .setNumberOfTickMarks(4)
      .setValue(reading_points_default)
      .setRange(1, 7)
      ;
    y+=cp_height+margin;
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
  }

  Textlabel myTextlabelA;
  Textlabel myTextlabelB;

  void display () {
    fill(255);
    int fy = y + margin;
    text("timeElapsed: " + millis()/1000, margin,fy);
    fy+=margin+5;
    text("macroState: " + macroStates[macroState], margin,fy);
    fy+=margin+5;
    text("machineState: " + machineStates[machineState], margin,fy);
    fy+=margin+5;
    text("decoderState: " + decoderStates[decoderState], margin,fy);
    fy+=margin+5;
    text("current_row_index: " + current_row_index, margin,fy);
    fy+=margin+5;
    text("last_direction: " + lastDir, margin,fy);
    fy+=margin+5;
  }

  // old
  /*
  void updateChart (float value) {
    myChart.push("incoming", value);
  }
  */

  void updateCharts (int [] values) {
    for (int i = 0; i < values.length; i++) {
      dataCharts[i].push("incoming_"+i, values[i]);
    }
  }
}
