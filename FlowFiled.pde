import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

/**
 * 流场类 —— 用二维向量场控制粒子的运动方向
 *
 * 原理：将画布按 resolution 划分为网格，每个网格存储一个 PVector（方向向量）。
 *       粒子根据自身位置查询所在网格的向量，沿该方向移动。
 *
 * 双层结构：
 *   field[][]    —— 基础流场，从 data/field.txt 加载，是粒子的"默认风向"
 *   tempField[][] —— 临时流场，由用户鼠标拖拽产生，会随时间衰减
 *
 * 粒子实际受力 = field + tempField（lookup 方法中做向量加法）
 */
class FlowField {
  PVector[][] field;      // 基础流场向量
  PVector[][] tempField;  // 用户交互产生的临时流场向量
  int cols, rows;         // 网格的列数和行数
  int resolution;         // 每个网格的像素尺寸（分辨率）
  int affectRadius;       // 鼠标画笔的影响半径（以网格为单位）
  float force;            // 鼠标画笔的力度系数
  File file = new File(dataPath("field.txt")); // 流场数据文件

  /**
   * 构造函数：初始化流场
   * @param r 网格分辨率（像素），值越小流场越精细
   */
  FlowField(int r) {
    resolution = r;
    cols = 1200 / resolution;
    rows = 950 / resolution;
    field = new PVector[cols][rows];
    tempField = new PVector[cols][rows];
    init();
    affectRadius = 3;
    force = 1;
  }

  /** 设置鼠标画笔的影响半径 */
  void setRadius(int r) {
    affectRadius = r;
  }

  /** 设置鼠标画笔的力度 */
  void setForce(float f) {
    force = f;
  }

  /**
   * 初始化流场数据
   * 先将临时流场全部置零，再尝试从 field.txt 读取基础流场；
   * 如果读取失败（文件不存在等），则将基础流场也全部置零
   */
  void init() {
    try {
      for (int i=0; i<cols; i++) {
        for (int j=0; j<rows; j++) {
          tempField[i][j] = new PVector(0, 0);
        }
      }
      readField();
    }
    catch(Exception e) {
      for (int i=0; i<cols; i++) {
        for (int j=0; j<rows; j++) {
          field[i][j] = new PVector(0, 0);
        }
      }
    }
  }

  /**
   * 查询指定坐标处的流场向量
   * 返回基础流场与临时流场的叠加结果
   * @param x 像素 x 坐标
   * @param y 像素 y 坐标
   * @return 该位置的合成方向向量
   */
  PVector lookup(float x, float y) {
    int column = int(constrain(x/resolution, 0, cols-1));
    int row = int(constrain(y/resolution, 0, rows-1));
    return PVector.add(field[column][row],tempField[column][row]);
  }

  /** 绘制鼠标画笔的圆形指示器 */
  void drawBrush() {
    pushStyle();
    noFill();
    stroke(255, 255, 255);
    ellipse(mouseX, mouseY, affectRadius*10, affectRadius*10);
    popStyle();
  }

  /**
   * 在指定位置向临时流场写入方向向量
   * 影响范围是以 (x,y) 为中心、affectRadius 为半径的圆形区域
   * @param x 像素 x 坐标
   * @param y 像素 y 坐标
   * @param v  要写入的方向向量
   */
  void drawField(float x, float y, PVector v) {
    int column = int(constrain(x/resolution, 0, cols-1));
    int row = int(constrain(y/resolution, 0, rows-1));
    for (int i=-affectRadius; i<=affectRadius; i++) {
      for (int j=-affectRadius; j<=affectRadius; j++) {
        // 只影响圆形区域内的网格（i*i+j*j < r*r）
        if (i*i+j*j<affectRadius*affectRadius) {
          try {
            // 将方向向量叠加到临时流场，并乘以 0.9 做轻微衰减
            tempField[column+i][row+j].add(v).mult(0.9);
          }
          catch(Exception e) {
          }
        }
      }
    }
  }

  /**
   * 每帧更新临时流场：所有向量乘以 0.992
   * 这使得用户绘制的流场效果会随时间逐渐消散，画面回归基础流场
   */
  void updateField(){
    for (int i=0; i<cols; i++) {
        for (int j=0; j<rows; j++) {
          tempField[i][j].mult(0.992);
        }
      }
  }

  /**
   * 鼠标拖拽事件：计算鼠标移动方向并写入临时流场
   * pmouseX/pmouseY 是上一帧的鼠标位置，据此算出拖拽方向
   */
  void onMouseDrag() {
    PVector direc = new PVector(mouseX-pmouseX, mouseY-pmouseY).normalize();
    drawField(pmouseX, pmouseY, direc.mult(force));
  }

  /**
   * 将基础流场数据保存到 data/field.txt
   * 格式：每行对应一列，网格之间用制表符分隔，x/y 用逗号分隔
   */
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
    catch(Exception e) {
    }
  }

  /**
   * 从 data/field.txt 读取基础流场数据
   * @throws IOException 文件不存在或格式错误时抛出
   */
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
