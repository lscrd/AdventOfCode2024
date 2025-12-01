import std/[sets, tables]

type
  Grid = seq[string]
  Position = tuple[r, c: int]
  Antennas = Table[char, seq[Position]]

# Read data.
var grid: Grid
var antennas: Antennas
var row = -1
for line in lines("p08.data"):
  if line.len != 0:
    inc row
    grid.add line
    for col, ch in line:
      if ch != '.':
        antennas.mgetOrPut(ch, @[]).add (row, col)


### Part 1 ###

proc antinodes1(grid: Grid; antennas: Antennas): HashSet[Position] =
  ## Return the list of antinodes as a HashSet using part 1 rules.
  let rmax = grid.high
  let cmax = grid[0].high
  for freq, list in antennas.pairs:
    # Process the list of antennas with frequency "freq".
    for i in 0..<list.high:
      let pos1 = list[i]
      for j in (i + 1)..list.high:
        let pos2 = list[j]
        let dr = pos2.r - pos1.r
        let dc = pos2.c - pos1.c
        let apos1: Position = (pos1.r - dr, pos1.c - dc)
        if apos1.r in 0..rmax and apos1.c in 0..cmax:
          result.incl apos1
        let apos2: Position = (pos2.r + dr, pos2.c + dc)
        if apos2.r in 0..rmax and apos2.c in 0..cmax:
          result.incl apos2

echo "Part 1: ", grid.antinodes1(antennas).card


### Part 2 ###

proc antinodes2(grid: Grid; antennas: Antennas): HashSet[Position] =
  ## Return the list of antinodes as a HashSet using part 2 rules.
  let rmax = grid.high
  let cmax = grid[0].high
  for freq, list in antennas.pairs:
    # Process the list of antennas with frequency "freq".
    for i in 0..<list.high:
      let pos1 = list[i]
      for j in (i + 1)..list.high:
        let pos2 = list[j]
        let dr = pos2.r - pos1.r
        let dc = pos2.c - pos1.c
        var apos1 = pos1
        while apos1.r in 0..rmax and apos1.c in 0..cmax:
          result.incl apos1
          dec apos1.r, dr
          dec apos1.c, dc
        var apos2 = pos2
        while apos2.r in 0..rmax and apos2.c in 0..cmax:
          result.incl apos2
          inc apos2.r, dr
          inc apos2.c, dc

echo "Part 2: ", grid.antinodes2(antennas).card
