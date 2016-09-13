import tables, strutils, parseutils

type
  Vert* = object
    x, y, z: float

  Face* = array[0..2, int]

  Mesh* = object
    verts: seq[Vert]
    faces: seq[Face]

  Model* = object
    meshes: Table[string, Mesh]

proc readFloat(input: string): float =
  if parseFloat(input, result) == 0:
    raise newException(IOError, "Unable to parse '" & input & "' as float")

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
          var v: Vert
          v.x = readFloat(tokens[1])
          v.y = readFloat(tokens[2])
          v.z = readFloat(tokens[3]) 
          result.meshes[currentMeshName].verts.add(v)
          continue
        
        if currentMeshName != "" and tokens.len >= 4 and command == "f":
          continue

    except IOError:
      echo "IO error!"
      raise
    except:
      echo "Unknown exception!"
      raise
    finally:
      close f
