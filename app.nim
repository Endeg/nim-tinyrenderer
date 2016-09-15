import sdl2

import render_buffer, color

var
  window: WindowPtr
  render: RendererPtr = nil
  screenHeight: int

proc initApp*(width, height: int) =
  discard sdl2.init(INIT_VIDEO)

  var
    dm: DisplayMode
    x = cint(0)
    y = cint(0)

  if getCurrentDisplayMode(0, dm) == SdlSuccess:
    x = cint(dm.w div 2 - width div 2)
    y = cint(dm.h div 2 - height div 2)
  else:
    echo "Unable to get display mode"

  window = createWindow("Own GL", x, y, cint(width), cint(height), SDL_WINDOW_SHOWN)
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

proc drawZBufferToWindow*(zBuffer: RenderBuffer[float], near: float = 1.0, far: float = 30.0) =
  if render == nil:
    raise newException(SystemError, "Init app first.")
  
  render.setDrawColor 0, 0, 0, 255
  render.clear

  var pointOperations = 0
  for x, y, z in zBuffer.entries():
    
    let c = byte(255.0 * (2.0 * near) / (far + near - z * (far - near)))

    render.setDrawColor c, c, c, 255
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
