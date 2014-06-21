/*======================================
 __                __                 
 / /__      _______/ /______ ___  _____
 / __/ | /| / / ___/ //_/ __ `__ \/ ___/
 / /_ | |/ |/ / /  / ,< / / / / / / /__  
 \__/ |__/|__/_/  /_/|_/_/ /_/ /_/\___/  
 
 ====== Sound Visualization Tool ======*/

import codeanticode.syphon.*;

PGraphics canvas;

int numChannels = 8;

Visualization[] visualization;
int visualizationID = 0;

SyphonServer server;
AudioHandler audio;

// add for beatDetection
import controlP5.*;
ControlP5 cp5;
float alpha = 0.9;
float threshold = 0.2f;

boolean setDrawDebug;


void setup()
{ 
  size(1024, 768, P3D); 
  // controls for BeatDetection
  cp5 = new ControlP5(this);
  cp5.addSlider("alpha")
    .setPosition(30, height-100)
      .setSize(100, 20)
        .setRange(0, 1)
          ;
  cp5.addSlider("threshold")
    .setPosition(30, height-50)
      .setSize(100, 20)
        .setRange(0, 1)
          ;

  audio = new AudioHandler(numChannels, true); // num channels, debug mode on or off

  canvas = createGraphics(width, height, P3D);

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

    setDebug(true);
  }

  void draw()
  { 
    background(0);
    audio.update();
    visualization[visualizationID].draw(canvas, audio.getSmoothed());
    image(canvas, 0, 0);
    if (setDrawDebug)
      audio.drawInput();
    server.sendImage(canvas);
  }


void keyPressed()
{
  try
  {
    int id = Integer.parseInt(key+"");
    if (id >= 0 && id <= visualization.length)
    {
      switchVisualization(id);
    }
  } 
  catch(Exception e) {
  }
  if (key == ' ')
  {
    switchVisualization(visualizationID+1);
  } else if (key == 'd')
  {
    setDebug(!setDrawDebug);
  }
}

void setDebug(boolean b)
{
  setDrawDebug = b;
  if (!setDrawDebug)
    cp5.hide();
  else
    cp5.show();
}
