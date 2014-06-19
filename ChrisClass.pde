import toxi.physics.constraints.*;
import toxi.physics.behaviors.*;
import toxi.physics.*;
import toxi.geom.*;
import toxi.math.*;
import penner.easing.*;

import java.util.Iterator;
import java.util.Calendar;

class ChrisClass implements Visualization
{

  // ------ mouse interaction ------
  float zoom = 750;
  int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
  float rotationX = 0, rotationY = 0, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY; 
  int spaceSizeX = 200, spaceSizeY = 300, spaceSizeZ = 200;

  // ------ drole particles on sphere ------
  int particleAmount = 500;
  Drole[] particles;

  float sphereSize = 300;
  int NUM_PARTICLES = 100;
  int REST_LENGTH=10;
  int SPHERE_RADIUS=300;

  VerletPhysics physics;
  VerletParticle head;

  // ------ pensee images inside sphere ------
  Pensee penseeA, penseeB, penseeC;

  ChrisClass()
  {
    setup();
  }
  
  void setup(int num, float size_x, float size_y)
  {
    println("WARNING: set up with empty handler");
  }

  void setup()
  {
    // setup stuff comes here (image loading etc)
    // create drole particles
    particles = new Drole[particleAmount];

    // create particles
    for (int i=0;i<NUM_PARTICLES;i++) {
      particles[i] = new Drole(new PVector(random(-3.1414, 3.1414), random(-3.1414, 3.1414), random(-3.1414, 3.1414)), sphereSize, i);
    }

    // create collision sphere at origin, replace OUTSIDE with INSIDE to keep particles inside the sphere
    ParticleConstraint sphereA=new SphereConstraint(new Sphere(new Vec3D(), SPHERE_RADIUS), SphereConstraint.OUTSIDE);
    ParticleConstraint sphereB=new SphereConstraint(new Sphere(new Vec3D(), SPHERE_RADIUS*1.1), SphereConstraint.INSIDE);
    physics=new VerletPhysics();
    // weak gravity along Y axis
    physics.addBehavior(new GravityBehavior(new Vec3D(0, 0.01, 0)));
    // set bounding box to 110% of sphere radius
    physics.setWorldBounds(new AABB(new Vec3D(), new Vec3D(SPHERE_RADIUS, SPHERE_RADIUS, SPHERE_RADIUS).scaleSelf(1.1)));
    VerletParticle prev=null;
    for (int i=0; i<NUM_PARTICLES; i++) {
      // create particles at random positions outside sphere
      VerletParticle p=new VerletParticle(Vec3D.randomVector().scaleSelf(SPHERE_RADIUS*2));
      // set sphere as particle constraint
      p.addConstraint(sphereA);
      p.addConstraint(sphereB);
      physics.addParticle(p);
      if (prev!=null) {
        physics.addSpring(new VerletSpring(prev, p, REST_LENGTH*5, 0.005));
        physics.addSpring(new VerletSpring(physics.particles.get((int)random(i)), p, REST_LENGTH*20, 0.00001 + i*.0005));
      }
      prev=p;
    }
    head=physics.particles.get(0);
    head.lock();

    // pensee images
    penseeA = new Pensee("content_small.png");
    penseeB = new Pensee("content_small.png");
    penseeC = new Pensee("content_small.png");
    penseeA.fillColor = color(255, 255, 255);
    penseeB.fillColor = color(200, 200, 0);
    penseeC.fillColor = color(100, 100, 0);
  }

  void draw(PGraphics canvas, float[] average)
  {
    // update pensee images
    penseeA.update();
    if(frameCount > 100) penseeB.update();
    if(frameCount > 200) penseeC.update();
    
    // println(frameRate);
    // update particle movement
    head.set(noise(frameCount*(.005 + cos(frameCount*.001)*.005))*width-width/2, noise(frameCount*.005 + cos(frameCount*.001)*.005)*height-height/2, noise(frameCount*.01 + 100)*width-width/2);
    physics.particles.get(10).set(noise(frameCount*(.005 + cos(frameCount*.001)*.005))*width-width/2, noise(frameCount*.005 + cos(frameCount*.001)*.005)*height-height/2, noise(frameCount*.01 + 100)*width-width/2);
    // also apply sphere constraint to head
    // this needs to be done manually because if this particle is locked
    // it won't be updated automatically
    head.applyConstraints();
    // update sim
    physics.update();
    // then all particles as dots
    int index=0;
    for (Iterator i=physics.particles.iterator(); i.hasNext();) {
      VerletParticle p=(VerletParticle)i.next();
      particles[index++].addPosition(p.x, p.y, p.z);
    }
    
    canvas.beginDraw();
    canvas.background(0);
    canvas.lights();
  
    canvas.pushMatrix();
    
    zoom = 400 + average[0]*200;
    
    // ------ set view ------
    canvas.translate(width/2, height/2, zoom); 
    canvas.rotateY(radians(average[1])+frameCount*.005); 
    canvas.rotateZ(radians(average[2])+frameCount*.002); 
    
    // ------ draw image pensée ------
    
    penseeA.fillColor = color(average[1]*255, average[1]*255, average[1]*255);
    penseeB.fillColor = color(100 + average[0]*100, 100 + average[0]*100, 0);
    
    penseeA.draw(canvas);
    penseeB.draw(canvas);
    penseeC.draw(canvas);
  
    canvas.popMatrix();
    
    canvas.endDraw();
  }
}


