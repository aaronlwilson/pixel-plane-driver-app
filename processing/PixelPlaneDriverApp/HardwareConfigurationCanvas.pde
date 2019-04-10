
class HardwareConfigurationCanvas extends Canvas {
  //CLASS VARS
  private Accordion accordion;
  
  public int gridSizeX = 0;
  public int gridSizeY = 0;
  public int gridStartX = 230;
  public int gridStartY = 200;
 
  
  private PFont font = createFont("PT Mono",16);  
  
  //CONSTRUCTOR
  public HardwareConfigurationCanvas() {
    super();
    
    cp5.addButton("SEARCH FOR CONTROLLERS")
       .setValue(0)
       .setPosition(10,45)
       .setSize(115,25)
       .plugTo(this,"rabbitSearch")
       .moveTo("Hardware Configuration");
       
    cp5.addButton("ADD CONTROLLER")
       .setValue(0)
       .setPosition(130,45)
       .setSize(80,25)
       .plugTo(this,"rabbitDemo")
       .moveTo("Hardware Configuration");
     
    
    //enter the dimentions of your grid  
    cp5.addTextfield("grid size X")
     .setPosition(10, 550)
     .setSize(50,30)
     .setFont(font)
     .setFocus(true)
     .moveTo("Hardware Configuration");
     
    cp5.addTextfield("grid size Y")
     .setPosition(80, 550)
     .setSize(50,30)
     .setFont(font)
     .setFocus(false)
     .moveTo("Hardware Configuration");
     
    cp5.addButton("SET GRID")
     .setPosition(150,550)
     .setSize(50,30) 
     .plugTo(this,"setGrid")
     .moveTo("Hardware Configuration")
     .getCaptionLabel().align(CENTER,CENTER);
     
     //The accordion that holds each rabbit group
     accordion = cp5.addAccordion("accordion")
               .setPosition(10,75)
               .setWidth(200)
               .moveTo("Hardware Configuration");
  }
 
  public void setup(PApplet theApplet) {
    
  }  

  public void draw(PGraphics p) { 
      if(viewId == 1){
        //basic background colors
        noStroke();
        background(210);
        fill(150);
        rect(0, 0, 1000, 30);//toolbar along the top
        fill(180);
        rect(0, 30, 220, 600);
        fill(150);
        rect(0, 540, 220, 60);
        fill(255,128,0);
        rect(0, 30, 1000, 5); 
      }
      
      //DRAW snappy grid for dropping tiles 
      if(gridSizeX > 0 && gridSizeY > 0){
        p.noFill();
        p.stroke(100);
        
        int xSpacing = 72;
        int xPos= gridStartX;
        int ySpacing = 72;
        int yPos= gridStartY;
        
        for(int j=0; j<gridSizeY; j++){
          for(int i=0; i<gridSizeX; i++){
            p.rect(xPos, yPos, xSpacing, ySpacing);
            xPos += xSpacing;
          }
          xPos = gridStartX;
          yPos += ySpacing;
        }
      }
     
  }//end draw
  
  public int deleteAllRabbits()
  {
    //check for the model
    int l = stateManager.rabbitArray.length;
    if(l>0){
      for(int i=0; i<l; i++){
        //delete all rabbits, rabbit Group Gui and tiles
        Rabbit rabbit = stateManager.rabbitArray[i];
        cp5.remove("TEST TILES "+rabbit.id);
        cp5.remove("TILE NUMBER "+rabbit.id);
        cp5.remove("IP_FIELD "+rabbit.id);
        cp5.remove("IP_LABEL "+rabbit.id);
        cp5.remove("MAC_LABEL "+rabbit.id);
        cp5.remove("RABBIT "+rabbit.id);
        rabbit.removeAllTiles();
        rabbit = null;
      }
      //null out the array
      stateManager.rabbitArray = new Rabbit[0];
    }
    return l;
  } //end deleteAllRabbits
    
  //this is an echo back from the IP Discovery service, also called by "ADD CONTROLLER" button, and parseXML function
  public Rabbit createRabbit(String ip, String mac, boolean canEdit){
    //first see if we already have a rabbit loaded with tiles placed, 
    //we can compare the MAC address and update the IP if DHCP changed it
    if(stateManager.rabbitArray.length > 0 && canEdit == false){
      for(Rabbit r : stateManager.rabbitArray){
        if(r.mac.equals(mac)){
          //just update the ip of our rabbit instead of making a new one.
          r.ip = ip;
          println( "FOUND RABBIT, by MAC: " + mac );    
           
          //update the IP address label    
          cp5.get(Textlabel.class, "IP_LABEL "+r.id).setText("IP: " +r.ip);
          
          accordion.open(0);
          return r;
        }
      }
    }
    
    //so we dont have that rabbit.mac, create an array with one spot
    Rabbit[] rArray = new Rabbit[1];    
    int id = stateManager.rabbitArray.length + 1;
    
    Rabbit r = new Rabbit(ip, id, mac);
    rArray[0] = r;
    accordion.addItem(createRabbitGroup(r, canEdit));   
                      
    stateManager.rabbitArray = (Rabbit[]) concat(stateManager.rabbitArray, rArray);
     
    accordion.open(0);
    return r;
    
  }//end createRabbit
  
