class ClipNodeScan extends AbstractClip {   
  
  //CLASS VARS
  private color _color;

  //constructor
  ClipNodeScan(String theClipName, String theChannel) {
    super(theClipName, theChannel);
  } 
  
  public void init() {
    super.init();
  }

  public void run() {

  }

  public void die() {

  }

  public int[] drawNode(Node node) {
        
    super.nodestate[0] = 0;
    super.nodestate[1] = 0;
    super.nodestate[2] = 0;
    
    //OLD 
    /*   
    int r = Utils.getR(node.cc);
    int g = Utils.getG(node.cc);
    int b = Utils.getB(node.cc);
    
    if(node.index == frame){
      r = 255;
      g = 255;
      b = 255;
    }
    
    node.r = r;
    node.g = g;
    node.b = b;
    
    rgb[0] = r;
    rgb[1] = g;
    rgb[2] = b;
    */
    
    return super.nodestate; // RGBXY
  } 
  
}
