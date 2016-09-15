import types, basic2d, basic3d

proc getBbox*(input: openArray[Vec2i]): Bbox =
  #lack of this initial values can create funky results
  result.min.x = high(int)
  result.min.y = high(int)
  result.max.x = low(int)
  result.max.y = low(int)
  for v in input:
    if v.x < result.min.x:
      result.min.x = v.x
    if v.y < result.min.y:
      result.min.y = v.y

    if v.x > result.max.x:
      result.max.x = v.x
    if v.y > result.max.y:
      result.max.y = v.y

proc sign(p: Vec2i, line: array[2, Vec2i]): int =
  result = (p.x - line[1].x) * (line[0].y - line[1].y) - 
           (line[0].x - line[1].x) * (p.y - line[1].y)

proc pointInTriangle*(p: Vec2i, tri: array[3, Vec2i]): bool =
  let
    b1 = sign(p, [tri[0], tri[1]]) < 0
    b2 = sign(p, [tri[1], tri[2]]) < 0
    b3 = sign(p, [tri[2], tri[0]]) < 0

  result = (b1 == b2) and (b2 == b3)

proc normal*(tri: Triangle): Vector3d =
  let
    u = tri[1] - tri[0]
    v = tri[2] - tri[1]

  var
    vecU = vector3d(u.x, u.y, u.z)
    vecV = vector3d(v.x, v.y, v.z)

  result = cross(vecV, vecU)
  if result.len != 0.0:
    result.normalize()

proc barycentric*(vsf: array[3, Vector2d], p: Vector2d): Vector3d =
  var
    s: array[2, Vector3d]

  s[1].x = vsf[2].y - vsf[0].y
  s[1].y = vsf[1].y - vsf[0].y
  s[1].z = vsf[0].y - p.y

  s[0].x = vsf[2].x - vsf[0].x
  s[0].y = vsf[1].x - vsf[0].x
  s[0].z = vsf[0].x - p.x
  
  let u = cross(s[0], s[1])
  if (abs(u.z) > 1e-2):
    result.x = 1.0 - (u.x + u.y) / u.z
    result.y = u.y / u.z
    result.z = u.x / u.z
  else:
    result.x = -1
    result.y = 1
    result.y = 1
