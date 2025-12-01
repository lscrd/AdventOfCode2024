import std/[sets, strutils]

const
  Xmax = 70
  Ymax = 70

type
  Coords = tuple[x, y: int]
  State {.pure.} = enum Free, Corrupted
  Grid = array[0..XMax, array[0..YMax, State]]  # State of memory.

const
  StartPos: Coords = (0, 0)
  EndPos: Coords = (Xmax, Ymax)
  NoPath = -1         # Value returned if no path was found.
  StartCount = 1024   # Number of corrupted positions from which to start.


var
  grid: Grid              # Default initialization value is "Free".
  bytePos: seq[Coords]    # Position of corrupted bytes.

proc simulate(grid: var Grid; bytePos: seq[Coords]; n: Positive) =
  # Simulate "n" corruptions of bytes.
  var idx = 0     # Index in "bytePos".
  for _ in 1..n:
    let pos = bytePos[idx]
    grid[pos.y][pos.x] = Corrupted
    inc idx

iterator neighbors(pos: Coords): Coords =
  ## Yield the coordinates of the neighbors of "pos".
  for delta in [Coords (-1, 0), (0, -1), (0, 1), (1, 0)]:
    let x = pos.x + delta.x
    let y = pos.y + delta.y
    if x in 0..Xmax and y in 0..Ymax:
      yield (x, y)

proc minPathLen(grid: Grid): int =
  ## Return the length of the shortest path from "StartPos"
  ## to "EndPos" or "NoPath" if a path could not be found.
  var positions = @[StartPos]
  var visited = positions.toHashSet()
  while true:
    inc result
    var nextPositions: seq[Coords]      # Positions on step later.
    for pos in positions:
      for nextPos in pos.neighbors():
        if nextPos == EndPos: return    # Shortest path found.
        if nextPos notin visited and grid[nextPos.y][nextPos.x] == Free:
          nextPositions.add nextPos
          visited.incl nextPos
    positions = move nextPositions
    if positions.len == 0: return NoPath


# Read the list of coordinates of corrupted bytes.
for line in lines("p18.data"):
  if line.len > 0:
    let coords = line.split(',')
    bytePos.add (parseInt(coords[0]), parseInt(coords[1]))


### Part 1 ###

grid.simulate(bytePos, StartCount)
echo "Part 1: ", grid.minPathLen()


### Part 2 ###

var pos: Coords
for idx in StartCount..bytePos.high:    # Continue from the last configuration.
  pos = bytePos[idx]
  grid[pos.y][pos.x] = Corrupted
  if grid.minPathLen() == NoPath:
    break

echo "Part 2: ", pos.x, ',', pos.y
