import tables, color

#TODO: better name?

type
  RenderBuffer*[P] = object
    #TODO: Use seq[x + y * w] instead
    data: seq[P]
    width*: int
    height*: int

proc init*[P](defaultValue: P, width: int = 0, height: int = 0): RenderBuffer[P] =
  result.data = newSeq[P](width * height)
  for i in result.data.low..result.data.high:
    result.data[i] = defaultValue
  result.width = width
  result.height = height

proc set*[P](self: var RenderBuffer[P], x: int, y: int, value: P) =
  if self.width > 0 and self.height > 0 and 
      (x < 0 or x >= self.width or y < 0 or y >= self.height):
    return
  self.data[x + y * self.width] = value

iterator entries*[P](self: RenderBuffer[P]): (int, int, P) =
  for x in 0..self.width - 1:
    for y in 0..self.height - 1:
      yield (x, y, self.data[x + y * self.width])

proc get*[P](self: RenderBuffer[P], x, y: int): P =
  var
    xx = x
    yy = y
  if xx > self.width - 1:
    xx = self.width - 1
  if yy > self.height - 1:
    yy = self.height - 1
  if xx < 0:
    xx = 0
  if yy < 0:
    yy = 0
  result = self.data[xx + yy * self.width]
