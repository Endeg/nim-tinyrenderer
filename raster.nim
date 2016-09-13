import render_buffer, color

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
     