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

    // TODO HW2


    // Initialize input
    ArrayList<Vector3> input = new ArrayList<Vector3>();
    for (int i = 0; i < points.length; i++) input.add(points[i]);
    int bn = boundary.length;

    // Clip against each edge of the boundary
    for (int b = 0; b < bn; b++) {
        ArrayList<Vector3> output = new ArrayList<Vector3>();
        Vector3 A = boundary[b];
        Vector3 B = boundary[(b + 1) % bn];
        for (int i = 0; i < input.size(); i++) {
            Vector3 P = input.get(i);
            Vector3 Q = input.get((i + 1) % input.size());
            boolean Pin = isInside(P, A, B);
            boolean Qin = isInside(Q, A, B);
            if (Pin && Qin) {
                output.add(Q);
            } else if (Pin && !Qin) {
                output.add(intersection(P, Q, A, B));
            } else if (!Pin && Qin) {
                output.add(intersection(P, Q, A, B));
                output.add(Q);
            }
        }
        input = output;
    }

    // Convert output to array
    Vector3[] result = new Vector3[input.size()];
    for (int i = 0; i < input.size(); i++) result[i] = input.get(i);
    return result;

}

boolean isInside(Vector3 p, Vector3 a, Vector3 b) {
    // Determine if point p is inside the edge ab
    return ((b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x)) <= 0;
}

// Compute the intersection point of line segments pq and ab
Vector3 intersection(Vector3 p, Vector3 q, Vector3 a, Vector3 b) {
    float dx1 = q.x - p.x, dy1 = q.y - p.y;
    float dx2 = b.x - a.x, dy2 = b.y - a.y;
    float denominator = dx1 * dy2 - dy1 * dx2;
    if (abs(denominator) < 1e-6) return q.copy();
    float t = ((a.x - p.x) * dy2 - (a.y - p.y) * dx2) / denominator;
    return new Vector3(p.x + t * dx1, p.y + t * dy1, 0);
}

public float getDepth(float x, float y, Vector3[] vertex) {
    // TODO HW3
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
    Vector3 v0 = Vector3.sub(B, A);
    Vector3 v1 = Vector3.sub(C, A);
    Vector3 v2 = Vector3.sub(P, A);

    Vector4 AW = verts[0];
    Vector4 BW = verts[1];
    Vector4 CW = verts[2];
    float wA = AW.w;
    float wB = BW.w;
    float wC = CW.w;
    // TODO HW4
    float areaABC = Vector3.cross(v0, v1).length();
    float areaPBC = Vector3.cross(Vector3.sub(B, P), Vector3.sub(C, P)).length();
    float areaPCA = Vector3.cross(Vector3.sub(C, P), Vector3.sub(A, P)).length();
    float areaPAB = Vector3.cross(Vector3.sub(A, P), Vector3.sub(B, P)).length();

    float alpha = areaPBC / areaABC;
    float beta  = areaPCA / areaABC;
    float gamma = areaPAB / areaABC;

    alpha /= wA;
    beta  /= wB;
    gamma /= wC;
    
    float sum = alpha + beta + gamma;

    alpha /= sum;
    beta  /= sum;
    gamma /= sum;
    float[] result = { alpha, beta, gamma };
    return result;
}

Vector3 interpolation(float[] abg, Vector3[] v) {
    return v[0].mult(abg[0]).add(v[1].mult(abg[1])).add(v[2].mult(abg[2]));
}

Vector4 interpolation(float[] abg, Vector4[] v) {
    return v[0].mult(abg[0]).add(v[1].mult(abg[1])).add(v[2].mult(abg[2]));
}

float interpolation(float[] abg, float[] v) {
    return v[0] * abg[0] + v[1] * abg[1] + v[2] * abg[2];
}
