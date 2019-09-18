isOutOfTime = function(testTimeLimit, testTimeStarted, itemTimeLimit, itemTimeFullRequired) {
  startedAgo = as.numeric(Sys.time()) - testTimeStarted
  testTimeLeft = testTimeLimit - startedAgo
  if(testTimeLimit > 0) {
    if(testTimeLeft <= 0) { return(T) }
    if(testTimeLeft < itemTimeLimit && itemTimeFullRequired) { return(T) }
  }
  return(F)
}

getBranch = function(testTimeLimit, testTimeStarted, itemTimeLimit, itemTimeFullRequired, itemNumLimit, minAccuracy, itemsAdministered, itemsNum, sem) {
  if(isOutOfTime(testTimeLimit, testTimeStarted, itemTimeLimit, itemTimeFullRequired)) {
    concerto.log("time out", "test status")
    return("stop")
  }

  if(itemNumLimit > 0 && length(itemsAdministered) >= itemNumLimit || length(itemsAdministered) >= itemsNum) {
    concerto.log("maximum items reached", "test status")
    return("stop")
  }

  if(minAccuracy != 0 && minAccuracy >= sem) {
    concerto.log("minimum accuracy", "test status")
    return("stop")
  }
  concerto.log("continue", "test status")
  return("continue")
}

.branch = getBranch(
  as.numeric(settings$testTimeLimit), 
  testTimeStarted, 
  as.numeric(settings$itemTimeLimit), 
  settings$itemTimeFullRequired == "1", 
  as.numeric(settings$itemNumLimit), 
  as.numeric(settings$minAccuracy), 
  itemsAdministered, 
  dim(items)[1], 
  sem
)
