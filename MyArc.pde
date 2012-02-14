public void arc(float x,float y,float degS,float degE,float rad,float w) {
  int start=(int)min (degS/SINCOS_PRECISION,SINCOS_LENGTH-1);
  int end=(int)min (degE/SINCOS_PRECISION,SINCOS_LENGTH-1);
  beginShape(QUAD_STRIP);
  for(int i=start; i<end; i++) {
    vertex(cosLUT[i]*(rad)+x,sinLUT[i]*(rad)+y);
    vertex(cosLUT[i]*(rad+w)+x,sinLUT[i]*(rad+w)+y);
  }
  endShape();
}

void myArc(float x,float y,float degS,float degE,float rad,float w, float step) {
  beginShape(QUAD_STRIP);
  noStroke();
  for (float i = degS; i < degE; i=i+step) {
    vertex(rad*cos(radians(i))+x,rad*sin(radians(i))+y);
    vertex((rad+w)*cos(radians(i))+x,(rad+w)*sin(radians(i))+y);
  }
  endShape();
}
