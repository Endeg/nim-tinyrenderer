import sdl2, sdl2/image

import render_buffer, color

var
  window: WindowPtr
  render: RendererPtr = nil
  screenHeight: int

proc initApp*(width, height: int) =
  discard sdl2.init(INIT_VIDEO)
  window = createWindow("Own GL", 100, 100, cint(width), cint(height), SDL_WINDOW_SHOWN)
  render = createRenderer(window, -1, Renderer_Software)
  screenHeight = height

proc drawRenderBufferToWindow*(buf: RenderBuffer[RenderColor]) =
  if render == nil:
    raise newException(SystemError, "Init app first.")

  render.setDrawColor 0, 0, 0, 255
  render.clear

  var pointOperations = 0
  for x, y, col in buf.entries():
    when defined(debug):
      echo $x & "x" & $y & ": " & $col.red & " " & $col.green & " " & $col.blue & " " & $col.alpha

    render.setDrawColor col.red, col.green, col.blue, col.alpha
    render.drawPoint cint(x), cint(screenHeight - y)
    inc(pointOperations)

  echo "Point operations: " & $pointOperations

  render.present
  
proc waitForAppClose*() =
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