// M_1_6_01_TOOL.pde
// Agent.pde, GUI.pde, Ribbon3d.pde, TileSaver.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

class Agent {
  boolean isOutside = false;
  PVector p, beginning;
  float offset, stepSize, angleY, angleZ;
  Ribbon3d ribbon;
  float spaceSize = 250;
  color myColor;
  int positionSteps;

  float[] positionsX = new float[positionSteps];
  float[] positionsY = new float[positionSteps];
  float[] positionsZ = new float[positionSteps];
  color[] colors;
  float r, g, b, a;

  int pathPosition = 0;

  Agent(PVector beginning, color thisColor, int positionSteps, float noiseScale, float noiseStrength) {
    p = new PVector(beginning.x, beginning.y, beginning.z);//new PVector(0, 0, 0);
    this.myColor = thisColor;
    this.beginning = beginning;
    this.positionSteps = positionSteps;

    positionsX = new float[positionSteps];
    positionsY = new float[positionSteps];
    positionsZ = new float[positionSteps];

    offset = 10000;
    stepSize = random(2, 4);
    // how many points has the ribbon
    int ribbonSize = (int)random(1, 2);
    int ribbonAmount = 2;
    switch(ribbonSize) {
    case 2:
      ribbonAmount = 4;
      break;
    case 3:
      ribbonAmount = 6;
      break;
    default:
      break;
    }
    ribbon = new Ribbon3d(p, ribbonAmount);//(int)random(2, 5));

    // precompute positions
    for (int i=0;i<positionSteps;i++) {
      PVector thisP = new PVector(p.x, p.y, p.z);
      if (i>1) {
        thisP.x = positionsX[i-1];
        thisP.y = positionsY[i-1];
        thisP.z = positionsZ[i-1];

        float angleY = noise(thisP.x/noiseScale, thisP.y/noiseScale, thisP.z/noiseScale) * noiseStrength; 
        float angleZ = noise(thisP.x/noiseScale+offset, thisP.y/noiseScale, thisP.z/noiseScale) * noiseStrength;

        thisP.x += cos(angleZ) * cos(angleY) * stepSize;
        thisP.y += sin(angleZ) * stepSize;
        thisP.z += cos(angleZ) * sin(angleY) * stepSize;

        positionsX[i] = thisP.x;
        positionsY[i] = thisP.y;
        positionsZ[i] = thisP.z;
      } 
      else {
        positionsX[i] = p.x;
        positionsY[i] = p.y;
        positionsZ[i] = p.z;
        p.x += 1;
      }
      // stepSize += .025;
    }

    // update(0);

    // set colors array
    colors = new color[getVertexCount()];
    for (int i=0;i<getVertexCount();i++) {
      colors[i] = myColor;
    }

    r = red(myColor)/255.0;
    g = green(myColor)/255.0;
    b = blue(myColor)/255.0;
    a = alpha(myColor)/255.0;
  }

  void update(int pathPosition) {
    // TODO: error handling / constrain to available positions

    // set curr position
    p.x = positionsX[pathPosition];
    p.y = positionsY[pathPosition];
    p.z = positionsZ[pathPosition];

    // boundingsphere wrap
    if (p.x*p.x+p.y*p.y+p.z*p.z > spaceSize*spaceSize) { 
      isOutside = true;
    }

    // create ribbons
    ribbon.update(p, isOutside);
    isOutside = false;
  }

  void draw() {
    // ribbon.drawLineRibbon(myColor, 1.0);
    // ribbon.drawMeshRibbon(myColor,1.0);
  }

  /**
   * return an array of vertices (TODO: maybe a toxic mesh to compute normals...)
   */
  PVector[] getVertices() {
    return ribbon.getVertices();
  }

  color[] getColors() {
    return colors;
  }

  int getVertexCount() {
    return ribbon.getVertexCount();
  }

