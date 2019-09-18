concerto.log(user, "user")

formatFields = function(user, extraFields) {
  userId = 0
  if(!is.null(user) && !is.na(user)) { userId=user$id }
  fields = list(
    user_id=userId,
    internal_id=concerto$session$id, 
    test_id=concerto$mainTest$id,
    startedTime=Sys.time(),
    updateTime=Sys.time(),
    finished=0
  )
  if(is.list(extraFields)) {
    for(name in ls(extraFields)) {
      fields[[name]] = extraFields[[name]]
    }
  }
  return(fields)
}

getMappedColumns = function(fieldNames, tableMap) {
  cols = c()
  for(i in 1:length(fieldNames)) {
    col = tableMap$columns[[fieldNames[i]]]
    if(!is.null(col)) {
      cols=c(cols,col)
      next
    }
    cols=c(cols,fieldNames[i])
  }
  return(cols)
}

insertSession = function(fields, tableMap) {
  sqlColumns = paste(getMappedColumns(ls(fields), tableMap), collapse=",")
  sqlValues = paste0("'{{",ls(fields),"}}'", collapse=",")
  sql = paste0("INSERT INTO {{table}} (",sqlColumns,") VALUES (",sqlValues,")")
  concerto.table.query(sql, params=append(fields, list(
    table=tableMap$table
  )))
  id = concerto.table.lastInsertId()

  sql = "SELECT * FROM {{table}} WHERE {{idColumn}}={{id}}"
  session = concerto.table.query(sql, params=list(
    table=tableMap$table,
    idColumn=tableMap$columns$id,
    id=id
  ))
  if(dim(session)[1] > 0) {
    return(session[1,])
  }
  return(NULL)
}

resumeSession = function(user, tableMap) {
  if(is.null(user)) { return(NULL) }

  session = concerto.table.query("
SELECT * FROM {{table}} 
WHERE 
{{testIdColumn}} = {{testId}} AND 
{{userIdColumn}} = '{{userId}}' AND 
{{finishedColumn}} = 0 
ORDER BY id DESC", params=list(
    table=tableMap$table, 
    testIdColumn=tableMap$columns$test_id, 
    testId=concerto$mainTest$id, 
    userIdColumn=tableMap$columns$user_id, 
    userId=user$id,
    finishedColumn=tableMap$columns$finished
  ), n=1)
  if(dim(session)[1] == 0) {
    return(NULL)
  }
  
  session = as.list(session)
  session$previousInternal_id = session$internal_id
  session$internal_id = concerto$session$id

  timeLimit = as.numeric(resumableExpiration)
  if(timeLimit > 0) {
    timeDiff = as.numeric(Sys.time()) - as.numeric(strptime(session$updateTime, "%Y-%m-%d %H:%M:%S"))
    if(timeDiff > timeLimit) {
      concerto.log("session resume time limit exceeded")
      return(NULL)
    }
  }

  concerto.table.query("
UPDATE {{table}} 
SET 
{{internalIdColumn}}='{{internal_id}}', 
{{updateTimeColumn}}=CURRENT_TIMESTAMP 
WHERE id={{id}}", params=list(
    table=tableMap$table,
    internalIdColumn=tableMap$columns$internal_id,
    internal_id=concerto$session$id,
    id=session$id,
    updateTimeColumn=tableMap$columns$updateTime
  ))

  return(session)
}

fields = formatFields(user, extraFields)
concerto.log(fields, "fields")
tableMap = fromJSON(sessionBankTable)

session = NULL
if(resumable == 1) {
  session = resumeSession(user, tableMap)
  if(!is.null(session)) {
    hash = concerto.table.query("SELECT hash FROM TestSession WHERE id={{id}}", list(id=session$previousInternal_id))
    concerto.log(hash, "resuming session...")
    if(!concerto.session.unserialize(hash=hash)) {
      	session = NULL
    }
  }
}
if(is.null(session)) {
	session = insertSession(fields, tableMap)
}
concerto.log(session, "session")
