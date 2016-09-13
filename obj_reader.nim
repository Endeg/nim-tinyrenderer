import tables

type
  Vert* = object
    x, y, z: float
  
  Face* = array[0..2, int]

  Mesh* = object
    verts: seq[Vert]
    faces: seq[Face]

  Model* = object
    meshes: Table[string, Mesh]

proc loadObj*(fileName: string): Model =
  var f: File
  if open(f, fileName):
    try:
      while not f.endOfFile:
        let line = f.readLine
        echo line
    except IOError:
      echo "IO error!"
      raise
    except:
      echo "Unknown exception!"
      raise
    finally:
      close f