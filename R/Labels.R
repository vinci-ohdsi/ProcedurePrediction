##' Create the labels of included persons
##'
##' Writes table to study database
##' @title createLabels
##' @param x state
##' @return Modified copy of state with metadata about labels (outcomes)
##' @author William J. O'Brien
##' @export
createLabels <- function(x) {

  checkmate::assertClass(x, "ProcedurePrediction")

  x$settings$predictionInterval <- paste0("'",
                                          x$settings$predictionInterval,
                                          "'")

  sqlFileName <- system.file("sql", "createLabels.sql",
                             package = "ProcedurePrediction")


  inputSql <- SqlRender::readSql(sqlFileName)

  renderedSql <- SqlRender::render(inputSql,
                                   cdmSchema = x$settings$cdmSchema,
                                   outputSchema = x$settings$outputSchema,
                                   predictionIntervalStart = x$settings$predictionInterval[1],
                                   predictionIntervalEnd = x$settings$predictionInterval[2],
                                   procedureSourceConcepts = paste0(x$settings$procedureSourceConcepts,
                                                                    collapse = ","))

  translatedSql <- SqlRender::translate(renderedSql,
                                        targetDialect = 'sql server')

  connection <- DatabaseConnector::connect(x$settings$connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection))

  DatabaseConnector::dbExecute(connection, translatedSql)

  tableName <- paste0(x$settings$outputSchema, ".population_labels")
  x$results$population_labels <- list()
  x$results$population_labels$databaseTable <- tableName
  x$results$population_labels$nRows <- DatabaseConnector::querySql(
    connection,
    SqlRender::translate(paste0("select count(*) from ", tableName),
                         targetDialect = 'sql server')
  )[1,1]

  x$results$population_labels$nOutcomes <- DatabaseConnector::querySql(
    connection,
    SqlRender::translate(paste0("select count(*) from ", tableName,
                                " where y = 1"),
                         targetDialect = 'sql server')
  )[1,1]

  message("Created labels")
  return(x)

}
