import sdl2, sdl2/image
import obj_reader
import render_buffer, color, raster

const
  WINDOW_WIDTH = 256
  WINDOW_HEIGHT = 256

var
  buf = render_buffer.init[RenderColor]()

  model = loadObj("models/fleur.obj")

when isMainModule:

  discard sdl2.init(INIT_VIDEO)
  let
    window = createWindow("Own GL", 100, 100, WINDOW_WIDTH, WINDOW_HEIGHT,
                          SDL_WINDOW_SHOWN)
    render = createRenderer(window, -1, Renderer_Software)

  render.setDrawColor 0, 0, 0, 255
  render.clear

  #---- draw from render buffer starts here

  buf.line(48, 77, 64, 56, rgb(200, 200, 200))

  buf.set(48, 77, rgb(255, 128, 128))
  buf.set(64, 56, rgb(255, 128, 255))

  buf.line(13, 20, 80, 40, rgb(255, 255, 255)) 
  buf.line(20, 13, 40, 80, rgb(255, 0, 0)) 
  buf.line(80, 40, 13, 20, rgb(255, 0, 0))

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