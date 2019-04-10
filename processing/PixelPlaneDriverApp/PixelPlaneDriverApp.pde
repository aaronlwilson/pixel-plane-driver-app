//LIBS
import controlP5.*;
import hypermedia.net.*;
import gifAnimation.Gif;
import codeanticode.syphon.*;
import krister.Ess.*;
import processing.opengl.*;


//JAVA
import java.awt.AWTException;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.Robot;
import java.awt.image.BufferedImage;

//GLOBAL VARS
public PixelPlaneDriverApp app;
public ControlP5 cp5;
public HardwareConfigurationCanvas hardwareCanvas;
public AnimationControlCanvas animationCanvas;
public StateManager stateManager;
public NetworkManager networkManager;
public AudioManager audioManager;

public int viewId;
public int frame;
public String fileSelectFlag;

//zoom and pan vars used in AnimationControlCanvas
public float displayZoom = 1.0;

//GLOBAL SET UP - change these to key events
public boolean BROADCAST = true;
public boolean AUDIOACTIVE = true;

public static int MAXTILES = 9;


/**
 * setup
 */
void setup() {
  size(1000, 600);
  frameRate( 60 );   //60 frames/sec max
  pixelDensity(2);
  
  //init singletons
  app = this;
  stateManager     = new StateManager();
  networkManager   = new NetworkManager();
  audioManager     = new AudioManager();
  
  cp5 = new ControlP5(this);
  cp5.addFrameRate().setInterval(10).setPosition(920, 4).moveTo("global");
  
  viewId = 0;
  frame = 0;
  
  // TABS
  // By default all controllers are stored inside Tab 'default' 
  cp5.addTab("Hardware Configuration")
     .setColorBackground(color(0, 160, 100))
     .setColorLabel(color(255))
     .setColorActive(color(255,128,0));

  cp5.addTab("Animation Control")
     .setColorBackground(color(150, 0, 150))
     .setColorLabel(color(255))
     .setColorActive(color(200,0,200));     

  cp5.getTab("default").hide();
  
  cp5.getTab("Hardware Configuration")
     .activateEvent(true)
     .setId(1)
     .setWidth(110)
     .setHeight(30);   

  cp5.getTab("Animation Control")
     .activateEvent(true)
     .setId(2)
     .setWidth(103)
     .setHeight(30);
     
  //switch to the hardware tab
  cp5.getTab("Hardware Configuration").bringToFront();
  viewId = 1;
  
  //MAIN NAV
  //create buttons to save, load or new project
  cp5.addButton("SAVE PROJECT")
       .setValue(0)
       .setPosition(230,5)
       .setSize(70,20)
       .plugTo(this,"saveProject")
       .moveTo("global")
       .getCaptionLabel().align(CENTER,CENTER);
      
       
  cp5.addButton("LOAD PROJECT")
       .setValue(0)
       .setPosition(310,5)
       .setSize(70,20)
       .plugTo(this,"loadProject")
       .moveTo("global")
       .getCaptionLabel().align(CENTER,CENTER);
       
  cp5.addButton("NEW PROJECT")
       .setValue(0)
       .setPosition(390,5)
       .setSize(70,20)
       .plugTo(this,"newProject")
       .moveTo("global")
       .getCaptionLabel().align(CENTER,CENTER);
       
  //LOGO button
  PImage[] imgs = {loadImage("ui/pixel_plane_logo.gif"),loadImage("ui/pixel_plane_logo_over.gif"),loadImage("ui/pixel_plane_logo_down.gif")};
  cp5.addButton("pixel_plane_logo")
     .setPosition(940,3)
     .setImages(imgs)
     .moveTo("global")
     .updateSize();


  // create a control window canvas and add it to
  // the previously created control window.  
  hardwareCanvas = new HardwareConfigurationCanvas();
  hardwareCanvas.pre(); // use cc.post(); to draw on top of existing controllers.
  cp5.addCanvas(hardwareCanvas); // add the canvas to cp5
  
  animationCanvas = new AnimationControlCanvas();
  animationCanvas.pre(); // use cc.post(); to draw on top of existing controllers.
  cp5.addCanvas(animationCanvas); // add the canvas to cp5
  
  /*    
  //load default scene. If your set-up never changes, you can set this to automatically load the same file on startup
  String myFilePath = "data/9tiles.xml";
  XML xml = loadXML(myFilePath);
  hardwareCanvas.parseHardwareXML(xml);
  */
       
}//end setup


void draw() {
  //update frame
  frame++;
  if(frame %144 ==0){
    frame = 0;
  }
      
  //send some test data!! testing only
  //networkManager.sendTestFrame();
}

//GENERAL CP5 Handlers. I'm catching all events here at the top
void controlEvent(ControlEvent theEvent) {
 
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup, Tab, or Controller
    //println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());

    String groupName = theEvent.getGroup().getName();
    String[] groupNameList = split(groupName, '.');
    float value = theEvent.getGroup().getValue();
    
    if (groupNameList[0].equals("1") == true) {
      animationCanvas.channelCanvas1.onClipChange(value);
    }else{
      animationCanvas.channelCanvas2.onClipChange(value);
    }
    
  }else if (theEvent.isTab()) {
    //println("got an event from tab : "+theEvent.getTab().getName()+" with id "+theEvent.getTab().getId());
    viewId = theEvent.getTab().getId();
    
  }else if (theEvent.isController()) {
    //println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
  
}//end controlEvent

//MAIN NAV handlers
void newProject(){
  //blow it all away
  hardwareCanvas.resetAllHardware();
}

void saveProject(){
  selectOutput("Save your project with .xml extention", "fileSelectedSave");
}

//Handlers for project file buttons
void loadProject(){
  fileSelectFlag = "loadproject";
  selectInput("Select a project file : ", "fileSelected");
}

void fileSelectedSave(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    //build an XML structure of the hardware state
    XML xml = stateManager.generateStateXML();
    saveXML(xml, selection.getAbsolutePath());  
  }
}

public void fileSelected(File selection) {
    if (selection == null) {
      println("no selection so far...");
    } else {
      String myFilePath = selection.getAbsolutePath();
        
      if(fileSelectFlag.equals("loadproject")){ //LOAD HARDWARE FILE
        println("User selected " + myFilePath);
        XML xml = loadXML(myFilePath);
        hardwareCanvas.parseHardwareXML(xml);
        
      }else if(fileSelectFlag.equals("load1")){
        println("User selected file for Channel1 " + myFilePath);
        animationCanvas.channelCanvas1.onImageFileChange(myFilePath);
      
      }else if(fileSelectFlag.equals("load2")){
        println("User selected file for Channel2 " + myFilePath);
        animationCanvas.channelCanvas2.onImageFileChange(myFilePath);
      }
      
    }
}


//UDP handler, pass it along
 /**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) {       // <-- default handler
public void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  networkManager.receive(data, ip, port);
}

//ESS handler, pass it along
public void audioInputData(AudioInput theInput) {
  audioManager.audioInputData(theInput);
}
