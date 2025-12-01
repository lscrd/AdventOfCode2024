import std/[sets, tables]

type
  Position = tuple[r, c: int]
  Grid = seq[string]
  Direction {.pure.} = enum North, East, South, West
  # State used to find the best paths.
  State = tuple[pos: Position; dir: Direction; score: int; path: seq[Position]]

# Displacements to apply according to the direction.
const Deltas = {North: (-1, 0), East: (0, 1), South: (1, 0), West: (0, -1)}.toTable()

proc rotatedCw(dir: Direction): Direction =
  ## Return the direction after a rotation clockwise.
  if dir == West: North else: succ(dir)

proc rotatedCCw(dir: Direction): Direction =
  ## Return the direction after a rotation counterclockwise.
  if dir == North: West else: pred(dir)

iterator neighbors(grid: Grid; pos: Position; dir: Direction):
                     tuple[pos: Position; dir: Direction; cost: int] =
  ## Yield the position and direction of the neighbors and the cost
  ## to reach them.
  for nextDir in [dir, dir.rotatedCw, dir.rotatedCCw]:
    let delta = Deltas[nextDir]
    let nextPos: Position = (pos.r + delta[0], pos.c + delta[1])
    if grid[nextPos.r][nextPos.c] != '#':
      let cost = if nextDir == dir: 1 else: 1001
      yield (nextPos, nextDir, cost)

# Read data, buid grid and find starting and ending positions.
var grid: Grid
var startPos, endPos: Position

var r = -1
for line in lines("p16.data"):
  if line.len > 0:
    inc r
    grid.add line
    for c, ch in line:
      if ch == 'E':
        endPos = (r, c)
      elif ch == 'S':
        startPos = (r, c)

# Find the best paths and the associated score.
var states: seq[State] = @[(startPos, East, 0, @[startPos])]
var bestScore = int.high
var scores = {startPos: 0}.toTable()  # Mapping of positions to best scores to reach them.
var bestPaths: seq[seq[Position]]
while states.len != 0:
  var newStates: seq[State]
  for state in states:
    for nextPos, nextDir, cost in grid.neighbors(state.pos, state.dir):
        let score = state.score + cost
        if nextPos == endPos:
          if score < bestScore:
            bestScore = score
            bestPaths.reset()
          bestPaths.add state.path & endPos
        else:
          let prevScore = scores.getOrDefault(nextPos, int.high)
          if score - 1000 <= prevScore:
            # Even if the intermediate score is 1000 higher, the final
            # score may be equal if, later, there is one less rotation.
            newStates.add (nextPos, nextDir, score, state.path & nextPos)
            # But there is no need to update the score table in this case.
            if score < prevScore: scores[nextPos] = score
  states = move newStates

### Part 1 ###

echo "Part 1: ", bestScore


### Part 2 ###

var posSet: HashSet[Position]
for path in bestPaths:
  for pos in path:
    posSet.incl pos

echo "Part 2: ", posSet.card
