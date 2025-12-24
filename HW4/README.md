# HW4
## 完成項目
- [x] (25%) Correctly implement the barycentric.
- [x] (25%) Correctly implement Phong Shading.
- [x] (25%) Correctly implement Flat Shading.
- [x] (25%) Correctly implement Gouraud Shading.
## 作業說明
### Correctly implement the barycentric

算出三角形的重心座標(ɑ,β,γ)
```java
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
```

### Correctly implement Phong Shading

![phong](/HW4/image/phong.png)

每個點都需要計算光照，並計算插值。

Material
```java
public class PhongMaterial extends Material {
    Vector3 Ka = new Vector3(0.3, 0.3, 0.3);
    float Kd = 0.5;
    float Ks = 0.5;
    float m = 20;

    PhongMaterial() {
        shader = new Shader(new PhongVertexShader(), new PhongFragmentShader());
    }

    Vector4[][] vertexShader(Triangle triangle, Matrix4 M) {
        Matrix4 MVP = main_camera.Matrix().mult(M);
        Vector3[] position = triangle.verts;
        Vector3[] normal = triangle.normal;
        Vector4[][] r = shader.vertex.main(new Object[] { position, normal }, new Object[] { MVP, M });
        return r;
    }

    Vector4 fragmentShader(Vector3 position, Vector4[] varing) {

        return shader.fragment
                .main(new Object[] { position, varing[0].xyz(), varing[1].xyz(), albedo, new Vector4(Ka.x(), Kd, Ks, m) });
    }

}
```

shader
```java
public class PhongVertexShader extends VertexShader {
    Vector4[][] main(Object[] attribute, Object[] uniform) {
        Vector3[] aVertexPosition = (Vector3[]) attribute[0];
        Vector3[] aVertexNormal = (Vector3[]) attribute[1];
        Matrix4 MVP = (Matrix4) uniform[0];
        Matrix4 M = (Matrix4) uniform[1];
        Vector4[] gl_Position = new Vector4[3];
        Vector4[] w_position = new Vector4[3];
        Vector4[] w_normal = new Vector4[3];

        for (int i = 0; i < gl_Position.length; i++) {
            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
            w_position[i] = M.mult(aVertexPosition[i].getVector4(1.0));
            w_normal[i] = M.mult(aVertexNormal[i].getVector4(0.0));
        }

        Vector4[][] result = { gl_Position, w_position, w_normal };

        return result;
    }
}

public class PhongFragmentShader extends FragmentShader {
    Vector4 main(Object[] varying) {
        Vector3 position = (Vector3) varying[0];
        Vector3 w_position = (Vector3) varying[1];
        Vector3 w_normal = (Vector3) varying[2];
        Vector3 albedo = (Vector3) varying[3];
        Vector4 kakdksm = (Vector4) varying[4];
        Light light = basic_light;
        Camera cam = main_camera;

        // TODO HW4
        // ===== normalize vectors =====
        Vector3 N = w_normal.unit_vector();
        Vector3 L = light.transform.position.sub(w_position).unit_vector();
        Vector3 V = cam.transform.position.sub(w_position).unit_vector();
        float ka = kakdksm.x; // ambient coefficient
        float kd = kakdksm.y; // diffuse coefficient
        float ks = kakdksm.z; // specular coefficient
        float m  = kakdksm.w; // shininess
        // ===== Ambient =====
        Vector3 ambient = albedo.mult(ka * light.intensity);

        // ===== Diffuse =====
        float NL = Vector3.dot(N, L);
        float diff = max(0.0f, NL);
        Vector3 diffuse = albedo.mult(kd * diff * light.intensity);

        // ===== Specular =====
        Vector3 R = Vector3.sub(Vector3.mult(2.0f * NL, N),L).unit_vector();
        float spec = pow(max(0.0f, Vector3.dot(R, V)), m);
        Vector3 specular = light.light_color.mult(ks * spec * light.intensity);

        // ===== Final color =====
        Vector3 phong_color = ambient.add(diffuse).add(specular);

        return new Vector4(phong_color.x(), phong_color.y(), phong_color.z(), 1.0f);
        //return new Vector4(0.0, 0.0, 0.0, 1.0);
    }
}
```

