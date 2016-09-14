import types, basic3d

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
    side1 = tri[0] - tri[1]
    side2 = tri[0] - tri[2]

  var
    vec1 = vector3d(side1.x, side1.y, side1.z)
    vec2 = vector3d(side2.x, side2.y, side2.z)

  result = cross(vec1, vec2)
  if result.len != 0.0:
    result.normalize()
