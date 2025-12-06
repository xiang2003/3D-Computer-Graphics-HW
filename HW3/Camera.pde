public class Camera {
    Matrix4 projection = new Matrix4();
    Matrix4 worldView = new Matrix4();
    int wid;
    int hei;
    float near;
    float far;
    Transform transform;

    Camera() {
        wid = 256;
        hei = 256;
        worldView.makeIdentity();
        projection.makeIdentity();
        transform = new Transform();
    }

    Matrix4 inverseProjection() {
        Matrix4 invProjection = Matrix4.Zero();
        float a = projection.m[0];
        float b = projection.m[5];
        float c = projection.m[10];
        float d = projection.m[11];
        float e = projection.m[14];
        invProjection.m[0] = 1.0f / a;
        invProjection.m[5] = 1.0f / b;
        invProjection.m[11] = 1.0f / e;
        invProjection.m[14] = 1.0f / d;
        invProjection.m[15] = -c / (d * e);
        return invProjection;
    }

    Matrix4 Matrix() {
        return projection.mult(worldView);
    }

    void setSize(int w, int h, float n, float f) {
        wid = w;
        hei = h;
        near = n;
        far = f;
        
        // TODO HW3
        // This function takes four parameters, which are 
        // the width of the screen, the height of the screen
        // the near plane and the far plane of the camera.
        // Where GH_FOV has been declared as a global variable.
        // Finally, pass the result into projection matrix.
        float aspect = (float)w / (float)h;
        float t = tan(radians(GH_FOV) * 0.5);
        projection.makeZero();
        projection.m[0] = 1.0f / (aspect * t);
        projection.m[5] = 1.0f / t;
        projection.m[10] = (f + n) / (f - n);
        projection.m[11] = (2.0f * f * n) / (f - n);
        projection.m[14] = -1.0f;

    }

    void setPositionOrientation(Vector3 pos, float rotX, float rotY) {

    }

    void setPositionOrientation(Vector3 pos, Vector3 lookat) {
        // TODO HW3
        // This function takes two parameters, which are the position of the camera and
        // the point the camera is looking at.
        // We uses topVector = (0,1,0) to calculate the eye matrix.
        // Finally, pass the result into worldView matrix.

        Vector3 up = new Vector3(0, 1, 0);
        Vector3 f = Vector3.sub(lookat, pos).unit_vector();
        Vector3 r = Vector3.cross(up, f).unit_vector();
        Vector3 u = Vector3.cross(f, r).unit_vector();
        Matrix4 view = new Matrix4(r,u,f.mult(-1));
        view = view.transposed();
        view.m[12] = -Vector3.dot(r, pos);
        view.m[13] = -Vector3.dot(u, pos);
        view.m[14] = -Vector3.dot(f, pos);
        worldView = view;

    }
}
