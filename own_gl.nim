import sdl2, sdl2/image
import obj_reader
import render_buffer, color, raster, types

import algorithm

const
  WINDOW_WIDTH = 512
  WINDOW_HEIGHT = 512

var
  buf = render_buffer.init[RenderColor](WINDOW_WIDTH, WINDOW_HEIGHT)

  model = loadObj("models/fighterCharUV_PolygonDan.1obj")

proc applyOffset(v: Vert, offset: float = 1.0): Vec2i =
  let offsetDouble = offset * 2.0
  result.x = int((v.x + offset) * WINDOW_WIDTH / offsetDouble)
  result.y = int((v.y + offset) * WINDOW_HEIGHT / offsetDouble) 

when isMainModule:

  discard sdl2.init(INIT_VIDEO)
  let
    window = createWindow("Own GL", 100, 100, WINDOW_WIDTH, WINDOW_HEIGHT,
                          SDL_WINDOW_SHOWN)
    render = createRenderer(window, -1, Renderer_Software)

  render.setDrawColor 0, 0, 0, 255
  render.clear

  #---- draw from render buffer starts here
  for tri in model.triangles():
    var vs: array[3, Vec2i]
    vs[0] = applyOffset(tri[0], 8.0)
    vs[1] = applyOffset(tri[1], 8.0)
    vs[2] = applyOffset(tri[2], 8.0)
    buf.triangle(vs)
    #buf.line([vs[0], vs[1]], rgb(200, 0, 0))
    #buf.line([vs[1], vs[2]], rgb(0, 200, 0))
    #buf.line([vs[2], vs[0]], rgb(0, 0, 200))

  var
    t0 = [vec2(10, 70), vec2(50, 160),  vec2(70, 80)]
    t1 = [vec2(180, 50), vec2(150, 1), vec2(70, 180)]
    t2 = [vec2(180, 150), vec2(120, 160), vec2(130, 180)]

  buf.triangle(t0, rgb(255, 0, 0))
  buf.triangle(t1, rgb(255, 255, 255))
  buf.triangle(t2, rgb(0, 255, 0))

  #---- end of drawing to render buffer

  var pointOperations = 0

  for x, y, col in buf.entries():
    render.setDrawColor col.red, col.green, col.blue, col.alpha
    render.drawPoint cint(x), WINDOW_HEIGHT - cint(y)
    inc(pointOperations)
  

  echo "Point operations: " & $pointOperations

  var
    done = false
    evt = sdl2.defaultEvent

  while not done:
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        done = true
        break
      elif evt.kind == WindowEvent:
        render.present
    delay 10

  destroy render
  destroy window