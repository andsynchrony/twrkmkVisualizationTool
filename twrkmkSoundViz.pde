import codeanticode.syphon.*;

PGraphics canvas;

int numChannels = 8;


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
    new Polyscape(width, height),
    new ChrisClass(),
    new ThomasClass(),
    new Branches(numChannels, width, height),
  };

}

void draw() { 
  background(0);

  audio.update();


  visualization[visualizationID].draw( canvas, audio.getSmoothed() );
  image(canvas, 0, 0);

  audio.drawInput();

  server.sendImage(canvas);
}


void keyPressed()
{
  int id = Integer.parseInt(key+"");
  if(id >= 0 && id <= visualization.length)
  {
    switchVisualization(id);
  }
  if(key == ' ')
  {
    switchVisualization(visualizationID+1);
  }
}



