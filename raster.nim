import render_buffer, color, types, algorithm

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
                  x0: float, y0: float,
                  x1: float, y1: float,
                  col: P) =
  self.line(int(x0), int(y0), int(x1), int(y1), col)

template triangle*(self: var RenderBuffer[RenderColor],
                   vs: var array[3, Vert],
                   col: RenderColor = rgb(255, 255, 255)) =
  vs.sort do (x, y: Vert) -> int:
    result = cmp(x.y, y.y)                  

  let totalHeight = vs[2].y - vs[0].y

  for y in vs[0].y..vs[1].y:
    let
      segmentHeight = vs[1].y - vs[0].y + 1
      alpha = float(y - vs[0].y) / totalHeight
      beta = float(y - vs[0].y) / segmentHeight

  let
    ax = vs[0].x + (vs[2].x - vs[0].x) * alpha
    ay = vs[0].y + (vs[2].y - vs[0].y) * alpha
    bx = vs[0].x + (vs[1].x - vs[0].x) * beta
    by = vs[0].y + (vs[1].y - vs[0].y) * beta

  self.set(ax, y, rgb(255, 0, 0))
  self.set(bx, y, rgb(0, 255, 0))

  #self.line(vs[0].x, vs[0].y, vs[1].x, vs[1].y, rgb(0, 255, 0))
  #self.line(vs[1].x, vs[1].y, vs[2].x, vs[2].y, rgb(0, 255, 0))
  #self.line(vs[2].x, vs[2].y, vs[0].x, vs[0].y, rgb(255, 0, 0))