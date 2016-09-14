import render_buffer, color, types, algorithm, geometry

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
                   vs: var array[3, Vec2i],
                   col: RenderColor = rgb(255, 255, 255)) =
  let bb = getBbox(vs)

  for x in bb.min.x..bb.max.x:
    for y in bb.min.y..bb.max.y:
      if pointInTriangle(vec2(x, y), vs):
        self.set(x, y, col)

  when defined(debug):
    self.line([vs[0], vs[1]], rgb(0, 255, 0))
    self.line([vs[1], vs[2]], rgb(0, 255, 0))
    self.line([vs[2], vs[0]], rgb(255, 0, 0))
