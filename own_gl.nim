import sdl2, sdl2/image
import obj_reader
import render_buffer, color, raster

const
  WINDOW_WIDTH = 256
  WINDOW_HEIGHT = 256

var
  buf = render_buffer.init[RenderColor]()

  model = loadObj("models/Tails/Tails.obj")

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
    buf.line(tri[0].x, tri[0].y, tri[1].x, tri[1].y, rgb(200, 200, 200))
    buf.line(tri[1].x, tri[1].y, tri[2].x, tri[2].y, rgb(200, 200, 200))
    buf.line(tri[2].x, tri[2].y, tri[0].x, tri[0].y, rgb(200, 200, 200))

  for x, y, col in buf.entries():
    render.setDrawColor col.red, col.green, col.blue, col.alpha
    render.drawPoint cint(x), WINDOW_HEIGHT - cint(y)

  #---- end of drawing to render buffer

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