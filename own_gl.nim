import obj_reader, texture, app
import render_buffer, color, raster, types, geometry

import algorithm, random, basic2d, basic3d

const
  WINDOW_WIDTH = 900
  WINDOW_HEIGHT = 900
  OFFSET = 1.0

var
  buf = render_buffer.init[RenderColor](rgb(0, 0, 0), WINDOW_WIDTH, WINDOW_HEIGHT)
  zBuffer = render_buffer.init[float](-999999.0, WINDOW_WIDTH, WINDOW_HEIGHT)

  model = loadObj("models/african_head/african_head.obj")
  tex = loadTexture("models/african_head/african_head_diffuse.tga")

proc orthoishWithOffset(v: Point3d): Point3d =
  let offsetDouble = OFFSET * 2.0
  result.x = (v.x + OFFSET) * WINDOW_WIDTH / offsetDouble
  result.y = (v.y + OFFSET) * WINDOW_HEIGHT / offsetDouble
  result.z = v.z

proc drawToRenderBuffer() =
  echo "Render in progress..."
  let
    lightDir = vector3d(0, 0, -1)
  
  var
    facesProcessed = 0

  for tri, uv in model.triangles():
    let
      intensity = dot(tri.normal(), lightDir)
    if intensity > 0:
      let col = rgb(byte(intensity * 255), byte(intensity * 255), byte(intensity * 255))
      triangle(buf, zBuffer, tex, orthoishWithOffset, tri, uv, col)

    inc facesProcessed
    if facesProcessed mod 500 == 0 or facesProcessed == model.facesCount:
      echo $facesProcessed & "/" & $model.facesCount & " faces processed..."
  echo "Render finished."

when isMainModule:
  initApp(WINDOW_WIDTH, WINDOW_HEIGHT)
  drawToRenderBuffer()
  drawRenderBufferToWindow(buf)
  #drawZBufferToWindow(zBuffer)
  #drawRenderBufferToWindow(tex)
  waitForAppClose()
