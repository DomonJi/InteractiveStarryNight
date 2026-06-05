import controlP5.*;

/**
 * GUI 控制面板类 —— 提供用户可交互的滑块控件
 *
 * 使用 ControlP5 库创建三个滑块，让用户实时调节：
 *   - Radius        鼠标画笔的影响半径
 *   - Force          鼠标画笔的力度
 *   - Particle Size  粒子绘制大小
 *
 * 控件位于画布右下角区域（x > 950, y > 830）
 */
class GUI {
  ControlP5 cp5;       // ControlP5 库主控制器
  Slider sliderR;      // 画笔半径滑块
  Slider sliderF;      // 画笔力度滑块
  Slider sliderS;      // 粒子大小滑块

  /**
   * 构造函数
   * @param thePApplet Processing 主画布对象，ControlP5 需要依附于它
   */
  GUI(PApplet thePApplet){
    cp5 = new ControlP5(thePApplet);
  }

  /**
   * 初始化所有滑块控件
   * 设置位置、范围、默认值和尺寸
   */
  void setup(){
    cp5.setColorBackground(0x141414); // 深灰色背景，与星夜画面风格统一

    // 画笔影响半径：范围 1~20，默认 12
    sliderR = cp5.addSlider("Radius")
                 .setPosition(980,890)
                 .setRange(1,20)
                 .setValue(12).setSize(150,25);

    // 画笔力度：范围 0.1~0.5，默认 0.3
    sliderF = cp5.addSlider("Force")
                 .setPosition(980,918)
                 .setRange(0.1,0.5)
                 .setValue(0.3).setSize(150,25);

    // 粒子大小：范围 0.8~2，默认 1.5
    sliderS = cp5.addSlider("Particle Size")
                 .setPosition(980,862)
                 .setRange(0.8,2)
                 .setValue(1.5).setSize(150,25);

  }

  /** 获取当前画笔半径值 */
  int getR(){
    return int(sliderR.getValue());
  }

  /** 获取当前画笔力度值 */
  float getF(){
    return sliderF.getValue();
  }

  /** 获取当前粒子大小值 */
  float getS(){
    return sliderS.getValue();
  }
}
