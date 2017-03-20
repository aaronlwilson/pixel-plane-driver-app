
class ChannelCanvas extends Canvas {
  //CLASS VARS
  public String namespace;
  public int channelX;
  public int channelWidth = 249;
  
  //text scroll only vars
  public String showText;
  public color textColor;
  public int textBoxWidth;
  
  private int clipPerametersY = 150;
    
  //CLIP CLASS ENUM
  public static final int NODESCAN = 0;
  public static final int COLORWASH = 1;
  public static final int SCREENCAPTURE = 2;
  public static final int ANIMATEDGIF = 3;
  public static final int IMAGESCROLL = 4;
  public static final int GRAPHICEQ = 5;
  public static final int TEXTSCROLL = 6;
  public static final int BASIC = 7;
  public static final int SIMPLEPARTICLES = 8;
  public static final int SYPHON = 9;
  
  public String[] clipNames = {"None", "Color Wash", "Screen Capture", "Animated GIF", "Image Scroll", "Graphic EQ", "Text Scroll", "Solid Color" };
  public AbstractClip currentClip;
  
  //GUI VARS
  private DropdownList currentClipDL;
  private Knob pKnob1;
  private Knob pKnob2;
  private Knob pKnob3;
  
  private Slider2D slider2D;
  private Slider sliderX;
  private Slider sliderY;
 
  private Textfield textInput;
  
  private Slider brightnessSlider;
  private Slider rBrightnessSlider;
  private Slider gBrightnessSlider;
  private Slider bBrightnessSlider;
  
