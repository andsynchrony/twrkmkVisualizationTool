void circles(float[] average) {
  canvas.beginDraw();
canvas.background(40);
  // draw ellipse channel 1
  canvas.stroke(0, 255, 255);
  canvas.fill(0, 255, 255);
  canvas.ellipse(width/8, height/3, average[0], average[0]);
  // draw ellipse channel 2
  canvas.stroke(255, 0, 255);
  canvas.fill(0, 0);
  canvas.ellipse(width/8*3, height/3, average[1], average[1]);
  // draw ellipse channel 3
  canvas.stroke(255, 255, 0);
  canvas.fill(0, 0);  
  canvas.ellipse(width/8*5, height/3, average[2], average[2]);
  // draw ellipse channel 4
  canvas.stroke(255, 255, 255);
  canvas.fill(0, 0);
  canvas.ellipse(width/8*7, height/3, average[3], average[3]);
  // draw ellipse channel 5
  canvas.stroke(0, 255, 255);
  canvas.fill(0, 0);
  canvas.ellipse(width/8, height/3*2, average[4], average[4]);
  // draw ellipse channel 6
  canvas.stroke(255, 0, 255);
  canvas.fill(0, 0);
  canvas.ellipse(width/8*3, height/3*2, average[5], average[5]);
  // draw ellipse channel 7
  canvas.stroke(255, 255, 0);
  canvas.fill(0, 0);
  canvas.ellipse(width/8*5, height/3*2, average[6], average[6]);
  // draw ellipse channel 8
  canvas.stroke(255, 255, 255);
  canvas.fill(0, 0);
  canvas.ellipse(width/8*7, height/3*2, average[7], average[7]);
  canvas.endDraw();

}


/*void circles2() {

  // draw ellipse channel 1
  stroke(0, 255, 255);
  fill(0, 255, 255);
  ellipse(width/8, height/3, average[0], average[0]);
  // draw ellipse channel 2
  stroke(255, 0, 255);
  fill(255, 0, 255);
  ellipse(width/8*3, height/3, average[1], average[1]);
  // draw ellipse channel 3
  stroke(255, 255, 0);
  fill(255, 255, 0);  
  ellipse(width/8*5, height/3, average[2], average[2]);
  // draw ellipse channel 4
  stroke(255, 255, 255);
  fill(255, 255, 255);
  ellipse(width/8*7, height/3, average[3], average[3]);
  // draw ellipse channel 5
  stroke(0, 255, 255);
  fill(0, 255, 255);
  ellipse(width/8, height/3*2, average[4], average[4]);
  // draw ellipse channel 6
  stroke(255, 0, 255);
  fill(255, 0, 255);
  ellipse(width/8*3, height/3*2, average[5], average[5]);
  // draw ellipse channel 7
  stroke(255, 255, 0);
  fill(255, 255, 0);
  ellipse(width/8*5, height/3*2, average[6], average[6]);
  // draw ellipse channel 8
  stroke(255, 255, 255);
  fill(255, 255, 255);
  ellipse(width/8*7, height/3*2, average[7], average[7]);
}*/
