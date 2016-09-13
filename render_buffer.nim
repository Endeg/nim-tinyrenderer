import tables

#TODO: better name?

type
  RenderBufferKey = tuple
    x: int
    y: int

  RenderBuffer*[P] = object
    map: Table[RenderBufferKey, P]

proc init*[P](): RenderBuffer[P] =
  result.map = initTable[RenderBufferKey, P]()

iterator entries*[P](self: RenderBuffer[P]): (int, int, P) =
  for k, v in self.map.pairs():
    yield (k.x, k.y, v)