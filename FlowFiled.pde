import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

class FlowField {
  PVector[][] field;
  int cols, rows;
  int resolution;
  int affectRadius;
  float force;
  File file = new File(dataPath("field.txt"));

  FlowField(int r) {
    resolution = r;
    cols = 1200 / resolution;
    rows = 950 / resolution;
    field = new PVector[cols][rows];
    init();
    affectRadius = 3;
    force = 1;
  }
  
  void setRadius(int r){
    affectRadius = r;
  }
  
  void setForce(float f){
    force = f;
  }

  void init() {
    try { readField(); }
    catch(Exception e) {
      for (int i=0; i<cols; i++) {
        for (int j=0; j<rows; j++) {
          field[i][j] = new PVector(0, 0);
        }
      }
    }
  }

  PVector lookup(float x, float y) {
    int column = int(constrain(x/resolution, 0, cols-1));
    int row = int(constrain(y/resolution, 0, rows-1));
    return field[column][row];
  }

  void drawField(float x, float y, PVector v) {
    int column = int(constrain(x/resolution, 0, cols-1));
    int row = int(constrain(y/resolution, 0, rows-1));
    for (int i=-affectRadius; i<=affectRadius; i++) {
      for (int j=-affectRadius; j<=affectRadius; j++) {
        if (i*i+j*j<affectRadius*affectRadius) {
          try { field[column+i][row+j] = field[column+i][row+j].add(v); }
          catch(Exception e) {}
        }
      }
    }
  }

  void onMouseDrag() {
    PVector direc = new PVector(mouseX-pmouseX, mouseY-pmouseY).normalize();
    drawField(pmouseX, pmouseY, direc.mult(force));
  }

  void saveField() {
    try {
      FileWriter out = new FileWriter(file);
      for (int i=0; i<cols; i++) {
        for (int j=0; j<rows; j++) {
          out.write(field[i][j].x+","+field[i][j].y+"\t");
        }
        out.write("\r\n");
      }
      out.close();
    }
    catch(Exception e) {}
  }

  void readField() throws IOException {
    try {
      BufferedReader in = new BufferedReader(new FileReader(file));
      String line;
      for (int i = 0; (line = in.readLine()) != null; i++) {
        String[] temp = line.split("\t"); 
        for (int j=0; j<temp.length; j++) {
          String[] xy = temp[j].split(",");
          float x = Float.parseFloat(xy[0]);
          float y = Float.parseFloat(xy[1]);
          field[i][j] = new PVector(x, y);
        }
      }
      in.close();
    }
    catch(Exception e) {
      throw new IOException("no field.txt");
    }
  }
}