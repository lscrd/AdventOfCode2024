import std/[algorithm, strscans, tables]

var list1, list2: seq[int]
for line in lines("p01.data"):
  if line.len > 0:
    var val1, val2: int
    if line.scanf("$i$s$i", val1, val2):
      list1.add val1
      list2.add val2


### Part 1 ###
list1.sort()
list2.sort()
var distance = 0
for i in 0..list1.high:
  distance += abs(list1[i] - list2[i])
echo "Part 1: ", distance


### Part 2 ###
let counts2 = list2.toCountTable
var similarity = 0
for val in list1:
  inc similarity, val * counts2[val]
echo "Part 2: ", similarity
