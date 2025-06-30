#' Diagnostics of test set predictions
#'
#' @param x state
#'
#' @returns Modified copy of state with information about test prediction diagnostics
#' @export
#'
#' @examples
createTestDiagnostics <- function(x){

  predictions <- Andromeda::loadAndromeda(file.path(x$settings$andromedaFolder,
                                                    x$results$predictions$andromedaFile))

  # density plot

  x$results$testPredictionsDensityPlot <- ggplot(predictions$predictions,
                                                 aes(x = p,
                                                     group = y,
                                                     fill = factor(ifelse(y == 0, '0', '1')))) +
    geom_density(alpha = .3)

  # c-statistic

  x$results$testPredictionsAuc <- auc(roc(collect(predictions$predictions), y, p))


  # calibration by predicted decile

  x$results$calibrationPlot <- collect(predictions$predictions) %>%
    mutate(predictionDecile = cut(p, 10,
                                  lowest = TRUE,
                                  labels = FALSE) / 10) %>%
    group_by(predictionDecile) %>%
    summarize(meanY = mean(y)) %>%
    ggplot(aes(x = predictionDecile,
               y = meanY)) +
    geom_point(aes(x = predictionDecile,
                   y = meanY)) +
    geom_abline(slope = 1, intercept = 0, color = 'gray70')

  message("Created diagnositcs")

  return(x)

}
