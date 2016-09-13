import sdl2, sdl2/image
import render_buffer, color

var
  buf = render_buffer.init[RenderColor]()

when isMainModule:
  discard