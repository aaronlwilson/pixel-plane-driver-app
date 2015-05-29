
class Tile extends Controller<Tile> {
  public Rabbit parentRabbit;
  public int[][] numberPImageArray;
  public int[][] rotatedPImageArray;
  public Node[][] tileNodeArray = new Node[12][12]; //this tile holds references to all its nodes, and where they are mapped considering rotation
  
  private int bgFill = 100;
  private int bgOverFill = 130;
  private int bgHideFill = 190;
  private int xSpacing = 6;
  private int ySpacing = 6;
  private int xOff = 0;
  private int yOff = 0;  
  
  public int id;
  public int snapX = -1;// -1 means its outside of the tilegrid
  public int snapY = -1;
  public int rotation = 0;
  
  public boolean hidden = false;
  
 
  //CONSTRUCTOR
  Tile(ControlP5 cp5, Rabbit theParentRabbit, int theId) {
    super(cp5, "tile"+theParentRabbit.id+"-"+theId);  
    
    parentRabbit = theParentRabbit;
    id = theId;
    
    String imagePath = "ui/pixel_number_"+id+".gif";
    PImage numberPImage = loadImage(imagePath);
    numberPImageArray = new int[12][12];
    
    //convert the image to a 2d array so that it can be rotated 
    int loc = 0;
    for (int j=0; j<12; j++){
      for (int i=0; i<12; i++){
        int c = numberPImage.pixels[loc];
        numberPImageArray[i][j] = c;
        loc++;
      }
    }//end convert
    rotatedPImageArray = numberPImageArray;
    
    //snap to grid behavior onRelease
    this.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        if (event.getAction()==ControlP5.ACTION_RELEASED) {
          Tile tile = (Tile)event.getController();
          int x=int(tile.getPosition().x);
          int y=int(tile.getPosition().y);

          //if its already in the tileGrid, remove it
          int[] point = Utils.find2DIndex(stateManager.tileGrid, tile);
          if(point != null){
            stateManager.tileGrid[point[0]][point[1]] = null;
            println("TILE " + tile.getName() +" REMOVED FROM: "+point[0]+" , "+ point[1]);
          }
          
          int gridSizeX = hardwareCanvas.gridSizeX;
          int gridSizeY = hardwareCanvas.gridSizeY;
          int gridStartX = hardwareCanvas.gridStartX;
          int gridStartY = hardwareCanvas.gridStartY;
          
          //if its dropped on the grid, snap it in place
          if(x+tile.xOff>=gridStartX && y+tile.yOff>=gridStartY && x+tile.xOff<gridStartX+(72*gridSizeX) && y+tile.yOff<gridStartY+(72*gridSizeY)){
            tile.snapX = round((x+tile.xOff-gridStartX)/72);
            tile.snapY = round((y+tile.yOff-gridStartY)/72);
          }else{//not over the grid
            tile.snapX = -1;
            tile.snapY = -1;
          }
          
          //check that snap is within the grid, sorta redundant based on the above conditional     
          if(tile.snapX < gridSizeX && tile.snapX >= 0 && tile.snapY < gridSizeY && tile.snapY >= 0){
            //println("snapX! " + tile.snapX);
            //println("snapY! " + tile.snapY);
            //println("rotate! " + tile.rotation);
            
            if(stateManager.tileGrid[tile.snapX][tile.snapY] == null){
              stateManager.tileGrid[tile.snapX][tile.snapY] = tile;
              tile.setPosition(gridStartX+(tile.snapX*72), gridStartY+(tile.snapY*72));
              println("TILE " + tile.getName() +" ADDED AT: "+tile.snapX+" , "+ tile.snapY);
            }else{
              //tile dropped on a space that is occupied
              tile.snapX = -1;
              tile.snapY = -1;
            }
          }else{// didn't fit the current grid
            tile.snapX = -1;
            tile.snapY = -1;
          }
          
          //save the state as Nodes array
          stateManager.saveHardwareConfiguration(gridSizeX, gridSizeY);
        }
      }
    });
    
  }//end constructor
  
  
  //called by sceneManager to construct a scene of nodes
  public Node[] getNodeLayout(int xOffset, int yOffset){
    //TODO this could be redone to use the rotation matrix
    
    Node[] nodeArray = new Node[144]; 
    //rotation normal(north)
    int index = 0;
    int xPos= 3;
    int yPos= 3;
    
    if(rotation == 1){//rotation (east)
      xPos= 3+(12*xSpacing);
      yPos = -3;
    }else if(rotation == 2){//rotation (south)
      xPos= 3+(13*xSpacing);
      yPos= 3+(11*ySpacing);
    }else if(rotation == 3){//rotation (west)
      xPos= 9;
      yPos= 3+(12*ySpacing);
    }
    
    for (int j=0; j<12; j++){
      for (int i=0; i<12; i++){

        if(rotation == 0){//rotation normal(north)
          xPos += xSpacing;
        }else if(rotation == 1){//rotation (east)
          yPos += ySpacing;
        }else if(rotation == 2){//rotation (south)
          xPos -= xSpacing;
        }else if(rotation == 3){//rotation (west)
          yPos -= ySpacing;
        }

        Node node = new Node(xPos+xOffset-3, yPos+yOffset+3, index, this);
        
        tileNodeArray[i][j] = node;
        nodeArray[index] = node;
        index++;
      }//end i
      
      //NEW "ROW"
      if(rotation == 0){//rotation normal(north)
        xPos = 3;
        yPos += ySpacing;
      }else if(rotation == 1){//rotation (east)
        xPos -= xSpacing;
        yPos = -3;
      }else if(rotation == 2){//rotation (south)
        xPos= 3+(13*xSpacing);
        yPos -= ySpacing;
      }else if(rotation == 3){//rotation (west)
        xPos += xSpacing;
        yPos = 3+(12*ySpacing);
      }
      
    }//end j
    
    return nodeArray;
  }//end getNodeLayout

  public void setup(PApplet theApplet) {

  }//end setup
  
  public void draw(PApplet p) { 
    int x=int(getPosition().x);
    int y=int(getPosition().y);
    int w=int(getWidth());
    int h=int(getHeight());
    
    //BG
    p.noStroke();
    if(cp5.isMouseOver(this)){
      p.fill(bgOverFill);
    }else{
      p.fill(bgFill);
    }
    if(hidden) p.fill(bgHideFill);
    p.rect(x, y, w, h);
    
    //rotation chip
    p.fill(0xffffffff);
    if(snapX>-1 && snapY>-1 && snapX<hardwareCanvas.gridSizeX && snapY<hardwareCanvas.gridSizeY){
      p.fill(0xffffff00);//turn yellow if this tile is snapped in the grid
    }
    
    if(rotation==0){
      p.triangle(x,y,x+10,y,x,y+10);
    }else if(rotation==1){
      p.triangle(x+w, y, x+w-10, y, x+w, y+10);
    }else if(rotation==2){
      p.triangle(x+w, y+h, x+w-10, y+h, x+w, y+h-10);
    }else if(rotation==3){
      p.triangle(x,y+h,x,y+h-10,x+10,y+h);
    }
      
    //node grid
    int xPos= 2;
    int yPos= 2;
    
    for (int j=0; j<12; j++){
      for (int i=0; i<12; i++){
        p.fill(rotatedPImageArray[i][j]);
        p.rect(xPos+x, yPos+y, 2, 2);
        xPos += xSpacing;
      }
      xPos = 2;
      yPos += ySpacing;
    }
  }//end draw
  
  public void rotateTile(){
    rotation++;
    if(rotation >=4) rotation=0;
    
    //when showing the tile numbers, the nodes don't yet have color, the number is displayed by the tile
    rotatedPImageArray = Utils.rotateArrayClockwise(rotatedPImageArray);
    //tileNodeArray = Utils.rotateArrayClockwise(tileNodeArray);
  }
  
  // override various input methods for mouse input control
  void onPress() {
    if(hidden)return;
    cursor(HAND);
    bgOverFill = 160;
    this.bringToFront();
    Pointer p1 = getPointer();
    xOff = p1.x();
    yOff = p1.y();
  }
  
  void onRelease() {
    cursor(ARROW);
    bgOverFill = 130;
    if (app.mouseButton == RIGHT && !hidden) {
      rotateTile();
    }
  }//end onRelease

  void onDrag() {
    if(hidden)return;
    cursor(HAND);
    
    int x = app.mouseX-xOff;
    int y = app.mouseY-yOff;
    this.setPosition(x, y);
  }
  
  void onReleaseOutside() {
    onLeave();
  }
  
  /*
  void onEnter() {
    if(hidden)return;
  }
  
  void onLeave() {
  }
  
  void onClick() {
    if (mouseButton == RIGHT) {
    }
  }

  void onMove() {
    println("moving "+this+" "+_myControlWindow.getMouseOverList());
  }
  
  void onScroll(int n) {}
  */
}
