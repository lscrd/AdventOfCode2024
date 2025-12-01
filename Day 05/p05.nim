import std/[sequtils, strscans, strutils, sets]

type
  Rule = (int, int)
  Rules = HashSet[Rule]
  Update = seq[int]

proc isInRightOrder(update: Update; rules: Rules): bool =
  ## Return true if the update is in right order for the given rules.
  for i in 0..<update.high:
    let page1 = update[i]
    for j in (i + 1)..update.high:
      let page2 = update[j]
      if (page2, page1) in rules:
        return false
  result = true

var rules: Rules
var updates: seq[Update]

# Read data.
var ruleSection = true
for line in lines("p05.data"):
  if line.len == 0:
    ruleSection = false
    continue
  if ruleSection:
    # Read a rule.
    var a, b: int
    if line.scanf("$i|$i", a, b):
      rules.incl (a, b)
    else:
      raise newException(ValueError, "wrong line: " & line)
  else:
    # Add an update.
    updates.add line.split(',').map(parseInt)


### Part 1 ###

var result = 0
var badUpdates: seq[Update]
for update in updates:
  if update.isInRightOrder(rules):
    result += update[update.len div 2]
  else:
    badUpdates.add update   # For part 2.

echo "Part 1: ", result


### Part 2 ###

proc fixed(update: Update; rules: Rules): Update =
  ## Return a fixed version of the update.
  result = update
  while true:
    block CheckAndUpdate:
      for i in 0..<result.high:
        let page1 = result[i]
        for j in (i + 1)..result.high:
          let page2 = result[j]
          if (page2, page1) in rules:
            swap result[i], result[j]
            break CheckAndUpdate  # Check again from start.
      return  # No modifications done. Update is now OK.

result = 0
for update in badUpdates:
  result += update.fixed(rules)[update.len div 2]

echo "Part 2: ", result
