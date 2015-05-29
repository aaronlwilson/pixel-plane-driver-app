class ClipSyphon extends AbstractClip {   
  
  //CLASS VARS
  private color _color;
  private PImage image;
  private SyphonClient client;
  
  private float scaleRatio;
  private float scale;
  private float offsetX;
  private float offsetY;
  private int imageW;
  private int imageH;

  //constructor
  ClipSyphon(String theClipName, String theChannel) {
    super(theClipName, theChannel);
  } 
  
  public void init() {
    super.init();
    
    println("Available Syphon servers:");
    println(SyphonClient.listServers());
    
    // Create syhpon client to receive frames 
    // from running server with given name: 
    client = new SyphonClient(app);
  
    // A Syphon server can be specified by the name of the application that it contains it,
    // its name, or both:
    
    // Only application name.
    //client = new SyphonClient(this, "SendFrames");
      
    // Both application and server names
    //client = new SyphonClient(this, "SendFrames", "Processing Syphon");
    
    // Only server name
    //client = new SyphonClient(this, "", "Processing Syphon");
      
    // An application can have several servers:
    //client = new SyphonClient(this, "Quartz Composer", "Raw Image");
    //client = new SyphonClient(this, "Quartz Composer", "Scene");
    
    //set the knob titles for this clips gui mapping
    /*
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob1", "scale");
    animationCanvas.getChannelCanvas(channel).setControllerText(".slider2D", "position");

    animationCanvas.getChannelCanvas(channel).setControllerHidden(".openfile", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".sliderX", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".sliderY", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".knob2", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".knob3", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".textInput", true);
    */
  }

  public void run() {
    if (client.available()) {
      // The first time getImage() is called with 
      // a null argument, it will initialize the PImage
      // object with the correct size.
      image = client.getImage(image); // load the pixels array with the updated image info
    }
    
    if(image != null){ 
      imageW = image.width;
      imageH = image.height;
      
      //scale is the ratio of pixels in the image to actual nodes and how far they are spaced
      //when p1 is 50%, the image is scaled to fill the stage horizontally
      float w = app.stateManager.stageWidth/nodeSpacing;
      scaleRatio = (imageW / w);
      
      scale = scaleRatio * (p1/50) - 0.001f;
      if(scale <0) scale = 0;
      //println("scale " + scale);
      
      offsetX = (p4-50)*(scaleRatio/1.5);
      offsetY = (p5-50)*(scaleRatio/1.5);
    }
  }

  public void die() {

  }

  public int[] drawNode(Node node) {  
    if(image != null){ 
        int tx = int(((node.x * scale) / nodeSpacing) - offsetX);
        int ty = int(((node.y * scale) / nodeSpacing) - offsetY);

        _color = color(image.get(tx % imageW, ty % imageH));

        nodestate[0] = int(Utils.getR(_color));
        nodestate[1] = int(Utils.getG(_color));
        nodestate[2] = int(Utils.getB(_color));
      }
  
      return super.nodestate; // RGBXY
  } 
  
}
