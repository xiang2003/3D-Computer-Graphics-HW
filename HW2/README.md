# HW2
## 完成項目
- [x] (20%) Correctly implement the 3 transformation matrices.
- [x] (25%) Correctly implement pnpoly.
- [x] (20%) Correctly implement the bounding box.
- [x] (35%) Correctly implement Sutherland Hodgman Algorithm.
## 作業說明
### 3 transformation matrices
#### Translation Matrix
![translation](/HW2/image/translation.gif)
![translation](/HW2/image/translation.png)

將t放到矩陣中的對應位置
```java
  void makeTrans(Vector3 t) {
    // TODO HW2
    makeIdentity();
    m[3] = t.x;
    m[7] = t.y;
    m[11] = t.z; 
  }
```
#### Rotation Matrix (Z-axis)
![rotation](/HW2/image/rotation.gif)
![rotate](/HW2/image/rotate.png)

將sin、cons放到各個旋轉矩陣的對應位置
```java
  void makeRotX(float a) {
    // TODO HW2
    makeIdentity();
    float cosA = cos(a); 
    float sinA = sin(a); 
    m[5] = cosA;
    m[6] = sinA;
    m[9] = -sinA;
    m[10] = cosA;
  }
  void makeRotY(float a) {
    // TODO HW2
    makeIdentity();
    float cosA = cos(a); 
    float sinA = sin(a); 
    m[0] = cosA;
    m[2] = sinA;
    m[8] = -sinA;
    m[10] = cosA;
  }
  void makeRotZ(float a) {
     // TODO HW2
    makeIdentity();
    float cosA = cos(a); 
    float sinA = sin(a); 
    m[0] = cosA;
    m[1] = sinA;
    m[4] = -sinA;
    m[5] = cosA;

  }
```

#### Scaling Matrix
![scaling](/HW2/image/scaling.gif)
![scaling](/HW2/image/Scaling.png)

將s放到矩陣中的對應位置
```java
  void makeScale(Vector3 s) {
    // TODO HW2
    makeIdentity();
    m[0] = s.x;
    m[5] = s.y;
    m[10] = s.z;
    m[15] = 1.0f;
  }
```
### pnpoly
![pnpoly](/HW2/image/pnpoly.png)

判斷每一條邊是否有穿過該點所在的水平線，並判斷穿過該水平線的邊總數，判斷該點是否在polygon中
* ```(py[i] > y) != (py[j] > y)```:判斷此邊是否有穿過該點所在的水平線
* ```(x < (px[j] - px[i]) * (y - py[i]) / (py[j] - py[i]) + px[i])```:判斷穿過該水平線的邊是否在該點的左邊(算一邊就好)
```java
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
```
### the bounding box

跑過polygon的每一個vertex，紀錄其x、y的最大/小值
```java
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
```

### Sutherland Hodgman Algorithm
![Sutherland](/HW2/image/Sutherland.png)

依照左下右上的順序，去對polygon進行裁切
```java
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
```
有三個輔助function
* **clipEdge:** 判斷是否要對邊進行裁切
* **inside:** 根據上下左右判斷點是否在邊界內
* **intersect:** 計算邊與邊界的交點，並回傳
```java
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
```

### 關於LLM
LLM用於幫助我理解演算法內容，並協助我將演算法實際改寫成能夠執行的code