  boolean[] getGaps() {
    return ribbon.getGaps();
  }
}



class Drole {
  PVector p;
  float sphereSize;
  int id;
  int stepsAmount = 40;
  PVector[] oldPositions;
  PVector xyzPos = new PVector();
  Drole(PVector p, float sphereSize, int id) {
    this.p = p;
    this.sphereSize = sphereSize;
    this.id = id;

    oldPositions = new PVector[stepsAmount];
    for (int i=0;i<stepsAmount;i++) {
      oldPositions[i] = new PVector();
    }
  }

  void update() {

    // wandering
    p.x += noise(p.x*100.01)*.02;//cos(i+frameCount*.005)*.001;//noise(particles[i].x*10.1)*(noise(frameCount*.1 + i)*.01);
    p.y += noise(p.y*10.01)*.01;//cos(i+frameCount*.01)*.001;//cos(noise(particles[i].y*10.1))*(noise(frameCount*.1 + i)*.01);

    if (p.y<-1||p.y>1)
    {
      p.y*=-1;
    }

    // new xyz position
    xyzPos.x = sin(p.x)*sqrt(1 - (p.y*p.y))*sphereSize;
    xyzPos.y = cos(p.x)*sqrt(1 - (p.y*p.y))*sphereSize; 
    xyzPos.z = p.y*sphereSize;

    oldPositions[0].x = xyzPos.x;
    oldPositions[0].y = xyzPos.y;
    oldPositions[0].z = xyzPos.z;

    // save old positions
    for (int i=stepsAmount-1;i>0;i--) {
      oldPositions[i].x = oldPositions[i-1].x;
      oldPositions[i].y = oldPositions[i-1].y;
      oldPositions[i].z = oldPositions[i-1].z;
    }
  }
  
  void addPosition(float x, float y, float z) {
    xyzPos.x = x;
    xyzPos.y = y;
    xyzPos.z = z;
    
    oldPositions[0].x = xyzPos.x;
    oldPositions[0].y = xyzPos.y;
    oldPositions[0].z = xyzPos.z;

    // save old positions
    for (int i=stepsAmount-1;i>0;i--) {
      oldPositions[i].x = oldPositions[i-1].x;
      oldPositions[i].y = oldPositions[i-1].y;
      oldPositions[i].z = oldPositions[i-1].z;
    }
  }
}



/**
 * loads an image and converts every pixel into an agent, wich wanders on a noise field trough the space
 *
 * @Author Christopher Warnow, hello@christopherwarnow.com
 *
 */
class Pensee {
  // ------ agents ------
  Agent[] agents;
  int agentsCount;

  float noiseScale = 150, noiseStrength = 20; 
  int vertexCount = 0;

  PImage content;
  // GLModel imageModel, imageQuadModel;
  PShape imageQuadModel;
  // GLSLShader imageShader; // should pe provided by mother class?

  // animation values
  int currPosition = 0;
  int positionSteps = 100;
  int animationDirection = -1;
  int oldEasedIndex = 0;
  float easedPosition = 0;

  color fillColor = color(255, 255, 255);

  Pensee(String imagePath) {
    noiseSeed((long)random(1000));
    // load image
    content = loadImage(imagePath);

    // init agents pased on images pixels
    agentsCount = content.width*content.height;
    agents = new Agent[agentsCount];

    int i=0;
    for (int x=0;x<content.width;x++) {
      for (int y=0;y<content.height;y++) {
        agents[i++]=new Agent(new PVector(x-content.width/2, y-content.height/2, 0), content.get(x, y), positionSteps, noiseScale, noiseStrength);
        vertexCount += agents[i-1].getVertexCount();
      }
    }
/*
    // extract agents vertices
    PVector[] vertices = new PVector[vertexCount];
    int vertexIndex = 0;
    for (Agent agent:agents) {
      for (PVector p:agent.getVertices()) {
        vertices[vertexIndex++] = new PVector(p.x, p.y, p.z);
      }
    }
    */
    
    // create a model that uses quads
    /*
    imageQuadModel = new GLModel(parent, vertexCount*4, QUADS, GLModel.DYNAMIC);
    imageQuadModel.initColors();
    imageQuadModel.initNormals();
    */
    imageQuadModel = createShape();
    
    // load shader
    // imageShader = new GLSLShader(parent, "imageVert.glsl", "imageFrag.glsl");
  }

  void update() {
    // update playhead on precomputed noise path
    if (currPosition == positionSteps-1) {
      animationDirection *= -1;
    }
    if (currPosition == 0) {
      // if (frameCount%200==0) {
        animationDirection *= -1;
        currPosition += animationDirection;
      // }
    }
    else {
      currPosition += animationDirection;
    }

    // eased value out of currStep/positionSteps
    easedPosition = Cubic.easeInOut (currPosition, 0, positionSteps-1, positionSteps);
    
  }

