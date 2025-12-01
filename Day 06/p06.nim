import std/[sets, strutils]

type
  Position = tuple[r, c: int]
  Direction {.pure.} = enum Up = "^", Right = ">", Down = "v", Left = "<"
  Grid = seq[string]

proc `[]`(grid: Grid; pos: Position): char =
  ## Return the character at given position.
  grid[pos.r][pos.c]

proc nextPosition(pos: Position; dir: Direction): Position =
  ## Return the next position in the given direction.
  const Deltas = [Up: (-1, 0), Right: (0, 1), Down: (1, 0), Left: (0, -1)]
  let (dr, dc) = Deltas[dir]
  result = (pos.r + dr, pos.c + dc)

proc nextDirection(dir: Direction): Direction =
  ## Return the new direction when turning right 90 degrees.
  result = if dir < Left: succ(dir) else: Up

iterator posdirs(grid: Grid; startPos: Position; startDir: Direction): (Position, Direction) =
  ## Yield the successive positions and directions.
  var pos = startPos
  var dir = startDir
  let rmax = grid.high
  let cmax = grid[0].high
  var leaving = false
  while not leaving:
    let nextPos = pos.nextPosition(dir)
    if grid[nextPos] == '#':
      dir = dir.nextDirection
    else:
      pos = nextPos
      if pos.r == 0 or pos.r == rmax or pos.c == 0 or pos.c == cmax:
        leaving = true
    yield (pos, dir)


# Build the grid and find starting position and direction.
var grid: Grid
var r = -1
var startPos: Position
var startDir: Direction
for line in lines("p06.data"):
  inc r
  grid.add line
  for c, ch in line:
    if ch in ['^', '>', 'v', '<']:
      startPos = (r, c)
      startDir = parseEnum[Direction]($ch)


### Part 1 ###

var visited = [startPos].toHashSet
var prevDir = startDir
for (pos, dir) in grid.posdirs(startPos, startDir):
  if dir == prevDir:
    # New position in same direction.
    visited.incl pos
  else:
    # Same position in new direction.
    prevDir = dir

echo "Part 1: ", visited.card


### Part 2 ###

proc hasLoop(grid: Grid; startPos: Position; startDir: Direction): bool =
  ## Return true if a loop has been found.
  ## There is a loop if we encounter twice a couple (position, direction).
  var history = [(startPos, startDir)].toHashSet
  for posdir in grid.posdirs(startPos, startDir):
    if posdir in history: return true
    history.incl posdir

var count = 0
for r in 0..grid.high:
  for c in 0..grid[0].high:
    if grid[r][c] == '.':
      var newGrid = grid
      newGrid[r][c] = '#'
      if newGrid.hasLoop(startPos, startDir):
        inc count

echo "Part 2: ", count
