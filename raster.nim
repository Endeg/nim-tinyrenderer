import render_buffer, color, types, algorithm, geometry, sequtils, basic2d, basic3d

template line*[P](self: var RenderBuffer[P],
                  x0: int, y0: int,
                  x1: int, y1: int,
                  col: P) =
  var
    steep = false
    xx0 = x0
    xx1 = x1
    yy0 = y0
    yy1 = y1

  if abs(x0 - x1) < abs(y0 - y1):
    swap(xx0, yy0)
    swap(xx1, yy1)
    steep = true
               
  if xx0 > xx1:
    swap(xx0, xx1)
    swap(yy0, yy1)

  for x in xx0..xx1:
    let t = float(x - xx0) / float(xx1 - xx0)
    let y = int(float(yy0) * (1.0 - t) + float(yy1) * t)
    if steep:
      self.set(y, x, col)
    else:
      self.set(x, y, col)

template line*[P](self: var RenderBuffer[P],
                  vs: array[2, Vec2i],
                  col: P) =
  self.line(vs[0].x, vs[0].y, vs[1].x, vs[1].y, col)

template line*[P](self: var RenderBuffer[P],
                  x0: float, y0: float,
                  x1: float, y1: float,
                  col: P) =
  self.line(int(x0), int(y0), int(x1), int(y1), col)

template triangle*(target: var RenderBuffer[RenderColor],
                   zBuffer: var RenderBuffer[float],
                   texture: RenderBuffer[RenderColor],
                   vs: VertexShader,
                   worldCoords: array[3, Point3d],
                   textureCoords: array[3, Point2d],
                   col: RenderColor = rgb(255, 255, 255)) =
  var
    transformedCoords: array[3, Point3d]
    screenCoords: array[3, Vec2i]
    transformedVectors: array[3, Vector2d]
  
  for i in worldCoords.low..worldCoords.high:
    transformedCoords[i] = vs(worldCoords[i])
    screenCoords[i].x = int(transformedCoords[i].x)
    screenCoords[i].y = int(transformedCoords[i].y)

    transformedVectors[i].x = transformedCoords[i].x
    transformedVectors[i].y = transformedCoords[i].y

  let bb = getBbox(screenCoords)

  for x in bb.min.x..bb.max.x:
    for y in bb.min.y..bb.max.y:
      let
        p = vector2d(float(x), float(y))
        bcScreen = barycentric(transformedVectors, p)
      if bcScreen.x < 0.0 or bcScreen.y < 0.0 or bcScreen.z < 0.0:
        continue
      var
        z = 0.0
      z = z + worldCoords[0].z * bcScreen.x
      z = z + worldCoords[1].z * bcScreen.y
      z = z + worldCoords[2].z * bcScreen.z

      let
        u = bcScreen.x * (textureCoords[0].x + textureCoords[1].x + textureCoords[2].x) / 3.0
        v = bcScreen.y * (textureCoords[0].y + textureCoords[1].y + textureCoords[2].y) / 3.0
      
      #echo "bcScreen: " & $bcScreen.x & "|" & $bcScreen.y & "|" & $bcScreen.z & " uv: " & $u & "|" & $v

      let texCol = texture.get(u, v)

      if zBuffer.get(x, y) < z:
        zBuffer.set(x, y, z)
        target.set(x, y, col)
        #target.set(x, y, texCol)
        #target.set(x, y, rgb(clamp(texCol.red + col.red, 0, 255),
        #                   clamp(texCol.green + col.green, 0, 255),
        #                   clamp(texCol.blue + col.blue, 0, 255)))

  when defined(debug):
    target.line([vs[0], vs[1]], rgb(0, 255, 0))
    target.line([vs[1], vs[2]], rgb(0, 255, 0))
    target.line([vs[2], vs[0]], rgb(255, 0, 0))