  void draw(PGraphics canvas) {//GLGraphics renderer) {
    // renderer.lights();
    // update glmodel
    
    // extract agents vertices

    //if(frameCount%100==0) {
    float[] floatQuadVertices = new float[vertexCount*16];
    float[] floatQuadNormals = new float[vertexCount*16];
    float[] floatQuadColors = new float[vertexCount*16];
    int quadVertexIndex = 0;
    int quadNormalIndex = 0;
    int quadColorIndex = 0;
    int allIndex = 0;
    int easedIndex = (int)easedPosition;
    float quadHeight = 5.0 + cos(frameCount*.01)*5;
    boolean isUpdate = false;
    if(oldEasedIndex != easedIndex) isUpdate = true;
    oldEasedIndex = easedIndex;
    
    imageQuadModel = createShape();
    imageQuadModel.setFill(fillColor);
    imageQuadModel.beginShape(QUADS);
    imageQuadModel.noStroke();
    
    // for (Agent agent:agents) {
    for(int i=0;i<agentsCount;i++) {
      Agent agent = agents[i];
      // set agents position
      // TODO: improve updating performance
      if(isUpdate) agent.update(easedIndex);
      
      boolean[] gaps = agent.getGaps();
      int gapIndex = 0;
      
      // create quads from ribbons
      PVector[] agentsVertices = agent.getVertices();
      int agentVertexNum = agentsVertices.length;
      
      for(int j=0;j<agentVertexNum-1;j++) {
        PVector thisP = agentsVertices[j];
        PVector nextP = agentsVertices[j+1];
        PVector thirdP = agentsVertices[j+1];
        /*
        // TODO: create quad from above vertices and save in glmodel, then add colors
        floatQuadVertices[quadVertexIndex++] = thisP.x;
        floatQuadVertices[quadVertexIndex++] = thisP.y;
        floatQuadVertices[quadVertexIndex++] = thisP.z;
        floatQuadVertices[quadVertexIndex++] = 1.0;
        
        floatQuadVertices[quadVertexIndex++] = thisP.x;
        floatQuadVertices[quadVertexIndex++] = thisP.y + quadHeight;
        floatQuadVertices[quadVertexIndex++] = thisP.z;
        floatQuadVertices[quadVertexIndex++] = 1.0;
        
        floatQuadVertices[quadVertexIndex++] = nextP.x;
        floatQuadVertices[quadVertexIndex++] = nextP.y + quadHeight;
        floatQuadVertices[quadVertexIndex++] = nextP.z;
        floatQuadVertices[quadVertexIndex++] = 1.0;
        
        floatQuadVertices[quadVertexIndex++] = nextP.x;
        floatQuadVertices[quadVertexIndex++] = nextP.y;
        floatQuadVertices[quadVertexIndex++] = nextP.z;
        floatQuadVertices[quadVertexIndex++] = 1.0;
        */
        imageQuadModel.vertex(thisP.x, thisP.y, thisP.z);
        imageQuadModel.vertex(thisP.x, thisP.y + quadHeight, thisP.z);
        imageQuadModel.vertex(nextP.x, nextP.y + quadHeight, nextP.z);
        imageQuadModel.vertex(nextP.x, nextP.y, nextP.z);
        
        // compute face normal
        PVector v1 = new PVector(thisP.x - nextP.x, thisP.y - nextP.y, thisP.z - nextP.z);
        PVector v2 = new PVector(nextP.x - thisP.x, (nextP.y+quadHeight) - thisP.y, nextP.z - thisP.z);
        PVector v3 = v1.cross(v2);
        v3.normalize();
        
        float nX = v3.x;
        float nY = v3.y;
        float nZ = v3.z;
        /*
        floatQuadNormals[quadNormalIndex++] = nX;
        floatQuadNormals[quadNormalIndex++] = nY;
        floatQuadNormals[quadNormalIndex++] = nZ;
        floatQuadNormals[quadNormalIndex++] = 1.0;
        
        floatQuadNormals[quadNormalIndex++] = nX;
        floatQuadNormals[quadNormalIndex++] = nY;
        floatQuadNormals[quadNormalIndex++] = nZ;
        floatQuadNormals[quadNormalIndex++] = 1.0;
        
        floatQuadNormals[quadNormalIndex++] = nX;
        floatQuadNormals[quadNormalIndex++] = nY;
        floatQuadNormals[quadNormalIndex++] = nZ;
        floatQuadNormals[quadNormalIndex++] = 1.0;
        
        floatQuadNormals[quadNormalIndex++] = nX;
        floatQuadNormals[quadNormalIndex++] = nY;
        floatQuadNormals[quadNormalIndex++] = nZ;
        floatQuadNormals[quadNormalIndex++] = 1.0;
        */
        imageQuadModel.normal(nX, nY, nZ);
        imageQuadModel.normal(nX, nY, nZ);
        imageQuadModel.normal(nX, nY, nZ);
        imageQuadModel.normal(nX, nY, nZ);
        /*
        // add colors
        float theAlpha = agent.a * ((!gaps[gapIndex++]) ? 1.0 : 0.0);
        
        floatQuadColors[quadColorIndex++] = agent.r;
        floatQuadColors[quadColorIndex++] = agent.g;
        floatQuadColors[quadColorIndex++] = agent.b;
        floatQuadColors[quadColorIndex++] = theAlpha;
        
        floatQuadColors[quadColorIndex++] = agent.r;
        floatQuadColors[quadColorIndex++] = agent.g;
        floatQuadColors[quadColorIndex++] = agent.b;
        floatQuadColors[quadColorIndex++] = theAlpha;
        
        floatQuadColors[quadColorIndex++] = agent.r;
        floatQuadColors[quadColorIndex++] = agent.g;
        floatQuadColors[quadColorIndex++] = agent.b;
        floatQuadColors[quadColorIndex++] = theAlpha;
        
        floatQuadColors[quadColorIndex++] = agent.r;
        floatQuadColors[quadColorIndex++] = agent.g;
        floatQuadColors[quadColorIndex++] = agent.b;
        floatQuadColors[quadColorIndex++] = theAlpha;
       */
        // imageQuadModel.setFill(color(255, 255, 255));
 
              
      }
      
    }
    
    imageQuadModel.endShape();
    canvas.shape(imageQuadModel);
    
  }
}



