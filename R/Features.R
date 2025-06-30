##' Create the features of included persons
##'
##' Writes table to study database
##' @title createFeatures
##' @param x state
##' @return Modified copy of state with metadata about features (covariates)
##' @author William J. O'Brien
##' @export
createFeatures <- function(x) {

  checkmate::assertClass(x, "ProcedurePrediction")

  features <- FeatureExtraction::getDbCovariateData(
    connectionDetails = x$settings$connectionDetails,
    cdmDatabaseSchema = x$settings$cdmSchema,
    cohortDatabaseSchema = x$settings$outputSchema,
    cohortTable = 'sample_cohort',
    cohortIds = 1,
    rowIdField = "subject_id",
    covariateSettings = x$settings$covariateSettings
  )

  x$results$features <- list()
  x$results$features$andromedaFile <- file.path(x$settings$andromedaFolder, "features")
  x$results$features$nRows <- pull(count(features$covariates))

  saveAndromeda(features, file.path(x$settings$andromedaFolder, "features"))

  message("Created features")

  return(x)

}
