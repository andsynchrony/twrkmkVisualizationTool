// by Simon Schweissinger (@thnklt)

import de.looksgood.ani.*;

class CatRobotDance implements Visualization {

    Robot[] r = new Robot[6];
    Cat[] c = new Cat[2];

    CatRobotDance(PApplet parent) {
        setup(parent);
    }

    void setup(int num, float size_x, float size_y) {
        println("WARNING: set up with empty handler");
    }

    void setup() {
        println("WARNING: set up with empty handler");
    }

    void setup(PApplet parent) {
        Ani.init(parent);
        for(int i = 0; i < r.length / 2; i++)
            r[i] = new Robot((width/5) * (i + 1), height/3);
        for(int i = 0; i < r.length / 2; i++)
            r[i + r.length / 2] = new Robot((width/5) + (width/5) * (i + 1), (height/3)*2);

        c[0] = new Cat((width/5) * 4 + 20, height/3 + 25);
        c[1] = new Cat((width/5) + 20, (height/3) * 2 + 25);
    }

    void draw(PGraphics canvas, float[] av) {
        
        canvas.beginDraw();
        canvas.background(0);

        for(int i = 0; i < r.length; i++)
            r[i].drawRobot(canvas, av[i]);
        for(int i = 0; i < c.length; i++)
            c[i].drawCat(canvas, av[i + r.length]);

        canvas.endDraw();
    }
};

class Robot {
    PVector loc;
    PImage chest, arm, leg, head;

    Robot(int x, int y) {
        loc = new PVector(x, y);
        chest = loadImage("chest.png");
        arm = loadImage("arm.png");
        leg = loadImage("leg.png");
        head = loadImage("head.png");
    }

    void drawRobot(PGraphics pg, float av) {
        pg.beginDraw();
        float rota = map(av, 0.0, 1.0, -HALF_PI, HALF_PI);

        pg.pushMatrix();
            pg.imageMode(CENTER);

            float ctr = map(av, 0.0, 1.0, -3, 3);
            pg.image(chest, loc.x, loc.y - ctr);

            pg.image(head, loc.x, loc.y - 40 - map(av, 0, 1.0, -5, 5));

            pg.image(leg, loc.x - 15, loc.y + 55);
            pg.image(leg, loc.x + 15, loc.y + 55 + map(av, 0, 1.0, -5, 5));

            pg.pushMatrix();
                pg.translate(loc.x - 37, loc.y - 20 - ctr);
                pg.rotate(rota);
                pg.image(arm, 0, 0);
            pg.popMatrix();

            pg.pushMatrix();
                pg.translate(loc.x + 37, loc.y - 20 - ctr);
                pg.rotate(PI - rota);
                pg.image(arm, 0, 0);
            pg.popMatrix();
        pg.popMatrix();

        pg.endDraw();
    }
} // eoc

class Cat {
    PVector loc;
    PImage body, head, eye, tail;

    Cat(int x, int y) {
        loc = new PVector(x, y);
        eye = loadImage("cat-eye.png");
        body = loadImage("cat-body.png");
        tail = loadImage("cat-tail.png");
        head = loadImage("cat-head.png");
    }

    void drawCat(PGraphics pg, float av) {
        pg.beginDraw();
        float rota = map(av, 0.0, 0.8, -QUARTER_PI, QUARTER_PI);

        pg.pushMatrix();
            pg.imageMode(CENTER);
            pg.scale(0.7);

            float ctr = map(av, 0, 75, -3, 3);
            pg.image(body, loc.x, loc.y - ctr);

            pg.pushMatrix();
                pg.translate(loc.x + 20, loc.y - 67);
                // pg.rotate(map(av, 0.0, 1.0, 0, HALF_PI));
                pg.rotate(map(av, 0.0, 0.8, QUARTER_PI, -QUARTER_PI));
                pg.image(head, 0, 0);
            pg.popMatrix();

            pg.pushMatrix();
                pg.translate(loc.x - 44, loc.y + 41);
                pg.rotate(rota);
                pg.image(tail, 0, 0);
            pg.popMatrix();

            pg.pushMatrix();
                pg.translate(loc.x + 22, loc.y - 69);
                pg.scale(map(av, 0.0, 1.0, 0.5, 1.5));
                pg.rotate(map(millis() % 10000, 0, 10000, 0, TWO_PI));
                pg.image(eye, 0, 0);
            pg.popMatrix();
        pg.popMatrix();

        pg.endDraw();
    }
} // eoc