class ClipScreenCapture extends AbstractClip {   
  
  //CLASS VARS
  private color _color;
  
  private PImage image;
  
  private float scale;
  private int offsetX;
  private int offsetY;
  
  private int screenW;
  private int screenH;
  

  //constructor
  ClipScreenCapture(String theClipName, String theChannel) {
    super(theClipName, theChannel);
  } 
  
  public void init() {
    super.init();
    
    offsetX = 0;
    offsetY = 0;
    
    //set the knob titles for this clips gui mapping
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob1", "scale");
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob2", "width");
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob3", "height");
    animationCanvas.getChannelCanvas(channel).setControllerText(".slider2D", "position");
    
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".openfile", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".textInput", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".sliderX", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".sliderY", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".textInput", true);
  }

  public void run() {
    scale = (p1/50);
    
    screenW = int(p2*10)+1;
    screenH = int(p3*10)+1;
       
    //todo offset dependant on scale
    offsetX = int(p4*10);
    offsetY = int(p5*10);
    
    image = Utils.getScreen(offsetX, offsetY, screenW, screenH);

    /*
    float w = app.stateManager.stageWidth/nodeSpacing;
    scale = (imageW / w) * (p1/50) - 0.001f;
    if(scale <0) scale = 0;
    //println("scale " + scale);
    */
  }

  public void die() {

  }

  public int[] drawNode(Node node) {
   
    if(image != null){
      int tx = int(node.x * scale);
      int ty = int(node.y * scale);
      _color = color(image.get(tx % screenW, ty % screenH));
      
      super.nodestate[0] = int(Utils.getR(_color));
      super.nodestate[1] = int(Utils.getG(_color));
      super.nodestate[2] = int(Utils.getB(_color));
      
    }

    return super.nodestate; // RGBXY
  } 
  
  
  
}
