class StateManager  {   
 
  public Rabbit[] rabbitArray;
  public Tile[][] tileGrid;
  public Node[] nodeArray = new Node[0];
  
  public int stageHeight;
  public int stageWidth;
  public int minY = 10000;
  public int minX = 10000;
  public int maxY = 0;
  public int maxX = 0;

  //constructor
  StateManager() {
    rabbitArray = new Rabbit[0];
  } 

  public void saveHardwareConfiguration(int gridSizeX, int gridSizeY){
    //clear out the old nodes
    nodeArray = new Node[0];
    
    for(int y=0; y<gridSizeY; y++){
      for(int x=0; x<gridSizeX; x++){
        Tile tile = tileGrid[x][y];
        if(tile!=null){
          //println("occupant: tile"+tile.id);
          //add the nodes from this tile to the master list
          Node[] tNodeArray = tile.getNodeLayout((tile.snapX*72), (tile.snapY*72));
          nodeArray = (Node[]) concat(nodeArray, tNodeArray);
     
        }else{
          //println("empty");
        }
      }
    }
    calculateStageSize();
    
        
    //scale off the tile grid, even if its empty 
    if(gridSizeX >= gridSizeY){
      displayZoom = (500.0-10.0)/float(gridSizeX*72);
    }else{
      displayZoom = (565.0-10.0)/float(gridSizeY*72);
    }
    
    println("nodeArray LENGTH: " + nodeArray.length + " stageHeight: " + stageHeight + "  stageWidth: " + stageWidth +"  displayZoom: " + displayZoom);
    
  } //end saveHardwareConfiguration
  
  //create a stage that fits around the nodes
  public void calculateStageSize(){   
    minY = 10000;
    minX = 10000;
    maxY = 0;
    maxX = 0;
  
    int l = nodeArray.length;
    for(int i=0; i<l; i++){
      int y = nodeArray[i].y;
      if(y > maxY) maxY = y;
      if(y < minY) minY = y;
    }
    for(int i=0; i<l; i++){
      int x = nodeArray[i].x;
      if(x > maxX) maxX = x;
      if(x < minX) minX = x;
    }
    
    stageHeight = maxY-minY+6;
    stageWidth = maxX-minX+6;
    
    /*
    //scale off the nodes
    if(stageWidth > stageHeight-1){
      displayZoom = (500.0-10.0)/float(stageWidth);
    }else{
      displayZoom = (565.0-10.0)/float(stageHeight);
    }
    */
    
  }
  
  public XML generateStateXML(){
    String data = "<?xml version='1.0'?><grid width='0' height='0'></grid>";
    XML xml = parseXML(data);
    if (xml == null) {
      println("XML could not be parsed.");
    } else {
 
      xml.setInt("width", hardwareCanvas.gridSizeX);
      xml.setInt("height", hardwareCanvas.gridSizeY);
      
      for(int i=0; i<rabbitArray.length; i++){
        //loop thorugh and capture each controller (rabbit) to XML
        Rabbit r = rabbitArray[i];
        XML rabbit = xml.addChild("rabbit");
        rabbit.setInt("id", r.id);
        rabbit.setString("ip", r.ip);
        rabbit.setString("mac", r.mac);
        
        //loop and capture each tile to XML
        for(int j=0; j<r.tileArray.length; j++){
          XML tile = rabbit.addChild("tile");
          tile.setInt("id", r.tileArray[j].id);
          tile.setInt("snapX", r.tileArray[j].snapX);
          tile.setInt("snapY", r.tileArray[j].snapY);
          tile.setInt("rotation", r.tileArray[j].rotation);
        }
      }
      
      println(xml);
    }
    
    return xml;
  }
  
} 
