import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import codeanticode.syphon.*; 
import beads.*; 
import de.looksgood.ani.*; 
import de.looksgood.ani.*; 
import toxi.physics.constraints.*; 
import toxi.physics.behaviors.*; 
import toxi.physics.*; 
import toxi.geom.*; 
import toxi.math.*; 
import penner.easing.*; 
import java.util.Iterator; 
import java.util.Calendar; 

import de.gulden.framework.jjack.*; 
import de.gulden.util.*; 
import de.gulden.application.jjack.*; 
import com.petersalomonsen.jjack.javasound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class twrkmkVisualizationTool extends PApplet {

/*======================================
   __                __                 
  / /__      _______/ /______ ___  _____
 / __/ | /| / / ___/ //_/ __ `__ \/ ___/
/ /_ | |/ |/ / /  / ,< / / / / / / /__  
\__/ |__/|__/_/  /_/|_/_/ /_/ /_/\___/  

====== Sound Visualization Tool ======*/



PGraphics canvas;

int numChannels = 8;

boolean setDrawDebug = true;


Visualization[] visualization;
int visualizationID = 0;

SyphonServer server;
AudioHandler audio;


public void setup() { 

  size(1024, 768, P3D); 

  audio = new AudioHandler(numChannels, true); // num channels, debug mode on or off


  canvas = createGraphics(width, height, P3D);
  canvas.beginDraw();
  canvas.background(0, 0, 0);
  canvas.endDraw();

  println("starting syphon...");
  try
  {
    // Create syhpon server to send frames out.
    server = new SyphonServer(this, "Processing Syphon");
    println("success!");
  }
  catch(Throwable e)
  {
    println("could not start syphon: " + e);
  }

  visualization = new Visualization[] {
    new CircleClass(), 
    new ThomasClass(), 
    new ChrisClass(), 
    new Polyscape(width, height),
    new Branches(numChannels, width, height), 
    new BeadWave(this), 
    new CatRobotDance(this)
    };
  }

  public void draw() { 
    background(0);

    audio.update();

    visualization[visualizationID].draw(canvas, audio.getSmoothed());
    
    image(canvas, 0, 0);

    if (setDrawDebug)
      audio.drawInput();

    server.sendImage(canvas);
  }


public void keyPressed()
{
  try
  {
    int id = Integer.parseInt(key+"");
    if (id >= 0 && id <= visualization.length)
    {
      switchVisualization(id);
    }
  } 
  catch(Exception e){}
  if (key == ' ')
  {
    switchVisualization(visualizationID+1);
  } else if (key == 'd')
  {
    setDrawDebug = !setDrawDebug;
  }
}



class AudioHandler
{
  AudioContext ac;

  boolean debug = false;

  float[] volume, average; 
  int buffer; 
  int portAudio;

  float[] maxima, normalized, smoothed;


  AudioHandler(int numPorts, boolean debug)
  {
    this.debug = debug;
    setup(numPorts);
  }

  AudioHandler(int numPorts)
  {
    setup(numPorts);
  }

  public void setup(int numPorts)
  {
    portAudio = numPorts;
    maxima = new float[portAudio];
    volume = new float[portAudio];
    average = new float[portAudio];
    normalized = new float[portAudio];
    smoothed = new float[portAudio];


    for (int p = 0; p < portAudio; p++)
    {
      volume[p] = 0;
      average[p] = 0;
      maxima[p] = 100;
      smoothed[p] = 0;
    }

    if (!debug)
    {
      println("starting audio...");
      try
      {
        // ac = new AudioContext(AudioContext.defaultAudioFormat(portAudio)); 
        ac = new AudioContext();
        ac.out.setGain(100); 
        UGen inputs = ac.getAudioInput(new int[] {
          0, 1, 2, 3, 4, 5, 6, 7
        }
        ); 
        ac.out.addInput(inputs); 
        ac.start();
        println(ac.getBufferSize());
        buffer = 6;
        println("Number of INs : "+ ac.getAudioInput().getOuts());
        println("Number of OUTs : "+ ac.out.getIns());
        println("success!");
      }
      catch (Throwable e)
      {
        println(e);
        debug = true;
      }
    }
  }

  public void update()
  {
    if (!debug)
    {
      try
      {
        for (int p = 0; p < portAudio; p++)
        {
          volume[p] = 0;
        }
        for (int p = 0; p < portAudio; p++)
        {
          for (int i = 0; i < ac.getBufferSize (); i++)
          {
            volume[p] += abs(ac.out.getValue(p, i));
          }
        }
      }
      catch(Throwable e)
      {
        println("AudioHandler broken: " + e);
        debug = true;
      }
    } else
    {
      for (int p = 0; p < portAudio; p++)
      {
        volume[p] = noise(p, frameCount*0.02f * p) * 100;
      }
    }

    for (int p = 0; p < portAudio; p++)
    {
      average[p] = ((average[p] * buffer) + volume[p])/(buffer + 1);
    }
    for (int i = 0; i < maxima.length; i++)
    {
      if (volume[i] != 0)
        maxima[i] += (volume[i] - maxima[i])*0.05f;
      normalized[i] = constrain(map(volume[i], 0, maxima[i], 0.0f, 1.0f), 0.0f, 1.0f);
    }

    for (int i = 0; i < smoothed.length; i++)
    {
      smoothed[i] += (normalized[i] - smoothed[i])*0.1f;
    }
  }

  public void drawInput()
  {
    fill(255);
    noStroke();
    float[] n = getSmoothed();
    for (int i = 0; i < portAudio; i++)
    {
      text(i + " " + nfc(n[i], 2), 30, 14 + i * 35);
      stroke(0);
      noFill();
      rect(30, 22 + i*35, 100, 15);
      noStroke();
      fill(255);
      rect(30, 22 + i*35, 100 * n[i], 15);
    }
  }
  
  // volume values, as received by Beads library
  public float[] getVolume()
  {
    return volume;
  }
  
  // average volume, unnormalized, unsmoothed
  public float[] getAverage()
  {
    return average;
  }
  
  // normalized volume, unsmoothed
  public float[] getNormalized()
  {
    return normalized;
  }
  
  // smoothed, normalized volume
  public float[] getSmoothed()
  {
    return smoothed;
  }
}

// BeadWave class [Simon]



int beadsize = 8;
int channels = 8;
int mod = 2;
int maxdur = 100;

class BeadWave implements Visualization
{
  BeadWave(PApplet parent) {
    setup(parent);
  }

  Wave[] w;

  public void setup()
  {
    println("WARNING: set up with empty handler");
  }

  public void setup(int num, float size_x, float size_y)
  {
    println("WARNING: set up with empty handler");
  }


  public void setup(PApplet parent) {
    // setup stuff comes here (image loading etc)

    // channels = average.length;
    // w = new Wave[average.length * mod];
    w = new Wave[channels * mod];

    Ani.init(parent);

    float colw = width / (channels * mod);
    for (int i = 0; i < channels; i++) {
      for (int k = 0; k < mod; k++) {
        w[i + k * channels] = new Wave(i, PApplet.parseInt(colw / 2 + ((i + (k * channels)) * colw)));
        /*
                if(k > 0) {
         int foo = w[i + k * channels].maxalpha;
         foo = (foo / mod) * k;
         w[i + k * channels].maxalpha -= foo;
         }
         */
      }
    }
  }

  public void draw(PGraphics canvas, float[] average) {
    canvas.beginDraw();

    canvas.background(0);

    for (int i = 0; i < channels; i++) {
      for (int k = 0; k < mod; k++) {
        w[i + k * channels].calcWave(average[i]*100.0f);
        w[i + k * channels].renderWave(canvas);
      }
    }

    canvas.endDraw();
  }
} //

class Wave {
  float xspacing;
  int xpos, w, timer, dur, id, alphaval, maxalpha;

  float theta, amplitude, period, dx;
  float[] xvalues;

  FloatList vals;

  Wave(int id, int xp) {
    xspacing = beadsize;
    xpos = xp;
    theta = 0.0f;
    amplitude = 75.0f;
    timer = 0;
    this.id = id;
    vals = new FloatList();
    alphaval = 0;
    maxalpha = 200;

    resetVars();
    // dur = 500;

    w = height + beadsize;
    dx = (TWO_PI / period) * xspacing;
    xvalues = new float[w / PApplet.parseInt(xspacing)];
  }

  public void resetVars() {
    // Ani.to(this, 2.5, "amplitude", random(40.0, 100.0));
    Ani.to(this, 2.5f, "xspacing", random(10.0f, 20.0f));
    dur = PApplet.parseInt(random(maxdur / 10, maxdur));
    period = PApplet.parseInt(random(100, 1000));
  }

  public void renderWave(PGraphics canvas) {
    canvas.noStroke();
    canvas.fill(255, alphaval);
    canvas.smooth();

    for (int x = 0; x < xvalues.length; x++) {
      canvas.ellipse(xpos + xvalues[x], x * xspacing, xspacing, xspacing);
    }
  }

  public void calcWave(float av) {

    int maxvals = 20;
    vals.append(av);
    if (vals.size() >= maxvals)
      vals.remove(0);

    float avrg = 0;
    for (int i = 0; i < vals.size (); i++) {
      avrg += vals.get(i);
    }
    avrg /= vals.size();

    // amplitude = map(mouseX, 0, width, 40, 100);
    amplitude = map(avrg, 0, 65, 0, 100);

    theta += 0.02f;
    float x = theta;
    for (int i = 0; i < xvalues.length; i++) {
      xvalues[i] = sin(x) * amplitude;
      x += dx;
    }

    int mt = 50;
    if (timer < mt) { 
      timer++;
    }
    if (av > 65 && timer >= mt) {
      resetVars();
      timer = 0;
    }

    if (avrg < 5)
      Ani.to(this, 1.5f, "alphaval", 20);
    if (avrg > 5 && alphaval < maxalpha)
      Ani.to(this, 1.5f, "alphaval", maxalpha);
  }
}

// branches visualization by stefan wagner (andsynchrony)

// WIP!!!!!!111

class Branches implements Visualization
{

  ArrayList branches;
  float velX, velY;


  Branches(int num, float size_x, float size_y)
  {
    setup(num, size_x, size_y);
  }

  public void setup()
  {
    println("WARNING: set up with empty handler");
  }

  public void setup(PApplet parent)
  {
    println("WARNING: set up with empty handler");
  }

  public void setup(int num, float size_x, float size_y)
  {
    branches = new ArrayList();
    for (int i = 0; i < num; i ++) {
      branches.add(new Branch2D(random(size_x/8), random(size_y/10), 0, 0));
    }
  }

  public void draw(PGraphics canvas, float[] average)
  {
    canvas.beginDraw();
    canvas.colorMode(HSB);
    canvas.background(0);
    for (int i = 0; i < branches.size (); i ++)
    {
      velX = abs(sin(radians(average[i])*200));
      velY = abs(cos(radians(average[i])/120));
      //velX = average[i]*0.12;
      //velY = average[i]/0.12;
      Branch2D branch = (Branch2D) branches.get(i);
      branch.generate(canvas, velX, velY);
    }
    canvas.endDraw();
  }
}


class Branch2D {
  float gravity = 0.0f;
  float mass = 6.0f;
  int numsprings = 25;
  ArrayList springs;
  float velX, velY;
  float posX, posY;
  float dirX, dirY;
  Branch2D(float posX, float posY, float dirX, float dirY) {
    this.posX = posX;
    this.posY = posY;
    this.dirX = dirX;
    this.dirY = dirY;
    springs = new ArrayList();
    for (int i = 0; i < numsprings; i += 5) {
      // randomSeed(i);
      if (i==0) {
        springs.add(new Spring2D(posX, posY, mass, gravity));
      } else {
        springs.add(new Spring2D(dirX-random(0, abs(dirX)), dirY-random(0, abs(dirY)), mass, gravity));
      }
      for (int j=1; j<4; j++) {
        springs.add(new Spring2D(random(-5, 5), random(-5, 5), mass, gravity));
      }
    }
  }
  public void generate(PGraphics canvas, float velX, float velY) {
    Spring2D firstspring = (Spring2D) springs.get(0);
    firstspring.update(posX, posY, velX, velY);
    firstspring.display(canvas, mouseX, mouseY);
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
        spring.display(canvas, backspring.x, backspring.y);
        canvas.stroke(0);
        canvas.strokeWeight(50/i);
        canvas.strokeCap(ROUND);
        canvas.line(spring.x, spring.y, backspring.x, backspring.y);
        for (int j = 1; j < 5; j++) {
          Spring2D spring2 = (Spring2D) springs.get(i+j);
          spring2.update(backspring.x, backspring.y, velX, velY);  
          canvas.stroke(0);
          canvas.line(spring2.x, spring2.y, backspring.x, backspring.y);
          spring2.display(canvas, backspring.x, backspring.y);
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
  float stiffness = 0.4f;
  float damping = 0.7f;
  float velX;
  float velY;
  Spring2D(float xpos, float ypos, float m, float g) {
    x = xpos;
    y = ypos;
    _x = xpos;
    _y = ypos;    
    mass = m;
    gravity = g;
  }
  public void update(float targetX, float targetY, float velX, float velY) {
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
  public void display(PGraphics canvas, float nx, float ny) {
    canvas.noStroke();

    for (int i = 0; i < 50; i++) {
      canvas.fill(95, random(300, 360), random(100, 360));
      canvas.rect(x+random(-20, 20), y+random(-20, 20), radius, radius);
    }
    randomSeed(round(x*2/3));
    for (int i = 0; i < 10; i++) {
      canvas.fill(0, 0, 360);
      canvas.rect(x+random(-10, 10), y+random(-10, 10), radius*2, radius*2);
    }
  }
}

// by Simon Schweissinger (@thnklt)



class CatRobotDance implements Visualization {

    Robot[] r = new Robot[8];

    CatRobotDance(PApplet parent) {
        setup(parent);
    }

    public void setup(int num, float size_x, float size_y) {
        println("WARNING: set up with empty handler");
    }

    public void setup() {
        println("WARNING: set up with empty handler");
    }

    public void setup(PApplet parent) {
        Ani.init(parent);
        for(int i = 0; i < r.length / 2; i++)
            r[i] = new Robot((width/(r.length + 1)) + i * (width/(r.length + 1)), 100);
        for(int i = 0; i < r.length / 2; i++)
            r[i + r.length / 2] = new Robot((width/(r.length + 1)) + i * (width/(r.length + 1)), 200);
    }

    public void draw(PGraphics canvas, float[] av) {
        canvas.beginDraw();
        canvas.background(0);

        for(int i = 0; i < r.length; i++)
            r[i].drawRobot(canvas, av[i]);

        canvas.endDraw();
    }
};

class Robot {
    PVector loc;
    PImage chest, arm, leg, head;

    Robot(int x, int y) {
        loc = new PVector(x, y);
        chest = loadImage("chest.png");
        arm = loadImage("arm.png");
        leg = loadImage("leg.png");
        head = loadImage("head.png");
    }

    public void drawRobot(PGraphics pg, float av) {
        pg.beginDraw();
        float rota = map(av, 0.0f, 1.0f, -HALF_PI, HALF_PI);

        pg.pushMatrix();
            pg.imageMode(CENTER);
            pg.translate(loc.x, loc.y);

            float ctr = map(av, 0, 75, -3, 3);
            pg.image(chest, loc.x, loc.y - ctr);

            pg.image(head, loc.x, loc.y - 40 - map(av, 0, 75, -5, 5));

            pg.image(leg, loc.x - 15, loc.y + 55);
            pg.image(leg, loc.x + 15, loc.y + 55 + map(av, 0, 75, -5, 5));

            pg.pushMatrix();
                pg.translate(loc.x - 37, loc.y - 20 - ctr);
                pg.rotate(rota);
                pg.image(arm, 0, 0);
            pg.popMatrix();

            pg.pushMatrix();
                pg.translate(loc.x + 37, loc.y - 20 - ctr);
                pg.rotate(PI - rota);
                pg.image(arm, 0, 0);
            pg.popMatrix();
        pg.popMatrix();

        pg.endDraw();
    }
}
// by Christopher Warnow











class ChrisClass implements Visualization
{

  // ------ mouse interaction ------
  float zoom = 750;
  int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
  float rotationX = 0, rotationY = 0, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY; 
  int spaceSizeX = 200, spaceSizeY = 300, spaceSizeZ = 200;

  // ------ drole particles on sphere ------
  int particleAmount = 500;
  Drole[] particles;

  float sphereSize = 300;
  int NUM_PARTICLES = 100;
  int REST_LENGTH=10;
  int SPHERE_RADIUS=300;

  VerletPhysics physics;
  VerletParticle head;

  // ------ pensee images inside sphere ------
  Pensee penseeA, penseeB, penseeC;

  ChrisClass()
  {
    setup();
  }

  public void setup(int num, float size_x, float size_y)
  {
    println("WARNING: set up with empty handler");
  }

  public void setup(PApplet parent)
  {
    println("WARNING: set up with empty handler");
  }

  public void setup()
  {
    // setup stuff comes here (image loading etc)
    // create drole particles
    particles = new Drole[particleAmount];

    // create particles
    for (int i=0; i<NUM_PARTICLES; i++) {
      particles[i] = new Drole(new PVector(random(-3.1414f, 3.1414f), random(-3.1414f, 3.1414f), random(-3.1414f, 3.1414f)), sphereSize, i);
    }

    // create collision sphere at origin, replace OUTSIDE with INSIDE to keep particles inside the sphere
    ParticleConstraint sphereA=new SphereConstraint(new Sphere(new Vec3D(), SPHERE_RADIUS), SphereConstraint.OUTSIDE);
    ParticleConstraint sphereB=new SphereConstraint(new Sphere(new Vec3D(), SPHERE_RADIUS*1.1f), SphereConstraint.INSIDE);
    physics=new VerletPhysics();
    // weak gravity along Y axis
    physics.addBehavior(new GravityBehavior(new Vec3D(0, 0.01f, 0)));
    // set bounding box to 110% of sphere radius
    physics.setWorldBounds(new AABB(new Vec3D(), new Vec3D(SPHERE_RADIUS, SPHERE_RADIUS, SPHERE_RADIUS).scaleSelf(1.1f)));
    VerletParticle prev=null;
    for (int i=0; i<NUM_PARTICLES; i++) {
      // create particles at random positions outside sphere
      VerletParticle p=new VerletParticle(Vec3D.randomVector().scaleSelf(SPHERE_RADIUS*2));
      // set sphere as particle constraint
      p.addConstraint(sphereA);
      p.addConstraint(sphereB);
      physics.addParticle(p);
      if (prev!=null) {
        physics.addSpring(new VerletSpring(prev, p, REST_LENGTH*5, 0.005f));
        physics.addSpring(new VerletSpring(physics.particles.get((int)random(i)), p, REST_LENGTH*20, 0.00001f + i*.0005f));
      }
      prev=p;
    }
    head=physics.particles.get(0);
    head.lock();

    // pensee images
    penseeA = new Pensee("content_small.png");
    penseeB = new Pensee("content_small.png");
    penseeC = new Pensee("content_small.png");
    penseeA.fillColor = color(255, 255, 255);
    penseeB.fillColor = color(200, 200, 0);
    penseeC.fillColor = color(100, 100, 0);
  }

  public void draw(PGraphics canvas, float[] average)
  {
    // update pensee images
    penseeA.update();
    if (frameCount > 100) penseeB.update();
    if (frameCount > 200) penseeC.update();

    // println(frameRate);
    // update particle movement
    head.set(noise(frameCount*(.005f + cos(frameCount*.001f)*.005f))*width-width/2, noise(frameCount*.005f + cos(frameCount*.001f)*.005f)*height-height/2, noise(frameCount*.01f + 100)*width-width/2);
    physics.particles.get(10).set(noise(frameCount*(.005f + cos(frameCount*.001f)*.005f))*width-width/2, noise(frameCount*.005f + cos(frameCount*.001f)*.005f)*height-height/2, noise(frameCount*.01f + 100)*width-width/2);
    // also apply sphere constraint to head
    // this needs to be done manually because if this particle is locked
    // it won't be updated automatically
    head.applyConstraints();
    // update sim
    physics.update();
    // then all particles as dots
    int index=0;
    for (Iterator i=physics.particles.iterator (); i.hasNext(); ) {
      VerletParticle p=(VerletParticle)i.next();
      particles[index++].addPosition(p.x, p.y, p.z);
    }

    canvas.beginDraw();
    canvas.background(0);
    canvas.lights();

    canvas.pushMatrix();

    zoom = 400 + average[0]*200;

    // ------ set view ------
    canvas.translate(width/2, height/2, zoom); 
    canvas.rotateY(radians(average[1])+frameCount*.005f); 
    canvas.rotateZ(radians(average[2])+frameCount*.002f); 

    // ------ draw image pens\u00e9e ------

    penseeA.fillColor = color(average[1]*255, average[1]*255, average[1]*255);
    penseeB.fillColor = color(100 + average[0]*100, 100 + average[0]*100, 0);

    penseeA.draw(canvas);
    penseeB.draw(canvas);
    penseeC.draw(canvas);

    canvas.popMatrix();

    canvas.endDraw();
  }
}


// M_1_6_01_TOOL.pde
// Agent.pde, GUI.pde, Ribbon3d.pde, TileSaver.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

class Agent {
  boolean isOutside = false;
  PVector p, beginning;
  float offset, stepSize, angleY, angleZ;
  Ribbon3d ribbon;
  float spaceSize = 250;
  int myColor;
  int positionSteps;

  float[] positionsX = new float[positionSteps];
  float[] positionsY = new float[positionSteps];
  float[] positionsZ = new float[positionSteps];
  int[] colors;
  float r, g, b, a;

  int pathPosition = 0;

  Agent(PVector beginning, int thisColor, int positionSteps, float noiseScale, float noiseStrength) {
    p = new PVector(beginning.x, beginning.y, beginning.z);//new PVector(0, 0, 0);
    this.myColor = thisColor;
    this.beginning = beginning;
    this.positionSteps = positionSteps;

    positionsX = new float[positionSteps];
    positionsY = new float[positionSteps];
    positionsZ = new float[positionSteps];

    offset = 10000;
    stepSize = random(2, 4);
    // how many points has the ribbon
    int ribbonSize = (int)random(1, 2);
    int ribbonAmount = 2;
    switch(ribbonSize) {
    case 2:
      ribbonAmount = 4;
      break;
    case 3:
      ribbonAmount = 6;
      break;
    default:
      break;
    }
    ribbon = new Ribbon3d(p, ribbonAmount);//(int)random(2, 5));

    // precompute positions
    for (int i=0; i<positionSteps; i++) {
      PVector thisP = new PVector(p.x, p.y, p.z);
      if (i>1) {
        thisP.x = positionsX[i-1];
        thisP.y = positionsY[i-1];
        thisP.z = positionsZ[i-1];

        float angleY = noise(thisP.x/noiseScale, thisP.y/noiseScale, thisP.z/noiseScale) * noiseStrength; 
        float angleZ = noise(thisP.x/noiseScale+offset, thisP.y/noiseScale, thisP.z/noiseScale) * noiseStrength;

        thisP.x += cos(angleZ) * cos(angleY) * stepSize;
        thisP.y += sin(angleZ) * stepSize;
        thisP.z += cos(angleZ) * sin(angleY) * stepSize;

        positionsX[i] = thisP.x;
        positionsY[i] = thisP.y;
        positionsZ[i] = thisP.z;
      } else {
        positionsX[i] = p.x;
        positionsY[i] = p.y;
        positionsZ[i] = p.z;
        p.x += 1;
      }
      // stepSize += .025;
    }

    // update(0);

    // set colors array
    colors = new int[getVertexCount()];
    for (int i=0; i<getVertexCount (); i++) {
      colors[i] = myColor;
    }

    r = red(myColor)/255.0f;
    g = green(myColor)/255.0f;
    b = blue(myColor)/255.0f;
    a = alpha(myColor)/255.0f;
  }

  public void update(int pathPosition) {
    // TODO: error handling / constrain to available positions

    // set curr position
    p.x = positionsX[pathPosition];
    p.y = positionsY[pathPosition];
    p.z = positionsZ[pathPosition];

    // boundingsphere wrap
    if (p.x*p.x+p.y*p.y+p.z*p.z > spaceSize*spaceSize) { 
      isOutside = true;
    }

    // create ribbons
    ribbon.update(p, isOutside);
    isOutside = false;
  }

  public void draw() {
    // ribbon.drawLineRibbon(myColor, 1.0);
    // ribbon.drawMeshRibbon(myColor,1.0);
  }

  /**
   * return an array of vertices (TODO: maybe a toxic mesh to compute normals...)
   */
  public PVector[] getVertices() {
    return ribbon.getVertices();
  }

  public int[] getColors() {
    return colors;
  }

  public int getVertexCount() {
    return ribbon.getVertexCount();
  }

  public boolean[] getGaps() {
    return ribbon.getGaps();
  }
}



class Drole {
  PVector p;
  float sphereSize;
  int id;
  int stepsAmount = 40;
  PVector[] oldPositions;
  PVector xyzPos = new PVector();
  Drole(PVector p, float sphereSize, int id) {
    this.p = p;
    this.sphereSize = sphereSize;
    this.id = id;

    oldPositions = new PVector[stepsAmount];
    for (int i=0; i<stepsAmount; i++) {
      oldPositions[i] = new PVector();
    }
  }

  public void update() {

    // wandering
    p.x += noise(p.x*100.01f)*.02f;//cos(i+frameCount*.005)*.001;//noise(particles[i].x*10.1)*(noise(frameCount*.1 + i)*.01);
    p.y += noise(p.y*10.01f)*.01f;//cos(i+frameCount*.01)*.001;//cos(noise(particles[i].y*10.1))*(noise(frameCount*.1 + i)*.01);

    if (p.y<-1||p.y>1)
    {
      p.y*=-1;
    }

    // new xyz position
    xyzPos.x = sin(p.x)*sqrt(1 - (p.y*p.y))*sphereSize;
    xyzPos.y = cos(p.x)*sqrt(1 - (p.y*p.y))*sphereSize; 
    xyzPos.z = p.y*sphereSize;

    oldPositions[0].x = xyzPos.x;
    oldPositions[0].y = xyzPos.y;
    oldPositions[0].z = xyzPos.z;

    // save old positions
    for (int i=stepsAmount-1; i>0; i--) {
      oldPositions[i].x = oldPositions[i-1].x;
      oldPositions[i].y = oldPositions[i-1].y;
      oldPositions[i].z = oldPositions[i-1].z;
    }
  }

  public void addPosition(float x, float y, float z) {
    xyzPos.x = x;
    xyzPos.y = y;
    xyzPos.z = z;

    oldPositions[0].x = xyzPos.x;
    oldPositions[0].y = xyzPos.y;
    oldPositions[0].z = xyzPos.z;

    // save old positions
    for (int i=stepsAmount-1; i>0; i--) {
      oldPositions[i].x = oldPositions[i-1].x;
      oldPositions[i].y = oldPositions[i-1].y;
      oldPositions[i].z = oldPositions[i-1].z;
    }
  }
}



/**
 * loads an image and converts every pixel into an agent, wich wanders on a noise field trough the space
 *
 * @Author Christopher Warnow, hello@christopherwarnow.com
 *
 */
class Pensee {
  // ------ agents ------
  Agent[] agents;
  int agentsCount;

  float noiseScale = 150, noiseStrength = 20; 
  int vertexCount = 0;

  PImage content;
  // GLModel imageModel, imageQuadModel;
  PShape imageQuadModel;
  // GLSLShader imageShader; // should pe provided by mother class?

  // animation values
  int currPosition = 0;
  int positionSteps = 100;
  int animationDirection = -1;
  int oldEasedIndex = 0;
  float easedPosition = 0;

  int fillColor = color(255, 255, 255);

  Pensee(String imagePath) {
    noiseSeed((long)random(1000));
    // load image
    content = loadImage(imagePath);

    // init agents pased on images pixels
    agentsCount = content.width*content.height;
    agents = new Agent[agentsCount];

    int i=0;
    for (int x=0; x<content.width; x++) {
      for (int y=0; y<content.height; y++) {
        agents[i++]=new Agent(new PVector(x-content.width/2, y-content.height/2, 0), content.get(x, y), positionSteps, noiseScale, noiseStrength);
        vertexCount += agents[i-1].getVertexCount();
      }
    }
    /*
    // extract agents vertices
     PVector[] vertices = new PVector[vertexCount];
     int vertexIndex = 0;
     for (Agent agent:agents) {
     for (PVector p:agent.getVertices()) {
     vertices[vertexIndex++] = new PVector(p.x, p.y, p.z);
     }
     }
     */

    // create a model that uses quads
    /*
    imageQuadModel = new GLModel(parent, vertexCount*4, QUADS, GLModel.DYNAMIC);
     imageQuadModel.initColors();
     imageQuadModel.initNormals();
     */
    imageQuadModel = createShape();

    // load shader
    // imageShader = new GLSLShader(parent, "imageVert.glsl", "imageFrag.glsl");
  }

  public void update() {
    // update playhead on precomputed noise path
    if (currPosition == positionSteps-1) {
      animationDirection *= -1;
    }
    if (currPosition == 0) {
      // if (frameCount%200==0) {
      animationDirection *= -1;
      currPosition += animationDirection;
      // }
    } else {
      currPosition += animationDirection;
    }

    // eased value out of currStep/positionSteps
    easedPosition = Cubic.easeInOut (currPosition, 0, positionSteps-1, positionSteps);
  }

  public void draw(PGraphics canvas) {//GLGraphics renderer) {
    // renderer.lights();
    // update glmodel

    // extract agents vertices

      //if(frameCount%100==0) {
    float[] floatQuadVertices = new float[vertexCount*16];
    float[] floatQuadNormals = new float[vertexCount*16];
    float[] floatQuadColors = new float[vertexCount*16];
    int quadVertexIndex = 0;
    int quadNormalIndex = 0;
    int quadColorIndex = 0;
    int allIndex = 0;
    int easedIndex = (int)easedPosition;
    float quadHeight = 5.0f + cos(frameCount*.01f)*5;
    boolean isUpdate = false;
    if (oldEasedIndex != easedIndex) isUpdate = true;
    oldEasedIndex = easedIndex;

    imageQuadModel = createShape();
    imageQuadModel.setFill(fillColor);
    imageQuadModel.beginShape(QUADS);
    imageQuadModel.noStroke();

    // for (Agent agent:agents) {
    for (int i=0; i<agentsCount; i++) {
      Agent agent = agents[i];
      // set agents position
      // TODO: improve updating performance
      if (isUpdate) agent.update(easedIndex);

      boolean[] gaps = agent.getGaps();
      int gapIndex = 0;

      // create quads from ribbons
      PVector[] agentsVertices = agent.getVertices();
      int agentVertexNum = agentsVertices.length;

      for (int j=0; j<agentVertexNum-1; j++) {
        PVector thisP = agentsVertices[j];
        PVector nextP = agentsVertices[j+1];
        PVector thirdP = agentsVertices[j+1];
        /*
        // TODO: create quad from above vertices and save in glmodel, then add colors
         floatQuadVertices[quadVertexIndex++] = thisP.x;
         floatQuadVertices[quadVertexIndex++] = thisP.y;
         floatQuadVertices[quadVertexIndex++] = thisP.z;
         floatQuadVertices[quadVertexIndex++] = 1.0;
         
         floatQuadVertices[quadVertexIndex++] = thisP.x;
         floatQuadVertices[quadVertexIndex++] = thisP.y + quadHeight;
         floatQuadVertices[quadVertexIndex++] = thisP.z;
         floatQuadVertices[quadVertexIndex++] = 1.0;
         
         floatQuadVertices[quadVertexIndex++] = nextP.x;
         floatQuadVertices[quadVertexIndex++] = nextP.y + quadHeight;
         floatQuadVertices[quadVertexIndex++] = nextP.z;
         floatQuadVertices[quadVertexIndex++] = 1.0;
         
         floatQuadVertices[quadVertexIndex++] = nextP.x;
         floatQuadVertices[quadVertexIndex++] = nextP.y;
         floatQuadVertices[quadVertexIndex++] = nextP.z;
         floatQuadVertices[quadVertexIndex++] = 1.0;
         */
        imageQuadModel.vertex(thisP.x, thisP.y, thisP.z);
        imageQuadModel.vertex(thisP.x, thisP.y + quadHeight, thisP.z);
        imageQuadModel.vertex(nextP.x, nextP.y + quadHeight, nextP.z);
        imageQuadModel.vertex(nextP.x, nextP.y, nextP.z);

        // compute face normal
        PVector v1 = new PVector(thisP.x - nextP.x, thisP.y - nextP.y, thisP.z - nextP.z);
        PVector v2 = new PVector(nextP.x - thisP.x, (nextP.y+quadHeight) - thisP.y, nextP.z - thisP.z);
        PVector v3 = v1.cross(v2);
        v3.normalize();

        float nX = v3.x;
        float nY = v3.y;
        float nZ = v3.z;
        /*
        floatQuadNormals[quadNormalIndex++] = nX;
         floatQuadNormals[quadNormalIndex++] = nY;
         floatQuadNormals[quadNormalIndex++] = nZ;
         floatQuadNormals[quadNormalIndex++] = 1.0;
         
         floatQuadNormals[quadNormalIndex++] = nX;
         floatQuadNormals[quadNormalIndex++] = nY;
         floatQuadNormals[quadNormalIndex++] = nZ;
         floatQuadNormals[quadNormalIndex++] = 1.0;
         
         floatQuadNormals[quadNormalIndex++] = nX;
         floatQuadNormals[quadNormalIndex++] = nY;
         floatQuadNormals[quadNormalIndex++] = nZ;
         floatQuadNormals[quadNormalIndex++] = 1.0;
         
         floatQuadNormals[quadNormalIndex++] = nX;
         floatQuadNormals[quadNormalIndex++] = nY;
         floatQuadNormals[quadNormalIndex++] = nZ;
         floatQuadNormals[quadNormalIndex++] = 1.0;
         */
        imageQuadModel.normal(nX, nY, nZ);
        imageQuadModel.normal(nX, nY, nZ);
        imageQuadModel.normal(nX, nY, nZ);
        imageQuadModel.normal(nX, nY, nZ);
        /*
        // add colors
         float theAlpha = agent.a * ((!gaps[gapIndex++]) ? 1.0 : 0.0);
         
         floatQuadColors[quadColorIndex++] = agent.r;
         floatQuadColors[quadColorIndex++] = agent.g;
         floatQuadColors[quadColorIndex++] = agent.b;
         floatQuadColors[quadColorIndex++] = theAlpha;
         
         floatQuadColors[quadColorIndex++] = agent.r;
         floatQuadColors[quadColorIndex++] = agent.g;
         floatQuadColors[quadColorIndex++] = agent.b;
         floatQuadColors[quadColorIndex++] = theAlpha;
         
         floatQuadColors[quadColorIndex++] = agent.r;
         floatQuadColors[quadColorIndex++] = agent.g;
         floatQuadColors[quadColorIndex++] = agent.b;
         floatQuadColors[quadColorIndex++] = theAlpha;
         
         floatQuadColors[quadColorIndex++] = agent.r;
         floatQuadColors[quadColorIndex++] = agent.g;
         floatQuadColors[quadColorIndex++] = agent.b;
         floatQuadColors[quadColorIndex++] = theAlpha;
         */
        // imageQuadModel.setFill(color(255, 255, 255));
      }
    }

    imageQuadModel.endShape();
    canvas.shape(imageQuadModel);
  }
}



// M_1_6_01_TOOL.pde
// Agent.pde, GUI.pde, Ribbon3d.pde, TileSaver.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

class Ribbon3d {
  int count; // how many points has the ribbon
  PVector[] p;
  boolean[] isGap;

  Ribbon3d (PVector theP, int theCount) {
    count = theCount; 
    p = new PVector[count];
    isGap = new boolean[count];
    for (int i=0; i<count; i++) {
      p[i] = new PVector(theP.x, theP.y, theP.z);
      isGap[i] = false;
    }
  }

  public void update(PVector theP, boolean theIsGap) {
    // shift the values to the right side
    // simple queue
    for (int i=count-1; i>0; i--) {
      p[i].set(p[i-1]);
      isGap[i] = isGap[i-1];
    }
    p[0].set(theP);
    isGap[0] = theIsGap;
  }
  /*
  void drawMeshRibbon(color theMeshCol, float theWidth) {
   // draw the ribbons with meshes
   fill(theMeshCol);
   noStroke();
   
   beginShape(QUAD_STRIP);
   for(int i=0; i<count-1; i++) {
   // if the point was wraped -> finish the mesh an start a new one
   if (isGap[i] == true) {
   vertex(p[i].x, p[i].y, p[i].z);
   vertex(p[i].x, p[i].y, p[i].z);
   endShape();
   beginShape(QUAD_STRIP);
   } 
   else {        
   PVector v1 = PVector.sub(p[i],p[i+1]);
   PVector v2 = PVector.add(p[i+1],p[i]);
   PVector v3 = v1.cross(v2);      
   v2 = v1.cross(v3);
   //v1.normalize();
   v2.normalize();
   //v3.normalize();
   //v1.mult(theWidth);
   v2.mult(theWidth);
   //v3.mult(theWidth);
   vertex(p[i].x+v2.x,p[i].y+v2.y,p[i].z+v2.z);
   vertex(p[i].x-v2.x,p[i].y-v2.y,p[i].z-v2.z);
   
   
   }
   
   }
   endShape();
   }
   
   
   void drawLineRibbon(color theStrokeCol, float theWidth) {
   // draw the ribbons with lines
   noFill();
   strokeWeight(theWidth);
   stroke(theStrokeCol);
   beginShape();
   for(int i=0; i<count; i++) {
   vertex(p[i].x, p[i].y, p[i].z);
   // if the point was wraped -> finish the line an start a new one
   if (isGap[i] == true) {
   endShape();
   beginShape();
   } 
   }
   endShape();
   }
   */
  public int getVertexCount() {
    return count;
  }

  // TODO: incorporate gaps
  public PVector[] getVertices() {
    return p;
  }

  public boolean[] getGaps() {
    return isGap;
  }
}

// by Lucas Dittebrandt

class CircleClass implements Visualization
{
  CircleClass()
  {
    setup();
  }

  public void setup()
  {
    // setup stuff comes here (image loading etc)
  }

  public void setup(int num, float size_x, float size_y) {
    println("WARNING: set up with empty handler");
  }

  public void setup(PApplet parent)
  {
    println("WARNING: set up with empty handler");
  }

  public void draw(PGraphics canvas, float[] average)
  {
    canvas.beginDraw();
    canvas.background(40);
    // draw ellipse channel 1
    canvas.stroke(0, 255, 255);
    canvas.fill(0, 255, 255);
    canvas.ellipse(width/8, height/3, 100 * average[0], 100 * average[0]);
    // draw ellipse channel 2
    canvas.stroke(255, 0, 255);
    canvas.fill(0, 0);
    canvas.ellipse(width/8*3, height/3, 100 * average[1], 100 * average[1]);
    // draw ellipse channel 3
    canvas.stroke(255, 255, 0);
    canvas.fill(0, 0);  
    canvas.ellipse(width/8*5, height/3, 100 * average[2], 100 * average[2]);
    // draw ellipse channel 4
    canvas.stroke(255, 255, 255);
    canvas.fill(0, 0);
    canvas.ellipse(width/8*7, height/3, 100 * average[3], 100 * average[3]);
    // draw ellipse channel 5
    canvas.stroke(0, 255, 255);
    canvas.fill(0, 0);
    canvas.ellipse(width/8, height/3*2, 100 * average[4], 100 * average[4]);
    // draw ellipse channel 6
    canvas.stroke(255, 0, 255);
    canvas.fill(0, 0);
    canvas.ellipse(width/8*3, height/3*2, 100 * average[5], 100 * average[5]);
    // draw ellipse channel 7
    canvas.stroke(255, 255, 0);
    canvas.fill(0, 0);
    canvas.ellipse(width/8*5, height/3*2, 100 * average[6], 100 * average[6]);
    // draw ellipse channel 8
    canvas.stroke(255, 255, 255);
    canvas.fill(0, 0);
    canvas.ellipse(width/8*7, height/3*2, 100 * average[7], 100 * average[7]);
    canvas.endDraw();
  }
}

// polyscape visualization by stefan wagner (andsynchrony)

class Polyscape implements Visualization
{
  PShape scape;
  float size_x;
  float size_y;
  int segments_x = 36;
  int segments_y = 26;
  float scale = 28.0f;

  float[][] vertices;

  Polyscape(float size_x, float size_y)
  {
    setup(0, size_x, size_y);
  }

  public void setup()
  {
    println("WARNING: set up with empty handler");
  }

  public void setup(PApplet parent)
  {
    println("WARNING: set up with empty handler");
  }

  public void setup(int num, float size_x, float size_y)
  {
    this.size_x = size_x;
    this.size_y = size_y;

    vertices = new float[segments_x * segments_y][];
    //scape.noStroke();
    float movement = frameCount * 0.2f;
    for (int y = 0; y < segments_y; y++)
    {
      for (int x = 0; x < segments_x; x++)
      {
        vertices[x + y * segments_x] = new float[] { 
          //scale * (x-segments_x/2), scale * (y-segments_y/2), 0
          x, y, 0
        };
      }
    }
  }

  public void draw(PGraphics canvas, float[] values)
  {
    updateScape();

    for (int i = 0; i < values.length; i++)
    {
      if (i == 2) // drums!
      {
        updateArea(1.0f, values[i]*500.0f, segments_x/2, segments_y/2, 16);
      } else 
      {
        randomSeed(i);
        updateArea(random(0, 4), values[i]*200.0f, PApplet.parseInt(random(segments_x)), PApplet.parseInt(random(segments_y)), 7);
      }
    }

    //updateArea(2.0, 200.0, segments_x * mouseX/width, segments_y * mouseY/height, 6);
    //updateArea(1.0, 200.0, segments_x/2, segments_y/2, 16);

    canvas.beginDraw();
    canvas.background(0);
    canvas.colorMode(HSB);
    canvas.ambientLight(0, 0, 100);
    noiseDetail(3, 0.5f);
    canvas.directionalLight(0, 0, 40, 0.0f, 0.0f, -1.0f);
    canvas.directionalLight(0, 360, 220, sin(0.001f*frameCount)*-0.9f, cos(0.001f*frameCount)*-1.0f, -0.1f);
    canvas.translate(width/2, height/2);
    canvas.scale(scale, scale, 1);
    canvas.translate( - segments_x/2, - segments_y/2, 0);
    //canvas.rotateY(radians(mouseX));
    //canvas.stroke(100);  
    canvas.noStroke();  
    canvas.beginShape(TRIANGLES);
    for (int y = 1; y < segments_y; y++)
    {
      for (int x = 0; x < segments_x - 1; x++)
      {
        canvas.fill(100 + 20.0f * y/PApplet.parseFloat(segments_y) + 30.0f * x/PApplet.parseFloat(segments_x), 100, 360);
        float[] f = vertices[x + (y-1) * segments_x];
        canvas.vertex(f[0], f[1], f[2]);
        f = vertices[x + y * segments_x];
        canvas.vertex(f[0], f[1], f[2]);
        f = vertices[(x+1) + (y-1) * segments_x];
        canvas.vertex(f[0], f[1], f[2]);
        f = vertices[x + y * segments_x];
        canvas.vertex(f[0], f[1], f[2]);       
        f = vertices[(x+1) + y * segments_x];
        canvas.vertex(f[0], f[1], f[2]);     
        f = vertices[(x+1) + (y-1) * segments_x];
        canvas.vertex(f[0], f[1], f[2]);
      }
    }

    canvas.endShape();
    canvas.endDraw();
  }

  public void updateScape()
  {
    float movement = millis() * 0.0004f;
    for (int y = 0; y < segments_y; y++)
    {
      for (int x = 0; x < segments_x; x++)
      {
        vertices[x + y * segments_x] = new float[] { 
          //scale * (x-segments_x/2), scale * (y-segments_y/2), 0
          x, y, 70.0f * noise(x, y, movement) - 0.5f
        };
      }
    }
  }

  public void updateArea(float speed, float amplitude, int cX, int cY, int radius)
  {
    for (int y = max (0, cY - radius); y < min(cY + radius, segments_y); y++)
    {
      for (int x = max (0, cX - radius); x < min(cX + radius, segments_x); x++)
      {
        float[] f = vertices[x + y * segments_x];
        float factor = map(dist(cX, cY, x, y), 0, radius*1.4f, 1.0f, 0.0f) * (sin( -frameCount * speed * 0.02f + PI * dist(cX, cY, x, y)/(radius*0.5f) )*0.5f + 0.5f);
        f[2] *= max(0.0f, 1.0f - factor);
        f[2] += amplitude * factor;
      }
    }
  }
}

// by Thomas Lipp

class ThomasClass implements Visualization
{
  ThomasClass()
  {
    setup();
  }

  PImage img;

  public void setup(int num, float size_x, float size_y)
  {
    println("WARNING: set up with empty handler");
  }

  public void setup()
  {

    img = loadImage("2.png");
    // setup stuff comes here (image loading etc)
  }

  public void setup(PApplet parent)
  {
    println("WARNING: set up with empty handler");
  }

  public void draw(PGraphics canvas, float[] average)
  {
    // drawing stuff comes here (image loading etc)

    int faktor = 1; 

    canvas.beginDraw();
    canvas.background(255);

    //canvas.smooth();

    // cat
    canvas.tint(255, 255-average[1]*3*faktor);
    canvas.imageMode(CENTER);
    canvas.image(img, width/2, height/2);

    // bass oder schlagzeug
    canvas.strokeWeight(0);
    canvas.rectMode(CENTER);
    canvas.fill(0, 200-average[3]*3*faktor);
    canvas.rect(width/2, height/2, width, height);

    // grid ellipsen
    canvas.tint(255);
    for (int i = 0; i < width+20; i+=width/50)
    {
      for (int j = 0; j < height+20; j+=width/50)
      {
        canvas.fill(23, 167, 118, 30);
        canvas.noFill();
        canvas.strokeWeight(1);
        canvas.stroke(23, 167, 118, 200);
        // position und gr\u00f6\u00dfe
        canvas.ellipse(i+random(average[0]/20*faktor), j+random(average[0]/20*faktor), average[2]/2*faktor, average[2]/2*faktor);
      }
    }


    // auge
    //canvas.strokeWeight(2);
    canvas.stroke(0, 40);

    canvas.fill(0, 0);
    canvas.rectMode(CENTER);
/*
    for (int k = 0; k < average[1]*faktor; k+=1)
    {
      canvas.ellipse(572, 294, average[4]*k*faktor, average[4]*k*faktor);
    }    
*/

    // rotating bars
    canvas.pushMatrix();

    canvas.translate(width/2, height/2);
    canvas.rotate(radians(average[5]*faktor));
/*
    for (int l = -height/2; l < height/2; l+=average[6]/5*faktor)
    {

      canvas.stroke(0, 100);
      canvas.strokeWeight(average[7]/30*faktor);
      canvas.line(l, -height/2, l, height/2);
    }
*/
    canvas.popMatrix();


    canvas.endDraw();
  }
}

public interface Visualization
{
  public void setup();
  public void setup(int num, float size_x, float size_y);
  public void setup(PApplet parent);
  public void draw(PGraphics canvas, float[] average);
}

public void switchVisualization(int id)
{
  visualizationID = constrain(id, 0, visualization.length-1);
  println("Switched to visualization # " + visualizationID);
}

    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "twrkmkVisualizationTool" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
