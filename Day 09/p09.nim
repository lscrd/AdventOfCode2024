import std/[sequtils, strutils]

const Free = -1

type
  BlockId = int
  Blocks = seq[BlockId]
  Position = tuple[first, last: int]

var blocks: Blocks

proc readData(filename: string): Blocks =
  ## Read data and return the list of blocks.
  var isFile = true
  var num = 0
  for c in readFile(filename).strip(leading = false):
    let size = ord(c) - ord('0')
    var val: int
    if isFile:
      val = num
      inc num
    else:
      val = Free
    result.add repeat(val, size)
    isFile = not isFile

proc lastFilePos(blocks: Blocks; before: int): Position =
  ## Return the position of last file located before "before".
  result.last = before - 1
  while blocks[result.last] == Free:
    dec result.last
  let id = blocks[result.last]
  result.first = result.last - 1
  while result.first >= 0 and blocks[result.first] == id:
    dec result.first
  inc result.first

proc checksum(blocks: Blocks): int =
  ## Return the checksum of the blocks.
  for pos, id in blocks:
    if id != Free:
      result += pos * id


### Part 1 ###

proc nextFreeIndex(blocks: Blocks; after: int): int =
  ## Return the index of the first free block after "after".
  result = after + 1
  while result < blocks.len and blocks[result] != Free:
    inc result
  if result == blocks.len: result = -1

proc move(blocks: var Blocks; filePos: var Position; freeIdx: var int) =
  ## Move the blocks of the file located at position "file Pos" into
  ## the free blocks starting at index "freeIdx".
  ## "filePos" and "freeIdx" are updated to reference the next free block
  ## and the previous file.
  var fileIdx = filePos.last
  while true:
    swap blocks[fileIdx], blocks[freeIdx]
    freeIdx = blocks.nextFreeIndex(freeIdx)
    dec fileIdx
    if freeIdx < 0 or freeIdx > fileIdx or fileIdx < filePos.first:
      break
  filePos = blocks.lastFilePos(filePos.first)

proc compact1(blocks: var Blocks) =
  ## Compact blocks using algorithm for part 1.
  var freeIdx = blocks.nextFreeIndex(0)
  var filePos = blocks.lastFilePos(blocks.len)
  while freeIdx >= 0 and freeIdx < filePos.first:
    blocks.move(filePos, freeIdx)

blocks = readData("p09.data")
blocks.compact1()

echo "Part 1: ", blocks.checksum()


### Part 2 ###

const None: Position = (-1, -1)

proc nextFreePos(blocks: Blocks; after: int; before: int): Position =
  ## Return the next position of the free blocks starting after "after"
  ## and ending before "before".
  result.first = after + 1
  while result.first < before and blocks[result.first] != Free:
    inc result.first
  if result.first >= before: return None
  result.last = result.first + 1
  while result.last < blocks.len and blocks[result.last] == Free:
    inc result.last
  dec result.last

proc filePositions(blocks: Blocks): seq[Position] =
  ## Return the list of file positions starting from the last one.
  var idx = blocks.len
  while idx > 0:
    let pos = blocks.lastFilePos(idx)
    result.add pos
    idx = pos.first

proc tryMove(blocks: var Blocks; filePos: Position) =
  ## Try to move the file at position "filePos".
  let fileSize = filePos.last - filePos.first + 1
  var freePos = blocks.nextFreePos(0, filePos.first)
  if freePos == None: return    # No possibiity.
  while fileSize > freePos.last - freePos.first + 1:
    freePos = blocks.nextFreePos(freePos.last, filePos.first)
    if freePos == None: return  # No possibility.
  # Move blocks.
  for i in 0..<fileSize:
    swap blocks[filePos.first + i], blocks[freePos.first + i]

proc compact2(blocks: var Blocks) =
  ## Compact blocks using algorithm for part 2.
  for filePos in blocks.filePositions():
    blocks.tryMove(filePos)

blocks = readData("p09.data")
blocks.compact2()
echo "Part 2: ", blocks.checksum()
