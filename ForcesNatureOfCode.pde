class Walker {
  
  PVector loc, vel, acc;
  float mass, diameter, velScale;
  float[] rgb = new float[3];
  ArrayList<Force> forces;
  Force netForce;
  
  Walker() {
    loc = new PVector(30, 30);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    mass = 1;
    diameter = mass * 16;
    velScale = 10;
    rgb[0] = random(0, 255);
    rgb[1] = random(0, 255);
    rgb[2] = random(0, 255);
    forces = new ArrayList<Force>();
    forces.add(new Force());
    forces.add(new Force());
    netForce = new Force();
  }
  
  Walker(float m, float x, float y, ArrayList<Force> fs, float vs) {
    loc = new PVector(x, y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    mass = m;
    diameter = mass * 16;
    rgb[0] = random(0, 255);
    rgb[1] = random(0, 255);
    rgb[2] = random(0, 255);
    forces = fs;
    netForce = new Force();
    velScale = vs;
  }
  
  void applyForce(Force f) {
    PVector adjustedForce = PVector.div(f.vec, mass);
    acc.add(adjustedForce);
  }
  
  void applyForces() {
    for (Force f : forces) {
      applyForce(f);
    }
  }
  
  void displayForces() {
    for (Force f : forces) {
      float[] forceColor = new float[3];
      forceColor[0] = 120;
      forceColor[1] = 120;
      forceColor[2] = 120;
      f.displayForce(loc.x, loc.y, forceColor);
    }
  }
  
  void displayNetForce() {
    netForce = new Force();
    for (Force f : forces) {
      Force scaledF = new Force(f.vec.x * f.scale, f.vec.y * f.scale, 1);
      netForce.vec.add(scaledF.vec);
    }
    netForce.scale = 1;
    float[] netForceColor = new float[3];
    netForceColor[0] = 0;
    netForceColor[1] = 0;
    netForceColor[2] = 0;
    netForce.displayForce(loc.x, loc.y, netForceColor);
  }
  
  void update() {
    checkEdges();
    vel.add(acc);
    loc.add(vel);
    acc.mult(0);
  }
  
  void display() {
    noStroke();
    fill(rgb[0], rgb[1], rgb[2], 140);
    ellipse(loc.x, loc.y, diameter, diameter);
  }
  
  void displayAcc() {
    Force accDisp = new Force(netForce.vec.x / mass, netForce.vec.y / mass, 1);
    float[] accColor = new float[3];
    accColor[0] = 255;
    accColor[1] = 0;
    accColor[2] = 0;
    accDisp.displayForce(loc.x, loc.y, accColor);
  }
  
  void displayVel() {
    Force velDisp = new Force(vel.x, vel.y, velScale);
    float[] velColor = new float[3];
    velColor[0] = 0;
    velColor[1] = 0;
    velColor[2] = 255;
    velDisp.displayForce(loc.x, loc.y, velColor);
  }
  
  void checkEdges() {
    if (loc.x + diameter / 2.0 > width) {
      loc.x = width - diameter / 2.0;
      vel.x *= -1;
    } else if (loc.x - diameter / 2.0 < 0) {
      vel.x *= -1;
      loc.x = diameter / 2.0;
    }
    
    if (loc.y + diameter / 2.0 > height) {
      loc.y = height - diameter / 2.0;
      vel.y *= -1;
    } else if (loc.y - diameter / 2.0 < 0) {
      loc.y = diameter / 2.0;
      vel.y *= -1;
    }
  }
}

class Force {
  
  PVector vec;
  float xDirection, yDirection, scale;
  
  Force() {
    vec = new PVector(0, 0);
    xDirection = 1;
    yDirection = 1;
    scale = 150;
  }
  
  Force(float x, float y, float s) {
    vec = new PVector(x, y);
    xDirection = 1;
    yDirection = 1;
    scale = s;
  }
  
  void displayForce(float x, float y, float[] rgb) {
    pushMatrix();
    translate(x, y);
    strokeWeight(2);
    stroke(rgb[0], rgb[1], rgb[2], 140);
    fill(rgb[0], rgb[1], rgb[2], 140);
    line(0, 0, vec.x * scale, vec.y * scale);
    float angle = atan(vec.x / vec.y);
    noStroke();
    if (vec.y > 0 && vec.x > 0 || vec.y > 0 && vec.x < 0) {
      xDirection = 1;
      yDirection = 1;
    } else if (vec.y < 0 && vec.x > 0 || vec.y < 0 && vec.x < 0) {
      xDirection = -1;
      yDirection = -1;
    }
    float x1 = vec.x * scale + 10 * sin(angle) * xDirection;
    float y1 = vec.y * scale + 10 * cos(angle) * yDirection;
    float x2 = vec.x * scale + 5 * cos(angle);
    float y2 = vec.y * scale - 5 * sin(angle);
    float x3 = vec.x * scale - 5 * cos(angle);
    float y3 = vec.y * scale + 5 * sin(angle);
    triangle(x1, y1, x2, y2, x3, y3); 
    popMatrix();
  }
}

Walker[] walkers = new Walker[5];
ArrayList<Force> fs = new ArrayList<Force>();
float x, allScale;

void setup() {
  size(1000, 800);
  background(255);
  allScale = 100;
  float numForces = 4;
  for (int i = 0; i < numForces; i++) {
    fs.add(new Force());
  }
  for (int i = 0; i < walkers.length; i++) {
    walkers[i] = new Walker(i * 5, width/2, height/2, fs, 5);
  }
  x = 0;
}

void draw() {
  background(255);
  for (int i = walkers.length - 1; i >= 0; i--) {
    walkers[i].forces.set(0, new Force(0, 0.1 * walkers[i].mass, allScale));
    walkers[i].forces.set(1, new Force(map(noise(x), 0, 1, -0.01, 0.01), 0, allScale));
    PVector mouse = new PVector(mouseX, mouseY);
    PVector dir = PVector.sub(mouse, walkers[i].loc);
    dir.normalize();
    dir.mult(10.0 / pow(mouse.dist(walkers[i].loc), 1));
    float gX = dir.x;
    float gY = dir.y;
    walkers[i].forces.set(3, new Force(gX, gY, allScale));
    walkers[i].update();
    walkers[i].display();
    walkers[i].applyForces();
    //walkers[i].displayForces();
    walkers[i].displayNetForce();
    walkers[i].displayAcc();
    walkers[i].displayVel();
  }
  x += 0.01;
}
