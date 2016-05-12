

--part 5 was now fully migrated to Achilles (analysis IDs 2001,2002,etc) (2000 range)


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
last revised: April 20 2016
author:  Vojtech Huser, Marc Suchard

description: rewrite to be better compatible with Achilles-Pre-computations

*************************/

--early rewrite of original Iris rules (removing those that are already in Achilles)
--to make it more compatible with other Achilles


WITH
iris_event AS ( --- CTE
    select
        10 AS analysis_id,
        CAST(a.cnt AS BIGINT) AS result
        --CAST('count of events' AS VARCHAR) AS explanation
FROM (
        select
            (select COUNT_BIG(*)   from @cdm_database_schema.person)
            +(select COUNT_BIG(*)  from @cdm_database_schema.observation)
            +(select COUNT_BIG(*)  from @cdm_database_schema.condition_occurrence)
            +(select COUNT_BIG(*)  from @cdm_database_schema.drug_exposure)
            +(select COUNT_BIG(*)  from @cdm_database_schema.visit_occurrence)
            +(select COUNT_BIG(*)  from @cdm_database_schema.death)
            +(select COUNT_BIG(*)  from @cdm_database_schema.observation)
            +(select COUNT_BIG(*)  from @cdm_database_schema.procedure_occurrence) cnt
    ) a
),
iris_dx_rx AS ( --- CTE
    select
        11 AS analysis_id,
        CAST(a.cnt AS BIGINT) AS result
--        CAST('count of patients with at least 1 Dx and 1 Rx' AS VARCHAR) AS explanation
    FROM (
        select COUNT_BIG(*) cnt from (
            select distinct person_id from @cdm_database_schema.condition_occurrence
            intersect
            select distinct person_id from @cdm_database_schema.drug_exposure
        ) b
    ) a
),

iris_dx_proc AS ( --- CTE
    select
        12 AS analysis_id,
        CAST(a.cnt AS BIGINT) AS result
        --CAST('count of patients with at least 1 Dx and 1 Proc' AS VARCHAR) AS explanation
    FROM (
        select COUNT_BIG(*) cnt from (
            select distinct person_id from @cdm_database_schema.condition_occurrence
            intersect
            select distinct person_id from @cdm_database_schema.procedure_occurrence
        ) b
    ) a
),

iris_obs_dx_rx AS ( --- CTE
    select
        13 AS analysis_id,
        CAST(a.cnt AS BIGINT) AS result
--        CAST('count of patients with at least 1 Meas, 1 Dx and 1 Rx' AS VARCHAR) AS explanation
    FROM (
        select COUNT_BIG(*) cnt from (
            select distinct person_id from @cdm_database_schema.measurement
            intersect
            select distinct person_id from @cdm_database_schema.condition_occurrence
            intersect
            select distinct person_id from @cdm_database_schema.drug_exposure
        ) b
    ) a
)
-- a single select returns concatenated CTEs
SELECT  analysis_id, result as count_value FROM (
    SELECT * FROM iris_event
    UNION ALL
    SELECT * FROM iris_dx_rx
    UNION ALL
    SELECT * FROM iris_dx_proc
    UNION ALL
    SELECT * FROM iris_obs_dx_rx
) concat
;
