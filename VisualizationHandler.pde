public interface Visualization
{
  public void setup();
  public void setup(int num, float size_x, float size_y);
  public void setup(PApplet parent);
  public void draw(PGraphics canvas, float[] average);
}

void switchVisualization(int id)
{
  visualizationID = constrain(id, 0, visualization.length-1);
  println("Switched to visualization # " + visualizationID);
}

