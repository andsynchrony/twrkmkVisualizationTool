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

    img = loadImage("2.png");
    // setup stuff comes here (image loading etc)
  }

  void draw(PGraphics canvas, float[] average)
  {
    // drawing stuff comes here (image loading etc)

    int faktor = 1; 

    canvas.beginDraw();
    canvas.background(255);

    //canvas.smooth();

    // cat
    canvas.tint(255, 255-average[1]*3*faktor);
    canvas.imageMode(CENTER);
    canvas.image(img, width/2, height/2);

    // bass oder schlagzeug
    canvas.strokeWeight(0);
    canvas.rectMode(CENTER);
    canvas.fill(0, 200-average[3]*3*faktor);
    canvas.rect(width/2, height/2, width, height);

    // grid ellipsen
    canvas.tint(255);
    for (int i = 0; i < width+20; i+=width/50)
    {
      for (int j = 0; j < height+20; j+=width/50)
      {
        canvas.fill(23, 167, 118, 30);
        canvas.noFill();
        canvas.strokeWeight(1);
        canvas.stroke(23, 167, 118, 200);
        // position und größe
        canvas.ellipse(i+random(average[0]/20*faktor), j+random(average[0]/20*faktor), average[2]/2*faktor, average[2]/2*faktor);
      }
    }


    // auge
    //canvas.strokeWeight(2);
    canvas.stroke(0, 40);

    canvas.fill(0, 0);
    canvas.rectMode(CENTER);

    for (int k = 0; k < average[1]*faktor; k+=1)
    {
      canvas.ellipse(572, 294, average[4]*k*faktor, average[4]*k*faktor);
    }    


    // rotating bars
    canvas.pushMatrix();

    canvas.translate(width/2, height/2);
    canvas.rotate(radians(average[5]*faktor));

    for (int l = -height/2; l < height/2; l+=average[6]/5*faktor)
    {

      canvas.stroke(0, 100);
      canvas.strokeWeight(average[7]/30*faktor);
      canvas.line(l, -height/2, l, height/2);
    }

    canvas.popMatrix();


    canvas.endDraw();
  }
}

