import controlP5.*;

class GUI {
  ControlP5 cp5;
  Slider sliderR;
  Slider sliderF;
  Slider sliderS;
  GUI(PApplet thePApplet){
    cp5 = new ControlP5(thePApplet);
  }
  
  void setup(){
    cp5.setColorBackground(0x141414);
    sliderR = cp5.addSlider("Radius")
                 .setPosition(980,890)
                 .setRange(1,20)
                 .setValue(12).setSize(150,25);
    sliderF = cp5.addSlider("Force")
                 .setPosition(980,918)
                 .setRange(0.1,0.5)
                 .setValue(0.3).setSize(150,25);
    sliderS = cp5.addSlider("Particle Size")
                 .setPosition(980,862)
                 .setRange(0.8,2)
                 .setValue(1.5).setSize(150,25);
    
  }
  
  int getR(){
    return int(sliderR.getValue());
  }
  
  float getF(){
    return sliderF.getValue();
  }
  
  float getS(){
    return sliderS.getValue();
  }
}