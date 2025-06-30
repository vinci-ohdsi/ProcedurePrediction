##' Create a sample from the study population
##'
##' Writes table to study database
##' @title createSample
##' @param x state
##' @return Modified copy of state with metadata about control cohort sample
##' @author William J. O'Brien
##' @export
createSample <- function(x) {

  checkmate::assertClass(x, "ProcedurePrediction")

  sqlFileName <- system.file("sql", "createSample.sql",
                             package = "ProcedurePrediction")

  inputSql <- SqlRender::readSql(sqlFileName)

  renderedSql <- SqlRender::render(inputSql,
                                   outputSchema = x$settings$outputSchema,
                                   nControlCases = x$settings$controlToCaseRatio * x$results$population_labels$nOutcomes)

  translatedSql <- SqlRender::translate(renderedSql,
                                        targetDialect = 'sql server')

  connection <- DatabaseConnector::connect(x$settings$connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection))

  DatabaseConnector::dbExecute(connection, translatedSql)

  tableName <- paste0(x$settings$outputSchema, ".sample_cohort")
  x$results$sample_cohort <- list()
  x$results$sample_cohort$databaseTable <- tableName
  x$results$sample_cohort$nRows <- DatabaseConnector::querySql(
    connection,
    SqlRender::translate(paste0("select count(*) from ", tableName),
                         targetDialect = 'sql server')
  )[1,1]


  tableName <- paste0(x$settings$outputSchema, ".sample_labels")
  x$results$sample_labels <- list()
  x$results$sample_labels$databaseTable <- tableName
  x$results$sample_labels$nRows <- DatabaseConnector::querySql(
    connection,
    SqlRender::translate(paste0("select count(*) from ", tableName),
                         targetDialect = 'sql server')
  )[1,1]

  x$results$sample_labels$nOutcomes <- DatabaseConnector::querySql(
    connection,
    SqlRender::translate(paste0("select count(*) from ", tableName,
                                " where y = 1"),
                         targetDialect = 'sql server')
  )[1,1]

  message("Created sample")

  return(x)

}
