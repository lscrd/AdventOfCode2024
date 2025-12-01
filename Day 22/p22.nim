import std/[math, strutils, sugar]

const N = 2000  # Nimber of random values for a buyer..

proc next(val: int): int =
  ## Return the next value of the random suite.
  result = (val shl 6 xor val) and 16777215
  result = (result shr 5 xor result) and 16777215
  result = (result shl 11 xor result) and 16777215

# Read data.
let data = collect(for line in lines("p22.data"): line.parseInt())


### Part 1 ###

var result = 0
for startVal in data:
  var val = startVal
  for _ in 1..N: val = val.next()
  result += val

echo "Part 1: ", result


### Part 2 ###

import std/[algorithm, sets, tables]

type
  Quad = array[1..4, int]         # Four sucessive change values.
  BananaCount = Table[Quad, int]  # Mapping from quadruplets to sums of bananas.
  ValueList = array[1..N, int]    # Array of N values.

# Build lists of prices and price changes.
var priceLists, changeLists: seq[ValueList]
for n, firstVal in data:
  var prevPrice = firstVal mod 10
  var prices, changes: ValueList
  var val = firstVal
  for i in 1..N:
    val = val.next()
    let price = val mod 10
    prices[i] = price
    changes[i] = price - prevPrice
    prevPrice = price
  priceLists.setLenUninit(n + 1)
  changeLists.setLenUninit(n + 1)
  priceLists[^1] = move prices
  changeLists[^1] = move changes

# Build the table giving the banana count for each quadruplet.
var bananaCount: BananaCount
for n, changeList in changeLists:
  var quad: Quad = [0, changeList[1], changeList[2], changeList[3]]
  var quadSet: HashSet[Quad]    # To keep only the first occurrence of a quadruplet.
  for i in 4..N:
    quad.rotateLeft(1)
    quad[4] = changeList[i]
    if quad notin quadSet:
      bananaCount.mgetOrput(quad, 0) += priceLists[n][i]
    quadSet.incl quad

# Find the largest number of bananas.
var best = 0
for val in bananaCount.values():
  if val > best: best = val

echo "Part 2: ", best
