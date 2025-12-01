import std/[math, sequtils, strscans, strutils]

type
  OpCode = enum opAdv, opBxl, opBst, opJnz, opBxc, opOut, opBdv, opCdv
  Value = 0..7
  Register = 'A'..'C'
  Instruction = tuple[opCode: OpCode, operand: Value]
  Computer = object
    mem: seq[Instruction]
    regs: array[Register, int]
    pc: int

var computer: Computer
var program: seq[int]       # Copy of the program (for part 2).

for line in lines("p17.data"):
  var reg: char
  var val: int
  if line.scanf("Register $c: $i", reg, val):
    computer.regs[reg] = val
  elif line.startsWith("Program: "):
    let words = line[9..^1].split(',')
    program = words.map(parseInt)
    var opCode = true
    var inst: Instruction
    for val in program:
      if opCode:
        inst.opCode = OpCode(val)
      else:
        inst.operand = val
        computer.mem.add inst
      opCode = not opCode


proc comboOperandValue(comp: Computer; opVal: Value): int =
  ## return the value of a combo operand.
  result = case opVal
           of 0..3: int(opVal)
           of 4: comp.regs['A']
           of 5: comp.regs['B']
           of 6: comp.regs['C']
           of 7: raise newException(ValueError, "Wrong value")

proc run(comp: var Computer): seq[int] =
  ## Run the computer and return the result as a sequence of integers.
  comp.pc = 0
  while comp.pc <= comp.mem.high:
    let inst = comp.mem[comp.pc]
    case inst.opCode
    of opAdv:
      comp.regs['A'] = comp.regs['A'] div (2 ^ comp.comboOperandValue(inst.operand))
    of opBxl:
      comp.regs['B'] = comp.regs['B'] xor inst.operand
    of opBst:
      comp.regs['B'] = comp.comboOperandValue(inst.operand) and 7
    of opJnz:
      if comp.regs['A'] != 0:
        comp.pc = inst.operand div 2    # We manage instructions rather then words of 3 bits.
        continue
    of opBxc:
      comp.regs['B'] = comp.regs['B'] xor comp.regs['C']
    of opOut:
      result.add comp.comboOperandValue(inst.operand) and 7
    of opBdv:
      comp.regs['B'] = comp.regs['A'] div (2 ^ comp.comboOperandValue(inst.operand))
    of opCdv:
      comp.regs['C'] = comp.regs['A'] div (2 ^ comp.comboOperandValue(inst.operand))
    inc comp.pc


### Part 1 ###

echo "Part 1: ", computer.run().join(",")


### Part 2 ###

proc run(comp: var Computer; regA: int; expected: seq[int]): bool {.used.} =
  ## This is the general procedure which works for the example given
  ## in the task description, but not usable for the actual program
  ## which deals with very big values.
  comp.regs['A'] = regA
  comp.regs['B'] = 0
  comp.regs['C'] = 0
  comp.pc = 0
  var idx = -1    # Index in 'expected".
  while comp.pc <= comp.mem.high:
    let inst = comp.mem[comp.pc]
    case inst.opCode
    of opAdv:
      comp.regs['A'] = comp.regs['A'] div (2 ^ comp.comboOperandValue(inst.operand))
    of opBxl:
      comp.regs['B'] = comp.regs['B'] xor inst.operand
    of opBst:
      comp.regs['B'] = comp.comboOperandValue(inst.operand) and 7
    of opJnz:
      if comp.regs['A'] != 0:
        comp.pc = inst.operand div 2    # We manage instructions rather then words of 3 bits.
        continue
    of opBxc:
      comp.regs['B'] = comp.regs['B'] xor comp.regs['C']
    of opOut:
      inc idx
      if idx == expected.len: return false    # Too much values.
      let val =comp.comboOperandValue(inst.operand) and 7
      if val != expected[idx]: return false   # Wrong value.
    of opBdv:
      comp.regs['B'] = comp.regs['A'] div (2 ^ comp.comboOperandValue(inst.operand))
    of opCdv:
      comp.regs['C'] = comp.regs['A'] div (2 ^ comp.comboOperandValue(inst.operand))
    inc comp.pc
  if idx != expected.high: return false   # Missing values.
  result = true

when false:
  # Code to use with sample program.
  var val = 0
  while true:
    if computer.run(val, program):
      break
    inc val

  echo "Part 2: ", val

# For the actual program, there is no way to get the result using the general procedure.
# Looking at the result produced by the program for successive values of register A,
# it appears first that the number of values produced depends on the initial value of A
# according to the following rule: one value for A in 0..7, two values for A in 8..63,
# three values for A in 64..511, etc. So to get 16 values, the value of A must be at least
# 8^16.
# A more detailed observation shows that for a given number of results,values are grouped
# in blocks starting from the left. So, toget the last expected value, we have to start at
# some offset from 8^16, multiple of 8^15, but, unfortunately, there may exist several
# possible offsets.
# To find the offsets, we check the successive results against the expected value, starting
# from the last one.
# Using this method, we get a sorted list of the values of A which will produce the expected
# values starting from the second one. The first value cannot be obtained this way and we
# have to do a final pass to keep only the first value producing the expected result.

proc run(computer:var Computer; regA: int): seq[int] =
  ## Run the computer with given value for register A and zero
  ## for registers B and C.
  computer.regs['A'] = regA
  computer.regs['B'] = 0
  computer.regs['C'] = 0
  result = computer.run()

# Find the candidates values.
var p = program.high    # Exponent to use at each step (starting from 15 to produce 16 values).
var idx = p             # Index of the result to check (we start from the last one).
var values = @[0]       # Current values at each step.
while idx >= 0:
  var newValues = values                      # Values computed for next step.
  for value in values:
    var newValue = value
    for n in 0..7:                            # We will add from 0 to 7 times "8^p".
      if newValue != 0 or n != 0:             # Skip this at the very beginning.
        let val = computer.run(newValue)
        if val[idx..^1] == program[idx..^1]:
          # Results form "idx" to last index are as expected.
          newValues.add newValue
      newValue += 8^p
  values = move newValues   # Prepare values for next step.
  dec p
  dec idx

# Keep only the first value producing the expected result.
var firstVal: int
for val in values:
  let result = computer.run(val)
  if result[0] == program[0]:     # Need only to check the first value of the result.
    firstVal = val
    break

echo "Part 2: ", firstVal
