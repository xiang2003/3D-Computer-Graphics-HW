public void CGLine(float x1, float y1, float x2, float y2) {
    stroke(0);
    line(x1, y1, x2, y2);
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
    // You need to find the bounding box of the vertexes v.

    Vector3 prevminV = new Vector3(-Float.MAX_VALUE);
    Vector3 prevmaxV = new Vector3(Float.MAX_VALUE);
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
    // You need to implement the Sutherland Hodgman Algorithm in this section.
    // The function you pass 2 parameter. One is the vertexes of the shape "points".
    // And the other is the vertexes of the "boundary".
    // The output is the vertexes of the polygon.

    float xmax = boundary[0].x, xmin = boundary[0].x, ymax = boundary[0].y, ymin = boundary[0].y, zmax = boundary[0].z, zmin = boundary[0].z;
    for (int i = 1; i < 4; i+=1){
      xmax = Math.max(xmax, boundary[i].x);
      xmin = Math.min(xmin, boundary[i].x);
      ymax = Math.max(ymax, boundary[i].y);
      ymin = Math.min(ymin, boundary[i].y);
      zmax = Math.max(zmax, boundary[i].z);
      zmin = Math.min(zmin, boundary[i].z);
    }
    input = clipEdge(input, "LEFT", xmin);
    input = clipEdge(input, "BOTTOM", ymin);
    input = clipEdge(input, "NEAR", zmin);
    input = clipEdge(input, "RIGHT", xmax);
    input = clipEdge(input, "TOP", ymax);
    input = clipEdge(input, "FAR", zmax);

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
        case "NEAR":   return p.z >= value;
        case "FAR":    return p.z <= value;
    }
    return false;
}

private Vector3 intersect(Vector3 p1, Vector3 p2, String edge, float value) {
    float t = 0;
    switch (edge) {
        case "LEFT":
        case "RIGHT":
            t = (value - p1.x) / (p2.x - p1.x);
            break;

        case "BOTTOM":
        case "TOP":
            t = (value - p1.y) / (p2.y - p1.y);
            break;

        case "NEAR":
        case "FAR":
            t = (value - p1.z) / (p2.z - p1.z);
            break;
    }
    
    float x = p1.x + t * (p2.x - p1.x);
    float y = p1.y + t * (p2.y - p1.y);
    float z = p1.z + t * (p2.z - p1.z);

    return new Vector3(x, y, z);
}
public float getDepth(float x, float y, Vector3[] vertex) {
    // TODO HW3
    // You need to calculate the depth (z) in the triangle (vertex) based on the
    // positions x and y. and return the z value;
    Vector3 v0 = vertex[0];
    Vector3 v1 = vertex[1];
    Vector3 v2 = vertex[2];
        
    float x0=v0.x, y0=v0.y, z0=v0.z;
    float x1=v1.x, y1=v1.y, z1=v1.z;
    float x2=v2.x, y2=v2.y, z2=v2.z;

    float det = (y1 - y2)*(x0 - x2) + (x2 - x1)*(y0 - y2);

    float alpha = ((y1 - y2)*(x - x2) + (x2 - x1)*(y - y2)) / det;
    float beta  = ((y2 - y0)*(x - x2) + (x0 - x2)*(y - y2)) / det;
    float gamma = 1.0f - alpha - beta;

    float z = alpha*z0 + beta*z1 + gamma*z2;
    return z;
}

float[] barycentric(Vector3 P, Vector4[] verts) {

    Vector3 A = verts[0].homogenized();
    Vector3 B = verts[1].homogenized();
    Vector3 C = verts[2].homogenized();

    // TODO HW4
    // Calculate the barycentric coordinates of point P in the triangle verts using
    // the barycentric coordinate system.

    float[] result = { 0.0, 0.0, 0.0 };

    return result;
}
