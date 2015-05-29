class Rabbit  { 
  public String ip;
  public int id;
  public String mac;
  public int numTiles;
  
  public Tile[] tileArray;

  //constructor
  Rabbit(String theIp, int theId, String theMac) {  
    ip = theIp;
    id = theId;
    mac = theMac;
  }    
  
  public void removeAllTiles(){
     //clean out any old tile objects and the p5 controllers associated with them
    if(tileArray == null) return;
    for(Tile oldTile : tileArray){
      //if its already snapped in the tileGrid, remove it
      int[] point = Utils.find2DIndex(stateManager.tileGrid, oldTile);
      if(point != null){
        stateManager.tileGrid[point[0]][point[1]] = null;
        println("TILE " + oldTile.getName() +" REMOVED FROM: "+point[0]+" , "+ point[1]);
      }
      cp5.remove(oldTile.getName());//delete the controller
    }
    stateManager.saveHardwareConfiguration(hardwareCanvas.gridSizeX, hardwareCanvas.gridSizeY);
          
  }//end removeAllTiles

} 
