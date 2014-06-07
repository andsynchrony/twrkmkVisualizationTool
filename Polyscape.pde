class Polyscape
{
  PShape scape;
  float size_x;
  float size_y;
  int segments_x = 30;
  int segments_y = 17;
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

    scape = createShape();
    scape.beginShape(TRIANGLES);
    scape.colorMode(HSB);
    scape.fill(0, 0, 360);
    scape.noStroke();
    float movement = frameCount * 0.2;
    for (int y = 0; y < segments_y; y++)
    {
      for (int x = 0; x < segments_x; x++)
      {
        vertices[x + y * segments_x] = new float[] { 
          scale * (x-segments_x/2), scale * (y-segments_y/2), 0
        };
      }
    }

    for (int y = 1; y < segments_y; y++)
    {
      for (int x = 0; x < segments_x-1; x++)
      {
        scape.fill(100 + 20.0 * y/float(segments_y) + 30.0 * x/float(segments_x), 100, 360);
        float[] f = vertices[x + (y-1) * segments_x];
        scape.vertex(f[0], f[1], f[2]);
        f = vertices[x + y * segments_x];
        scape.vertex(f[0], f[1], f[2]);
        f = vertices[(x+1) + (y-1) * segments_x];
        scape.vertex(f[0], f[1], f[2]);
        f = vertices[x + y * segments_x];
        scape.vertex(f[0], f[1], f[2]);       
        f = vertices[(x+1) + y * segments_x];
        scape.vertex(f[0], f[1], f[2]);     
        f = vertices[(x+1) + (y-1) * segments_x];
        scape.vertex(f[0], f[1], f[2]);
      }
    }

    scape.endShape();
  }

  void draw(PGraphics canvas, float[] average)
  {
    updateScape();
    canvas.beginDraw();
    canvas.background(0);
    canvas.colorMode(HSB);
    canvas.ambientLight(0, 0, 100);
    noiseDetail(3, 0.5);
    canvas.directionalLight(0, 0, 40, 0.0, 0.0, -1.0);
    canvas.directionalLight(0, 360, 220, -0.9, -1.0, -0.1);
    canvas.translate(width/2, height/2);
    //canvas.rotateY(radians(mouseX));
    canvas.shape(scape);
    canvas.endDraw();
  }

  void updateScape()
  {
    float movement = frameCount * 0.005;
    for (int i = 0; i < scape.getVertexCount (); i++)
    {
      //scape.fill(180.0 * y/float(segments_y), 360, 360);
      PVector f = scape.getVertex(i);
      f.z = 40.0*noise(f.x, f.y, movement);
      scape.setVertex(i, f);
    }
  }
}

