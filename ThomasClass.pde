// by Thomas Lipp

class ThomasClass implements Visualization
{
  ThomasClass()
  {
    setup();
  }

  PImage img;

  void setup(int num, float size_x, float size_y)
  {
    println("WARNING: set up with empty handler");
  }

  void setup()
  {
    println("WARNING: set up with empty handler");
  }

  void setup(PApplet parent)
  {
    println("WARNING: set up with empty handler");
  }

  void draw(PGraphics canvas, float[] average, boolean b) {
  }

  void draw(PGraphics canvas, float[] average)
  {
    canvas.beginDraw();
    if (random(0, 1) > 0.95)
      canvas.background(255, 2);
    else
      canvas.background(0);
    canvas.noFill();
    canvas.stroke(255);
    canvas.strokeWeight(1);
    canvas.rectMode(CENTER);

    float triggerwert = 0.75;
    int h = height/4;
    int luecken = 25;    // ab 30 > linien verschwinden
    //float rota = radians((values[0]-0.5)*20);    // rotation nur von einem kanal abhängig > dann unten auskomm.
    int valtemp;


    // werte zwischen 0 und 1 zwingen
    float[] values = new float[8];
    for (int i = 0; i < 8; i++)
    {
      if (average[i] > 0 && average[i] < 1)
        values[i] = average[i];
      else
        values[i] = 0;
    }


    // anordnung position (kasten links oben)
    canvas.translate(width/2-(1.5*h), h/2);

    /*
    // fill über triggerwert
     if(values[0] > triggerwert)
     {
     canvas.fill(255, values[0]*30);
     }
     */

    // array
    for (int i=0; i < 4; i++)
    {
      for (int j=0; j < 4; j++)
      {
        // 8 channels in grid anordnen
        if (j == 0 || j == 2)
          valtemp = i;
        else
          valtemp = i+4;

        // innerhalb (an richtiger position)
        canvas.pushMatrix();  

        canvas.translate(i*h, j*h);
        //canvas.scale(1.9);
        //for(int r= h-luecken; r > (1-values[valtemp])*200; r-= 5)
        for (int r= h-luecken; r > (1.3-values[valtemp])*200; r-= 5)    // dichte der kaesten ineinander || evtl. problemstelle??? > constrain > vorher berechnen (variable?)
        {
          float rota = radians((values[valtemp])*5);      // rotation / tiefe abahaengig
          //float rota = radians((values[7-valtemp]-0.5)*20);    // rotation / tiefe unabahaengig
          //if(j == 2 || j == 3)
          if (keyPressed == true && keyCode == DOWN)
            ;
          else
            canvas.rotate(rota);
          canvas.stroke(map(r, h-luecken, 0, 255, -100));
          canvas.rect(0, 0, r, r);
        }

        canvas.popMatrix();  
        // innerhalb ende


        // grün bei wenig signal
        if (values[valtemp] < 0.25)
        {
          canvas.noStroke();
          canvas.fill(23, 167, 118, 200);
          canvas.rect(i*h, j*h, h-(luecken/2), h-(luecken/2));
          canvas.noFill();
        }


        // gewitter
        if (values[0]+values[1]+values[2]+values[3]+values[4]+values[5]+values[6]+values[7] > 7.7) // 0 bis 8
        {
          canvas.noStroke();
          if (random(0, 1) > 0.5)
            canvas.fill(255);
          canvas.rect(i*h, j*h, h-(luecken/2), h-(luecken/2));
          canvas.noFill();
        }
      }
    }
    canvas.endDraw();
  }
}

