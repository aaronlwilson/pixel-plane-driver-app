class ClipAnimatedGif extends AbstractClip {   
  
  //CLASS VARS
  private color _color;
  
  private PImage[] animation;
  private PImage image;
  private int imageCount;
  private int frame;
  private int tick;
  private int ticksPerFrame;
  private float scaleRatio;
  private float scale;
  private float offsetX;
  private float offsetY;
  private float posX;
  private float posY;
  private int imageW;
  private int imageH;
  

  //constructor
  ClipAnimatedGif(String theClipName, String theChannel) {
    super(theClipName, theChannel);
  } 
  
  public void init() {
    super.init();
    loadFile("animated/sonic.gif");

    frame = 0;
    offsetX = 0;
    offsetY = 0;
    
    //set the knob titles for this clips gui mapping
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob1", "scale");
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob2", "speed");
    animationCanvas.getChannelCanvas(channel).setControllerText(".slider2D", "position");
    
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".knob3", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".sliderX", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".sliderY", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".textInput", true);
  }

  public void run() {
    scale = scaleRatio * (p1/50) - 0.001f;
    if(scale <0) scale = 0;
    
    offsetX = (p4-50)*(scaleRatio/1.5);
    offsetY = (p5-50)*(scaleRatio/1.5);
    
    ticksPerFrame = (int)Math.floor(p2/10);
    tick++;
    
    if(tick > ticksPerFrame){//this controls the playback speed
      tick=0;
      frame++;
    }
   
    if(frame %imageCount ==0){
      frame = 0;
    }
    
    if(frame <= animation.length){
      image = animation[frame];
    }
  }
  
  public void loadFile(String filePath) {
    animation = Gif.getPImages(app, filePath);
    imageCount = animation.length;   
    image = animation[0];
    imageW = image.width;
    imageH = image.height;
    
    //scale is the ratio of pixels in the image to actual nodes and how far they are spaced
    //when p1 is 50%, the image is scaled to fill the stage horizontally
    float w = app.stateManager.stageWidth/nodeSpacing;
    scaleRatio = (imageW / w);
    
    posX = 10000*imageW;
    posY = 10000*imageH;
    
    frame = 0;
    offsetX = 0;
    offsetY = 0;
    
    posX = 1000*imageW;
    posY = 1000*imageH;
  
  }

  public void die() {

  }

  public int[] drawNode(Node node) {
    
    if(image != null){
      
      //int tx = int((node.x * scale) + offsetX);
      //int ty = int((node.y * scale) + offsetY);
      int tx = int(((node.x * scale) / nodeSpacing) - offsetX + posX);
      int ty = int(((node.y * scale) / nodeSpacing) - offsetY + posY);
      
      _color = color(image.get(tx % imageW, ty % imageH));
      
      super.nodestate[0] = int(Utils.getR(_color));
      super.nodestate[1] = int(Utils.getG(_color));
      super.nodestate[2] = int(Utils.getB(_color));
    }

    return super.nodestate; // RGBXY
  } 
  
  
  
}
