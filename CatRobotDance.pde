// by Simon Schweissinger


import de.looksgood.ani.*;

class CatRobotDance {

    Robot[] r = new Robot[8];

    CatRobotDance(PApplet parent) {
        Ani.init(parent);
        for(int i = 0; i < r.length / 2; i++)
            r[i] = new Robot((width/(r.length + 1)) + i * (width/(r.length + 1)), 100);
        for(int i = 0; i < r.length / 2; i++)
            r[i + r.length / 2] = new Robot((width/(r.length + 1)) + i * (width/(r.length + 1)), 200);
    }

    void draw(PGraphics canvas, float[] av) {
        canvas.beginDraw();
        canvas.background(0);

        for(int i = 0; i < r.length; i++)
            r[i].drawRobot(canvas, av[i]);

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
        float rota = map(av, 0, 75, -HALF_PI, HALF_PI);

        pg.pushMatrix();
            pg.imageMode(CENTER);
            pg.translate(loc.x, loc.y);

            float ctr = map(av, 0, 75, -3, 3);
            pg.image(chest, loc.x, loc.y - ctr);

            pg.image(head, loc.x, loc.y - 40 - map(av, 0, 75, -5, 5));

            pg.image(leg, loc.x - 15, loc.y + 55);
            pg.image(leg, loc.x + 15, loc.y + 55 + map(av, 0, 75, -5, 5));

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
}