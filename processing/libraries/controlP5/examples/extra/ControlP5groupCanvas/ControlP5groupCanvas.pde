/**
 * ControlP5 Canvas
 *
 * by andreas schlegel, 2011
 * www.sojamo.de/libraries/controlp5
 * 
 */
 
import controlP5.*;
  
ControlP5 cp5;
  
void setup() {
  size(400,600);
  smooth();
  
  cp5 = new ControlP5(this);
  cp5.addGroup("myGroup")
     .setLabel("Testing Canvas")
     .setPosition(100,200)
     .setWidth(200)
     .addCanvas(new TestCanvas())
     ;
}

void draw() {
  background(0);
}

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } 
  else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}

class TestCanvas extends Canvas {
  
  float n;
  float a;
  
  public void setup(PApplet p) {
    println("starting a test canvas.");
    n = 1;
  }
  public void draw(PApplet p) {
    n += 0.01;
    p.ellipseMode(CENTER);
    p.fill(lerpColor(color(0,100,200),color(0,200,100),map(sin(n),-1,1,0,1)));
    p.rect(0,0,200,200);
    p.fill(255,150);
    a+=0.01;
    ellipse(100,100,abs(sin(a)*150),abs(sin(a)*150));
    ellipse(40,40,abs(sin(a+0.5)*50),abs(sin(a+0.5)*50));
    ellipse(60,140,abs(cos(a)*80),abs(cos(a)*80));
  }
}
