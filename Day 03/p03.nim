import std/[algorithm, re, strutils]

let mulPattern = re"mul\((\d{1,3}),(\d{1,3})\)"

iterator mulOps(memory: string): tuple[pos, val: int] =
  ## Yield the position and result of the Mul instructions.
  var matches: array[2, tuple[first, last: int]]
  var start = 0
  while true:
    let(first, last) = memory.findBounds(mulPattern, matches, start)
    if first == -1: break
    let op1 = memory[matches[0].first..matches[0].last]
    let op2 = memory[matches[1].first..matches[1].last]
    yield (first, parseInt(op1) * parseInt(op2))
    start = last + 1

# Read memory (splitted in several lines).
var memory = ""
for line in lines("p03.data"):
  if line.len != 0:
    memory.add line


### Part 1 ###

var result = 0
for pos, val in memory.mulOps():
  result += val

echo "Part 1: ", result


### Part 2 ###
type
  Inst {.pure.} = enum Mul, Do, Dont
  Operation = tuple[inst: Inst; result: int]

let doPattern = re"do\(\)"
let dontPattern = re"don't\(\)"

# List of operations with their starting positions in memory.
var operations: seq[tuple[pos: int; op: Operation]]

# Add Mul operations.
for pos, val in memory.mulOps():
  operations.add (pos, (Mul, val))

# Add Do operations.
var start = 0
while true:
  let(first, last) = memory.findBounds(doPattern, start)
  if first == -1: break
  start = last + 1
  operations.add (first, (Do, 0))

# Add Dont operations.
start = 0
while true:
  let (first, last) = memory.findBounds(dontPattern, start)
  if first == -1: break
  start = last + 1
  operations.add (first, (Dont, 0))

# Sort by positions.
operations.sort()

result = 0
var active = true
for (pos, op) in operations:
  case op.inst
  of Mul:
    if active: result += op.result
  of Do:
    active = true
  of Dont:
    active = false

echo "Part 2: ", result
