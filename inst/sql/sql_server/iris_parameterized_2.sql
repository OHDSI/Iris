/*********************************************************************************
# Copyright 2015 Observational Health Data Sciences and Informatics
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
********************************************************************************/

/************************

script to evaluate CDM repository

last revised: July 21 2015

author:  Vojtech Huser
modifications by: Marc Suchard

description:

*************************/

--start of analysis

-- Use CTEs as suggest by SqlRender vignette so no temporary tables nor Oracle write-permissions are necessary



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

