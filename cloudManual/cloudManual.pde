OPC opc;
int n = 0;
int[] ids = {
  0, 2, 3, 4, 5, 6, 7
};
int currLED = 0;
int currShape = 0;
int LEDCOUNT = 15;
int SHAPECOUNT = 7;

int startTime;
IntList beatTimes;
int delay = 0;
int nextEvent = 0;

void setup() {
  size(600, 300);
  colorMode(HSB);
  background(0);
  noSmooth();

  // Connect to the local instance of fcserver
  opc = new OPC(this, "192.168.2.52", 7890);
  opc.showLocations(false);

  for (int i=0; i<SHAPECOUNT; i++) {
    opc.ledStrip(64*ids[i], LEDCOUNT, 100, 100+i, 1, 0, false);
  }
  tempoInit();
}
void tempoInit() {
  startTime = -1;
  beatTimes = new IntList();
}
void draw() {
  noStroke();
  fill(0, 10);
  rect(0, 0, width, height);

  if (millis() > nextEvent && delay > 50) {
    for (int i=0; i<5; i++) {
      currLED = (int)random(LEDCOUNT);
      currShape = (int)random(SHAPECOUNT);
      set(100 + currLED, 100+currShape, color(map(currLED, 0, LEDCOUNT, 0, 255), 255, 255));
    }
    nextEvent += delay;
  }
}
void keyPressed() {
  if (key == ' ') {
    int currTime = millis();

    if (beatTimes.size() >= 2) {
      if (beatTimes.get(beatTimes.size()-1) - beatTimes.get(beatTimes.size()-2) > 2000) {
        tempoInit();
      }
    }

    if (startTime == -1)
      startTime = currTime;

    int x = beatTimes.size();
    int y = currTime - startTime;

    beatTimes.append(y);
    int beatCount = beatTimes.size();

    if (beatCount >= 2) {
      delay = y / x;
      nextEvent = currTime + delay;
    }
  }
  if (key == ENTER) {
    startTime = millis();
    nextEvent = startTime + delay;
  }
}

