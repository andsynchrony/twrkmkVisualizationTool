// BeadWave class [Simon]

import de.looksgood.ani.*;

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

  void setup()
  {
    println("WARNING: set up with empty handler");
  }

  void setup(int num, float size_x, float size_y)
  {
    println("WARNING: set up with empty handler");
  }


  void setup(PApplet parent) {
    w = new Wave[channels * mod];

    Ani.init(parent);

    float colw = width / (channels * mod);
    for (int i = 0; i < channels; i++) {
      for (int k = 0; k < mod; k++) {
        w[i + k * channels] = new Wave(i, int(colw / 2 + ((i + (k * channels)) * colw)));
      }
    }
  }

  void draw(PGraphics canvas, float[] average) {
    canvas.beginDraw();

    canvas.background(0);

    for (int i = 0; i < channels; i++) {
      for (int k = 0; k < mod; k++) {
        w[i + k * channels].calcWave(average[i]);
        w[i + k * channels].renderWave(canvas);
      }
    }

    canvas.endDraw();
  }
  
  void draw(PGraphics canvas, float[] average, boolean beat){
    draw(canvas, average);
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
    theta = 0.0;
    amplitude = 75.0;
    timer = 0;
    this.id = id;
    vals = new FloatList();
    alphaval = 0;
    maxalpha = 200;

    resetVars();
    // dur = 500;

    w = height + beadsize;
    dx = (TWO_PI / period) * xspacing;
    xvalues = new float[w / int(xspacing)];
  }

  void resetVars() {
    // Ani.to(this, 2.5, "amplitude", random(40.0, 100.0));
    Ani.to(this, 2.5, "xspacing", random(10.0, 20.0));
    dur = int(random(maxdur / 10, maxdur));
    period = int(random(100, 1000));
  }

  void renderWave(PGraphics canvas) {
    canvas.noStroke();
    canvas.fill(255, alphaval);
    canvas.smooth();

    for (int x = 0; x < xvalues.length; x++) {
      canvas.ellipse(xpos + xvalues[x], x * xspacing, xspacing, xspacing);
    }
  }

  void calcWave(float av) {

    int maxvals = 20;
    vals.append(av);
    if (vals.size() >= maxvals)
      vals.remove(0);

    float avrg = 0;
    for (int i = 0; i < vals.size (); i++) {
      avrg += vals.get(i);
    }
    avrg /= vals.size();

    amplitude = map(avrg, 0, 1, 0, 100);

    theta += 0.02;
    float x = theta;
    for (int i = 0; i < xvalues.length; i++) {
      xvalues[i] = sin(x) * amplitude;
      x += dx;
    }

    int mt = 50;
    if (timer < mt) { 
      timer++;
    }
    if (avrg > 0.9 && timer >= mt) {
      resetVars();
      timer = 0;
    }

    if (avrg < 0.05)
      Ani.to(this, 1.5, "alphaval", 20);
    if (avrg > 0.05 && alphaval < maxalpha)
      Ani.to(this, 1.5, "alphaval", maxalpha);
  }
}

