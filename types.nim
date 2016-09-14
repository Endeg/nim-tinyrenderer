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