### Correctly implement Flat Shading

![flat](/HW4/image/flat.png)

只需要計算一次光照，整個面都用同一個
不用計算插值

material
```java

public class FlatMaterial extends Material {
    Vector3 Ka = new Vector3(0.3, 0.3, 0.3);
    float Kd = 0.5;
    float Ks = 0.5;
    float m = 20;
    FlatMaterial() {
        shader = new Shader(new FlatVertexShader(), new FlatFragmentShader());
    }

    Vector4[][] vertexShader(Triangle triangle, Matrix4 M) {
        Matrix4 MVP = main_camera.Matrix().mult(M);
        Vector3[] position = triangle.verts;

        // TODO HW4
        // pass the uniform you need into the shader.
        Vector3 e1 = Vector3.sub(position[1], position[0]);
        Vector3 e2 = Vector3.sub(position[2], position[0]);
        Vector3 faceNormal = Vector3.cross(e1, e2).unit_vector();

        Vector4[][] r = shader.vertex.main(new Object[] { position, faceNormal}, new Object[] { MVP, M });
        return r;
    }

    Vector4 fragmentShader(Vector3 position, Vector4[] varing) {

        return shader.fragment
                .main(new Object[] { position, varing[0].xyz(), varing[1].xyz(), albedo, new Vector4(Ka.x(), Kd, Ks, m) });
    }
}
```

shader
```java

public class FlatVertexShader extends VertexShader {
    Vector4[][] main(Object[] attribute, Object[] uniform) {
        // TODO HW4
        Vector3[] aVertexPosition = (Vector3[]) attribute[0];
        //Vector3[] aVertexNormal = (Vector3[]) attribute[1];
        Matrix4 MVP = (Matrix4) uniform[0];
        Matrix4 M = (Matrix4) uniform[1];
        Vector4[] gl_Position = new Vector4[3];
        Vector4[] w_position = new Vector4[3];
        Vector4[] w_normal = new Vector4[3];
        
        Vector3 p0 = M.mult(aVertexPosition[0].getVector4(1.0)).xyz();
        Vector3 p1 = M.mult(aVertexPosition[1].getVector4(1.0)).xyz();
        Vector3 p2 = M.mult(aVertexPosition[2].getVector4(1.0)).xyz();
        Vector3 face_normal = Vector3.cross(Vector3.sub(p1, p0), Vector3.sub(p2, p0)).unit_vector();
        Vector3 face_position = p0;

        for (int i = 0; i < 3; i++) {
            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
            w_position[i] = new Vector4(face_position, 1.0);
            w_normal[i] = new Vector4(face_normal, 0.0);    
        }
        Vector4[][] result = { gl_Position, w_position, w_normal };


        return result;
    }
}

public class FlatFragmentShader extends FragmentShader {
    Vector4 main(Object[] varying) {
        Vector3 position = (Vector3) varying[0];
        // TODO HW4
        Vector3 w_position = (Vector3) varying[1];
        Vector3 w_normal = (Vector3) varying[2];
        Vector3 albedo = (Vector3) varying[3];
        Vector4 kakdksm = (Vector4) varying[4];
        Light light = basic_light;
        Camera cam = main_camera;
        // ===== normalize vectors =====
        Vector3 N = w_normal.unit_vector();
        Vector3 L = light.transform.position.sub(position).unit_vector();
        Vector3 V = cam.transform.position.sub(position).unit_vector();
        float ka = kakdksm.x; // ambient coefficient
        float kd = kakdksm.y; // diffuse coefficient
        float ks = kakdksm.z; // specular coefficient
        float m  = kakdksm.w; // shininess

        // ===== Ambient =====
        Vector3 ambient = albedo.mult(ka * light.intensity);

        // ===== Diffuse =====
        float NL = max(0.0f, Vector3.dot(N, L));
        Vector3 diffuse = albedo.mult(kd * NL * light.intensity);

        // ===== Specular =====
        Vector3 R = Vector3.sub(Vector3.mult(2.0f * NL, N), L).unit_vector();
        float spec = pow(max(0.0f, Vector3.dot(R, V)), m);
        Vector3 specular = light.light_color.mult(ks * spec * light.intensity);
        // ===== Final color =====
        Vector3 flat_color = ambient.add(diffuse).add(specular);

        return new Vector4(flat_color.x(), flat_color.y(), flat_color.z(), 1.0f);
    }
}
```

