
// import UDP library
import hypermedia.net.*;

UDP udp;  // define the UDP object
  
int numTiles    = 9;
String ip       = "192.168.1.102";  // the remote IP address, rabbit uses DHCP, so you might have to check the router or use the driver app to get the IP
int port        = 7;   //the destination port 

int numColors = 3;
int[] c = new int[numColors*3];
int currentNode = 0;
int count   = 0;
int numNodes = 12*12;

int[][] nodeMap = new int[12][12];

/**
 * init
 */
void setup() {

  size(360, 360, P2D);
  frameRate( 60 );   //frames/sec 80 is max
  
  //green
  c[0] = 200;//255 is max
  c[1] = 0;
  c[2] = 0;
  
  //blue
  c[3] = 0;
  c[4] = 200;
  c[5] = 0;
  
  //blue
  c[6] = 0;
  c[7] = 0;
  c[8] = 200;
  
  //fill a hash map with hardware node positions
  createNodeMap();  
  
  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 7777 );
  udp.log( true ); 		// <-- printout the connection activity
  udp.listen( true );
}


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

//process events
void draw() {
          // clear background
          background( 0, 0, 0 );
          fill( c[count + 0], c[count + 1], c[count + 2] );
          rect((currentNode%12)*30, (currentNode/12)*30, 30, 30);
      
          for (int t=0; t<numTiles; t++){
                int nodeCount = 0;
               
                byte[] data = new byte[(432+4)];
                
                data[0] = (byte) (unhex("ff"));
                data[1] = (byte) (unhex("ff")); //chip command
                data[2] = (byte) (unhex("00")); //start command
                data[3] = (byte) t; //tile address
  
                for (int y=0; y<12; y++){
                     for (int x=0; x<12; x++){
                        if(nodeCount != currentNode){
                          
                          data[nodeMap[y][x]+4] = (byte) (PApplet.unhex("00"));
                          data[nodeMap[y][x]+3+4] = (byte) (PApplet.unhex("00"));
                          data[nodeMap[y][x]+6+4] = (byte) (PApplet.unhex("00"));
    
                        }else{
                          
                          data[nodeMap[y][x]+4] = (byte) c[count + 1]; //b
                          data[nodeMap[y][x]+3+4] = (byte) c[count + 0]; //r
                          data[nodeMap[y][x]+6+4] = (byte) c[count + 2]; //g
                        }
                       
                        nodeCount++;  
                     }
                }
                
                // send the message for each tile
                udp.send( data, ip, port );
          }//end for num tiles
          
          //swap command
          byte[] data = new byte[2];
          data[0] = (byte) (unhex("FF"));
          data[1] = (byte) (unhex("FE"));
          udp.send( data, ip, port );


          currentNode++;//increment node
          if(currentNode >= numNodes){
            currentNode = 0; 
           
            count+=3;//increment color
            if(count >= (numColors*3)){
              count = 0;
            } 
          }

}

/** 
 * on key pressed event:
 * send the current key value over the network
 */
void keyPressed() {  
    String message  = str( key );	// the message to send
    // formats the message for Pd
    message = message+";\n";
    // send the message
    udp.send( message, ip, port );
}

/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) { 			// <-- default handler
void receive( byte[] data, String ip, int port ) {	// <-- extended handler
  
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);
  String message = new String( data );
  
  // print the result
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
}

