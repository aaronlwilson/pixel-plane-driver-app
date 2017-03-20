class ClipGraphicEQ extends AbstractClip {   
  
  //CLASS VARS
  private color _color;
  
  private float amp;
  private int l;

  //constructor
  ClipGraphicEQ(String theClipName, String theChannel) {
    super(theClipName, theChannel);
  } 
  
  public void init() {
    super.init();
    
    //set the knob titles for this clips gui mapping
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob1", "hue");
    animationCanvas.getChannelCanvas(channel).setControllerText(".sliderX", "volume");
    animationCanvas.getChannelCanvas(channel).setControllerText(".sliderY", "damp");
    
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".openfile", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".slider2D", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".knob2", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".knob3", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".textInput", true);
  }

  public void run() {
      amp = ((p6)/50)*1.5;
      float damp = ((p7)/100);
      println(damp);
      audioManager.setDamp(damp);
      
      l = audioManager.audioFFT.spectrum.length;
  }

  public void die() {

  }

  public int[] drawNode(Node node) {
    
    //TODO change the number of bars
    //TODO flip or sideways
    //TODO top color and bottom color fade
            
    //get a  frequency from the x pos of this node
    float perX = Utils.getPercent(node.x, stateManager.maxX); 
    float perY = Utils.getPercent(node.y, stateManager.maxY);
  
    int freq = (int) floor((perX/100) * audioManager.bufferSize);
    
    float limit = audioManager.audioFFT.spectrum[l-freq+1]*(100*amp);
    float flipLimit = 100 - limit;
    

    colorMode(HSB, 100);  // Use HSB with scale of 0-100
    _color = color(p1, 100, 0);
   
    if(perY >  flipLimit){
      float c = (flipLimit+p1)%100; 
      _color = color(c, 100, 100);
    }
    
    colorMode(RGB, 255);
    
    super.nodestate[0] = int(Utils.getR(_color));
    super.nodestate[1] = int(Utils.getG(_color));
    super.nodestate[2] = int(Utils.getB(_color));
   
    return super.nodestate; // RGBXY
  } 
  
}
