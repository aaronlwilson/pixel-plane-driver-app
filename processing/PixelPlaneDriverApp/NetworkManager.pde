class NetworkManager  {   
    
  private UDP udp;                           // define the UDP object                          
  public String uniIp    = "255.255.255.255";//broadcast address to all devices on the network
  public int myPort      = 7777; //6000 also works
  
  public int rabbitPort  = 7;                //the destination port 
  public int[][] nodeMap = new int[12][12];  //translates normal cartisian coordinates to custom PixelPusher 3 serial line, interlaced mapping
  
  
  //only needed for the sendTestFrame method
  private int numColors = 3;
  private int[] c = new int[numColors*3];
  private int currentNode = 0;
  private int count   = 0;
  private int numNodes = 12*12;
  

  //constructor
  NetworkManager() {
    //from UDPclientRabbitPixelPlane
    //green
    c[0] = 255;
    c[1] = 0;
    c[2] = 0;
    
    //blue
    c[3] = 0;
    c[4] = 255;
    c[5] = 0;
    
    //red
    c[6] = 0;
    c[7] = 0;
    c[8] = 255;
    
    //fill a hash map with hardware node positions
    createNodeMap();  
    
    // create a new datagram connection on 6000
    // and wait for incomming message
    udp = new UDP( app, myPort );
    udp.setBuffer(2000);
    
    udp.log( false );     // <-- printout the connection activity, but performance is affected
    udp.listen( true );
  } 
  
  //the node map is a hash of how the bytes are ordered for the 3 serial lines of the Pixel Plane tile
  void createNodeMap(){
    for (int k=0; k<12; k++){//y
       for (int j=0; j<12; j++){//x
          int serial_port = (int) k/4; //what serial port does this coordinate belong to?
          //println(serial_port);
          int chipRow = (k%4)/2;// either 0 or 1
          int chipCol = (int) ((1-chipRow)*4);
          int chip_address = (int) chipCol+ (int)(j/3);
          //println(chip_address);
          
          int node_number = 0;
          
          if(k%2==0){//calculate the node number now
             if (j%3==0){
                node_number=4;
             }else if (j%3==1){
                node_number=5;
             }else{
                node_number=0; 
             }
       
          }else{
             //node_number=(j%3)+2;
             if (j%3==0){
                node_number=3;
             }else if (j%3==1){
                node_number=2;
             }else{
                node_number=1; 
             }
          }
   
          //we now have serialport chipadress and node number
          //now we need to calculate the corresponding address in the outbuff
          int OUTBUFF_position = ((chip_address*6*9)+node_number*9);//this is the base chip position
          OUTBUFF_position = OUTBUFF_position+serial_port;// offset by the corrct amount for the correct serial port.
          nodeMap[k][j] = OUTBUFF_position;
          
        }
     }
       /* 
       for (int y=0; y<12; y++){
         for (int x=0; x<12; x++){
           println(nodeMap[y][x]);
         }
       }
       */
  }
  
  //broadcast across the entire LAN, Rabbits will reply with their MAC address, and we get the IP
  public void broadcastIpSearch(){
    byte[] data = new byte[2];
    data[0] = (byte) (unhex("FF")); //listen for command
    data[1] = (byte) (unhex("FD")); 
    if(app.BROADCAST)udp.send( data, uniIp, rabbitPort );
  }
  
  //called by the draw() loop in AnimationControlCanvas, to change the frame. All pixels on all rabbits change at the same instant, 
  //to combat frame tearing on large displays
  public void swapFrame(){
    byte[] dataLatch = new byte[2];
    dataLatch[0] = (byte) (unhex("FF")); //listen for command
    dataLatch[1] = (byte) (unhex("FE"));
    if(app.BROADCAST)udp.send( dataLatch, uniIp, rabbitPort );
  }
  
  public void sendNumberFrame(Tile tile){
     int[][] frameArray = tile.numberPImageArray;
     
     //data for one tile, one frame
     byte[] data = new byte[(432+4)]; //144 nodes * 3 channels per node = 432
     
     data[0] = (byte) (unhex("ff")); //listen for command
     data[1] = (byte) (unhex("ff")); //chip command
     data[2] = (byte) (unhex("00")); //start command
     data[3] = byte(tile.id-1); //tile address
     
     //node map for one tile
     for (int y=0; y<12; y++){
       for (int x=0; x<12; x++){     
         //one node, set each channel
         data[nodeMap[y][x]+4] = (byte)(frameArray[x][y]);                       
         data[nodeMap[y][x]+3+4] = (byte)(frameArray[x][y]); 
         data[nodeMap[y][x]+6+4] = (byte)(frameArray[x][y]);
       }
     }
     // send the message for 1 tile
     String ip = tile.parentRabbit.ip;
     if(app.BROADCAST && ip!="X.X.X.X"){
       udp.send( data, ip, rabbitPort );
     }
  }//end sendNumberFrame
  
  
  public void sendTileFrame(Tile tile){
     //data for one tile, one frame
     byte[] data = new byte[(432+4)]; //144 nodes * 3 channels per node = 432
     
     data[0] = (byte) (unhex("ff")); //listen for command
     data[1] = (byte) (unhex("ff")); //chip command
     data[2] = (byte) (unhex("00")); //start command
     data[3] = byte(tile.id-1); //tile address
     
     //node map for one tile
     for (int y=0; y<12; y++){
       for (int x=0; x<12; x++){     
         //one node, set each channel
         Node node = tile.tileNodeArray[x][y];
      
         data[nodeMap[y][x]+4] = (byte)node.g;                       
         data[nodeMap[y][x]+3+4] = (byte)node.r;
         data[nodeMap[y][x]+6+4] = (byte)node.b;
       }
     }
     // send the message for 1 tile
     String ip = tile.parentRabbit.ip;
     
     if(app.BROADCAST && ip!="X.X.X.X"){
       udp.send( data, ip, rabbitPort );
     }
     
  }//end sendTileFrame
  
  
  public void blackOutAll(){
    //TODO, look how many tile there actually are
     for (int t=0; t<MAXTILES; t++){
       //data for one tile, one frame
       byte[] data = new byte[(432+4)]; //144 nodes * 3 channels per node = 432
       
       data[0] = (byte) (unhex("ff")); //listen for command
       data[1] = (byte) (unhex("ff")); //chip command
       data[2] = (byte) (unhex("00")); //start command
       data[3] = (byte) t; //tile address
       
       //node map for one tile
       for (int y=0; y<12; y++){
         for (int x=0; x<12; x++){     
           //one node, set each channel
           data[nodeMap[y][x]+4] = (byte)(unhex("00"));                       
           data[nodeMap[y][x]+3+4] = (byte)(unhex("00"));
           data[nodeMap[y][x]+6+4] = (byte)(unhex("00"));
         }
       }
       
       // send the message for each tile, on a universal IP
       if(app.BROADCAST)udp.send( data, uniIp, rabbitPort );
       
     }//end for tiles
     swapFrame();
  }//end blackOutAll
  
  public void sendTestFrame(){
    for (int t=0; t<MAXTILES; t++){
      int nodeCount = 0;
     
      //data for one tile, one frame
      byte[] data = new byte[(432+4)]; //144 nodes * 3 channels per node = 432
      
      data[0] = (byte) (unhex("ff")); //listen for command
      data[1] = (byte) (unhex("ff")); //chip command
      data[2] = (byte) (unhex("00")); //start command
      data[3] = (byte) t; //tile address

      for (int y=0; y<12; y++){
         for (int x=0; x<12; x++){
            if(nodeCount != currentNode){
              //light up one LED at a time
              data[nodeMap[y][x]+4] = (byte) c[count + 2]; //b
              data[nodeMap[y][x]+3+4] = (byte) c[count + 0]; //r
              data[nodeMap[y][x]+6+4] = (byte) c[count + 1]; //g

            }else{
              data[nodeMap[y][x]+4] = (byte) (PApplet.unhex("00"));
              data[nodeMap[y][x]+3+4] = (byte) (PApplet.unhex("00"));
              data[nodeMap[y][x]+6+4] = (byte) (PApplet.unhex("00"));
              //data[nodeMap[y][x]+3] = (byte) c[count + 2]; //b
              //data[nodeMap[y][x]+3+3] = (byte) c[count + 0]; //r
              //data[nodeMap[y][x]+6+3] = (byte) c[count + 1]; //g
            }
            nodeCount++;  
         }
      }
      
      // send the message for each tile, blast all IP addys
      udp.send( data, uniIp, rabbitPort );
    }
    swapFrame();
  
    currentNode++;//increment node
    if(currentNode >= numNodes){
      currentNode = 0; 
     
      count+=3;//increment color
      if(count >= (numColors*3)){
        count = 0;
      } 
    }
  }// end sendTestFrame
  
  //called from the app singleton
  public void receive( byte[] data, String ip, int port ) {
    String[] dataStr = new String[data.length]; 

    for(int i=0; i<data.length; i++){
      //println(hex(data[i]));
      dataStr[i] = hex(data[i]);
    }
    String macaddy = join(dataStr, ":"); 
    
    println( "UDP receive: \""+macaddy+"\" from "+ip+" on port "+port );
    
    if(port == rabbitPort){
      //got an echo back from a rabbit (master tile), add to model and create GUI
      hardwareCanvas.createRabbit(ip, macaddy);
    }
  }


} 


