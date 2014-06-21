// catz visualization by stefan wagner (andsynchrony)

class Catz implements Visualization
{

  PImage cat_front;
  Cat2[] c;
  int numX = 4;
  int numY = 4;

  Catz()
  {
    setup();
  }

  void setup()
  {
    cat_front = loadImage("catzeye_front.png");

    c = new Cat2[numX * numY];
    for (int x = 0; x < numX; x++)
    {
      for (int y = 0; y < numY; y++)
      {
        c[x + y * numX] = new Cat2();
      }
    }
  }

  void setup(int num, float size_x, float size_y) {
    println("WARNING: set up with empty handler");
  }

  void setup(PApplet parent)
  {
    println("WARNING: set up with empty handler");
  }

  void draw(PGraphics canvas, float[] average, boolean b) {
  }


  void draw(PGraphics canvas, float[] average)
  {
    float scale = 0.4;
    canvas.beginDraw();
        canvas.fill(0);
    canvas.tint(255);
    canvas.ellipseMode(CENTER);
    canvas.imageMode(CENTER);
    canvas.background(255);
    for (int x = 0; x < numX; x++)
    {
      for (int y = 0; y < numY; y++)
      {
        c[x + y * numX].draw(x*cat_front.width*scale*0.5 + cat_front.width * scale * 0.25, y*cat_front.height*scale*0.5  + cat_front.width * scale * 0.25, scale, cat_front, canvas);
      }
    }
    canvas.endDraw();
  }
}

class Cat2 {
  float dir;
  Cat2()
  {
    dir = random(PI*2);
  }

  void draw(float x, float y, float scale, PImage cat_front, PGraphics canvas)
  {
    canvas.pushMatrix();
    //image(cat, x, y, cat.width*0.5*scale, cat.height*0.5*scale);
    canvas.noStroke();
    float n = noise(x, y, 0.06*frameCount);

    canvas.translate(x, y );

    //PVector v = new PVector(mouseX - x, mouseY - y);
    //float dir = v.heading();
    if ( abs(n - 0.4) < 0.002) dir = random(PI*2);
    //println(degrees(dir));
    //dir = -dir + PI/2;

    //if (int(random(0, 14)) != frameCount%50)
    {
      canvas.ellipse(sin(dir)*50*scale, cos(dir)*20*scale, n*3.0*25*scale, 190*scale);
    }

    canvas.popMatrix();
    canvas.image(cat_front, x, y+ n * 30 - 15, cat_front.width*0.5*scale, cat_front.height*0.5*scale);
  }
}