  public Group createRabbitGroup(Rabbit rabbit, boolean canEdit){
    
    Group g = cp5.addGroup("RABBIT "+rabbit.id)
                  .setBackgroundColor(color(0, 64))
                  .setPosition(0,0)
                  .setId(rabbit.id)
                  .setBackgroundHeight(40);
     
    g.addListener(new RabbitGroupControlListener());            
          
          
    if(canEdit == true){ 
      //this is the result of "ADD CONTROLLER BUTTON"
      Textfield ipField = cp5.addTextfield("IP_FIELD "+rabbit.id)
       .setPosition(10,10)
       .setSize(180,20)
       .setFont(font)
       .moveTo(g)
       .setId(rabbit.id)
       .setAutoClear(false)
       .setFocus(true);  
      
      
      ipField.setText(rabbit.ip);
      ipField.getCaptionLabel().setText("Enter IP address"); 
    
    }else{                 
      Textlabel ipTextLabel = cp5.addTextlabel("IP_LABEL "+rabbit.id)
                        .setText("IP: " + rabbit.ip)
                        .setPosition(5,5)
                        .setColorValue(0xffffffff)
                        .setFont(createFont("PT Mono",16))
                        .moveTo(g);   
                        
      Textlabel macTextLabel = cp5.addTextlabel("MAC_LABEL "+rabbit.id)
                      .setText("MAC: " + rabbit.mac)
                      .setPosition(5,25)
                      .setColorValue(0xffffffff)
                      .setFont(createFont("PT Mono",14))
                      .moveTo(g);                 
    }
         
    Textfield tileNumberField = cp5.addTextfield("TILE NUMBER "+rabbit.id)
       .setPosition(10, 60)
       .setSize(50,20)
       .setFont(font)
       .moveTo(g)
       .setFocus(false);   
    tileNumberField.getCaptionLabel().setText("number of tiles   ( 9 max )");       
  
    Button testButton = cp5.addButton("TEST TILES "+rabbit.id)
       .setPosition(110,60)
       .setSize(80,20)
       .moveTo(g)
       .setId(rabbit.id);
    testButton.getCaptionLabel().setText("test tiles"); 
       
    testButton.getCaptionLabel().align(CENTER,CENTER);
       
    testButton.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction()==ControlP5.ACTION_RELEASED) {
          
          //This block creates the specified number of tiles connected to this rabbit
          int id = theEvent.getController().getId();
          println("RABBIT TEST " +  id);
          
          int numTiles = int(cp5.get(Textfield.class,"TILE NUMBER "+id).getText());
          if(numTiles <1 || numTiles > MAXTILES){
            numTiles = MAXTILES;
          }
    
          int xPos = 230;
          int yPos = 20 + (30*id);
          
          //store the newly created tiles in the rabbit model so that they can be hidden when other rabbits are selected
          Rabbit rabbit = stateManager.rabbitArray[id-1];
          rabbit.removeAllTiles();
          
          //empty / initialize the array to hold the child tiles
          rabbit.tileArray = new Tile[numTiles];
          
          for(int i=1; i<=numTiles; i++){
            Tile tile = createTile(rabbit, i, xPos, yPos);
            
            //represent the state of this tile on the hardware
            networkManager.sendNumberFrame(tile);
            xPos += 82;
          }
          networkManager.swapFrame();
        }
      }
    });
       
    return g;
  }//end createRabbitGroup
  
  public void rabbitSearch() {
    println("RABBIT SEARCH");
     
    deleteAllRabbits(); 
    //ping the entire network looking for rabbits
    if(BROADCAST){
      networkManager.broadcastIpSearch();
    }else{
      //todo error message, broadcast is not enabled
    }
  }// end rabbitSearch
  
  public void rabbitDemo() {
    createRabbit("X.X.X.X", "", true);
  }// end rabbitDemo
  
  public Tile createTile(Rabbit rabbit, int id, int xPos, int yPos){
    Tile t = new Tile(cp5, rabbit, id)
                      .setPosition(xPos, yPos)
                      .setSize(72, 72)
                      .moveTo("Hardware Configuration");
                      
    rabbit.tileArray[id-1] = t;          
    return t;
  }//end createTile
  
  public void setGrid() {
    int newGridSizeX = int(cp5.get(Textfield.class,"grid size X").getText());
    int newGridSizeY = int(cp5.get(Textfield.class,"grid size Y").getText());
    println("SET GRID| gridSizeX: "+newGridSizeX+" gridSizeY: "+newGridSizeY);
    
    Tile[][] newTileGrid = new Tile[newGridSizeX][newGridSizeY];
    
    //check to see if there are already tiles in the old grid....
    for(int y=0; y<gridSizeY; y++){
      for(int x=0; x<gridSizeX; x++){
        Tile tile = stateManager.tileGrid[x][y];
        if(tile!=null){
          //if the old tile is still in bounds of the new grid, then move it over.
          if(x < newGridSizeX && y < newGridSizeY){
            newTileGrid[x][y] = tile; 
          }
        }
      }
    }

    stateManager.tileGrid = newTileGrid;
    gridSizeX = newGridSizeX;
    gridSizeY = newGridSizeY;
    stateManager.saveHardwareConfiguration(gridSizeX, gridSizeY);
  }
  
  public void parseHardwareXML(XML xml){ 
    //temporarily hide tab/groups while we create components so that drawing is disabled
    viewId = 0;
    cp5.getTab("default").bringToFront();
    
    //set up the grid for the tiles to snap into
    String w = xml.getString("width");
    String h = xml.getString("height");
    println("loaded hardware XML| width: " + w + " height: " + h);
    cp5.get(Textfield.class,"grid size X").setText(w);
    cp5.get(Textfield.class,"grid size Y").setText(h);
    setGrid();
    
    deleteAllRabbits();
    XML[] rabbits = xml.getChildren("rabbit");

    for(int j=0; j<rabbits.length; j++){  
      //println(rabbits[j].getString("ip"));
      Rabbit rabbit = createRabbit(rabbits[j].getString("ip"), rabbits[j].getString("mac"), false);
      
      XML[] tiles = rabbits[j].getChildren("tile");
      stateManager.rabbitArray[j].tileArray = new Tile[tiles.length];
      
      //set the number of tiles to the text box
      cp5.get(Textfield.class, "TILE NUMBER "+rabbit.id).setText(str(tiles.length));
      
      for (int i = 0; i < tiles.length; i++) {
        int id = tiles[i].getInt("id");
        int snapX = tiles[i].getInt("snapX");
        int snapY = tiles[i].getInt("snapY");
        int rotation = tiles[i].getInt("rotation");
 
        Tile tile = createTile(stateManager.rabbitArray[j], id, 100, 100);
        tile.snapX = snapX;
        tile.snapY = snapY;
        
        if(rotation > 0){
          for(int r = 0; r < rotation; r++) {//i is already in use
            tile.rotateTile();
          }
        }
       
        //place each tile in the grid, or outside the grid
        if(tile.snapX>=0 && tile.snapY>=0 && tile.snapX<gridSizeX && tile.snapY<gridSizeY){ //check array bounds
          if(stateManager.tileGrid[tile.snapX][tile.snapY] == null){
            stateManager.tileGrid[tile.snapX][tile.snapY] = tile;
            tile.setPosition(gridStartX+(tile.snapX*72), gridStartY+(tile.snapY*72));
            //println("TILE ADDED AT: "+tile.snapX+" , "+ tile.snapY);
            
            //represent the state of this tile on the hardware
            networkManager.sendNumberFrame(tile);
          }else{
            println("ERROR: attempting to add a tile to an occupied spot in the grid");
          }
        }else{
          println("The tile: " + tile.id + " is outside of the grid");
          tile.setPosition(230+(82*(tile.id-1)), 20+(30*rabbit.id));
        }
      }//end tile for loop
      
      selectedRabbitGroup(1);
    }//end rabbit loop
    
    //save the state as Nodes array
    stateManager.saveHardwareConfiguration(gridSizeX, gridSizeY);
    
    //data latch
    networkManager.swapFrame(); //assuming network conf has not changed.
    
    //OK, now show the loaded hardware configuration view
    cp5.getTab("Hardware Configuration").bringToFront();
    viewId = 1;
    
    //now we have a new project loaded, scan the network to see if IP addresses are different
    networkManager.broadcastIpSearch();
    
  }//end parseHardwareXML
  
  public void resetAllHardware(){
    //blackout LEDs
    //why do we need multiple calls to push the data through? anyway, wash it out
    if(BROADCAST){
      for(int b=0; b<MAXTILES; b++){
        networkManager.blackOutAll(); 
      } 
    }
    
    cp5.get(Textfield.class,"grid size X").setText("0");
    cp5.get(Textfield.class,"grid size Y").setText("0");
    setGrid();
    
    deleteAllRabbits();
  } 
  
  public void selectedRabbitGroup(int id){
    for(Rabbit r : stateManager.rabbitArray){
      //Rabbit rabbit = stateManager.rabbitArray[id-1];
      boolean selected = false;
      if(r.id == id) selected = true;
      
      if(r.tileArray == null) continue;
      for (Tile t : r.tileArray) {
        t.hidden = true;
        if(selected) {
          t.hidden = false;
          t.bringToFront();
        }
      }
    }
  }
  
}//end HardwareConfigurationCanvas

//Implement ControlListener class. Since callbacks are not allowed on control groups...
class RabbitGroupControlListener implements ControlListener {
  public void controlEvent(ControlEvent theEvent) {
    //each time we open a group in the accordion, highlight the tiles associated with the rabbit represented by the group and hide the others
    if(theEvent.getGroup().isOpen()){
      int id = theEvent.getGroup().getId();
      hardwareCanvas.selectedRabbitGroup(id);
    }
  }
}
