#' Fit regression model
#'
#' @param x state
#'
#' @returns Modified copy of state with fit object in list of results
#' @export
#'
#' @examples
trainModel <- function(x){

  connection <- DatabaseConnector::connect(x$settings$connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection))

  xTrain <- Andromeda::loadAndromeda(file.path(x$settings$andromedaFolder, "x_train"))

  yTrain <- Andromeda::andromeda()

  query <- sprintf("select * from %s",
                   x$results$y_train$databaseTable)

  DatabaseConnector::querySqlToAndromeda(
    connection = connection,
    sql = query,
    andromeda = yTrain,
    andromedaTableName = "labels"
  )

  cyclopsData <- Cyclops::convertToCyclopsData(
    yTrain$labels,
    distinct(xTrain$covariates),   # why does featureExtraction give dupe entries?
    modelType = "lr"
  )

  message("Fitting Cyclops model")

  x$results$fit <- Cyclops::fitCyclopsModel(
    cyclopsData,
    prior = createPrior("laplace", useCrossValidation = TRUE),
    control = createControl(threads = 4, cvRepetitions = 1)
  )

  message("Trained model")

  return(x)
}
