import sdl2, sdl2/image
import obj_reader
import render_buffer, color, raster, types, geometry

import algorithm, random, basic3d

const
  WINDOW_WIDTH = 256
  WINDOW_HEIGHT = 256

var
  buf = render_buffer.init[RenderColor](WINDOW_WIDTH, WINDOW_HEIGHT)

  model = loadObj("models/african_head/african_head.obj")

proc applyOffset(v: Point3d, offset: float = 1.0): Vec2i =
  let offsetDouble = offset * 2.0
  result.x = int((v.x + offset) * WINDOW_WIDTH / offsetDouble)
  result.y = int((v.y + offset) * WINDOW_HEIGHT / offsetDouble) 

proc drawRenderBufferToWindow(buf: RenderBuffer[RenderColor], render: RendererPtr) =
  var pointOperations = 0
  for x, y, col in buf.entries():
    when defined(debug):
      echo $x & "x" & $y & ": " & $col.red & " " & $col.green & " " & $col.blue & " " & $col.alpha

    render.setDrawColor col.red, col.green, col.blue, col.alpha
    render.drawPoint cint(x), WINDOW_HEIGHT - cint(y)
    inc(pointOperations)
  render.present
  echo "Point operations: " & $pointOperations

when isMainModule:

  discard sdl2.init(INIT_VIDEO)
  let
    window = createWindow("Own GL", 100, 100, WINDOW_WIDTH, WINDOW_HEIGHT,
                          SDL_WINDOW_SHOWN)
    render = createRenderer(window, -1, Renderer_Software)

  render.setDrawColor 0, 0, 0, 255
  render.clear

  #---- draw from render buffer starts here
  let
    lightDir = vector3d(0, 0, -1)

  for tri in model.triangles():
    var vs: array[3, Vec2i]
    vs[0] = applyOffset(tri[0], 1.0)
    vs[1] = applyOffset(tri[1], 1.0)
    vs[2] = applyOffset(tri[2], 1.0)

    let
      intensity = dot(tri.normal(), lightDir)
    if intensity > 0:
      let col = rgb(byte(intensity * 255), byte(intensity * 255), byte(intensity * 255))
      buf.triangle(vs, col)
  #---- end of drawing to render buffer

  drawRenderBufferToWindow(buf, render)

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