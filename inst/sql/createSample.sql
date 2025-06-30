-- everyone with outcome=yes
drop table if exists #population_outcomes_yes

select distinct a.*
into #population_outcome_yes
from @outputSchema.population_cohort a
join @outputSchema.population_labels b
  on a.subject_id = b.rowId
where b.y = 1

-- everyone with outcome=no
drop table if exists #population_outcomes_no

select distinct a.*
into #population_outcome_no
from @outputSchema.population_cohort a
join @outputSchema.population_labels b
  on a.subject_id= b.rowId
where b.y = 0

-- sample from everyone with outcome=no
drop table if exists #sample_outcome_no
select top @nControlCases *
into #sample_outcome_no
from #population_outcome_no
order by NEWID()

-- stack all outcomes with the sample of no-outcomes
drop table if exists @outputSchema.sample_cohort
select a.*
into @outputSchema.sample_cohort
from (select * from #population_outcome_yes
      UNION
      select * from #sample_outcome_no) a

-- table of labels for sample
drop table if exists @outputSchema.sample_labels
select b.*
into @outputSchema.sample_labels
from @outputSchema.sample_cohort a
left join @outputSchema.population_labels b
on a.subject_id = b.rowId
