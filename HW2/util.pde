public void CGLine(float x1, float y1, float x2, float y2) {
    // TODO HW1
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
  if(sx==1){
    for (float x = x1; x <= x2; x += sx) {
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
  else{
    for (float x = x1; x >= x2; x += sx) {
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
}

public boolean outOfBoundary(float x, float y) {
    if (x < 0 || x >= width || y < 0 || y >= height)
        return true;
    return false;
}

public void drawPoint(float x, float y, color c) {
    int index = (int) y * width + (int) x;
    if (outOfBoundary(x, y))
        return;
    pixels[index] = c;
}

public float distance(Vector3 a, Vector3 b) {
    Vector3 c = a.sub(b);
    return sqrt(Vector3.dot(c, c));
}

boolean pnpoly(float x, float y, Vector3[] vertexes) {
    // TODO HW2 
    int numVertices = vertexes.length;
    boolean inside = false;
    float[] px = new float[numVertices];
    float[] py = new float[numVertices];
    for (int i = 0; i < numVertices; i++) {
        px[i] = vertexes[i].x;
        py[i] = vertexes[i].y;
    }
    for (int i = 0, j = numVertices - 1; i < numVertices; j = i++) {
        if (((py[i] > y) != (py[j] > y)) && (x < (px[j] - px[i]) * (y - py[i]) / (py[j] - py[i]) + px[i])) {
            inside = !inside;
        }
    }
    return inside;
}

public Vector3[] findBoundBox(Vector3[] v) {
    // TODO HW2 

    Vector3 prevminV = new Vector3(0);
    Vector3 prevmaxV = new Vector3(999);
    for (int i = 1; i < v.length; i++) {
        Vector3 currentVertex = v[i];

        prevminV.x = Math.min(prevminV.x, currentVertex.x);
        prevminV.y = Math.min(prevminV.y, currentVertex.y);
        prevminV.z = Math.min(prevminV.z, currentVertex.z);

        prevmaxV.x = Math.max(prevmaxV.x, currentVertex.x);
        prevmaxV.y = Math.max(prevmaxV.y, currentVertex.y);
        prevmaxV.z = Math.max(prevmaxV.z, currentVertex.z);
    }    
    Vector3[] result = { prevminV, prevmaxV };
    return result;
}

public Vector3[] Sutherland_Hodgman_algorithm(Vector3[] points, Vector3[] boundary) {
    ArrayList<Vector3> input = new ArrayList<Vector3>();
    ArrayList<Vector3> output = new ArrayList<Vector3>();
    for (int i = 0; i < points.length; i += 1) {
        input.add(points[i]);
    }

    // TODO HW2
    float xmax = boundary[0].x, xmin = boundary[0].x, ymax = boundary[0].y, ymin = boundary[0].y;
    for (int i = 1; i < 4; i+=1){
      xmax = Math.max(xmax, boundary[i].x);
      xmin = Math.min(xmin, boundary[i].x);
      ymax = Math.max(ymax, boundary[i].y);
      ymin = Math.min(ymin, boundary[i].y);
    }
    input = clipEdge(input, "LEFT", xmin);
    input = clipEdge(input, "BOTTOM", ymin);
    input = clipEdge(input, "RIGHT", xmax);
    input = clipEdge(input, "TOP", ymax);

    output = input;

    Vector3[] result = new Vector3[output.size()];
    for (int i = 0; i < result.length; i += 1) {
        result[i] = output.get(i);
    }
    return result;
}

private ArrayList<Vector3> clipEdge(ArrayList<Vector3> input, String edge, float value) {
    ArrayList<Vector3> output = new ArrayList<>();

    for (int i = 0; i < input.size(); i++) {
        Vector3 A = input.get(i);
        Vector3 B = input.get((i + 1) % input.size());

        boolean A_inside = inside(A, edge, value);
        boolean B_inside = inside(B, edge, value);

        if (A_inside && B_inside) {
            output.add(B);
        } else if (A_inside && !B_inside) {
            output.add(intersect(A, B, edge, value));
        } else if (!A_inside && B_inside) {
            output.add(intersect(A, B, edge, value));
            output.add(B);
        }
    }

    return output;
}

private boolean inside(Vector3 p, String edge, float value) {
    switch (edge) {
        case "LEFT":   return p.x >= value;
        case "RIGHT":  return p.x <= value;
        case "BOTTOM": return p.y >= value;
        case "TOP":    return p.y <= value;
    }
    return false;
}

private Vector3 intersect(Vector3 p1, Vector3 p2, String edge, float value) {
    float x = 0, y = 0;
    float dx = p2.x - p1.x;
    float dy = p2.y - p1.y;

    switch (edge) {
        case "LEFT":
            x = value;
            y = p1.y + dy * (value - p1.x) / dx;
            break;
        case "RIGHT":
            x = value;
            y = p1.y + dy * (value - p1.x) / dx;
            break;
        case "BOTTOM":
            y = value;
            x = p1.x + dx * (value - p1.y) / dy;
            break;
        case "TOP":
            y = value;
            x = p1.x + dx * (value - p1.y) / dy;
            break;
    }
    return new Vector3(x, y, 0);
}