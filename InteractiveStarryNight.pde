/**
 * InteractiveStarryNight —— 交互式星夜
 *
 * 核心思路：
 *   1. 加载梵高《星夜》图片，提取每个像素的颜色
 *   2. 生成大量粒子，每个粒子从原图采样颜色
 *   3. 粒子沿流场（FlowField）方向移动，绘制带颜色的短线段
 *   4. 用户可用鼠标拖拽来改变流场方向，从而"画"出新的风向
 *
 * 视觉效果：无数彩色短线段随流场流动，模拟梵高画中的笔触风格
 */

// ==================== 全局常量 ====================

final int STAGE_WIDTH = 1200;       // 画布宽度
final int STAGE_HEIGHT = 950;       // 画布高度
final int NB_PARTICLES = 60000;     // 粒子总数（6万）
final float MAX_PARTICLE_SPEED = 5; // 粒子最大速度，防止运动过快导致线条断裂

final int MIN_LIFE_TIME = 20;       // 粒子最短生命周期（帧数）
final int MAX_LIFE_TIME = 80;       // 粒子最长生命周期（帧数）
final String IMAGE_PATH = "starrynight.jpg"; // 星夜原图路径

// ==================== 全局变量 ====================

myVector tabParticles[];  // 粒子数组
float particleSize = 1.2; // 粒子绘制大小
PImage myImage;           // 星夜原图
int imageW;               // 图片宽度
int imageH;               // 图片高度
color myPixels[];         // 图片像素颜色数组
FlowField ff;             // 流场对象
GUI gui;                  // GUI 控制面板

/**
 * Processing 入口：初始化画布、图片、粒子和 GUI
 */
void setup()
{
  size(1200, 950, P3D); // 使用 P3D 渲染器以获得更好的性能
  background(0);         // 黑色背景
  initializeImage();
  initializeParticles();
  ff = new FlowField(5); // 网格分辨率 5 像素，流场较精细
  gui = new GUI(this);
  gui.setup();
}

/**
 * 加载星夜原图并提取所有像素颜色
 * 颜色数据存入 myPixels[]，供粒子采样使用
 */
void initializeImage()
{
  myImage = loadImage(IMAGE_PATH);
  imageW = myImage.width;
  imageH = myImage.height;
  myPixels = new color[imageW * imageH];
  myImage.loadPixels();
  myPixels = myImage.pixels;
  image(myImage, 0, 0); // 先绘制一次原图作为初始背景
}

/**
 * 初始化（或重置）单个粒子
 * 随机位置、随机生命周期、从原图采样颜色
 * @param i 粒子在数组中的索引
 */
void setParticle(int i) {
  tabParticles[i] = new myVector((int)random(imageW), (int)random(imageH));
  tabParticles[i].prevX = tabParticles[i].x;
  tabParticles[i].prevY = tabParticles[i].y;
  tabParticles[i].count = (int)random(MIN_LIFE_TIME, MAX_LIFE_TIME);
  // 根据粒子位置从原图采样颜色
  tabParticles[i].myColor = myPixels[(int)(tabParticles[i].y)*imageW + (int)(tabParticles[i].x)];
}

/**
 * 初始化所有粒子
 */
void initializeParticles()
{
  tabParticles = new myVector[NB_PARTICLES];
  for (int i = 0; i < NB_PARTICLES; i++)
  {
    setParticle(i);
  }
}

/**
 * 主绘制循环 —— 每帧执行
 *
 * 流程：
 *   1. 从 GUI 读取最新参数
 *   2. 遍历所有粒子：查询流场 → 更新位置 → 绘制线段
 *   3. 粒子出界或生命耗尽时重置
 *   4. 更新临时流场（衰减用户绘制的向量）
 */
void draw()
{
  // 从 GUI 滑块读取最新参数
  ff.setRadius(gui.getR());
  ff.setForce(gui.getF());
  particleSize = gui.getS();

  float vx;
  float vy;
  PVector v;

  for (int i = 0; i < NB_PARTICLES; i++)
  {
    // 保存上一帧位置，用于绘制线段
    tabParticles[i].prevX = tabParticles[i].x;
    tabParticles[i].prevY = tabParticles[i].y;

    // 查询当前位置的流场向量
    v = ff.lookup(tabParticles[i].x, tabParticles[i].y);
    vx = v.x;
    vy = v.y;

    // 限制最大速度，防止粒子飞出画面
    vx = constrain(vx, -MAX_PARTICLE_SPEED, MAX_PARTICLE_SPEED);
    vy = constrain(vy, -MAX_PARTICLE_SPEED, MAX_PARTICLE_SPEED);

    // 更新粒子位置
    tabParticles[i].x += vx;
    tabParticles[i].y += vy;

    // 生命值递减
    tabParticles[i].count--;

    // 粒子出界或生命耗尽 → 重置
    if ((tabParticles[i].x < 0) || (tabParticles[i].x > imageW-1) ||
      (tabParticles[i].y < 0) || (tabParticles[i].y > imageH-1) ||
      tabParticles[i].count < 0) {
      setParticle(i);
    }

    // 绘制从上一帧位置到当前位置的线段，模拟笔触效果
    strokeWeight(1.5*particleSize);
    stroke(tabParticles[i].myColor, 250); // 250/255 透明度，略带透明感
    line(tabParticles[i].prevX, tabParticles[i].prevY, tabParticles[i].x, tabParticles[i].y);
  }

  // 每帧衰减临时流场，使鼠标绘制效果逐渐消散
  ff.updateField();
}

/**
 * 鼠标拖拽事件
 * 如果鼠标在 GUI 控件区域（右下角）则忽略，避免误触
 * 否则将拖拽方向写入流场
 */
void mouseDragged() {
  if(mouseX>950 && mouseY>830) return; // 排除 GUI 控件区域
  ff.onMouseDrag();
}

/**
 * 键盘事件
 * 按 S 键保存当前流场到文件（目前已被注释掉）
 */
void keyPressed() {
  //if (key =='s' || key == 'S') {
  //  ff.saveField();
  //}
}

/**
 * 自定义向量类 —— 继承 Processing 的 PVector
 *
 * 扩展了以下属性：
 *   prevX, prevY —— 上一帧的位置，用于绘制线段
 *   count         —— 生命值（剩余帧数），归零后粒子重置
 *   myColor       —— 从原图采样的颜色
 */
class myVector extends PVector
{
  myVector (float p_x, float p_y) {
    super(p_x, p_y);
  }
  float prevX;   // 上一帧 x 坐标
  float prevY;   // 上一帧 y 坐标
  int count;     // 剩余生命帧数
  color myColor; // 粒子颜色（来自原图像素）
}
