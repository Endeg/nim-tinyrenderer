import basic2d, basic3d

type
  #TODO: Refactor raster functions to use this type
  Vec2i* = object
    x*, y*: int

  Bbox* = object
    min*, max*: Vec2i

  VertexShader* = proc (v: Point3d): Point3d

proc vec2*(x: int, y: int): Vec2i =
  result.x = x
  result.y = y
