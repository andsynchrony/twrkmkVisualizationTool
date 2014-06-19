import codeanticode.syphon.*;

PGraphics canvas;

int numChannels = 8;


SyphonServer server;
AudioHandler audio;

// visualizations
ProtoClass circles;
Polyscape polyscape;
Branches branches;
//ThomasClass thomas;



void setup() { 

  size(1024, 768, P3D); 

  audio = new AudioHandler(numChannels, false); // num channels, debug mode on or off


  canvas = createGraphics(width, height, P2D);
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
  //polyscape = new Polyscape(width, height) new ThomasClass();
  //branches = new Branches(numChannels, width, height);
  //chrisClass = new ChrisClass();
  //thomas = new ThomasClass();
}

void draw() { 
  background(0);

  audio.update();


  circles.draw( canvas, audio.getSmoothed() );
  //polyscape.draw( canvas, audio.getVolume() );
  //thomas.draw( canvas, audio.getVolume() );
  //branches.draw( canvas, audio.getVolume() );
  //chrisClass.draw(canvas, audio.getVolume());
  image(canvas, 0, 0);

  debugDraw();

  server.sendImage(canvas);
}

void debugDraw()
{
  fill(255);
  noStroke();
  float[] a = audio.getVolume();
  float[] n = audio.getNormalized();
  for (int i = 0; i < a.length; i++)
  {
    text(i + " " + a[i], 30, 14 + i * 35);
    stroke(0);
    noFill();
    rect(30, 22 + i*35, 100, 15);
    noStroke();
    fill(255);
    rect(30, 22 + i*35, 100 * n[i], 15);
  }
}


