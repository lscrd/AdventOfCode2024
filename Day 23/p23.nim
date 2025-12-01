import std/[algorithm, sequtils, sets, strscans, strutils, tables]


type
  Name = string
  CompSet = HashSet[Name]
  Connections = Table[Name, CompSet]

# Read connections.
var connections: Connections
for line in lines("p23.data"):
  var comp1, comp2: Name
  if line.scanf("$w-$w", comp1, comp2):
    connections.mgetOrPut(comp1, initHashSet[Name]()).incl comp2
    connections.mgetOrPut(comp2, initHashSet[Name]()).incl comp1


### Part 1 ###

# Find triplets.
var triplets: HashSet[CompSet]
for comp1, comps in connections:
  for comp2 in comps:
    for comp3 in comps * connections[comp2]:
      triplets.incl [comp1, comp2, comp3].toHashSet()

# Find the count of triplets where at least one member name starts with "t".
var count = 0
for triplet in triplets:
  for comp in triplet:
    if comp[0] == 't':
      inc count
      break

echo "Part 1: ", count


### Part 2 ###

var compSets: HashSet[CompSet]        # Set of sets of strongly connected computers.
for comp in connections.keys:
  compSets.incl [comp].toHashSet()    # Initialized with singletons.

# We build "compSets" by adding computers step by step.
let allComps = connections.keys.toSeq().toHashSet()
while true:
  var newCompSets: HashSet[CompSet]   # Next vaue of "compSets".
  for compSet in compSets:
    var candidates = allComps
    # The candidates must be connected with the computers already in set.
    for comp in compSet:
      candidates = candidates * connections[comp]
    for comp in candidates:           # Create a set for each new computer added.
      var newCompSet = compSet
      newCompSet.incl comp
      newCompSets.incl newCompSet
  if newCompSets.card == 0: break
  compSets = newCompSets

# Find the largest set of computers.
var largestSet: CompSet
var largestSize = 0
for compSet in compSets:
  if compSet.card > largestSize:
    largestSize = compSet.card
    largestSet = compSet

echo "Part 2: ", largestSet.toSeq().sorted().join(",")
