class AudioManager  {   
  
  public int bufferSize;
  public int steps;
  public float limitDiff;
  public int numAverages=32;
  public float damp = 0.15f;
  public float maxLimit,minLimit;
  public FFT audioFFT;
  public AudioInput audioInput;
 

  //constructor
  AudioManager() {
    //SETUP AUDIO ESS
    Ess.start(app);
    // set up our AudioInput
    bufferSize=512;
    audioInput=new AudioInput(bufferSize);
    
    // set up our FFT
    audioFFT=new FFT(bufferSize*2);
    audioFFT.equalizer(true);
  
    // set up our FFT normalization/dampening
    minLimit=.005;
    maxLimit=.05;
    audioFFT.limits(minLimit,maxLimit);
    audioFFT.damp(damp);
    audioFFT.averages(numAverages);
  
    // get the number of bins per average 
    steps=bufferSize/numAverages;
  
    // get the distance of travel between minimum and maximum limits
    limitDiff=maxLimit-minLimit;       
    
    audioInput.start();
  }   
 
  public void setDamp(float theDamp){
    audioFFT.damp(theDamp);
  }
  
  //called from the main app singleton
  public void audioInputData(AudioInput theInput) {
    audioFFT.getSpectrum(audioInput);
  }
  
} 
