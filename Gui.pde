public class Gui {
  
  ControlP5 cp5;
  int [] last_values = new int [100];

  Gui (Controlp5 _cp5) {
    cp5 = _cp5;
  }

  void init () {
    cp5.setColorForeground(color(255, 80));
    cp5.setColorBackground(color(255, 20));
    
    // initial values for the chart data
    for (int i = 0; i < last_values.length; i++) {
      last_values[i] = 0;
    }
  }

  void chart () {
    myChart = cp5.addChart("dataflow")
      .setPosition(0, 0)
      .setSize(200, 100)
      .setRange(0, 255)
      .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
      .setStrokeWeight(1.5)
      .setColorBackground(color(20))
      .setColorForeground(color(255))
      .setColorCaptionLabel(color(255))
      ;
    myChart.addDataSet("incoming");
    myChart.setData("incoming", new float[100]);
  }

  void updateChart (float value) {
    myChart.push("incoming", value);
  }


}