  public float channelBrightness = 100;
  public float rBrightness = 100;
  public float gBrightness = 100;
  public float bBrightness = 100;
  
  
  
  
  //CONSTRUCTOR
  public ChannelCanvas(String theNamespace, int theChannelX) {
    super();
    namespace = theNamespace;
    channelX = theChannelX+500;
    
    Textlabel channelLabel = cp5.addTextlabel(namespace+"label")
                      .setText("Channel " + namespace)
                      .setPosition(channelX + 5, 35+5)
                      .setSize(channelWidth-10,25)
                      .setColorValue(0xffffffff)
                      .setColorBackground(color(190)) 
                      .setFont(createFont("Helvetica",20))
                      .moveTo("Animation Control");

   
   //brightness slider  
   colorMode(HSB, 100);  // Use HSB with scale of 0-100
   brightnessSlider = cp5.addSlider(namespace+".brightness")
     .setPosition(channelX,90)
     .setRange(0,100)
     .setValue(100)
     .setColorActive(color(55, 100, 100))
     .setSize(channelWidth, 25)
     .plugTo(this,"onBrightnessChange")
     .moveTo("Animation Control"); 
   brightnessSlider.getCaptionLabel().setText("brightness"); 
   colorMode(RGB, 255); 
   
   //position the slider Label
   brightnessSlider.getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(10);
   brightnessSlider.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(10); 
   
   
   //RGB cutouts
   int brightnessSliderY = 567;
   rBrightnessSlider = cp5.addSlider(namespace+".Rb")
     .setPosition(channelX,brightnessSliderY)
     .setRange(0,100)
     .setValue(100)
     .setSize(channelWidth, 10)
     .plugTo(this,"onBrightnessChangeR")
     .moveTo("Animation Control"); 
   rBrightnessSlider.getCaptionLabel().setText("red cut"); 
     
   gBrightnessSlider = cp5.addSlider(namespace+".Gb")
     .setPosition(channelX,brightnessSliderY+11)
     .setRange(0,100)
     .setValue(100)
     .setSize(channelWidth, 10)
     .plugTo(this,"onBrightnessChangeG")
     .moveTo("Animation Control"); 
   gBrightnessSlider.getCaptionLabel().setText("green cut");
     
   bBrightnessSlider = cp5.addSlider(namespace+".Bb")
     .setPosition(channelX,brightnessSliderY+22)
     .setRange(0,100)
     .setValue(100)
     .setSize(channelWidth, 10)
     .plugTo(this,"onBrightnessChangeB")
     .moveTo("Animation Control");
   bBrightnessSlider.getCaptionLabel().setText("blue cut");
  
  //move the MASTER RGB labels
  rBrightnessSlider.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.LEFT).setPaddingX(5);
  gBrightnessSlider.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.LEFT).setPaddingX(5);
  bBrightnessSlider.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.LEFT).setPaddingX(5);
  
   
   //RESET perameters
   cp5.addButton(namespace+".reset")
       .setPosition(channelX+10,clipPerametersY)
       .setSize(110,25)
       .plugTo(this,"onResetPerameters")
       .moveTo("Animation Control")
       .getCaptionLabel().align(CENTER,CENTER).setText("RESET"); 

   
   //OPEN FILE BUTTON
   cp5.addButton(namespace+".openfile")
       .setPosition(channelX+10+120,clipPerametersY)
       .setSize(110,25)
       .plugTo(this,"openFile")
       .moveTo("Animation Control")
       .getCaptionLabel().align(CENTER,CENTER).setText("OPEN FILE"); 
   
   //CREATE KNOBS
   pKnob1 = cp5.addKnob(namespace+".knob1")
               .setPosition(channelX+10, clipPerametersY+35)
               .plugTo(this,"onKnob1Change");
   customizeKnob(pKnob1);   

   pKnob2 = cp5.addKnob(namespace+".knob2")
               .setPosition(channelX+10+80, clipPerametersY+35)
               .plugTo(this,"onKnob2Change");
   customizeKnob(pKnob2);    
   
   pKnob3 = cp5.addKnob(namespace+".knob3")
               .setPosition(channelX+10+160, clipPerametersY+35)
               .plugTo(this,"onKnob3Change");
   customizeKnob(pKnob3); 
   
   //CREATE SLIDER2D
   slider2D = cp5.addSlider2D(namespace+".slider2D")
         .setPosition(channelX+20, clipPerametersY + 130)
         .setSize(100,100)
         .setArrayValue(new float[] {50, 50})
         .plugTo(this,"onSlider2DChange")
         .moveTo("Animation Control");
         
  sliderX = cp5.addSlider(namespace+".sliderX")
     .setPosition(channelX+130, clipPerametersY + 130)
     .setSize(45,100)
     .setRange(0,100)
     .setValue(50)
     .plugTo(this,"onSliderXChange")
     .moveTo("Animation Control");
  sliderX.getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE);
  
     
  sliderY = cp5.addSlider(namespace+".sliderY")
     .setPosition(channelX+130+55, clipPerametersY + 130)
     .setSize(45,100)
     .setRange(0,100)
     .setValue(50)
     .plugTo(this,"onSliderYChange")
     .moveTo("Animation Control");
  sliderY.getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE);
     
         
  //TEXT INPUT
  textInput = cp5.addTextfield(namespace+".textInput")
       .setPosition(channelX+20, clipPerametersY + 250)
       .setSize(210,20)
       .setAutoClear(false)
       .setFont(loadFont("Standard0754-8.vlw"))
       //.setColorBackground(color(0, 0, 0))
       .plugTo(this,"onTextInputChange")
       .moveTo("Animation Control");
      
       
   // create a DropdownList to select a clip
   currentClipDL = cp5.addDropdownList(namespace+".currentClipDL")
       .setPosition(channelX, 90)
       .setSize(channelWidth,(clipNames.length*20)+25);       
   customizeDL(currentClipDL);
  }
  
  void customizeDL(DropdownList ddl) {
    // a convenience function to customize a DropdownList
    ddl.setBackgroundColor(color(190));
    ddl.setItemHeight(20);
    ddl.setBarHeight(25);
    ddl.captionLabel().set("CHOOSE A CLIP");
    ddl.captionLabel().style().marginTop = 10;
    ddl.captionLabel().style().marginLeft = 10;
    ddl.moveTo("Animation Control");
    
    int numClips = clipNames.length;
    for (int i=0;i<numClips;i++) {
      ddl.addItem(clipNames[i], i);
    }
    //ddl.scroll(0);
    ddl.setColorBackground(color(60));
    ddl.setColorActive(color(255, 128));
  }//end customizeDL
  
  void customizeKnob(Knob knob) {
    knob.setRange(0,100);
    knob.setValue(50);
    knob.setRadius(35);
    //.setColorForeground(color(255))
    knob.setColorBackground(color(50, 50, 50));
    knob.setColorActive(color(255,255,0));
    knob.setDragDirection(Knob.HORIZONTAL);
    knob.moveTo("Animation Control");
  }//end customizeKnob
  
  void customizeSlider(Slider slider) {
    
  }//end customizeSlider
  
  private void constructNewClip(int clipClass){
   
    AbstractClip clip = new AbstractClip("Abstract Clip", namespace);
    switch(clipClass){
      case NODESCAN:clip      = new ClipNodeScan(clipNames[NODESCAN], namespace);break;
      case COLORWASH:clip     = new ClipColorWash(clipNames[COLORWASH], namespace);break;
      case SCREENCAPTURE:clip = new ClipScreenCapture(clipNames[SCREENCAPTURE], namespace);break;
      case ANIMATEDGIF:clip   = new ClipAnimatedGif(clipNames[ANIMATEDGIF], namespace);break;
      case TEXTSCROLL:clip    = new ClipText(clipNames[TEXTSCROLL], namespace);break;
      case IMAGESCROLL:clip   = new ClipImageScroll(clipNames[IMAGESCROLL], namespace);break;
      //case GRAPHICEQ:clip     = new ClipGraphicEQ(clipNames[GRAPHICEQ], namespace);break;
      case SYPHON:clip        = new ClipSyphon(clipNames[SYPHON], namespace);break;
      case BASIC:clip         = new ClipBasic(clipNames[BASIC], namespace);break;
    }
    
    
    if(clip != null){
      clip.init();
      currentClip = clip;
      currentClip.p1 = pKnob1.getValue();
      currentClip.p2 = pKnob2.getValue();
      currentClip.p3 = pKnob3.getValue();
      currentClip.p4 = slider2D.arrayValue()[0];
      currentClip.p5 = slider2D.arrayValue()[1];
      currentClip.p6 = sliderX.getValue();
      currentClip.p7 = sliderY.getValue();
      //println(namespace + " NEW CLIP: " + currentClip.clipName);
    }
  }
  
  //SETTERS FOR GUI ELEMENTS
  public void setControllerText(String controller, String text){
    Controller c = (Controller)cp5.get(namespace+controller);
    c.getCaptionLabel().setText(text);
  }
  
  public void setControllerHidden(String controller, boolean hidden){
    Controller c = (Controller)cp5.get(namespace+controller);
    if(hidden){
      c.hide();
    }else{
      c.show();
    }
  }
  
  public void resetAllControllers(){
    setControllerText(".knob1", "knob1");
    setControllerText(".knob2", "knob2");
    setControllerText(".knob3", "knob3");
    setControllerText(".slider2D", "slider2D");
    setControllerText(".sliderX", "sliderX");
    setControllerText(".sliderY", "sliderY");
    setControllerText(".textInput", "Text Input");
    
    setControllerHidden(".knob1", false);
    setControllerHidden(".knob2", false);
    setControllerHidden(".knob3", false);
    setControllerHidden(".slider2D", false);
    setControllerHidden(".sliderX", false);
    setControllerHidden(".sliderY", false);
    setControllerHidden(".textInput", false);
    setControllerHidden(".reset", false);
    setControllerHidden(".openfile", false);
  }
  
 
  
  //HANDLERS FOR GUI ELEMENTS
  void onBrightnessChange(float brightness) {
    channelBrightness = brightness;
    colorMode(HSB, 100);  // Use HSB with scale of 0-100
    brightnessSlider.setColorActive(color(55, 100, brightness));
    colorMode(RGB, 255);
  }
  
  void onBrightnessChangeR(float brightness) {
    rBrightness = brightness;
    rBrightnessSlider.setColorActive(color((brightness*2.55), 0, 0));
  }
  void onBrightnessChangeG(float brightness) {
    gBrightness = brightness;
    gBrightnessSlider.setColorActive(color(0, (brightness*2.55), 0));
  }
  void onBrightnessChangeB(float brightness) {
    bBrightness = brightness;
    bBrightnessSlider.setColorActive(color(0, 0, (brightness*2.55)));
  }
  
  void onKnob1Change(float knobValue) {
    //println("a knob event. setting background to "+knobValue);
    if(currentClip != null) currentClip.p1 = knobValue;
    colorMode(HSB, 100);  // Use HSB with scale of 0-100
    pKnob1.setColorActive(color(knobValue, 100, 100));
    colorMode(RGB, 255);
  }
  
  void onKnob2Change(float knobValue) {
    if(currentClip != null) currentClip.p2 = knobValue;
    colorMode(HSB, 100);  // Use HSB with scale of 0-100
    pKnob2.setColorActive(color(knobValue, 100, 100));
    textColor = color(knobValue, 100, 100);
    colorMode(RGB, 255);
  }  
  
  void onKnob3Change(float knobValue) {
    if(currentClip != null) currentClip.p3 = knobValue;
    colorMode(HSB, 100);  // Use HSB with scale of 0-100
    pKnob3.setColorActive(color(knobValue, 100, 100));
    textBoxWidth = int(knobValue*2.5);
    if(textBoxWidth>248) textBoxWidth = 248;
    
    colorMode(RGB, 255);
  }
  
  void onSlider2DChange() {
    if(currentClip != null) currentClip.p4 = slider2D.arrayValue()[0];
    if(currentClip != null) currentClip.p5 = slider2D.arrayValue()[1];
  }
  
  void onSliderXChange() {
    if(currentClip != null) currentClip.p6 = sliderX.getValue();
  }
  void onSliderYChange() {
    if(currentClip != null) currentClip.p7 = sliderY.getValue();
  }

  
  public void onClipChange(float value){
    //called from the master controlEvent method in the app singleton
    //println(namespace + " onClipChange: " + value);
    constructNewClip(int(value));
  }
  
  private void onResetPerameters() {
    pKnob1.setValue(50);
    pKnob2.setValue(50);
    pKnob3.setValue(50);
    slider2D.setArrayValue(new float[] {50, 50});
    sliderX.setValue(50);
    sliderY.setValue(50);
  }
  
 
  public void setup(PApplet theApplet) {
    //TEMP, in the future wait for GUi or file load
    //constructNewClip(0);
  }//end setup 

  public void draw(PApplet p) {
    showText = cp5.get(Textfield.class, namespace+".textInput").getText();
    
    if(currentClip != null){
      currentClip.run();
    }
  }//end draw
 
  //Handlers for project file buttons
  void openFile(){
    fileSelectFlag = "load"+namespace;
    selectInput("Select a .JPG, .GIF or .PNG : ", "fileSelected");
  }
  
  public void onImageFileChange(String filePath){
    //TODO check for file extention
    //called from the master fileSelected method in the app singleton
    println(namespace + " onImageFileChange: " + filePath);
    //TODO write file name on the button to confirm selection
    if(currentClip != null){
      currentClip.loadFile(filePath);
    }
  }


}//end class
