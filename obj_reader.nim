import tables, strutils, parseutils, sequtils, basic2d, basic3d
import types

type
  IndexGroup = tuple
    v: int
    t: int
    n: int

  Face* = array[0..2, IndexGroup]

  Mesh* = object
    verts: seq[Point3d]
    texCoords: seq[Point2d]
    faces: seq[Face]

  Model* = object
    meshes: Table[string, Mesh]
    facesCount*: int

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

  if count >= 1 and ind[0] != "":
    result.v = readInt(ind[0]) - 1
  if count >= 2 and ind[1] != "":
    result.t = readInt(ind[1]) - 1
  if count >= 3 and ind[2] != "":
    result.n = readInt(ind[2]) - 1

proc smartSplit(input: string): seq[string] =
  result = @[]
  for elem in input.split(" "):
    let stripped = elem.strip()
    if stripped != "":
      result.add(stripped)

iterator triangles*(self: Model): array[3, Point3d] =
  for m in self.meshes.values():
    for f in m.faces:
      var tri: array[3, Point3d]
      tri[0] = m.verts[f[0].v]
      tri[1] = m.verts[f[1].v]
      tri[2] = m.verts[f[2].v]
      yield tri

proc loadObj*(fileName: string): Model =
  echo "Loading model from '" & fileName & "'..."
  result.meshes = initTable[string, Mesh]()
  result.facesCount = 0

  var
    f: File
    vertsCount = 0

  if open(f, fileName):
    try:
      var currentMeshName = "~~~scratch~~~"
      result.meshes[currentMeshName] = Mesh(verts: @[], texCoords: @[], faces: @[])
      while not f.endOfFile:
        let line = f.readLine
        let tokens = line.smartSplit()

        if tokens.len == 0:
          continue

        let command = tokens[0]

        if tokens.len == 2 and command == "o":
          let meshName = tokens[1]
          currentMeshName = meshName
          result.meshes[meshName] = Mesh(verts: @[], texCoords: @[], faces: @[])

        elif tokens.len == 4 and command == "v":
          var v: Point3d
          v.x = readFloat(tokens[1])
          v.y = readFloat(tokens[2])
          v.z = readFloat(tokens[3]) 
          result.meshes[currentMeshName].verts.add(v)
          inc vertsCount
        elif (tokens.len == 3 or tokens.len == 4) and command == "vt":
          let texCoord = point2d(readFloat(tokens[1]), readFloat(tokens[2]))
          result.meshes[currentMeshName].texCoords.add(texCoord)
        elif tokens.len >= 4 and command == "f":
          let faceElements = map(tokens[1..tokens.len - 1], extractIndexes)

          if faceElements.len < 3:
            continue
          elif faceElements.len == 3:
            var f: Face
            f[0] = faceElements[0]
            f[1] = faceElements[1]
            f[2] = faceElements[2]

            result.meshes[currentMeshName].faces.add(f)
            inc result.facesCount
          elif faceElements.len == 4:
            var f: Face
            f[0] = faceElements[0]
            f[1] = faceElements[1]
            f[2] = faceElements[3]

            result.meshes[currentMeshName].faces.add(f)
            inc result.facesCount

            f[0] = faceElements[1]
            f[1] = faceElements[2]
            f[2] = faceElements[3]

            result.meshes[currentMeshName].faces.add(f)
            inc result.facesCount
          else:
            raise newException(IOError, "Faces with more that 4 vertices not supported")
      
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
      close f
      echo "Done. Faces: " & $result.facesCount & " Vertices: " & $vertsCount
