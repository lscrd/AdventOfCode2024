import std/strscans

type
  Position = tuple[x, y: int]
  Delta = tuple[x, y: int]
  Machine = object
    buttonA: Delta
    buttonB: Delta
    prize: Position

const NoSolution = (-1, -1)

proc pushCounts(machine: Machine): tuple[a, b: int] =
  ## Return the count of pushes of A and B buttons to get the prize
  ## if this is possible or else return NoSolution.
  ## Solution is found by solving a system of two equations with two unknowns.
  let denom = machine.buttonA.x * machine.buttonB.y - machine.buttonA.y * machine.buttonB.x
  let num1 = machine.buttonB.y * machine.prize.x - machine.buttonB.x * machine.prize.y
  let num2 = machine.buttonA.x * machine.prize.y - machine.buttonA.y * machine.prize.x
  if num1 mod denom != 0 or num2 mod denom != 0: return NoSolution
  result = (num1 div denom, num2 div denom)

proc cost(machines: seq[Machine]): int =
  ## Return the total of cost (number of tokens) to use for the given machines.
  for machine in machines:
    let counts = machine.pushCounts()
    if counts != NoSolution:
      result += 3 * counts.a + counts.b

var machines: seq[Machine]

## Read data and build the Machine objects.
var machine: Machine
for line in lines("p13.data"):
  if line.len != 0:
    var button: char
    var delta: Delta
    var pos: Position
    if line.scanf("Button $c: X+$i, Y+$i", button, delta.x, delta.y):
      if button == 'A': machine = Machine(buttonA: delta)
      elif button == 'B': machine.buttonB = delta
      else: quit "Wrong button", QuitFailure
    elif line.scanf("Prize: X=$i, Y=$i", pos.x, pos.y):
      machine.prize = pos
      machines.add machine


### Part 1 ###

echo "Part 1: ", machines.cost()


### Part 2 ###

# Modify the prize positions.
for machine in machines.mitems:
  machine.prize.x += 10000000000000
  machine.prize.y += 10000000000000

echo "Part 2: ", machines.cost()
