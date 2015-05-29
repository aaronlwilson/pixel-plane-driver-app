/**
 * MultiList (v1.6)
 * by Ammon.Owed (2013/Feb)
 *
 * http://forum.processing.org/topic/local-menu-right-click-menu-in-c
 */

import controlP5.*;

MultiList l;
byte value;
final static PVector mouse = new PVector();

void setup() {
  size(700, 400);
  frameRate(10);
  textAlign(CENTER, CENTER);
  textSize(100);

  ControlP5 c = new ControlP5(this);

  l = c.addMultiList("myList", 0, height, 70, 12);
  MultiListButton b = l.add("level 1", 1);
  //b.add("level 11", 11).setLabel("level 1 item 1");
  //b.add("level 12", 12).setLabel("level 1 item 2");

  b = l.add("level 2", 2);
  //b.add("level 2 item 1", 21).add("level 31", 31).setLabel("level 3 item 1");
  //b.add("level 22", 22).setLabel("level 2 item 2");

/*
  c.addMultiList("myExtra", 30, 30, 65, 10).add("Click Here!", -10)
    .add("Sub-Button 1", 5).add("Sub-Button 2", -5)
      .setLabel("Yeepee!").setLabel("Yikes!");
      */
}

void draw() {
  background(0);
  text(value, width>>1, height>>1);
}

void controlEvent(ControlEvent theEvent) {
  value = (byte) theEvent.value();
  l.updateLocation(0, height);
  l.close();
}

void mousePressed() {
  if (mouseButton == RIGHT) {
    mouse.set(mouseX, mouseY, 0);
    mouse.sub( l.position() );
    l.updateLocation(mouse.x, mouse.y);
  }
}
