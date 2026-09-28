import processing.serial.*;

Serial monPort;
String data = "";
float angle, distance;
float pixsDistance;
String iAngle = "";
String iDistance = "";

float[] distHistory = new float[181];

void setup() {
  size(1300, 750);
  smooth();

  for (int i = 0; i <= 180; i++) {
    distHistory[i] = 500.0;
  }

  printArray(Serial.list());
  String portName = Serial.list()[5]; // Adapter l'index selon le port USB affiché dans la console
  monPort = new Serial(this, portName, 9600);

  // Lecture jusqu'au point (.) envoyé par l'Arduino
  monPort.bufferUntil('.');
}

void draw() {
  fill(0, 15);
  noStroke();
  rect(0, 0, width, height);

  pushMatrix();
  translate(width/2, height - height*0.08);
  drawRadarGrid();
  drawPersistentObstacles();
  drawDetectionZone();
  popMatrix();

  drawText();
}

// Écoute du port série USB
void serialEvent(Serial monPort) {
  data = monPort.readStringUntil('.');
  if (data != null) {
    data = trim(data);

    // Retrait du point final pour récupérer uniquement les valeurs
    if (data.endsWith(".")) {
      data = data.substring(0, data.length() - 1);
    }

    String[] list = split(data, ',');
    if (list.length >= 2) {
      iAngle = list[0];
      iDistance = list[1];

      angle = float(iAngle);
      distance = float(iDistance);

      int intAngle = constrain(round(angle), 0, 180);
      distHistory[intAngle] = distance;
    }
  }
}

void drawRadarGrid() {
  pushMatrix();
  strokeWeight(2);
  float maxRadius = width - width*0.06;
  float rMax = maxRadius / 2;

  for (int i = 1; i <= 4; i++) {
    float r = maxRadius * (i*0.25);
    noFill();
    stroke(98, 245, 31, 255);
    arc(0, 0, r, r, PI, TWO_PI);

    fill(98, 245, 31);
    noStroke();
    textSize(15);
    textAlign(LEFT, BOTTOM);
    text(i*10 + "cm", (r/2) + 5, -5);
  }

  for (int a = 30; a <= 150; a += 30) {
    float lineLength = rMax * 1.04;
    float x = -lineLength * cos(radians(a));
    float y = -lineLength * sin(radians(a));

    stroke(98, 245, 31, 255);
    line(0, 0, x, y);

    pushMatrix();
    translate(x*1.03, y*1.03);
    rotate(radians(-90 + a));
    fill(98, 245, 31);
    textAlign(CENTER, BOTTOM);
    text(a + "°", 0, 0);
    popMatrix();
  }
  popMatrix();
  textAlign(LEFT, BASELINE);
}

void drawPersistentObstacles() {
  pushMatrix();
  float rMax = (width - width*0.06) / 2;
  float lineLength = rMax * 1.04;
  float scaleFactor = rMax / 40.0;

  stroke(255, 10, 10, 15);
  strokeWeight(4);

  for (int i = 0; i <= 180; i++) {
    float d = distHistory[i];
    if (d < 40 && d > 0) {
      float pDist = d * scaleFactor;
      line(pDist*cos(radians(i)), -pDist*sin(radians(i)),
           lineLength*cos(radians(i)), -lineLength*sin(radians(i)));
    }
  }
  popMatrix();
}

void drawDetectionZone() {
  pushMatrix();
  float rMax = (width - width*0.06) / 2;
  float lineLength = rMax * 1.04;

  pixsDistance = distance * (rMax / 40.0);

  if (distance < 40 && distance > 0) {
    stroke(30, 250, 60);
    strokeWeight(5);
    line(0, 0, pixsDistance*cos(radians(angle)), -pixsDistance*sin(radians(angle)));

    stroke(255, 10, 10, 255);
    strokeWeight(6);
    line(pixsDistance*cos(radians(angle)), -pixsDistance*sin(radians(angle)),
         lineLength*cos(radians(angle)), -lineLength*sin(radians(angle)));
  } else {
    stroke(30, 250, 60);
    strokeWeight(5);
    line(0, 0, lineLength*cos(radians(angle)), -lineLength*sin(radians(angle)));
  }
  popMatrix();
}

void drawText() {
  fill(0);
  noStroke();
  rect(0, height-height*0.08, width, height);

  fill(98, 245, 31);
  textSize(30);
  text("Angle: " + iAngle + " °", width/2 - 65, height-30);
  text("Distance: " + iDistance + " cm", width/2 + 200, height-30);

  textSize(30);
  if (distance < 40 && distance > 0) {
    fill(255, 10, 10);
    text("WARNING : TARGET DETECTED !", 100, height-30);
  } else {
    fill(30, 250, 60);
    text("SCANNING AREA...", 100, height-30);
  }
}
