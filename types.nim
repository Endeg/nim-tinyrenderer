type
  #TODO: Refactor raster functions to use this type
  Vec2i* = object
    x*, y*: int

  Vert* = object
    x*, y*, z*: float
  
  Triangle* = array[3, Vert]

  Bbox* = object
    min*, max*: Vec2i

proc vec2*(x: int, y: int): Vec2i =
  result.x = x
  result.y = y

proc getBbox*(input: openArray[Vec2i]): Bbox =
  for v in input:
    if v.x < result.min.x:
      result.min.x = v.x
    if v.y < result.min.y:
      result.min.y = v.y

    if v.x > result.max.x:
      result.max.x = v.x
    if v.y > result.max.y:
      result.max.y = v.y