// M_1_6_01_TOOL.pde
// Agent.pde, GUI.pde, Ribbon3d.pde, TileSaver.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

class Ribbon3d {
  int count; // how many points has the ribbon
  PVector[] p;
  boolean[] isGap;

  Ribbon3d (PVector theP, int theCount) {
    count = theCount; 
    p = new PVector[count];
    isGap = new boolean[count];
    for(int i=0; i<count; i++) {
      p[i] = new PVector(theP.x,theP.y,theP.z);
      isGap[i] = false;
    }
  }

  void update(PVector theP, boolean theIsGap){
    // shift the values to the right side
    // simple queue
    for(int i=count-1; i>0; i--) {
      p[i].set(p[i-1]);
      isGap[i] = isGap[i-1];
    }
    p[0].set(theP);
    isGap[0] = theIsGap;
  }
/*
  void drawMeshRibbon(color theMeshCol, float theWidth) {
    // draw the ribbons with meshes
    fill(theMeshCol);
    noStroke();

    beginShape(QUAD_STRIP);
    for(int i=0; i<count-1; i++) {
      // if the point was wraped -> finish the mesh an start a new one
      if (isGap[i] == true) {
        vertex(p[i].x, p[i].y, p[i].z);
        vertex(p[i].x, p[i].y, p[i].z);
        endShape();
        beginShape(QUAD_STRIP);
      } 
      else {        
        PVector v1 = PVector.sub(p[i],p[i+1]);
        PVector v2 = PVector.add(p[i+1],p[i]);
        PVector v3 = v1.cross(v2);      
        v2 = v1.cross(v3);
        //v1.normalize();
        v2.normalize();
        //v3.normalize();
        //v1.mult(theWidth);
        v2.mult(theWidth);
        //v3.mult(theWidth);
        vertex(p[i].x+v2.x,p[i].y+v2.y,p[i].z+v2.z);
        vertex(p[i].x-v2.x,p[i].y-v2.y,p[i].z-v2.z);


      }

    }
    endShape();
  }


  void drawLineRibbon(color theStrokeCol, float theWidth) {
    // draw the ribbons with lines
    noFill();
    strokeWeight(theWidth);
    stroke(theStrokeCol);
    beginShape();
    for(int i=0; i<count; i++) {
      vertex(p[i].x, p[i].y, p[i].z);
      // if the point was wraped -> finish the line an start a new one
      if (isGap[i] == true) {
        endShape();
        beginShape();
      } 
    }
    endShape();
  }
  */
  int getVertexCount() {
    return count;
  }
  
  // TODO: incorporate gaps
  PVector[] getVertices() {
    return p;
  }
  
  boolean[] getGaps() {
    return isGap;
  }
}
