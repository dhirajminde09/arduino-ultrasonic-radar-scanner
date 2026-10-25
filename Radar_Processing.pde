import processing.serial.*;

import processing.serial.*;

Serial myPort;

String angle = "";
String distance = "";
String data = "";
String noObject;

float pixsDistance;
int iAngle, iDistance;
int index1 = 0;

PFont orcFont;

void setup() {

  size(1200, 700);
  smooth();

  myPort = new Serial(this, "COM3", 9600);
  myPort.bufferUntil('.');

  orcFont = createFont("Arial", 32);
}

void draw() {

  fill(0, 15);
  noStroke();
  rect(0, 0, width, height);

  fill(98, 245, 31);

  drawRadar();
  drawLine();
  drawObject();
  drawText();
}

void serialEvent(Serial myPort) {

  data = myPort.readStringUntil('.');

  if (data != null) {

    data = trim(data);

    index1 = data.indexOf(",");

    angle = data.substring(0, index1);
    distance = data.substring(index1 + 1);

    iAngle = int(angle);
    iDistance = int(distance);
  }
}

void drawRadar() {

  pushMatrix();

  translate(width / 2, height - height * 0.074);

  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);

  arc(0, 0, width * 0.9, width * 0.9, PI, TWO_PI);
  arc(0, 0, width * 0.7, width * 0.7, PI, TWO_PI);
  arc(0, 0, width * 0.5, width * 0.5, PI, TWO_PI);
  arc(0, 0, width * 0.3, width * 0.3, PI, TWO_PI);

  line(-width / 2, 0, width / 2, 0);

  for (int i = 0; i <= 180; i += 30) {

    line(
      0,
      0,
      (-width / 2) * cos(radians(i)),
      (-width / 2) * sin(radians(i))
    );
  }

  popMatrix();
}

void drawObject() {

  pushMatrix();

  translate(width / 2, height - height * 0.074);

  strokeWeight(9);
  stroke(255, 10, 10);

  pixsDistance = iDistance * 10;

  if (iDistance < 40) {

    line(
      pixsDistance * cos(radians(iAngle)),
      -pixsDistance * sin(radians(iAngle)),
      (width / 2) * cos(radians(iAngle)),
      -(width / 2) * sin(radians(iAngle))
    );
  }

  popMatrix();
}

void drawLine() {

  pushMatrix();

  strokeWeight(9);
  stroke(30, 250, 60);

  translate(width / 2, height - height * 0.074);

  line(
    0,
    0,
    (width / 2) * cos(radians(iAngle)),
    -(width / 2) * sin(radians(iAngle))
  );

  popMatrix();
}

void drawText() {

  pushMatrix();

  if (iDistance > 40) {
    noObject = "Out of Range";
  } else {
    noObject = "In Range";
  }

  fill(0);
  noStroke();
  rect(0, height - height * 0.08, width, height);

  fill(98, 245, 31);

  textSize(25);

  text("10cm", width - width * 0.3854, height - height * 0.0833);
  text("20cm", width - width * 0.281, height - height * 0.0833);
  text("30cm", width - width * 0.177, height - height * 0.0833);
  text("40cm", width - width * 0.0729, height - height * 0.0833);

  textSize(40);

  text("RADAR SYSTEM", width - width * 0.875, height - height * 0.0277);

  text(
    "Angle: " + iAngle + "°",
    width - width * 0.48,
    height - height * 0.0277
  );

  text(
    "Distance: ",
    width - width * 0.26,
    height - height * 0.0277
  );

  if (iDistance < 40) {

    text(
      iDistance + " cm",
      width - width * 0.18,
      height - height * 0.0277
    );
  }

  text(
    noObject,
    width - width * 0.9,
    height - height * 0.0277
  );

  textSize(25);

  translate(
    (width - width * 0.4994) + width / 2 * cos(radians(30)),
    (height - height * 0.0907) - width / 2 * sin(radians(30))
  );

  rotate(radians(-60));
  text("30°", 0, 0);

  resetMatrix();

  translate(
    (width - width * 0.503) + width / 2 * cos(radians(60)),
    (height - height * 0.0888) - width / 2 * sin(radians(60))
  );

  rotate(radians(-30));
  text("60°", 0, 0);

  resetMatrix();

  translate(
    (width - width * 0.507) + width / 2 * cos(radians(90)),
    (height - height * 0.0833) - width / 2 * sin(radians(90))
  );

  rotate(radians(0));
  text("90°", 0, 0);

  resetMatrix();

  translate(
    (width - width * 0.513) + width / 2 * cos(radians(120)),
    (height - height * 0.07129) - width / 2 * sin(radians(120))
  );

  rotate(radians(-30));
  text("120°", 0, 0);

  resetMatrix();

  translate(
    (width - width * 0.5104) + width / 2 * cos(radians(150)),
    (height - height * 0.0574) - width / 2 * sin(radians(150))
  );

  rotate(radians(-60));
  text("150°", 0, 0);

  popMatrix();
}
