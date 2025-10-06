public void CGLine(float x1, float y1, float x2, float y2) {
  float dx = abs(x2 - x1);
  float dy = abs(y2 - y1);
  float sx = (x1 < x2) ? 1 : -1;
  float sy = (y1 < y2) ? 1 : -1;

  boolean steep = dy > dx;
  if (steep) { 
    float temp = x1; x1 = y1; y1 = temp;
    temp = x2; x2 = y2; y2 = temp;
    temp = dx; dx = dy; dy = temp;
    temp = sx; sx = sy; sy = temp;
  }

  float d = 2*dy - dx; 
  float y = y1;

  for (float x = x1; x != x2 + sx; x += sx) {
    if (steep) {
      drawPoint(y, x, color(0, 0, 0)); 
    } else {
      drawPoint(x, y, color(0, 0, 0));
    }

    if (d > 0) { // NE
      y += sy;
      d -= 2*dx;
    }
    d += 2*dy; // E
  }
}

public void CGCircle(float xc, float yc, float r) {
  float x = 0;
  float y = r;
  float d = 1 - r;  

  while (x <= y) {
    drawPoint(xc + x, yc + y, color(0, 0, 0));
    drawPoint(xc - x, yc + y, color(0, 0, 0));
    drawPoint(xc + x, yc - y, color(0, 0, 0));
    drawPoint(xc - x, yc - y, color(0, 0, 0));
    drawPoint(xc + y, yc + x, color(0, 0, 0));
    drawPoint(xc - y, yc + x, color(0, 0, 0));
    drawPoint(xc + y, yc - x, color(0, 0, 0));
    drawPoint(xc - y, yc - x, color(0, 0, 0));

    if (d < 0) {
      d += 2 * x + 3;
    } else {
      d += 2 * (x - y) + 5;
      y -= 1;
    }
    x += 1;
  }    
}

public void CGEllipse(float xc, float yc, float r1, float r2) {
  float x = 0;
  float y = r2;
  float d1 = (r2 * r2) - (r1 * r1 * r2) + (0.25f * r1 * r1);
  float dx = 2 * r2 * r2 * x;
  float dy = 2 * r1 * r1 * y;

  while (dx < dy) {
    drawPoint(xc + x, yc + y, color(0, 0, 0));
    drawPoint(xc - x, yc + y, color(0, 0, 0));
    drawPoint(xc + x, yc - y, color(0, 0, 0));
    drawPoint(xc - x, yc - y, color(0, 0, 0));

    if (d1 < 0) { //  E
      x++;
      dx += 2 * r2 * r2;
      d1 += dx + r2 * r2;
    } else { //  SE
      x++;
      y--;
      dx += 2 * r2 * r2;
      dy -= 2 * r1 * r1;
      d1 += dx - dy + r2 * r2;
    }
  }

  float d2 = (r2 * r2) * ((x + 0.5f) * (x + 0.5f)) +
             (r1 * r1) * ((y - 1) * (y - 1)) -
             (r1 * r1 * r2 * r2);

  while (y >= 0) {
    drawPoint(xc + x, yc + y, color(0, 0, 0));
    drawPoint(xc - x, yc + y, color(0, 0, 0));
    drawPoint(xc + x, yc - y, color(0, 0, 0));
    drawPoint(xc - x, yc - y, color(0, 0, 0));

    if (d2 > 0) { //  S
      y--;
      dy -= 2 * r1 * r1;
      d2 += r1 * r1 - dy;
    } else { //  SE
      y--;
      x++;
      dx += 2 * r2 * r2;
      dy -= 2 * r1 * r1;
      d2 += dx - dy + r1 * r1;
    }
  }
}

public void CGCurve(Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4) {
 float step = 0.001;  
  for (float t = 0; t <= 1.0; t += step) {
    float x = pow(1-t,3)*p1.x + 3*t*pow((1-t),2)*p2.x + 3*pow(t,2)*(1-t)*p3.x+pow(t,3)*p4.x;
    float y = pow(1-t,3)*p1.y + 3*t*pow((1-t),2)*p2.y + 3*pow(t,2)*(1-t)*p3.y+pow(t,3)*p4.y;
    
    drawPoint(x, y, color(0, 0, 0));
    }
}

public void CGEraser(Vector3 p1, Vector3 p2) {
    float minX = min(p1.x, p2.x);
    float maxX = max(p1.x, p2.x);
    float minY = min(p1.y, p2.y);
    float maxY = max(p1.y, p2.y);
  
    for (float x = minX; x <= maxX; x++) {
      for (float y = minY; y <= maxY; y++) {
        drawPoint(x, y, color(250)); 
      }
    }
  
}

public void drawPoint(float x, float y, color c) {
    stroke(c);
    point(x, y);
}

public float distance(Vector3 a, Vector3 b) {
    Vector3 c = a.sub(b);
    return sqrt(Vector3.dot(c, c));
}
