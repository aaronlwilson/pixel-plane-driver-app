class ClipColorWash extends AbstractClip {  
 
  //CLASS VARS
  private float _speed;
  private float _angle;
  private color _color;
  private float _rCut = 1;
  private float _gCut = 1;
  private float _bCut = 1;
  private float _angle1;
  private float _angle2;
  private float _angleCalc;
  private float _spreadCalc; 

  //constructor
  ClipColorWash(String theClipName, String theChannel) {
    super(theClipName, theChannel);
  } 
  
  public void init() {
    super.init();
    
    setParamDefault(1, 50);
    setParamDefault(2, 50);
    setParamDefault(3, 50);
    
    //set the knob titles for this clips gui mapping
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob1", "angle");
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob2", "speed");
    animationCanvas.getChannelCanvas(channel).setControllerText(".knob3", "spread");
    
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".openfile", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".slider2D", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".sliderX", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".sliderY", true);
    animationCanvas.getChannelCanvas(channel).setControllerHidden(".textInput", true);
  }

  public void run() {
    //_rCut = Utils.getPercent(p1, 100) *.01f;
    //_gCut = Utils.getPercent(p2, 100) *.01f;
    //_bCut = Utils.getPercent(p3, 100) *.01f;
    
    _angle1 = (float)p1/100;
    _angle2 = (float)Math.abs((p1-100))/100;
    
    _speed += (float)p2/10; 
    _spreadCalc = (float)p3/50;
  }

  public void die() {

  }

  public int[] drawNode(Node node) {
    _angleCalc =  node.y * _angle1;
    _angleCalc += node.x * _angle2;
    
    //_angleCalc = Utils.getPercent(node.x, stateManager.stageWidth);
    _angle = _angleCalc*_spreadCalc;
    
    colorMode(HSB, 100);  // Use HSB with scale of 0-100
    _color = color((_angle+_speed)%100, 100, 100);
    
    //_color = Color.HSBtoRGB(_speed + _angle, 1, 1);
    //_color = color(50, 100, 100);
    colorMode(RGB, 255);
   
    /*
    super.nodestate[0] = (int) (Utils.getR(_color) * _rCut);
    super.nodestate[1] = (int) (Utils.getG(_color) * _gCut);
    super.nodestate[2] = (int) (Utils.getB(_color) * _bCut);
    */
    
    super.nodestate[0] = int(Utils.getR(_color));
    super.nodestate[1] = int(Utils.getG(_color));
    super.nodestate[2] = int(Utils.getB(_color));
    
    return super.nodestate; // RGBXY
  } 
  
}
