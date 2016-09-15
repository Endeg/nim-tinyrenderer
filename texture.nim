import sdl2, sdl2/image
import render_buffer, color

proc loadTexture*(fileName: string): RenderBuffer[RenderColor] =
  let surf = load(fileName)
  try:
    if surf == nil:
      raise newException(SystemError, "Cannot load surface from '" & fileName & "'")
    if surf.lockSurface() == -1:
      raise newException(SystemError, "Cannot lock surface")

    if surf.format.BitsPerPixel == 24:
      let bitmap = cast[seq[array[3, byte]]](surf.pixels)
      result = render_buffer.init[RenderColor](rgb(0, 0, 0), surf.w, surf.h)
      for x in 0..surf.w - 1:
        for y in 0..surf.h - 1:
          let p = bitmap[x + y * surf.w]
          result.set(x, surf.h - y, rgb(p[0], p[1], p[2]))
    elif surf.format.BitsPerPixel == 32:
      raise newException(SystemError, "32-bit images not implemented yet.")
    else:
      raise newException(SystemError, "Not supported pixel format: " & $surf.format.BitsPerPixel)
      
  except:
    raise
  finally:
    surf.unlockSurface()
    surf.destroy()