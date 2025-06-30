#' Train/test split
#'
#' Writes new train/test tables to local andromeda objects
#'
#' @param x state
#'
#' @returns Modified copy of state with metadata about train/test split
#' @export
#'
#' @examples
trainTestSplit <- function(x){

  checkmate::assertClass(x, "ProcedurePrediction")

  sqlFileName <- system.file("sql", "trainTestSplit.sql",
                             package = "ProcedurePrediction")


  inputSql <- SqlRender::readSql(sqlFileName)

  renderedSql <- SqlRender::render(inputSql,
                                   outputSchema = x$settings$outputSchema,
                                   trainProportion = x$settings$trainProportion)

  translatedSql <- SqlRender::translate(renderedSql,
                                        targetDialect = 'sql server')

  connection <- DatabaseConnector::connect(x$settings$connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection))

  DatabaseConnector::dbExecute(connection, translatedSql)

  yTrainTableName <- paste0(x$settings$outputSchema, ".y_train")
  x$results$y_train <- list()
  x$results$y_train$databaseTable <- yTrainTableName
  x$results$y_train$nRows <- DatabaseConnector::querySql(
    connection,
    SqlRender::translate(paste0("select count(*) from ", yTrainTableName),
                         targetDialect = 'sql server')
  )[1,1]

  yTestTableName <- paste0(x$settings$outputSchema, ".y_test")
  x$results$y_test <- list()
  x$results$y_test$databaseTable <- yTestTableName
  x$results$y_test$nRows <- DatabaseConnector::querySql(
    connection,
    SqlRender::translate(paste0("select count(*) from ", yTestTableName),
                         targetDialect = 'sql server')
  )[1,1]



  features <- Andromeda::loadAndromeda(file.path(x$settings$andromedaFolder, "features"))

  # andromeda training X
  query <- "select distinct rowId from @outputSchema.y_train"
  query <- SqlRender::render(query,
                             outputSchema = x$settings$outputSchema)
  query <- SqlRender::translate(query, targetDialect = 'sql server')
  trainIds <- DatabaseConnector::querySql(connection, query)

  x_train <- Andromeda::andromeda()
  x_train$covariates <- filter(features$covariates, rowId %in% trainIds$ROWID)

  x$results$x_train <- list()
  x$results$x_train$andromedaFile <- "x_train"
  x$results$x_train$nRows <- pull(count(x_train$covariates))
  saveAndromeda(x_train, file.path(x$settings$andromedaFolder, "x_train"))

  # andromeda testing X
  query <- "select distinct rowId from @outputSchema.y_test"
  query <- SqlRender::render(query,
                             outputSchema = x$settings$outputSchema)
  query <- SqlRender::translate(query, targetDialect = 'sql server')
  testIds <- DatabaseConnector::querySql(connection, query)

  x_test <- Andromeda::andromeda()
  x_test$covariates <- filter(features$covariates, rowId %in% testIds$ROWID)

  x$results$x_test <- list()
  x$results$x_test$andromedaFile <- "x_test"
  x$results$x_test$nRows <- pull(count(x_test$covariates))
  saveAndromeda(x_test, file.path(x$settings$andromedaFolder, "x_test"))

  message("Created train/test split")
  return(x)

}
