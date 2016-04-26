/*********************************************************************************
# Copyright 2015 Observational Health Data Sciences and Informatics
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
********************************************************************************/
/************************
last revised: April 2016  author:  Vojtech Huser
*************************/

--this report is a pilot for producing a list of unmapped source values across several tables (Rx, Dx, Proc, Meas)

select * from (
select 'measurement' as table_name,measurement_source_value as source_value, count(*) as cnt from measurement where measurement_concept_id = 0 group by measurement_source_value
union
select 'procedure_occurrence' as table_name,procedure_source_value as source_value, count(*) as cnt from procedure_occurrence where procedure_concept_id = 0 group by procedure_source_value
union
select 'drug_exposure' as table_name,drug_source_value as source_value, count(*) as cnt from drug_exposure where drug_concept_id = 0 group by drug_source_value
union
select 'condition_occurrence' as table_name,condition_source_value as source_value, count(*) as cnt from condition_occurrence where condition_concept_id = 0 group by condition_source_value
) a
where cnt >= 100 --use other threshold if needed (e.g., 10)
order by a.table_name desc, cnt desc
;
