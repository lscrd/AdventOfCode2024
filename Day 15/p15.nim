import std/strutils

type
  Position = tuple[r, c: int]
  Grid = seq[string]
  Direction {.pure.} = enum Up = "^", Down = "v", Left = "<", Right = ">"

const Deltas: array[Direction, Position] = [(-1, 0), (1, 0), (0, -1), (0, 1)]

template `[]`(grid: Grid; pos: Position): char = grid[pos.r][pos.c]
template `[]=`(grid: Grid; pos: Position; ch: char) = grid[pos.r][pos.c] = ch
template `+`(pos, delta: Position): Position = (pos.r + delta.r, pos.c + delta.c)

proc moveSmallBoxes(grid: var Grid; dir: Direction; pos: Position): bool =
  ## Move small boxes in direction "dir" starting at position "pos".
  let delta = Deltas[dir]
  var nextPos = pos
  while true:
    nextPos = nextPos + delta
    case grid[nextPos]
    of '#':
      return false
    of '.':
      grid[nextPos] = 'O'
      grid[pos] = '.'
      return true
    of 'O':
      continue
    else:
      quit "Wrong value", QuitFailure

proc moveWihSmallBoxes(grid: var Grid; dir: Direction; pos: var Position) =
  ## Move the robot in direction "dir" starting from position "pos", using
  ## the algorithm for small boxes.
  let nextPos = pos + Deltas[dir]
  let ch = grid[nextPos]
  if ch == '#': return
  if ch == 'O':
    if not grid.moveSmallBoxes(dir, nextPos):
      return
  grid[pos] = '.'
  grid[nextPos] = '@'
  pos = nextPos

proc canBeMoved(grid: Grid; dir: Direction; pos: Position): bool =
  ## Recursivley check if a wide box can be moved.
  let delta = Deltas[dir]
  let ch = grid[pos]
  case ch
  of '#':
    return false
  of '.':
    return true
  of '[', ']':
    if dir == Left or dir == Right:
      return grid.canBeMoved(dir, pos + delta)
    let next = pos + (if ch == '[': Deltas[Right] else: Deltas[Left])
    return grid.canBeMoved(dir, pos + delta) and grid.canBeMoved(dir, next + delta)
  else:
    discard

proc doMove(grid: var Grid; dir: Direction; pos: Position; prev: char) =
  ## Actually recursively move a wide box.
  let delta = Deltas[dir]
  let ch = grid[pos]
  grid[pos] = prev
  if ch == '[' or ch == ']':
    grid.doMove(dir, pos + delta, ch)
    if dir == Up or dir == Down:
      var nextPos: Position
      var nextCh: char
      if ch == '[':
        nextPos = pos + Deltas[Right]
        nextCh = ']'
      else:
        nextPos = pos + Deltas[Left]
        nextCh = '['
      grid[nextPos] = '.'
      grid.doMove(dir, nextPos + delta, nextCh)

proc moveWideBoxes(grid: var Grid; dir: Direction; pos: Position): bool =
  ## Move wide boxes in direction "dir" starting at position "pos".
  result = grid.canBeMoved(dir, pos)
  if result: grid.doMove(dir, pos, '@')

proc moveWithWideBoxes(grid: var Grid; dir: Direction; pos: var Position) =
  ## Move the robot in direction "dir" starting from position "pos", using
  ## the algorithm for wide boxes.
  let nextPos = pos + Deltas[dir]
  let ch = grid[nextPos]
  if ch == '#': return
  if ch == '[' or ch == ']':
    if not grid.moveWideBoxes(dir, nextPos):
      return
  # Robot can move. Do it.
  grid[pos] = '.'
  grid[nextPos] = '@'
  pos = nextPos

proc display(grid: Grid) {.used.} =
  ## Display the grid.
  for row in grid:
    echo row


### Part 1 ###

# Read data, build grid and build list of moves.
var grid: Grid
var dirs: seq[Direction]
var startPos: Position
var rnum = -1
for line in lines("p15.data"):
  if line.len == 0: continue
  inc rnum
  if line.startswith('#'):
    # Add a row to the grid.
    grid.add line
    let idx = line.find('@')
    if idx >= 0: startPos = (rnum, idx)
  else:
    # Parse the line and update the list of moves.
    for ch in line:
      dirs.add parseEnum[Direction]($ch)

let gridRef = grid    # make a copy for part 2.

# Apply the list of moves.
var pos = startPos
for dir in dirs:
  grid.moveWihSmallBoxes(dir, pos)

# Compute the sum of GPS coordinates of boxes.
var result = 0
for r, row in grid:
  for c, ch in row:
    if ch == 'O':
      result += 100 * r + c

echo "Part 1: ", result


### Part 2 ###

# Build the grid with wide boxes.
grid.reset()
for r, row in gridRef:
  var newRow: string
  for ch in row:
    case ch
    of '.': newRow.add ".."
    of '@': newRow.add "@."
    of '#': newRow.add "##"
    of 'O': newRow.add "[]"
    else: quit "Wrong character", QuitFailure
  let idx = newRow.find('@')
  if idx >= 0: startPos = (r, idx)
  grid.add newRow

# Apply the list of moves.
pos = startPos
for dir in dirs:
  grid.moveWithWideBoxes(dir, pos)

# Compute the sum of GPS coordinates of boxes.
result = 0
for r, row in grid:
  for c, ch in row:
    if ch == '[':
      result += 100 * r + c
echo "Part 2: ", result
