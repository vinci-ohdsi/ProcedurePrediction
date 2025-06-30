drop table if exists @outputSchema.population_labels;
drop table if exists @outputSchema.allProcedures;


with allProcedures as
(select person_id subject_id,
  procedure_date,
  procedure_concept_id,
  procedure_source_concept_id
from @cdmSchema.procedure_occurrence
  where procedure_date >= @predictionIntervalStart
    and procedure_date <= @predictionIntervalEnd
    and (procedure_concept_id in (@procedureSourceConcepts)
      or procedure_source_concept_id in (@procedureSourceConcepts)))
select a.subject_id,
  b.procedure_date,
  b.procedure_concept_id,
  b.procedure_source_concept_id
into @outputSchema.allProcedures
from @outputSchema.population_cohort a
  left join allProcedures b
    on a.subject_id = b.subject_id

select subject_id rowId,
  case when
    count(procedure_date) > 0 then 1
    else 0
  end as y
into @outputSchema.population_labels
from @outputSchema.allProcedures
group by subject_id
