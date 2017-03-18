class ClipBasic extends AbstractClip {   
  
  //CLASS VARS
  private color _color;
  
  int numColors = 3;
  int[] c = new int[numColors*3];
  int currentNode = 0;
  int count   = 0;
  
  float hue = 100;
  float saturation = 100;
  float brightness = 100;

  //constructor
  ClipBasic(String theClipName, String theChannel) {
    super(theClipName, theChannel);
  } 
  
  public void init() {
    super.init();
    
    //green
    c[0] = 254;//255 is max
    c[1] = 0;
    c[2] = 0;
    
    //blue
    c[3] = 0;
    c[4] = 254;
    c[5] = 0;
    
    //blue
    c[6] = 0;
    c[7] = 0;
    c[8] = 254;
    
    //set the knob titles for this clips gui mapping
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob1", "hue");
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob2", "saturation");
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob3", "brightness");
    
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".openfile", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".sliderX", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".sliderY", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".slider2D", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".textInput", true);
  }

  public void run() {
    currentNode++;//increment node for scanning effect
    if(currentNode >= 144){
      currentNode = 0; 
     
      count+=3;//increment color
      if(count >= (numColors*3)){
        count = 0;
      } 
    }
    
    hue = p1;
    saturation = p2;
    brightness = p3;
  }

  public void die() {

  }

  public int[] drawNode(Node node) {

    //FOR QUICKLY TESTING TILES, JUST ROTATE ALL RED, GREEN, BLUE

    super.nodestate[0] = c[count + 1]; //b
    super.nodestate[1] = c[count + 0]; //r
    super.nodestate[2] = c[count + 2]; //g
    return super.nodestate; // RGBXY
      
      
      /*
    //PUT BACK this bit for production
    colorMode(HSB, 100);  // Use HSB with scale of 0-100
    _color = color(hue, saturation, brightness);
    colorMode(RGB, 255);
        
    super.nodestate[0] = int(Utils.getR(_color));
    super.nodestate[1] = int(Utils.getG(_color));
    super.nodestate[2] = int(Utils.getB(_color));
    return super.nodestate; // RGBXY
    
    */
  } 
  
}
