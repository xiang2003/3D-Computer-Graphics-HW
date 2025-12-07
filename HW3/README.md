# HW3
## 完成項目
- [x] (40%) Correctly implement the 3 matrices.
- [x] (20%) Correctly implement depth buffer.
- [x] (20%) Correctly implement camera control.
- [x] (20%) Correctly implement backculling.
## 作業說明
### Correctly implement the 3 matrices.
![matrix](/HW3/image/matrix.gif)
#### Model Matrix
並將worldToLocal的matrices改成inverse轉換成localToWorld
```java
Matrix4.Trans(transform.position).mult(Matrix4.RotY(transform.rotation.y))
                .mult(Matrix4.RotX(transform.rotation.x)).mult(Matrix4.RotZ(transform.rotation.z))
                .mult(Matrix4.Scale(transform.scale));
```
#### View Matrix
```java
        float aspect = (float)w / (float)h;
        float t = tan(radians(GH_FOV) * 0.5);
        projection.makeZero();
        projection.m[0] = 1.0f / (aspect * t);
        projection.m[5] = 1.0f / t;
        projection.m[10] = (f + n) / (f - n);
        projection.m[11] = (2.0f * f * n) / (f - n);
        projection.m[14] = -1.0f;
```
#### Projection Matrix
```java
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

```

### Correctly implement depth buffer.
![depth1](/HW3/image/depth1.png)
![depth2](/HW3/image/depth2.png)

發現用bilinear interpolation看起來沒有用

改用Barycentric interpolation找z
```java
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
```

### Correctly implement camera control.
![camera](/HW3/image/camera.gif)
用wsad控制上下左右、用qe控制前後
```java
    float speed = 0.2;

    if (keyPressed) {
        if (key == 'a') cam_position.x += speed;
        if (key == 'd') cam_position.x -= speed;
        if (key == 'w') cam_position.y += speed;
        if (key == 's') cam_position.y -= speed;
        if (key == 'q') cam_position.z += speed;
        if (key == 'e') cam_position.z -= speed;
    }
    
    main_camera.setPositionOrientation(cam_position, lookat);
```


### Correctly implement backculling.
![back](/HW3/image/backremove.png)
判斷三角形的法向量跟眼睛的夾角，辨別是否為back
若為back，則不畫出來
```java
            Vector3 v0 = localToWorld().mult(triangle.verts[0].getVector4(1.0)).homogenized();
            Vector3 v1 = localToWorld().mult(triangle.verts[1].getVector4(1.0)).homogenized();
            Vector3 v2 = localToWorld().mult(triangle.verts[2].getVector4(1.0)).homogenized();

            Vector3 edge1 = v1.sub(v0);
            Vector3 edge2 = v2.sub(v0);
            Vector3 normal = Vector3.cross(edge1, edge2);

            Vector3 toCamera = camPos.sub(v0);

            if (Vector3.dot(normal, toCamera) < 0) 
                continue;
```

### 關於LLM

LLM用於幫助我理解演算法內容，並協助我將演算法實際改寫成能夠執行的code
