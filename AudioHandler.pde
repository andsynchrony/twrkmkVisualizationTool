import beads.*;

class AudioHandler
{
  AudioContext ac;

  boolean debug = false;

  float[] volume, average; 
  int buffer; 
  int portAudio;

  float[] maxima, normalized, smoothed;


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
    maxima = new float[portAudio];
    volume = new float[portAudio];
    average = new float[portAudio];
    normalized = new float[portAudio];
    smoothed = new float[portAudio];


    for (int p = 0; p < portAudio; p++)
    {
      volume[p] = 0;
      average[p] = 0;
      maxima[p] = 100;
      smoothed[p] = 0;
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
          for (int i = 0; i < ac.getBufferSize (); i++)
          {
            volume[p] += abs(ac.out.getValue(p, i));
          }
        }
      }
      catch(Throwable e)
      {
        println("AudioHandler broken: " + e);
        debug = true;
      }
    } else
    {
      for (int p = 0; p < portAudio; p++)
      {
        volume[p] = noise(p, frameCount*0.02 * p) * 100;
      }
    }

    for (int p = 0; p < portAudio; p++)
    {
      average[p] = ((average[p] * buffer) + volume[p])/(buffer + 1);
    }
    for (int i = 0; i < maxima.length; i++)
    {
      if (volume[i] != 0)
        maxima[i] += (volume[i] - maxima[i])*0.05;
      normalized[i] = constrain(map(volume[i], 0, maxima[i], 0.0, 1.0), 0.0, 1.0);
    }

    for (int i = 0; i < smoothed.length; i++)
    {
      smoothed[i] += (normalized[i] - smoothed[i])*0.1;
    }
  }

  void drawInput()
  {
    fill(255);
    noStroke();
    float[] n = getSmoothed();
    for (int i = 0; i < portAudio; i++)
    {
      text(i + " " + nfc(n[i], 2), 30, 14 + i * 35);
      stroke(0);
      noFill();
      rect(30, 22 + i*35, 100, 15);
      noStroke();
      fill(255);
      rect(30, 22 + i*35, 100 * n[i], 15);
    }
  }
  
  // volume values, as received by Beads library
  float[] getVolume()
  {
    return volume;
  }
  
  // average volume, unnormalized, unsmoothed
  float[] getAverage()
  {
    return average;
  }
  
  // normalized volume, unsmoothed
  float[] getNormalized()
  {
    return normalized;
  }
  
  // smoothed, normalized volume
  float[] getSmoothed()
  {
    return smoothed;
  }
}

