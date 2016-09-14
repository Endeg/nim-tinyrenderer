import sdl2, sdl2/image
import obj_reader
import render_buffer, color, raster, types

import algorithm

const
  WINDOW_WIDTH = 900
  WINDOW_HEIGHT = 900

var
  buf = render_buffer.init[RenderColor](WINDOW_WIDTH, WINDOW_HEIGHT)

  model = loadObj("models/fighterCharUV_PolygonDan.obj")

template drawLineForWindow(self: RenderBuffer, v0: Vert, v1: Vert, offset: float = 1.0) =
  let offsetDouble = offset * 2.0
  buf.line((v0.x + offset) * WINDOW_WIDTH / offsetDouble, (v0.y + offset) * WINDOW_HEIGHT / offsetDouble,
           (v1.x + offset) * WINDOW_WIDTH / offsetDouble, (v1.y + offset) * WINDOW_HEIGHT / offsetDouble,
           rgb(200, 200, 200))

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

    #buf.drawLineForWindow(tri[0], tri[1], 8.0)
    #buf.drawLineForWindow(tri[1], tri[2], 8.0)
    #buf.drawLineForWindow(tri[2], tri[0], 8.0)

  var pointOperations = 0

  for x, y, col in buf.entries():
    render.setDrawColor col.red, col.green, col.blue, col.alpha
    render.drawPoint cint(x), WINDOW_HEIGHT - cint(y)
    inc(pointOperations)
  #---- end of drawing to render buffer

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