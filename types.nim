import basic3d

type
  #TODO: Refactor raster functions to use this type
  Vec2i* = object
    x*, y*: int

  Bbox* = object
    min*, max*: Vec2i

proc vec2*(x: int, y: int): Vec2i =
  result.x = x
  result.y = y
