import render_buffer, color, types, algorithm, geometry, sequtils, basic2d

template line*[P](self: var RenderBuffer[P],
                  x0: int, y0: int,
                  x1: int, y1: int,
                  col: P) =
  var
    steep = false
    xx0 = x0
    xx1 = x1
    yy0 = y0
    yy1 = y1

  if abs(x0 - x1) < abs(y0 - y1):
    swap(xx0, yy0)
    swap(xx1, yy1)
    steep = true
               
  if xx0 > xx1:
    swap(xx0, xx1)
    swap(yy0, yy1)

  for x in xx0..xx1:
    let t = float(x - xx0) / float(xx1 - xx0)
    let y = int(float(yy0) * (1.0 - t) + float(yy1) * t)
    if steep:
      self.set(y, x, col)
    else:
      self.set(x, y, col)

template line*[P](self: var RenderBuffer[P],
                  vs: array[2, Vec2i],
                  col: P) =
  self.line(vs[0].x, vs[0].y, vs[1].x, vs[1].y, col)

template line*[P](self: var RenderBuffer[P],
                  x0: float, y0: float,
                  x1: float, y1: float,
                  col: P) =
  self.line(int(x0), int(y0), int(x1), int(y1), col)

template triangle*(self: var RenderBuffer[RenderColor],
                   zBuffer: var RenderBuffer[float],
                   worldCoords: Triangle,
                   screenCoords: array[3, Vec2i],
                   col: RenderColor = rgb(255, 255, 255)) =
  let bb = getBbox(vs)
  var vsf: array[3, Vector2d]
  for i in screenCoords.low..screenCoords.high:
    vsf[i].x = float(vs[i].x)
    vsf[i].y = float(vs[i].y)

  for x in bb.min.x..bb.max.x:
    for y in bb.min.y..bb.max.y:
      let
        p = vector2d(float(x), float(y))
        bcScreen = barycentric(vsf, p)
      if bcScreen.x < 0.0 or bcScreen.y < 0.0 or bcScreen.z < 0.0:
        continue
      var
        z = 0.0
      z = z + worldCoords[0].z * bcScreen.x
      z = z + worldCoords[1].z * bcScreen.y
      z = z + worldCoords[2].z * bcScreen.z
      if zBuffer.get(x, y) < z:
        zBuffer.set(x, y, z)
        self.set(x, y, col)

  when defined(debug):
    self.line([vs[0], vs[1]], rgb(0, 255, 0))
    self.line([vs[1], vs[2]], rgb(0, 255, 0))
    self.line([vs[2], vs[0]], rgb(255, 0, 0))
