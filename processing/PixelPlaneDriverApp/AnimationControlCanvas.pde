
class AnimationControlCanvas extends Canvas {
  //CLASS VARS
  public ChannelCanvas channelCanvas1;
  public ChannelCanvas channelCanvas2;
  
  //this is a hacky way of grabbing the dynamic text as pixel data for use when scrolling text
  public PImage loadPixelsImage;  
  //for text input 
  //private PFont font = createFont("arial",20);
  public PFont font;
    
  
  //CONSTRUCTOR
  public AnimationControlCanvas() {
    super();
 
    channelCanvas1 = new ChannelCanvas("1", 0); //namespace and x position
    channelCanvas1.pre(); // use cc.post(); to draw on top of existing controllers.
    cp5.addCanvas(channelCanvas1); // add the canvas to cp5
    
    channelCanvas2 = new ChannelCanvas("2", 250);
    channelCanvas2.pre();
    cp5.addCanvas(channelCanvas2);
  }
 
  public void setup(PApplet theApplet) {
    font = loadFont("Standard0754-8.vlw");
    textFont(font);
  }  

  public void draw(PGraphics p) {
    if(viewId == 2){
      //basic background colors
      noStroke();
      fill(30);
      rect(0, 0, 1000, 30);//toolbar along the top
      rect(0, 35, 1000, 565);//node bg
      fill(150, 0, 150);
      rect(990, 30, 10, 10);
      fill(200,0,200);
      rect(0, 30, 1000, 5); 
      fill(12);
      rect(499, 35, 500, 565); 
      
      //these are the blocks that contain the clip perameters
      fill(20);
      rect(500+10, 150, 230, 290);//channel 1
      rect(750+10, 150, 230, 290);//channel 2
      
      
      //draw user input text
      stroke(50);
      fill(0);
      rect(500,460,channelCanvas1.textBoxWidth,72);
      rect(750,460,channelCanvas2.textBoxWidth,72);
      noStroke();
      
      fill(channelCanvas1.textColor);
      text(channelCanvas1.showText, 501,462,channelCanvas1.textBoxWidth-2,70);//channel 1
      fill(channelCanvas2.textColor);
      text(channelCanvas2.showText, 751,462,channelCanvas2.textBoxWidth-2,70);//channel 2
      
                  
      //draw the node state using current sceneManagers data
      fill(0);
      //get the full list of hardware nodes
      Node[] vNodeArray = stateManager.nodeArray;
      int l= vNodeArray.length;
      
      for(int i=0; i<l; i++){
        Node n = vNodeArray[i];
        int[] rgb = renderNode(n);
        
        //now store that color on the node so we can send it as UDP data to the lights
        n.r = rgb[0];
        n.g = rgb[1];
        n.b = rgb[2];
        
        //render node to screen
        fill(rgb[0], rgb[1], rgb[2]);

        //ellipse(20+ (n.x-1)*2, 50+ (n.y-1)*2, 8, 8);
        //rect(20+ (n.x-1)*2, 50+ (n.y-1)*2, 8*displayZoom, 8*displayZoom);
        
        //scale the pixels to fit the display width or height. Set in StateManager
        rect(0+((n.x-3)*displayZoom), 35+((n.y-3)*displayZoom), 2*displayZoom, 2*displayZoom);
      }//end for all nodes
      
      //render to LED hardware
      //TODO perhaps move this to a master loop...
      if(BROADCAST){
        for(int y=0; y< hardwareCanvas.gridSizeY; y++){
            for(int x=0; x< hardwareCanvas.gridSizeX; x++){
              Tile tile = stateManager.tileGrid[x][y];
              if(tile != null)networkManager.sendTileFrame(tile);
            }
        }
        
        //data latch
        networkManager.swapFrame();
      }
      
      //grab the entire screen as pixels
      loadPixelsImage = createImage(1000, 600, RGB);
      loadPixels(); 
      loadPixelsImage.pixels = pixels;
      
      //ESS
      noStroke();
      fill(255,128);
      // draw the spectrum
      /*
      for (int i=0; i<audioManager.bufferSize; i++) {
        rect(0+i,40,1,audioManager.audioFFT.spectrum[i]*500);
      }
      */
    }//end if viewId ==2
   
  }//end draw
  
  public ChannelCanvas getChannelCanvas(String canvasNum){
    if(canvasNum.equals("1")){
      return channelCanvas1;
    }else{
      return channelCanvas2;
    }
  }
  
  //drill down through the Animation GUI to determine final color for each node each frame
  public int[] renderNode(Node node){    
    //return this
    int[] rgb = new int[3];
    int[] rgb1 = new int[3];
    int[] rgb2 = new int[3];
    
    if(channelCanvas1.currentClip != null){
      rgb1 = channelCanvas1.currentClip.drawNode(node);
      //apply channel brightness
      rgb1[0] = int(rgb1[0] * (channelCanvas1.channelBrightness/100) * (channelCanvas1.rBrightness/100));
      rgb1[1] = int(rgb1[1] * (channelCanvas1.channelBrightness/100) * (channelCanvas1.gBrightness/100));
      rgb1[2] = int(rgb1[2] * (channelCanvas1.channelBrightness/100) * (channelCanvas1.bBrightness/100));
    }
    
    if(channelCanvas2.currentClip != null){
      rgb2 = channelCanvas2.currentClip.drawNode(node);
      //apply channel brightness
      rgb2[0] = int(rgb2[0] * (channelCanvas2.channelBrightness/100) * (channelCanvas1.rBrightness/100));
      rgb2[1] = int(rgb2[1] * (channelCanvas2.channelBrightness/100) * (channelCanvas1.gBrightness/100));
      rgb2[2] = int(rgb2[2] * (channelCanvas2.channelBrightness/100) * (channelCanvas1.bBrightness/100));
    }
    
    //blend channels together
    rgb[0] = rgb1[0] + rgb2[0];
    rgb[1] = rgb1[1] + rgb2[1];
    rgb[2] = rgb1[2] + rgb2[2];
    
    
    return rgb;
  }//end render node
  
  
}//end class
