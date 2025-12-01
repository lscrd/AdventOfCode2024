import std/[sets, tables]

type
  Height = 0..9
  Position = tuple[r, c: int]
  Grid = seq[seq[Height]]

var
  grid: Grid
  startPos: seq[Position]   # Positions at height 0.
  nextPositions: Table[Position, seq[Position]]  # Mapping of positions to higher positions by one.


template toHeight(c: char): Height = ord(c) - ord('0')
template `[]`(grid: Grid; pos: Position): Height = grid[pos.r][pos.c]

iterator neighbors(grid: Grid; pos: Position): Position =
  ## Yield the neighbor positions of a position.
  let rmax = grid.high
  let cmax = grid[0].high
  for delta in [(-1, 0), (0, -1), (0, 1), (1, 0)]:
    let r = pos.r + delta[0]
    let c = pos.c + delta[1]
    if r in 0..rmax and c in 0..cmax:
      yield (r, c)

# Read data, build grid and store starting positions.
var r = 0
for line in lines("p10.data"):
  if line.len != 0:
    var row: seq[Height]
    for c, ch in line:
      row.add ch.toHeight
      if ch == '0': startPos.add (r, c)
    grid.add row
    inc r

# Build table of next positions.
for r, row in grid:
  for c, height in row:
    let pos: Position = (r, c)
    for nextPos in grid.neighbors(pos):
      if grid[nextPos] == height + 1:
        nextPositions.mgetOrPut(pos, @[]).add nextPos


### Part 1 ###

proc reachablePos(grid: Grid; pos: Position): HashSet[Position] =
  ## Return the set of positions at length 9 reachable from "pos".
  if grid[pos] == 9: return [pos].toHashSet
  if pos notin nextPositions: return
  for nextPos in nextPositions[pos]:
    result.incl grid.reachablePos(nextPos)

var scoreSum = 0
for start in startPos:
  scoreSum += grid.reachablePos(start).card
echo "Part 1: ", scoreSum


### Part 2 ###

proc pathCount(grid: Grid; pos: Position): int =
  ## Return the number of paths starting from "pos" and
  ## leading to a position at height 9.
  if grid[pos] == 9: return 1
  if pos notin nextPositions: return
  for nextPos in nextPositions[pos]:
    result += grid.pathCount(nextPos)

var ratingSum = 0
for start in startPos:
  ratingSum += grid.pathCount(start)
echo "Part 2: ", ratingSum
