##' Create initial state
##'
##' Returns a list of validated prediction settings
##' @title createPredictionSettings
##' @param connectionDetails
##' @param cdmSchema
##' @param procedureStandardConcepts
##' @param procedureSourceConcepts
##' @param predictionInterval
##' @param continuousObservationInterval
##' @param controlToCaseRatio
##' @return List of class "ProcedurePrediction"
##' @author William J. O'Brien
##' @export
createInitialState <- function(connectionDetails,
                               cdmSchema,
                               outputSchema,
                               procedureStandardConcepts,
                               procedureSourceConcepts,
                               predictionInterval,
                               continuousObservationInterval,
                               controlToCaseRatio = NULL,
                               covariateSettings = FeatureExtraction::createDefaultCovariateSettings(),
                               andromedaFolder = "./",
                               trainProportion = 0.8) {

    checkmate::assertClass(connectionDetails, "ConnectionDetails")
    checkmate::assertIntegerish(controlToCaseRatio, null.ok = TRUE)

    result <- list(
      settings = list(
        connectionDetails = connectionDetails,
        cdmSchema = cdmSchema,
        outputSchema = outputSchema,
        procedureStandardConcepts = procedureStandardConcepts,
        procedureSourceConcepts = procedureSourceConcepts,
        predictionInterval = predictionInterval,
        continuousObservationInterval = continuousObservationInterval,
        controlToCaseRatio = controlToCaseRatio,
        covariateSettings = covariateSettings,
        andromedaFolder = andromedaFolder,
        trainProportion = trainProportion
      ),

      results = list()
    )

    class(result) <- "ProcedurePrediction"

    return(result)
}
