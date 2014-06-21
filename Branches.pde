// branches visualization by stefan wagner (andsynchrony)

// WIP!!!!!!111

class Branches implements Visualization
{

  ArrayList branches;
  float velX, velY;
  PImage gradient;

  Branches(int num, float size_x, float size_y)
  {
    setup(num, size_x, size_y);
  }

  void setup()
  {
    println("WARNING: set up with empty handler");
  }

  void setup(PApplet parent)
  {
    println("WARNING: set up with empty handler");
  }

  void setup(int num, float size_x, float size_y)
  {
    branches = new ArrayList();
    for (int i = 0; i < num*2; i ++) {
      randomSeed(i);
      branches.add(new Branch2D(190+(i%4)*200, 80+(i/4)*200, 0, 0,i));
    }
    gradient = loadImage("gradient.png");
  }

  void draw(PGraphics canvas, float[] average)
  {
    canvas.beginDraw();
    canvas.colorMode(HSB);
    canvas.imageMode(CENTER);
    canvas.background(100);
    //canvas.blendMode(ADD);
    for (int i = 0; i < branches.size (); i ++)
    {
      velX = (noise(8768, average[i%average.length])-0.5)*10;
      velY = (noise(6875, average[i%average.length])-0.5)*10;
      //velX = average[i]*0.12;
      //velY = average[i]/0.12;
      Branch2D branch = (Branch2D) branches.get(i);
      branch.generate(canvas, velX, velY, gradient);
    }
    canvas.blendMode(NORMAL);
    canvas.endDraw();
  }

  void draw(PGraphics canvas, float[] average, boolean beat) {
    draw(canvas, average);
  }
}


class Branch2D {
  float gravity = 0.0;
  float mass = 6.0;
  int numsprings = 25;
  ArrayList springs;
  float velX, velY;
  float posX, posY;
  float dirX, dirY;
  Branch2D(float posX, float posY, float dirX, float dirY, float randomVal) {
    this.posX = posX;
    this.posY = posY;
    this.dirX = dirX;
    this.dirY = dirY;
    springs = new ArrayList();
    for (int i = 0; i < numsprings; i += 5) {
       randomSeed(int(randomVal+i*posX*posY*dirX*dirY));
      if (i==0) {
        springs.add(new Spring2D(posX, posY, mass, gravity, true));
      } else {
        springs.add(new Spring2D(dirX-random(0, dirX), dirY-random(0, dirY), mass, gravity, false));
      }
      for (int j=1; j<4; j++) {
        springs.add(new Spring2D(random(-5, 5), random(-4, 6), mass, gravity, false));
      }
    }
  }
  void generate(PGraphics canvas, float velX, float velY, PImage img) {
    Spring2D firstspring = (Spring2D) springs.get(0);
    firstspring.update(posX, posY, velX, velY);
    firstspring.display(canvas, mouseX, mouseY, velX, velY, img);
    for (int i = 0; i < springs.size (); i += 5) {
      randomSeed(i);
      if (i == 0) {
      } else {
        Spring2D spring = (Spring2D) springs.get(i);
        Spring2D backspring;
        if (i == 5) {
          backspring = (Spring2D) springs.get(i-5);
        } else {
          backspring = (Spring2D) springs.get(i-round(random(1, 5)));
        }
        spring.update(backspring.x, backspring.y, velX, velY);
        spring.display(canvas, backspring.x, backspring.y, velX, velY, img);
        canvas.stroke(0);
        canvas.strokeWeight(50/i);
        canvas.strokeCap(ROUND);
        canvas.line(spring.x, spring.y, backspring.x, backspring.y);
        for (int j = 1; j < 5; j++) {
          Spring2D spring2 = (Spring2D) springs.get(i+j);
          spring2.update(backspring.x, backspring.y, velX, velY);  
          canvas.stroke(0);
          canvas.line(spring2.x, spring2.y, backspring.x, backspring.y);
          spring2.display(canvas, backspring.x, backspring.y, velX, velY, img);
        }
      }
    }
  }
}


class Spring2D {
  float vx, vy; // The x- and y-axis velocities
  float x, y, _x, _y; // The x- and y-coordinates
  float gravity;
  float mass;
  float radius = 5;
  float stiffness = 0.5;
  float damping = 0.9;
  float velX;
  float velY;
  boolean isFixed = false;
  Spring2D(float xpos, float ypos, float m, float g, boolean f) {
    isFixed = f;
    x = xpos;
    y = ypos;
    _x = xpos;
    _y = ypos;    
    mass = m;
    gravity = g;
  }
  void update(float targetX, float targetY, float velX, float velY) {
    if (!isFixed)
    {
      float forceX = (targetX - x) * stiffness;
      float ax = forceX / mass;
      vx = damping * (vx + ax);
      vx += velX;
      x += vx;
      x += _x;
      float forceY = (targetY - y) * stiffness;
      forceY += gravity;
      float ay = forceY / mass;
      vy = damping * (vy + ay);
      vy += velY;
      y += vy;
      y += _y;
    }
  }
  void display(PGraphics canvas, float nx, float ny, float velX, float velY, PImage img) {
    //canvas.noStroke();
    canvas.stroke(0,40);
    canvas.strokeWeight(1);

    for (int i = 0; i < 1; i++) {
      canvas.tint(95, random(300, 360), random(100, 360), vx * 100);
      //canvas.rect(x+random(-20, 20), y+random(-20, 20), radius, radius);
      //canvas.image(img, x+random(-20, 20), y+random(-20, 20), radius, radius);
      canvas.line(x,y,x+velX*20,y+velY*20);
    }
    randomSeed(round(x*2/3));
    /*
    for (int i = 0; i < 10; i++) {
      canvas.tint(0, 0, 360, vx * 100);
      //canvas.rect(x+random(-10, 10), y+random(-10, 10), radius*2, radius*2);
       canvas.line(x+random(-10, 10), y+random(-10, 10),x+vx,x+vy);

      //canvas.image(img, x+random(-10, 10), y+random(-10, 10), radius*2, radius*2);
    }
    */
  }
}

