class ClipImageScroll extends AbstractClip {   
  
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
  ClipImageScroll(String theClipName, String theChannel) {
    super(theClipName, theChannel);
  } 
  
  public void init() {
    super.init();
    
    //TODO, these don't change the knob values
    //setParamDefault(1, 50);
    //setParamDefault(2, 50);
    //setParamDefault(3, 50);  
    
    loadFile("still/yoshi.gif");
    
    //set the knob titles for this clips gui mapping
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob1", "scale");
    animationCanvas.getChannelCanvas(channel).setControllerText(".slider2D", "position");
    animationCanvas.getChannelCanvas(channel).setControllerText(".sliderX", "X scroll");
    animationCanvas.getChannelCanvas(channel).setControllerText(".sliderY", "Y scroll");
    
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".knob2", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".knob3", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".textInput", true);
  }

  public void run() {   
    scale = scaleRatio * (p1/50) - 0.001f;
    if(scale <0) scale = 0;
    //println("scale " + scale);
    
    offsetX = (p4-50)*(scaleRatio/1.5);
    offsetY = (p5-50)*(scaleRatio/1.5);
   
    speed = p2/100;
    speedX = (p6-50)/10;
    speedY = (p7-50)/10;
    
    posX -= (speed*speedX);
    posY -= (speed*speedY);  
  }
  
  public void loadFile(String filePath) {
    image = loadImage(filePath);
    imageW = image.width;
    imageH = image.height;
    //scale is the ratio of pixels in the image to actual nodes and how far they are spaced
    //when p1 is 50%, the image is scaled to fill the stage horizontally
    float w = app.stateManager.stageWidth/nodeSpacing;
    scaleRatio = (imageW / w);
    
    offsetX = 0;
    offsetY = 0;
    
    posX = 1000*imageW;
    posY = 1000*imageH;
  }

  public void die() {

  }

  public int[] drawNode(Node node) {
    if(image != null){
    
      int tx = int(((node.x * scale) / nodeSpacing) - offsetX + posX);
      int ty = int(((node.y * scale) / nodeSpacing) - offsetY + posY);
      
      //if(tx < 1) tx = imageW - (tx % imageW);
      //if(ty < 1) ty = imageH - (ty % imageH);
      
      _color = color(image.get(tx % imageW, ty % imageH));
      //_color = color(image.get(node.x % image.width, node.y % image.height));
      
      nodestate[0] = int(Utils.getR(_color));
      nodestate[1] = int(Utils.getG(_color));
      nodestate[2] = int(Utils.getB(_color));
    }

    return super.nodestate; // RGBXY
  } 
  
}
