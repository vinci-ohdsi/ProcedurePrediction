drop table if exists @outputSchema.population_cohort

-- all people satisfying continuous observation criterion

select distinct
  1 cohort_definition_id,
  person_id subject_id,
  @predictionStartIndex cohort_start_date,
  @predictionEndIndex cohort_end_date
into @outputSchema.population_cohort
from @cdmSchema.observation_period
where observation_period_start_date <= @observationStartIndex
  and observation_period_end_date >= @observationEndIndex


