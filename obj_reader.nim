import tables, strutils, parseutils, sequtils

type
  Vert* = object
    x*, y*, z*: float

  IndexGroup = tuple
    v: int
    t: int
    n: int

  Face* = array[0..2, IndexGroup]

  Mesh* = object
    verts: seq[Vert]
    faces: seq[Face]

  Model* = object
    meshes: Table[string, Mesh]

  Triangle = array[0..2, Vert]

proc readFloat(input: string): float =
  if parseFloat(input, result) == 0:
    raise newException(IOError, "Unable to parse '" & input & "' as float")

proc readInt(input: string): int =
  if parseInt(input, result) == 0:
    raise newException(IOError, "Unable to parse '" & input & "' as int")

proc extractIndexes(input: string): IndexGroup =
  let
    ind = input.split("/")
    count = ind.len

  result.v = -1
  result.t = -1
  result.n = -1

  if count >= 1:
    result.v = readInt(ind[0]) - 1
  if count >= 2:
    result.t = readInt(ind[1]) - 1
  if count >= 3:
    result.n = readInt(ind[2]) - 1

proc smartSplit(input: string): seq[string] =
  result = @[]
  for elem in input.split(" "):
    let stripped = elem.strip()
    if stripped != "":
      result.add(stripped)

iterator triangles*(self: Model): Triangle =
  for m in self.meshes.values():
    for f in m.faces:
      var tri: Triangle
      tri[0] = m.verts[f[0].v]
      tri[1] = m.verts[f[1].v]
      tri[2] = m.verts[f[2].v]
      yield tri

proc loadObj*(fileName: string): Model =
  result.meshes = initTable[string, Mesh]()

  var f: File
  if open(f, fileName):
    try:
      var currentMeshName = "~~~scratch~~~"
      result.meshes[currentMeshName] = Mesh(verts: @[], faces: @[])
      while not f.endOfFile:
        let line = f.readLine
        let tokens = line.smartSplit()

        if tokens.len == 0:
          continue

        let command = tokens[0].strip()

        if tokens.len == 2 and command == "o":
          let meshName = tokens[1]
          currentMeshName = meshName
          result.meshes[meshName] = Mesh(verts: @[], faces: @[])

        elif tokens.len == 4 and command == "v":
          var v: Vert
          v.x = readFloat(tokens[1])
          v.y = readFloat(tokens[2])
          v.z = readFloat(tokens[3]) 
          result.meshes[currentMeshName].verts.add(v)
        
        elif tokens.len >= 4 and command == "f":
          let faceElements = map(tokens[1..tokens.len - 1], extractIndexes)
          if faceElements.len > 3:
            raise newException(IOError, "Non-triangle faces not supported")

          var f: Face
          f[0] = faceElements[0]
          f[1] = faceElements[1]
          f[2] = faceElements[2]

          result.meshes[currentMeshName].faces.add(f)

        else:
          discard
          #echo "Tokens: " & $tokens

    except IOError:
      echo "IO error!"
      raise
    except:
      echo "Unknown exception!"
      raise
    finally:
      #echo "Result model: " & $result
      close f
