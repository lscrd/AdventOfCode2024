import std/[strutils, tables]

type
  Position = tuple[r, c: int]
  Grid = seq[string]
  # Mapping from time saved to count of shortcuts saving this time.
  Cheats = CountTable[int]

const None: Position = (-1, -1)

proc next(grid: Grid; pos, prev: Position): Position =
  ## Return the next position which is unique as there is
  ## only one path from the start position to the end position.
  for (dr, dc) in [(-1, 0), (0, -1), (0, 1), (1, 0)]:
    result = (pos.r + dr, pos.c + dc)
    if result != prev and grid[result.r][result.c] != '#':
      return

proc findCheats(grid: Grid; path: seq[Position]; maxLength: int): Cheats =
  ## Return the table of cheats using an algorithm suited for part 1 and part 2.
  for i in 0..(path.high - 4):    # At least a gap of four between two positions.
    let pos1 = path[i]
    for j in (i + 4)..path.high:
      let pos2 = path[j]
      let dist = abs(pos1.r - pos2.r) + abs(pos1.c - pos2.c)
      if dist <= maxLength and dist < j - i:
        result.inc(j - i - dist)

proc bestSaveCount(cheats: Cheats): int =
  ## Return the number of cheats which allow to save at least 100 picoseconds.
  for save, cheatCount in cheats:
    if save >= 100:
      inc result, cheatCount

# Read data and build grid.
var grid: Grid
var startPos, endPos = None
var r = -1
for line in lines("p20.data"):
  if line.len != 0:
    inc r
    grid.add line
    if startPos == None:
      let c = line.find('S')
      if c >= 0: startPos = (r, c)
    if endPos == None:
      let c = line.find('E')
      if c >= 0: endPos = (r, c)

# Build the path from start position to end position.
var pos = startPos
var prevPos = None
var path = @[startPos]
while pos != endPos:
  let nextPos = grid.next(pos, prevPos)
  prevPos = pos
  pos = nextPos
  path.add pos

### Part 1 ###

var cheats = grid.findCheats(path, 2)
echo "Part 1: ", cheats.bestSaveCount()


### Part 2 ###

cheats = grid.findCheats(path, 20)
echo "Part 2: ", cheats.bestSaveCount()
