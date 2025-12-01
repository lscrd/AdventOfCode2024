import std/[strutils, tables]

# Some optimizations are possible, for instance using a mapping of characters
# to list of patterns starting with these characters, but this make the code
# more complicated for a minimal gain.

# Cache mapping designs to number of ways to build it.
var cache = {"": 1}.toTable()

proc ways(design: string; patterns: seq[string]): int =
  ## Return the number of ways to build the given design
  ## using the given patterns.
  if design in cache: return cache[design]
  for pattern in patterns:
    if design.startsWith(pattern):
      let newDesign = design[pattern.len..^1]
      result += newDesign.ways(patterns)
  cache[design] = result

# Read patterns and designs.
var patterns, designs: seq[string]
var readPatterns = true
for line in lines("p19.data"):
  if line.len == 0:
    readPatterns = false
  elif readPatterns:
    patterns = line.split(", ")
  else:
    designs.add line


### Part 1 ###

var availableCount = 0
for design in designs:
  availableCount += ord(design.ways(patterns) != 0)
echo "Part 1: ", availableCount


### Part 2 ###

var wayCount = 0
for design in designs:
  wayCount += design.ways(patterns)
echo "Part 2: ", wayCount
