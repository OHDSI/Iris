/*********************************************************************************
# Copyright 2016 Observational Health Data Sciences and Informatics
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
********************************************************************************/
/************************
last revised: April 2016  author:  Vojtech Huser
*************************/


--start of analysis
--analysis of how many source values are in source and into how many distinct concept_ids these are mapped
--and also including unmapped source_values

select 'measurement' as domain,
(select COUNT_BIG(distinct measurement_concept_id) from @cdmSchema.measurement) as target_cnt,
(select COUNT_BIG(distinct measurement_source_value) from @cdmSchema.measurement) as source_cnt,
(select COUNT_BIG(distinct measurement_source_value) from @cdmSchema.measurement where measurement_concept_id = 0) as source_unmapped_cnt

UNION

select 'condition' as domain,
(select COUNT_BIG(distinct condition_concept_id) from @cdmSchema.condition_occurrence) as target_cnt,
(select COUNT_BIG(distinct condition_source_value) from @cdmSchema.condition_occurrence) as source_cnt,
(select COUNT_BIG(distinct condition_source_value) from @cdmSchema.condition_occurrence where condition_concept_id = 0) as source_unmapped_cnt


UNION

select 'procedure' as domain,
(select COUNT_BIG(distinct procedure_concept_id) from @cdmSchema.procedure_occurrence) as target_cnt,
(select COUNT_BIG(distinct procedure_source_value) from @cdmSchema.procedure_occurrence) as source_cnt,
(select COUNT_BIG(distinct procedure_source_value) from @cdmSchema.procedure_occurrence where procedure_concept_id = 0) as source_unmapped_cnt

UNION

select 'drug' as domain,
(select count(distinct drug_concept_id) from @cdmSchema.drug_exposure) as target_cnt,
(select count(distinct drug_source_value) from @cdmSchema.drug_exposure) as source_cnt,
(select count(distinct drug_source_value) from @cdmSchema.drug_exposure where drug_concept_id = 0) as source_unmapped_cnt

UNION

select 'observation' as domain,
(select count(distinct observation_concept_id) from @cdmSchema.observation) as target_cnt,
(select count(distinct observation_source_value) from @cdmSchema.observation) as source_cnt,
(select count(distinct observation_source_value) from @cdmSchema.observation where observation_concept_id = 0) as source_unmapped_cnt;
;

