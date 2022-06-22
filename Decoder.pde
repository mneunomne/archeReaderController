public class Decoder {
  
  
  int cols=192;
  int rows=266;
  int length = 51040;
  
  int [] bits = new int[length];

  int grid_width=cols;
  int grid_height=rows;

  PGraphics pg; 
  
  Decoder () {
    pg = createGraphics(width, height);
    for (int i = 0; i < length; i++) bits[i] = random(100) > 50 ? 1 : 0;
    pg.beginDraw();
    pg.background(100);
    pg.endDraw();
    // println(bits);
  }

  void storeDataPoint (float value) {

  }

  void interpretSignalArray () {

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
}