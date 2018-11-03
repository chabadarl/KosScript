
until false {
if addons:TR:available {
  print "Yes trajectories works" at (5,5).
  if addons:TR:hasimpact print "the impact will be there :" at (5,6).
  if addons:TR:hasimpact print addons:TR:impactPos at (5,7).
}
clearscreen.
}
