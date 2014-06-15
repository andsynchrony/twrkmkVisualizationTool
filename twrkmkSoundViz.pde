import codeanticode.syphon.*;

PGraphics canvas;


SyphonServer server;
AudioHandler audio;

// visualizations
ProtoClass circles;
Polyscape polyscape;
Branches branches;
ChrisClass chrisClass;


void setup() { 

  size(1024, 768, P3D); 

  audio = new AudioHandler(8, true); // num channels, debug mode on or off

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
  //circles = new ProtoClass();
  //polyscape = new Polyscape(width, height);
  branches = new Branches(audio.getVolume(), width, height);
  //chrisClass = new ChrisClass();

}

void draw() { 
  background(0);

  audio.update();

  //circles.draw( canvas, audio.getAverage() );
  //polyscape.draw( canvas, audio.getVolume() );
  branches.draw( canvas, audio.getVolume() );
  //chrisClass.draw(canvas, audio.getVolume());
  image(canvas, 0, 0);

  server.sendImage(canvas);
}

