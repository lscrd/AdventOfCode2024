import std/[algorithm, tables]

type
  Position = tuple[r, c: int]
  Plot = ref object
    pos: Position
    plant: char
    region: Region
  Region = ref object
    plant: char
    plots: seq[Plot]
    area: int
    perimeter: int
    sides: int
  Regions = seq[Region]
  Garden = seq[seq[Plot]]


iterator neighbors(garden: Garden; pos: Position): Position =
  ## Yield the neighbor positions of a position.
  let rmax = garden.high
  let cmax = garden[0].high
  for deltas in [(-1, 0), (0, -1), (0, 1), (1, 0)]:
    let r = pos.r + deltas[0]
    let c = pos.c + deltas[1]
    if r in 0..rmax and c in 0..cmax:
      yield (r, c)

iterator neighbors(garden: Garden; plot: Plot): Plot =
  ## Yield the neighbor plots of a plot.
  for neighborPos in garden.neighbors(plot.pos):
    yield garden[neighborPos.r][neighborPos.c]

proc updateRegion(garden: Garden; region: Region; plot: Plot) =
  ## Update recursively a region starting from given plot.
  plot.region = region
  region.plots.add plot
  for neighbor in garden.neighbors(plot):
    if neighbor.plant == region.plant and neighbor.region == nil:
      # With the right plant and not yet in the region: add it.
      garden.updateRegion(region, neighbor)

proc buildRegions(garden: var Garden): Regions =
  ## Build the list of regions.
  for row in garden:
    for plot in row:
      if plot.region == nil:
        ## Found a plot without region. Use it as the starting plot.
        let region = Region(plant: plot.plant)
        garden.updateRegion(region, plot)
        result.add region

# Read data and build the garden and the plots representations.
var garden: Garden
var r = 0
for line in lines("p12.data"):
  var row: seq[Plot]
  if line.len != 0:
    for c, plant in line:
      let plot = Plot(pos: (r, c), plant: plant, region: nil)
      row.add plot
    garden.add row
  inc r

let regions = garden.buildRegions()


### Part 1 ###

proc computeAreaAndPerimeters(garden: Garden; regions: Regions) =
  ## Compute the areas and the perimeters of the regions.
  for region in regions:
    region.area = region.plots.len
    for plot in region.plots:
      var count = 4   # Starting with four potential sides.
      for neighbor in garden.neighbors(plot):
        if neighbor.region == region:
          dec count   # Eliminate a neighbor.
      inc region.perimeter, count

garden.computeAreaAndPerimeters(regions)

var price = 0
for region in regions:
  inc price, region.area * region.perimeter

echo "Part 1: ", price


### Part 2 ###

# Mapping of plot rows/columns to list of plot columns/rows.
# Used to find the number of sides in a region.
type SideTable = Table[int, seq[int]]

proc sideCount(table: var SideTable): int =
  ## Compute the side count from a side table.
  for vals in table.mvalues():
    vals.sort()             # Row or column number must be in ascending order.
    var last = -2           # Set to a value to create the first side.
    for val in vals:
      if val != last + 1:   # Start of a new side.
        inc result
      last = val

proc computeSideCounts(garden: Garden; regions: Regions) =
  ## Compute the side counts of the regions.
  let rmax = garden.high
  let cmax = garden[0].high
  for region in regions:
    var up, down, left, right: SideTable
    for plot in region.plots:
      let (row, col) = plot.pos
      if row == 0 or garden[row - 1][col].region != region:
        up.mgetOrPut(row, @[]).add col
      if row == rmax or garden[row + 1][col].region != region:
        down.mgetOrPut(row, @[]).add col
      if col == 0 or garden[row][col - 1].region != region:
        left.mgetOrPut(col, @[]).add row
      if col == cmax or garden[row][col + 1].region != region:
        right.mgetOrPut(col, @[]).add row
    region.sides = up.sideCount + down.sideCount + left.sideCount + right.sideCount

garden.computeSideCounts(regions)

price = 0
for region in regions:
  inc price, region.area * region.sides

echo "Part 2: ", price
