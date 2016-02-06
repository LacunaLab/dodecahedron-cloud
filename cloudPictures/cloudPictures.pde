// Some real-time FFT! This visualizes music in the frequency domain using a
// polar-coordinate particle system. Particle size and radial distance are modulated
// using a filtered FFT. Color is sampled from an image.

import ddf.minim.analysis.*;
import ddf.minim.*;

OPC opc;
PImage dot;
PImage colors;
Minim minim;
AudioInput in;
FFT fft;
float[] fftFilter;

float spin = 0.001;
float radiansPerBucket = radians(2);
float decay = 0.95;
float opacity = 50;
float minSize = 0.1;
float sizeScale = 0.2;

File f;
File[] fs;

void setup()
{
  size(600, 300, P3D);
  background(0);
//  frameRate(30);

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn();

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  dot = loadImage("dot.png");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "192.168.2.52", 7890);
  opc.showLocations(false);

  opc.ledStrip(64*0, 15, width/2 + (width / 12)*4, height/2, width / 70.0, HALF_PI, false);
  opc.ledStrip(64*1, 15, width/2 + (width / 12)*3, height/2, width / 70.0, HALF_PI, false);
  opc.ledStrip(64*2, 15, width/2 + (width / 12)*2, height/2, width / 70.0, HALF_PI, false);
  opc.ledStrip(64*3, 15, width/2 + (width / 12)*1, height/2, width / 70.0, HALF_PI, false);
  opc.ledStrip(64*4, 15, width/2 - (width / 12)*1, height/2, width / 70.0, HALF_PI, false);
  opc.ledStrip(64*5, 15, width/2 - (width / 12)*2, height/2, width / 70.0, HALF_PI, false);
  opc.ledStrip(64*6, 15, width/2 - (width / 12)*3, height/2, width / 70.0, HALF_PI, false);
  opc.ledStrip(64*7, 15, width/2 - (width / 12)*4, height/2, width / 70.0, HALF_PI, false);

  f = new File("/home/funpro/Pictures - Nexus One/Instagram");
  fs = f.listFiles();
  loadRandomImg();
}
void loadRandomImg() {
  int id = (int)random(fs.length);  
  colors = loadImage(fs[id].getAbsolutePath());
}

void draw() {
  if (frameCount % 60*30 == 900) {
    loadRandomImg();
  }

  blendMode(SUBTRACT);
  noStroke();
  fill(10);
  rect(0, 0, width, height);  
 
  fft.forward(in.mix);
  for (int i = 0; i < fftFilter.length; i++) {
    fftFilter[i] = max(fftFilter[i] * decay, log(1 + fft.getBand(i)));
  }
  blendMode(BLEND);
  for (int i = 0; i < fftFilter.length; i += 3) {   
    color rgb = colors.get(
      int(map(i, 0, fftFilter.length-1, 0, colors.width-1)), 
      (colors.height/2+frameCount)%colors.height);

    fill(rgb, 40);
    
    float sz = random(2, 12);
    ellipse(map(i, 0, fftFilter.length-1, width*0.2, width*0.8)+random(-20, 20), 
    height/5 + fftFilter[i] * 100 + random(-10, 10), sz, sz);
  }
}
