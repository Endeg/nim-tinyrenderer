import render_buffer, color

template line*[P](self: var RenderBuffer[P],
               x0: int, y0: int,
               x1: int, y1: int,
               col: P) =
  for x in x0..x1:
    let t = float(x - x0) / float(x1 - x0)
    let y = int(y0 * (1.0 - t) + y1 * t)
    self.set(x, y, col)
     