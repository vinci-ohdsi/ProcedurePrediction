

#' Predict on data not used during training
#'
#' @param x state
#'
#' @returns Modified copy of state with information about test performance in results list
#' @export
#'
#' @examples
predictOnTestSet <- function(x){

  xTest <- Andromeda::loadAndromeda(file.path(x$settings$andromedaFolder, "x_test"))

  yTest <- Andromeda::andromeda()

  query <- sprintf("select * from %s",
                   x$results$y_test$databaseTable)

  connection <- DatabaseConnector::connect(x$settings$connectionDetails)
  DatabaseConnector::querySqlToAndromeda(
    connection = connection,
    sql = query,
    andromeda = yTest,
    andromedaTableName = "labels"
  )

  saveAndromeda(yTest, file.path(x$settings$andromedaFolder, "y_test"))

  yTest <- Andromeda::loadAndromeda(file.path(x$settings$andromedaFolder, "y_test"))

  # cyclops predict method errors when provided andromeda objects (x and y must share same source)
  xTest <- data.frame(xTest$covariates)
  yTest <- data.frame(yTest$labels)

  predictions <- predict(x$results$fit,
                         yTest,
                         xTest)

  message("created predictions")
  predictions <- data.frame(subject_id = names(predictions),
                            p = predictions)
  rownames(predictions) <- NULL

  p <- Andromeda::andromeda()
  p$predictions <- left_join(predictions,
                             mutate(yTest, subject_id = as.character(rowId)) %>%
                               select(-rowId),
                             by = 'subject_id')

  saveAndromeda(p, file.path(x$settings$andromedaFolder, "predictions"))

  x$results$predictions <- list()
  x$results$predictions$andromedaFile <- file.path(x$settings$andromedaFolder, "predictions")

  message("Created predictions on test set")

  return(x)

}






