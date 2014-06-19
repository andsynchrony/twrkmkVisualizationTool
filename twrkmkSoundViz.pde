import codeanticode.syphon.*;

PGraphics canvas;

int numChannels = 8;

boolean setDrawDebug = true;


Visualization[] visualization;
int visualizationID = 0;

SyphonServer server;
AudioHandler audio;


void setup() { 

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

  void draw() { 
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
  catch(Exception e){}
  if (key == ' ')
  {
    switchVisualization(visualizationID+1);
  } else if (key == 'd')
  {
    setDrawDebug = !setDrawDebug;
  }
}

