##' Create the cohort of included persons
##'
##' Writes table to study database
##' @title createInclusionCohort
##' @param x state
##' @return Modified copy of state with metadata about study population
##' @author William J. O'Brien
##' @export
createPopulation <- function(x) {

  checkmate::assertClass(x, "ProcedurePrediction")

  continuousObservationInterval <- paste0("'",
                                            x$settings$continuousObservationInterval,
                                            "'")

  predictionInterval <- paste0("'",
                                 x$settings$predictionInterval,
                                 "'")

  sqlFileName <- system.file("sql", "createPopulation.sql",
                             package = "ProcedurePrediction")


  inputSql <- SqlRender::readSql(sqlFileName)

  renderedSql <- SqlRender::render(inputSql,
                                   cdmSchema = x$settings$cdmSchema,
                                   outputSchema = x$settings$outputSchema,
                                   observationStartIndex = continuousObservationInterval[1],
                                   observationEndIndex = continuousObservationInterval[2],
                                   predictionStartIndex = predictionInterval[1],
                                   predictionEndIndex = predictionInterval[2])

  translatedSql <- SqlRender::translate(renderedSql,
                                        targetDialect = 'sql server')

  connection <- DatabaseConnector::connect(x$settings$connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection))

  DatabaseConnector::dbExecute(connection, translatedSql)

  tableName <- paste0(x$settings$outputSchema, ".population_cohort")
  x$results$population_cohort <- list()
  x$results$population_cohort$databaseTable <- tableName
  x$results$population_cohort$nRows <- DatabaseConnector::querySql(
    connection,
    SqlRender::translate(paste0("select count(*) from ", tableName),
                         targetDialect = 'sql server')
  )[1,1]

  message("Created population")
  return(x)

}
