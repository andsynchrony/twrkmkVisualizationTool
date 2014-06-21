// by Simon Schweissinger (@thnklt)

import de.looksgood.ani.*;

class CatRobotDance implements Visualization {

    Robot[] r = new Robot[12];
    Cat[] c = new Cat[4];

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

        for(int i = 0; i < 4; i++) {
            int temp = 0;
            for(int k = 0; k < 3; k++) {
                if(i == k)  temp = 192;
                r[i * 3 + k] = new Robot(128 + 192/2 + 192 * k + temp, 96 + i * 192);
            }
            c[i] = new Cat(128 + 192/2 + 192 * i, 96 + i * 192);
        }
    }

    void draw(PGraphics canvas, float[] av, boolean b) {}

    void draw(PGraphics canvas, float[] av) {
        canvas.beginDraw();
        canvas.background(0);
        canvas.tint(255);
        for(int k = 0; k < 4; k++) {
            for(int i = 0; i < 4; i++) {
                int indx = ((k * 4) + i) > 7 ? ((k * 4) + i) - 8 : (k * 4) + i;
                if(i > 0)   r[(k * 3) + i - 1].drawRobot(canvas, av[indx]);
                else        c[k].drawCat(canvas, av[indx]);
            }
        }
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
    int mod = 1;

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
            pg.translate(loc.x, loc.y);
            pg.scale(0.7 * mod, 0.7);

            pg.image(body, 0, 0);

            pg.pushMatrix();
                pg.translate(20, -67);
                pg.rotate(map(av, 0.0, 0.8, QUARTER_PI, -QUARTER_PI));
                pg.image(head, 0, 0);
            pg.popMatrix();

            pg.pushMatrix();
                pg.translate(-44, 41);
                pg.rotate(rota);
                pg.image(tail, 0, 0);
            pg.popMatrix();

            pg.pushMatrix();
                pg.translate(22, -69);
                pg.scale(map(av, 0.0, 1.0, 0.5, 1.5));
                pg.rotate(map(millis() % 10000, 0, 10000, 0, TWO_PI));
                pg.image(eye, 0, 0);
            pg.popMatrix();
        pg.popMatrix();

        pg.endDraw();
    }
} // eoc
