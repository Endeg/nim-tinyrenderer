import tables

#TODO: better name?

type
  RenderBufferKey = tuple
    x: int
    y: int

  RenderBuffer*[P] = object
    map: Table[RenderBufferKey, P]
    width: int
    height: int

proc init*[P](width: int = 0, height: int = 0): RenderBuffer[P] =
  result.map = initTable[RenderBufferKey, P]()
  result.width = width
  result.height = height

proc set*[P](self: var RenderBuffer[P], x: int, y: int, value: P) =
  if self.width > 0 and self.height > 0 and 
      (x < 0 or x >= self.width or y < 0 or y >= self.height):
    return
  self.map[(x, y)] = value

iterator entries*[P](self: RenderBuffer[P]): (int, int, P) =
  for k, v in self.map.pairs():
    yield (k.x, k.y, v)
