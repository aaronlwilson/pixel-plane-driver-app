class ClipText extends AbstractClip {   
  
  //CLASS VARS
  private color _color;
  private PImage image;
  private float scaleRatio;
  private float scale;
  private float speed;
  private float speedX;
  private float speedY;
  private float posX;
  private float posY;
  private float offsetX;
  private float offsetY;
  private int imageW;
  private int imageH;

  //constructor
  ClipText(String theClipName, String theChannel) {
    super(theClipName, theChannel);
  } 
  
  public void init() {
    super.init();
    
    float w = stateManager.stageWidth/nodeSpacing;
    scaleRatio = (36 / w);
    
    
    //set the knob titles for this clips gui mapping
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob1", "scale");
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob2", "hue");
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob3", "box width");
    animationCanvas.getChannelCanvas(channel).setControllerText(".slider2D", "position");
    animationCanvas.getChannelCanvas(channel).setControllerText(".sliderX", "X scroll");
    animationCanvas.getChannelCanvas(channel).setControllerText(".sliderY", "Y scroll");
    
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".openfile", true);
    
  }

  public void run() {
    
    float p = p3;
    if(p <2) p = 2.0f;
    imageW= int(p*2.5)-2;
    imageH= 70;
    image = createImage(imageW, imageH, RGB);
    
    scale = (scaleRatio * (p1/50)) - 0.001f;
    
    offsetX = (p4-50);
    offsetY = (p5-50);
   
    speed = 1;
    speedX = (p6-50)/10;
    speedY = (p7-50)/10;
    
    posX -= (speed*speedX);
    posY -= (speed*speedY); 
        
    for(int y=0; y<imageH; y++){
      for(int x=0; x<imageW; x++){ 
        // Create a grayscale color based on random number 
        //float rand = random(255);
        //color c = color(rand);
        int channelOff = 0;
        if(channel.equals("2")) channelOff = 250;
        image.set(x, y, animationCanvas.loadPixelsImage.get(x+501+channelOff, y+461));
      }
    }
    
  }//end run

  public void die() {

  }

  public int[] drawNode(Node node) {
    
    //int tx = int((node.x * scale) - offsetX + posX);
    //int ty = int((node.y * scale) - offsetY + posY);
    
    int tx = int(((node.x * scale) / nodeSpacing) - offsetX + posX);
    int ty = int(((node.y * scale) / nodeSpacing) - offsetY + posY);
    
    _color = color(image.get(tx % imageW, ty % imageH));
    
    //colorMode(HSB, 100);  // Use HSB with scale of 0-100
    //_color = color(p1, 100, 100);
    //colorMode(RGB, 255);
        
    super.nodestate[0] = int(Utils.getR(_color));
    super.nodestate[1] = int(Utils.getG(_color));
    super.nodestate[2] = int(Utils.getB(_color));
   
    return super.nodestate; // RGBXY
  } 
  
}
