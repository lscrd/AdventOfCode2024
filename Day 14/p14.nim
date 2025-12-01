import std/[math, sequtils, sets, strscans, strutils]

type
  Coords = tuple[x, y: int]
  Robot = tuple[pos, vel: Coords]

const
  Width = 101
  Height = 103

proc move(robots: var seq[Robot]) =
  ## Move all robots for one second.
  for robot in robots.mitems:
    robot.pos.x = floorMod((robot.pos.x + robot.vel.x), Width)
    robot.pos.y = floorMod((robot.pos.y + robot.vel.y), Height)

# Read robot data.
var robots: seq[Robot]
for line in lines("p14.data"):
  var pos, vel: Coords
  if line.scanf("p=$i,$i v=$i,$i", pos.x, pos.y, vel.x, vel.y):
    robots.add (pos, vel)

let initialState = robots  # Save robot state for part 2.


### Part 1 ###

for _ in 1..100:
  robots.move()

# Count number of robots in each quadrant.
const Mx = Width div 2
const My = Height div 2
var counts: array[4, int]
for robot in robots:
  if robot.pos.x != Mx and robot.pos.y != My:
    let quadrant = 2 * ord(robot.pos.x > Mx) + ord(robot.pos.y > My)
    inc counts[quadrant]

# Compute safety factor.
var safetyFactor = 1
for count in counts:
  safetyFactor *= count

echo "Part 1: ", safetyFactor


### Part 2 ###

# For part 2, we assume that when the robots are arranged in a
# picture of a Christmas tree, no robots occupy the same position.
# And actually it works!

const DisplayPicture = true

proc display(robots: seq[Robot]) =
  ## Display the area.
  var grid = newSeqWith(Height, strutils.repeat('.', Width))
  for robot in robots:
    grid[robot.pos.y][robot.pos.x] = '*'
  for row in grid:
    echo row

proc doNotOverlap(robots: var seq[Robot]): bool =
  ## Return true if no robots are at the same position.
  var posSet: HashSet[Coords]
  for robot in robots:
    if robot.pos in posSet: return
    posSet.incl robot.pos
  result = true

# Move the robots until none occupy the same position.
robots = initialState
var round = 0
while true:
  inc round
  robots.move()
  if robots.doNotOverlap():
    break

echo "Part 2: ", round

if DisplayPicture:
  echo()
  robots.display()
