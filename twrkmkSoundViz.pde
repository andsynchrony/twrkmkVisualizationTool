import codeanticode.syphon.*;

PGraphics canvas;


SyphonServer server;
AudioHandler audio;

// visualizations
ProtoClass circles;


void setup() { 

  size(640, 480, P3D); 

  audio = new AudioHandler(8, true); // num 

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

  // visualizations
  circles = new ProtoClass();
}

void draw() { 
  background(0);

  audio.update();

  circles.draw( canvas, audio.getAverage() );
  image(canvas, 0, 0);

  server.sendImage(canvas);
}

