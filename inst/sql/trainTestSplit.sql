-- y train
drop table if exists @outputSchema.y_train;
with randomized as (
SELECT rowId
    ,y
	  ,row_number() over (order by newid()) rand
	  ,count(*) over () nrows
  FROM @outputSchema.sample_labels
)
select rowId
    ,y
into @outputSchema.y_train
from randomized
where rand < @trainProportion * nrows


-- y test
drop table if exists @outputSchema.y_test
select a.*
into @outputSchema.y_test
from @outputSchema.sample_labels a
left join @outputSchema.y_train b
  on a.rowId = b.rowId
where b.rowId is NULL

