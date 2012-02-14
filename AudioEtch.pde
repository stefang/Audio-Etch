import krister.Ess.*;
import processing.opengl.*;
import processing.pdf.*;

String audioFilename = "md";
String audioFilenameL = audioFilename+".L";
String audioFilenameR = audioFilename+".R";

int imgSize = 1500;
public static final float sinLUT[];
public static final float cosLUT[];
public static final float SINCOS_PRECISION=1f;
public static final int SINCOS_LENGTH= (int) (360f/SINCOS_PRECISION);
static {
  sinLUT=new float[SINCOS_LENGTH];
  cosLUT=new float[SINCOS_LENGTH];
  for (int i=0; i<SINCOS_LENGTH; i++) {
    sinLUT[i]= (float)Math.sin(i*DEG_TO_RAD*SINCOS_PRECISION);
    cosLUT[i]= (float)Math.cos(i*DEG_TO_RAD*SINCOS_PRECISION);
  }
}


AudioChannel chnL;
AudioChannel chnR;
FFT fftL;
FFT fftR;
FFTOctaveAnalyzer octL;
FFTOctaveAnalyzer octR;
int bufferSize = 1024;
int samplingRate = 44100;

int frameL = 0; 
int frameR = 360; 
int framesPerSecond = 30; 

int samplesPerDegree;
int section;

float[] limits = new float[9];
float[] radii = new float[9];
float[] linethick = new float[9];

float radStep;

void setup() {
  size(imgSize, imgSize, OPENGL);
  noStroke();
  Ess.start(this);
  chnL = new AudioChannel(dataPath(audioFilenameL));
  chnR = new AudioChannel(dataPath(audioFilenameR));
  samplesPerDegree = chnL.size/181;
  fftL = new FFT(bufferSize*2);
  fftR = new FFT(bufferSize*2);
  fftL.limits();
  fftR.limits();
  fftL.damp(.5);
  fftR.damp(.5);
  octL = new FFTOctaveAnalyzer(fftL, samplingRate, 1);
  octR = new FFTOctaveAnalyzer(fftR, samplingRate, 1);
  octL.peakHoldTime = 10; // hold longer
  octL.peakDecayRate = 3; // decay slower
  octL.linearEQIntercept = 0.7; // reduced gain at lowest frequency
  octL.linearEQSlope = 0.02; // increasing gain at higher frequencies
  octR.peakHoldTime = 10; // hold longer
  octR.peakDecayRate = 3; // decay slower
  octR.linearEQIntercept = 0.7; // reduced gain at lowest frequency
  octR.linearEQSlope = 0.02; // increasing gain at higher frequencies
  background(255);
  fill(0);
  noLoop();
}

void draw() { 
  limits[0] = 0.3;
  limits[1] = 0.6;
  limits[2] = 0.5;
  limits[3] = 0.4;
  limits[4] = 0.4;
  limits[5] = 0.4;
  limits[6] = 0.3;
  limits[7] = 0.3;
  limits[8] = 0.3;
  
  float radStart = imgSize/10;
  float radEnd = imgSize*0.9;
  radStep = (radEnd-radStart)/9;
  float radCurrent = radStart;
  
  for (int r = 0; r < 9; r++) {
    radii[r] = radCurrent/2;
    radCurrent = radCurrent+radStep;
    println(radii[r]);
  }

  PGraphicsPDF pdf=(PGraphicsPDF)beginRaw(PDF, "out/pdf_complex_out.pdf"); 
    pdf.strokeJoin(MITER);
    pdf.strokeCap(SQUARE);
    pdf.fill(0);
    pdf.noStroke();
    for (int frm = 0; frm < 181; frm++) {
      analyze(); 
      render(); 
      advance();     
    }
  endRaw();
} 

void analyze() { 
  section = (int)(frameL * samplesPerDegree);
  fftL.getSpectrum(chnL.samples, section);
  fftR.getSpectrum(chnR.samples, section);
  octL.calculate();
  octR.calculate();
} 

void render() {
  for (int i = 0; i < 9; i++) {
    if (octL.averages[i]>limits[i]) myArc(width/2,height/2,frameL,frameL+2,radii[i],radStep/2.5,.5);
    if (octR.averages[i]>limits[i]) myArc(width/2,height/2,frameR,frameR+2,radii[i],radStep/2.5,.5);
  }
}

void advance() { 
    frameL ++;
    frameR --;
} 

public void stop() {
  Ess.stop();
  super.stop();
}
