import std/[math, sequtils, strutils]

type Report = seq[int]


### Part 1 ###

var reports: seq[Report]
for line in lines("p02.data"):
  if line.len > 0:
    reports.add map(line.split(' '), parseInt)

proc isSafe1(report: Report): bool =
  var diffs: seq[int]
  var prev = report[0]
  for idx in 1..report.high:
    diffs.add report[idx] - prev
    prev = report[idx]

  result = if diffs[0] > 0: allIt(diffs, it in 1..3)
           else: allIt(diffs, it in -3 .. -1)

var count = 0
for report in reports:
  count.inc ord(report.isSafe1)

echo "Part 1: ", count


### Part 2 ###

proc isSafe2(report: Report): bool =
  if report.isSafe1: return true
  for i in 0..report.high:
    var newReport = report
    newReport.delete(i)
    if newReport.isSafe1: return true

count = 0
for report in reports:
  count.inc ord(report.isSafe2)

echo "Part 2: ", count
