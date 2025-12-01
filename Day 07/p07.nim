import std/[math, strutils]

type
  Operator = enum opAdd, opMul, opConcat
  Operand = tuple[value, digits: int]
  Equation = object
    target: int
    operands: seq[Operand]

proc concat(op1, op2, op2digits: int): int =
  op1 * 10 ^ op2digits + op2

proc canBeTrue(equation: Equation; operators: openArray[Operator]): bool =
  ## Return true if the equation can be made true using the given operators.

  var values = @[equation.operands[0].value]
  for i in 1..equation.operands.high:
    var nextValues: seq[int]
    for val in values:
      for operator in operators:
        let nextVal = case operator
                      of opAdd:
                        val + equation.operands[i].value
                      of opMul:
                        val * equation.operands[i].value
                      of opConcat:
                        let op2 = equation.operands[i]
                        concat(val, op2.value, op2.digits)
        if nextVal <= equation.target:
          nextValues.add nextVal
    if nextValues.len == 0: return    # Impossible.
    values = move nextValues

  for val in values:
    if val == equation.target:
      return true   # Found at least one solution.


# Read equations.
var equations: seq[Equation]
for line in lines("p07.data"):
  var equation: Equation
  if line.len != 0:
    let fields = line.split(": ")
    equation.target = parseInt(fields[0])
    for str in fields[1].split(' '):
      equation.operands.add (parseInt(str), str.len)
    equations.add equation


### Part 1 ###
var result = 0
for equation in equations:
  if equation.canBeTrue([opAdd, opMul]):
    result += equation.target

echo "Part 1: ", result


### Part 2 ###

result = 0
for equation in equations:
  if equation.canBeTrue([opAdd, opMul, opConcat]):
    result += equation.target

echo "Part 2: ", result
