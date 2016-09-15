import obj_reader, app
import render_buffer, color, raster, types, geometry

import algorithm, random, basic3d

const
  WINDOW_WIDTH = 900
  WINDOW_HEIGHT = 900

var
  buf = render_buffer.init[RenderColor](rgb(0, 0, 0), WINDOW_WIDTH, WINDOW_HEIGHT)
  zBuffer = render_buffer.init[float](-999999.0, WINDOW_WIDTH, WINDOW_HEIGHT)

  model = loadObj("models/Tails/Tails.obj")

proc applyOffset(v: Point3d, offset: float = 1.0, y = 0): Vec2i =
  let offsetDouble = offset * 2.0
  result.x = int((v.x + offset) * WINDOW_WIDTH / offsetDouble)
  result.y = int((v.y + offset) * WINDOW_HEIGHT / offsetDouble) - y 

proc drawToRenderBuffer() =
  let
    lightDir = vector3d(0, 0, -1)

  for tri in model.triangles():
    var vs: array[3, Vec2i]
    vs[0] = applyOffset(tri[0], 5.0, WINDOW_HEIGHT div 2)
    vs[1] = applyOffset(tri[1], 5.0, WINDOW_HEIGHT div 2)
    vs[2] = applyOffset(tri[2], 5.0, WINDOW_HEIGHT div 2)

    let
      intensity = dot(tri.normal(), lightDir)
    if intensity > 0:
      let col = rgb(byte(intensity * 255), byte(intensity * 255), byte(intensity * 255))
      buf.triangle(zBuffer, tri, vs, col)

when isMainModule:
  initApp(WINDOW_WIDTH, WINDOW_HEIGHT)
  drawToRenderBuffer()
  drawRenderBufferToWindow(buf)
  #drawZBufferToWindow(zBuffer)
  waitForAppClose()
