import tables, strutils

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
  result.meshes = initTable[string, Mesh]()

  var f: File
  if open(f, fileName):
    try:
      var currentMeshName = ""
      while not f.endOfFile:
        let line = f.readLine

        let tokens = line.split(" ")

        if tokens.len == 0:
          continue

        let command = tokens[0]

        if tokens.len == 2 and command == "o":
          let meshName = tokens[1]
          currentMeshName = meshName
          result.meshes[meshName] = Mesh(verts: @[], faces: @[])
          continue

        if currentMeshName != "" and tokens.len == 4 and command == "v":
          echo currentMeshName & ": " & line
          continue

    except IOError:
      echo "IO error!"
      raise
    except:
      echo "Unknown exception!"
      raise
    finally:
      close f