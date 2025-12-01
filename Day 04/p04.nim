import std/[algorithm, strutils]

type Grid = seq[string]


### Part 1 ###

proc horizontalCount(grid: Grid; word: string): int =
  ## Return the number of occurrences of the word in the rows
  ## of the grid either in direct order or in reverse order.
  let revWord = word.reversed.join()
  for row in grid:
    result += row.count(word, overlapping = true) + row.count(revWord, overlapping = true)

proc verticalCount(grid: Grid; word: string): int =
  ## Return the number of occurrences of the word in the columns
  ## of the grid either in direct order or in reverse order.
  let revWord = word.reversed.join()
  for c in 0..grid[0].high:
    var col = ""
    for r in 0..grid.high:
      col.add grid[r][c]
    result += col.count(word, overlapping = true) + col.count(revWord, overlapping = true)

proc diagonal1Count(grid: Grid; word: string): int =
  ## Return the number of occurrences of the word in the top left to bottom
  ## right diagonals of the grid either in direct order or in reverse order.
  let revWord = word.reversed.join()
  var start = (r: grid.len - word.len, c: 0)
  while start.c != grid[0].len - word.len:
    # Build a diagonal.
    var diag = ""
    var (r, c) = start
    while r < grid.len and c < grid[0].len:
      diag.add grid[r][c]
      inc r
      inc c
    result += diag.count(word, overlapping = true) + diag.count(revWord, overlapping = true)
    if start.r != 0:
      dec start.r
    else:
      inc start.c

proc diagonal2Count(grid: Grid; word: string): int =
  ## Return the number of occurrences of the word in the top right to bottom
  ## left diagonals of the grid either in direct order or in reverse order.
  let revWord = word.reversed.join()
  var start = (r: 0, c: word.high)
  while start.r != grid.len - word.len:
    # Build a diagonal.
    var diag = ""
    var (r, c) = start
    while r < grid.len and c >= 0:
      diag.add grid[r][c]
      inc r
      dec c
    result += diag.count(word, overlapping = true) + diag.count(revWord, overlapping = true)
    if start.c != grid[0].high:
      inc start.c
    else:
      inc start.r

proc count(grid: Grid; word: string): int =
  ## Return the number of occurrences of the word in the grid
  ## whatever the direction and the order.
  result = grid.horizontalCount(word) + grid.verticalCount(word) +
           grid.diagonal1Count(word) + grid.diagonal2Count(word)


var grid: Grid
for line in lines("p04.data"):
  if line.len > 0:
    grid.add line

echo "Part 1: ", grid.count("XMAS")


### Part 2 ###

proc hasXMas(grid: Grid; r, c: int): bool =
  ## Return true if an X-MAS is present at given position.
  let c1 = grid[r-1][c-1]
  let c2 = grid[r-1][c+1]
  let c3 = grid[r+1][c-1]
  let c4 = grid[r+1][c+1]
  let b1 = c1 == 'M' and c4 == 'S'
  let b2 = c1 == 'S' and c4 == 'M'
  let b3 = c2 == 'M' and c3 == 'S'
  let b4 = c2 == 'S' and c3 == 'M'
  result = (b1 or b2) and (b3 or b4)


var result = 0
for r in 1..<grid.high:
  for c in 1..<grid[0].high:
    if grid[r][c] == 'A':
      if grid.hasXMas(r, c):
        inc result

echo "Part 2: ", result
