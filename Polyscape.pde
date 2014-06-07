class Polyscape
{
  PShape scape;
  float size_x;
  float size_y;
  int segments_x = 30;
  int segments_y = 19;
  float scale = 28.0;

  float[][] vertices;

  Polyscape(float size_x, float size_y)
  {
    setup(size_x, size_y);
  }

  void setup(float size_x, float size_y)
  {
    this.size_x = size_x;
    this.size_y = size_y;

    vertices = new float[segments_x * segments_y][];
    //scape.noStroke();
    float movement = frameCount * 0.2;
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

  void draw(PGraphics canvas, float[] average)
  {
    updateScape();
    updateArea(90.0, segments_x * mouseX/width, segments_y * mouseY/height, 4);
    updateArea(60.0, segments_x/2, segments_y/2, 16);

    canvas.beginDraw();
    canvas.background(0);
    canvas.colorMode(HSB);
    canvas.ambientLight(0, 0, 100);
    noiseDetail(3, 0.5);
    canvas.directionalLight(0, 0, 40, 0.0, 0.0, -1.0);
    canvas.directionalLight(0, 360, 220, sin(0.001*frameCount)*-0.9, cos(0.001*frameCount)*-1.0, -0.1);
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
        canvas.fill(100 + 20.0 * y/float(segments_y) + 30.0 * x/float(segments_x), 100, 360);
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

  void updateScape()
  {
    float movement = millis() * 0.0004;
    for (int y = 0; y < segments_y; y++)
    {
      for (int x = 0; x < segments_x; x++)
      {
        vertices[x + y * segments_x] = new float[] { 
          //scale * (x-segments_x/2), scale * (y-segments_y/2), 0
          x, y, 70.0 * noise(x, y, movement) - 0.5
        };
      }
    }
  }

  void updateArea(float amplitude, int cX, int cY, int radius)
  {
    for (int y = max (0, cY - radius); y < min(cY + radius, segments_y); y++)
    {
      for (int x = max (0, cX - radius); x < min(cX + radius, segments_x); x++)
      {
        float[] f = vertices[x + y * segments_x];
        float factor = 1.0 - dist(cX, cY, x, y)/(radius*0.7);
        println(factor);
        f[2] *= max(0.0, 0.8 - factor);
        f[2] += sin(frameCount*0.02) * amplitude * factor;
      }
    }
  }
}

