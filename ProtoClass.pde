// test class, alle visualisierung können 

class ProtoClass
{
  ProtoClass()
  {
    setup();
  }

  void setup()
  {
    // setup stuff comes here (image loading etc)
  }

  void draw(PGraphics canvas, float[] average)
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

