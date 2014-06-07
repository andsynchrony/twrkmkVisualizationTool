import beads.*;

class AudioHandler
{
  AudioContext ac;

  boolean debug = false;

  float[] volume, average; 
  int buffer; 
  int portAudio;

  AudioHandler(int numPorts, boolean debug)
  {
    this.debug = debug;
    setup(numPorts);
  }

  AudioHandler(int numPorts)
  {
    setup(numPorts);
  }

  void setup(int numPorts)
  {
    portAudio = numPorts;
    volume = new float[portAudio];
    average = new float[portAudio];
    for (int p = 0; p < portAudio; p++)
    {
      volume[p] = 0;
    }
    for (int p = 0; p < portAudio; p++)
    {
      average[p] = 0;
    }
    if (!debug)
    {
      println("starting audio...");
      try
      {
        ac = new AudioContext(AudioContext.defaultAudioFormat(portAudio)); 
        ac.out.setGain(100); 
        UGen inputs = ac.getAudioInput(new int[] {
          0, 1, 2, 3, 4, 5, 6, 7
        }
        ); 
        ac.out.addInput(inputs); 
        ac.start();
        println(ac.getBufferSize());
        buffer = 6;
        println("Number of INs : "+ ac.getAudioInput().getOuts());
        println("Number of OUTs : "+ ac.out.getIns());
        println("success!");
      }
      catch (Throwable e)
      {
        println(e);
        debug = true;
      }
    }
  }

  void update()
  {
    if (!debug)
    {
      try
      {
        for (int p = 0; p < portAudio; p++)
        {
          volume[p] = 0;
        }
        for (int p = 0; p < portAudio; p++)
        {
          for (int i = 0; i < ac.getBufferSize(); i++)
          {
            volume[p] += abs(ac.out.getValue(p, i));
          }
        }
        for (int p = 0; p < portAudio; p++)
        {
          average[p] = ((average[p] * buffer) + volume[p])/(buffer + 1);
        }
      }
      catch(Throwable e)
      {
        println("AudioHandler broken: " + e);
        debug = true;
      }
    }
    else
    {
          for (int p = 0; p < portAudio; p++)
        {
          volume[p] = noise(p, frameCount*0.02) * 100;
        }
        for (int p = 0; p < portAudio; p++)
        {
          average[p] = ((average[p] * buffer) + volume[p])/(buffer + 1);
        }
    }
  }

  float[] getVolume()
  {
    return volume;
  }

  float[] getAverage()
  {
    return average;
  }
}

