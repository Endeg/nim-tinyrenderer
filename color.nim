
const
    RED = 0
    GREEN = 1
    BLUE = 2
    ALPHA = 3

type
  RenderColor* = object
    comp: array[0..4, byte]

proc rgb*(r: byte, g: byte, b: byte): RenderColor =
  result.comp[RED] = r
  result.comp[GREEN] = g
  result.comp[BLUE] = b
  result.comp[ALPHA] = high(byte)

proc red*(self: RenderColor): byte = self.comp[RED]
proc green*(self: RenderColor): byte = self.comp[GREEN]
proc blue*(self: RenderColor): byte = self.comp[BLUE]
proc alpha*(self: RenderColor): byte = self.comp[ALPHA]