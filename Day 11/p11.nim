import std/[math, sequtils, strutils, tables]

# As, in fact the order of stones in the line doesn't matter, we use a table.
# The stones are identified by their integer value. Identifying them by their
# string representation is significantly less efficient.

type Stones = CountTable[int]

var stones = readFile("p11.data").strip(leading = false).split(' ').map(parseInt).toCountTable

template isEven(n: int): bool = (n and 1) == 0

proc digitCount(n: int): int =
  ## Return the number of digits of "n".
  if n == 0: return 1
  var n = n
  while n != 0:
    n = n div 10
    inc result

proc doRound(stones: Stones): Stones =
  ## Run one round of the simulation.
  for stone, count in stones:
    if stone == 0:
      result.inc(1, count)
    else:
      let strlen = stone.digitCount
      if strlen.isEven:
        let d = 10 ^ (strlen div 2)
        result.inc(stone div d, count)
        result.inc(stone mod d, count)
      else:
        result.inc(stone * 2024, count)

proc simulate(stones: Stones; rounds: Positive): int =
  ## Simulate "rounds" rounds and return the final number of stones.
  var stones = stones
  for _ in 1..rounds:
    stones = stones.doRound()
  for count in stones.values:
    result += count


### Part 1 ###

echo "Part 1: ", stones.simulate(25)


### Part 2 ###

echo "Part 2: ", stones.simulate(75)
