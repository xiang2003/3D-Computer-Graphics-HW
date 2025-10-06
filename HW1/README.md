# HW1
## 完成項目
- [x] (25%) Correctly implement the line algorithm.
- [x] (25%) Correctly implement the circle algorithm.
- [x] (15%) Correctly implement the ellipse algorithm.
- [x] (15%) Correctly implement the curve algorithm.
- [x] (20%) Correctly implement the eraser.

## 作業說明
### Line
![line](/HW1/image/line.gif)

使用Midpoint進行繪製
根據上課所抄寫的code進行更改
並用sx、sy表示line在x、y軸上移動的方向
用steep紀錄x、y軸哪個增長速度較快
用這三個變數將二維象限分為八個不同的區域
確保可以正常繪製

```java
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
```

### Circle
![circle](/HW1/image/circle.gif)

同樣使用midpoint進行繪製
利用園的對稱性將園分成八等分同時繪製

```java
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
```
### Ellipse
![eliipse](/HW1/image/ellipse.gif)

作法跟circle很像，切成8個區域去繪製
不同的是橢圓一次只能同時畫四個區域
且要分為兩次繪畫，因為dx、dy大小的關係
這樣能讓畫出的橢圓看起來更細緻
(主要參考hackmd給的資源)
```java
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
```
### Curve
![curve](/HW1/image/curve.gif)

利用插值法計算出每一點的位置

```java
 float step = 0.001;  
  for (float t = 0; t <= 1.0; t += step) {
    float x = pow(1-t,3)*p1.x + 3*t*pow((1-t),2)*p2.x + 3*pow(t,2)*(1-t)*p3.x+pow(t,3)*p4.x;
    float y = pow(1-t,3)*p1.y + 3*t*pow((1-t),2)*p2.y + 3*pow(t,2)*(1-t)*p3.y+pow(t,3)*p4.y;
    
    drawPoint(x, y, color(0, 0, 0));
    }
```

### Erase
![erase](/HW1/image/erase.gif)

將p1、p2圍成的正方形區域，全部用背景色覆蓋

```java
    float minX = min(p1.x, p2.x);
    float maxX = max(p1.x, p2.x);
    float minY = min(p1.y, p2.y);
    float maxY = max(p1.y, p2.y);
  
    for (float x = minX; x <= maxX; x++) {
      for (float y = minY; y <= maxY; y++) {
        drawPoint(x, y, color(250)); 
      }
    }
```

## 關於LLM
原先用上課筆記抄寫的code，發現line有些方向的線畫不出來

因此有使用LLM去協助我分析並修改code