### Correctly implement Gouraud Shading
![gouraud](/HW4/image/gouraud.png)

只要需要計算頂點顏色
其他的用插值計算

material
```java
public class GouraudMaterial extends Material {
    Vector3 Ka = new Vector3(0.3, 0.3, 0.3);
    float Kd = 0.5;
    float Ks = 0.5;
    float m = 20;
    GouraudMaterial() {
        shader = new Shader(new GouraudVertexShader(), new GouraudFragmentShader());
    }

    Vector4[][] vertexShader(Triangle triangle, Matrix4 M) {
        Matrix4 MVP = main_camera.Matrix().mult(M);
        Vector3[] position = triangle.verts;
        
        // TODO HW4
        // pass the uniform you need into the shader.
        Vector3[] normal = triangle.normal;

        Vector4[][] r = shader.vertex.main(new Object[] { position, normal, albedo, new Vector4(Ka.x(), Kd, Ks, m) }, new Object[] { MVP, M });
        return r;
    }

    Vector4 fragmentShader(Vector3 position, Vector4[] varing) {
        return shader.fragment.main(new Object[] { position ,varing[0] });
    }
}
```

shader
```java
public class GouraudVertexShader extends VertexShader {
    Vector4[][] main(Object[] attribute, Object[] uniform) {
        // TODO HW4
        Vector3[] aVertexPosition = (Vector3[]) attribute[0];
        Vector3[] aVertexNormal = (Vector3[]) attribute[1];
        Vector3 albedo = (Vector3) attribute[2];
        Vector4 kakdksm = (Vector4) attribute[3]; 
        Matrix4 MVP = (Matrix4) uniform[0];
        Matrix4 M = (Matrix4) uniform[1];
        Vector4[] gl_Position = new Vector4[3];
        Vector4[] vertexColor = new Vector4[3];
        
        Light light = basic_light;
        Camera cam = main_camera;

        for (int i = 0; i < 3; i++) {
            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
            Vector3 w_pos    = M.mult(aVertexPosition[i].getVector4(1.0)).xyz();
            Vector3 w_normal = M.mult(aVertexNormal[i].getVector4(0.0)).xyz().unit_vector();

            // ===== normalize vectors =====
            Vector3 N = w_normal;
            Vector3 L = light.transform.position.sub(w_pos).unit_vector();
            Vector3 V = cam.transform.position.sub(w_pos).unit_vector();
            float ka = kakdksm.x; // ambient coefficient
            float kd = kakdksm.y; // diffuse coefficient
            float ks = kakdksm.z; // specular coefficient
            float m  = kakdksm.w; // shininess
            // ===== Ambient =====
            Vector3 ambient  = albedo.mult(ka * light.intensity);
            // ===== Diffuse =====
            float NL = max(0.0f, Vector3.dot(N, L));
            Vector3 diffuse  = albedo.mult(kd * NL * light.intensity);
            // ===== Specular =====
            Vector3 R = Vector3.sub(Vector3.mult(2.0f * NL, N), L).unit_vector();
            float specFactor = pow(max(0.0f, Vector3.dot(R, V)), m);
            Vector3 specular = light.light_color.mult(ks * specFactor * light.intensity);
            // ===== Final color =====
            Vector3 gouraud_color = ambient.add(diffuse).add(specular);

            vertexColor[i] = new Vector4(gouraud_color.x(), gouraud_color.y(), gouraud_color.z(), 1.0);
        }

        Vector4[][] result = { gl_Position, vertexColor };

        return result;
    }
}

public class GouraudFragmentShader extends FragmentShader {
    Vector4 main(Object[] varying) {
        // TODO HW4
        Vector3 position = (Vector3) varying[0];
        Vector4 gouraud_color = (Vector4) varying[1];
        return gouraud_color;
    }
}
```

### 關於LLM
LLM用於幫助我理解演算法內容，並協助我將演算法實際改寫成能夠執行的code，協助我debug