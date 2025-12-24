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
