import tables

#TODO: better name?

type
  RenderBufferKey = tuple
    x: int
    y: int

  RenderBuffer*[P] = object
    map: Table[RenderBufferKey, P]

proc init*[P](): RenderBuffer[P] =
  result.map = initTable[RenderBufferKey, P]
