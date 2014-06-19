// by Simon Schweissinger

import de.looksgood.ani.*;

class CatRobotDance implements Visualization {

  Robot r;

  CatRobotDance(PApplet parent) {
    Ani.init(parent);
    r = new Robot(width/2, height/2);
  }

  void setup(int num, float size_x, float size_y)
  {
    println("WARNING: set up with empty handler");
  }

  void setup(PApplet parent)
  {
    println("WARNING: set up with empty handler");
  }

  void setup()
  {
    println("WARNING: set up with empty handler");
  }


  void draw(PGraphics canvas, float[] average) {
    canvas.beginDraw();
    canvas.background(0);

    r.drawRobot(canvas);

    canvas.endDraw();
  }
};

class Robot {
  PVector loc;

  Robot(int x, int y) {
    loc = new PVector(x, y);
  }

  void drawRobot(PGraphics pg) {
    pg.fill(0);
    pg.stroke(255);
    pg.rectMode(CENTER);

    pg.rect(loc.x, loc.y, 100, 100);
  }
}

