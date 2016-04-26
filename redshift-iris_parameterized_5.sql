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

author:  Vojtech Huser, Marc Suchard

description:

*************************/

--start of analysis

-- Use CTEs as suggest by SqlRender vignette so no temporary tables nor Oracle write-permissions are necessary

WITH
iris_event AS ( --- CTE
    select
        10 AS analysis_id,
        CAST(a.cnt AS BIGINT) AS result
        --CAST('count of events' AS VARCHAR) AS explanation
FROM (
        select
            (select COUNT(*)   from mdcd_v5.person)
            +(select COUNT(*)  from mdcd_v5.observation)
            +(select COUNT(*)  from mdcd_v5.condition_occurrence)
            +(select COUNT(*)  from mdcd_v5.drug_exposure)
            +(select COUNT(*)  from mdcd_v5.visit_occurrence)
            +(select COUNT(*)  from mdcd_v5.death)
            +(select COUNT(*)  from mdcd_v5.observation)
            +(select COUNT(*)  from mdcd_v5.procedure_occurrence) cnt
    ) a
),
iris_dx_rx AS ( --- CTE
    select
        11 AS analysis_id,
        CAST(a.cnt AS BIGINT) AS result
--        CAST('count of patients with at least 1 Dx and 1 Rx' AS VARCHAR) AS explanation
    FROM (
        select COUNT(*) cnt from (
            select distinct person_id from mdcd_v5.condition_occurrence
            intersect
            select distinct person_id from mdcd_v5.drug_exposure
        ) b
    ) a
),

iris_dx_proc AS ( --- CTE
    select
        12 AS analysis_id,
        CAST(a.cnt AS BIGINT) AS result
        --CAST('count of patients with at least 1 Dx and 1 Proc' AS VARCHAR) AS explanation
    FROM (
        select COUNT(*) cnt from (
            select distinct person_id from mdcd_v5.condition_occurrence
            intersect
            select distinct person_id from mdcd_v5.procedure_occurrence
        ) b
    ) a
),

iris_obs_dx_rx AS ( --- CTE
    select
        13 AS analysis_id,
        CAST(a.cnt AS BIGINT) AS result
--        CAST('count of patients with at least 1 Meas, 1 Dx and 1 Rx' AS VARCHAR) AS explanation
    FROM (
        select COUNT(*) cnt from (
            select distinct person_id from mdcd_v5.measurement
            intersect
            select distinct person_id from mdcd_v5.condition_occurrence
            intersect
            select distinct person_id from mdcd_v5.drug_exposure
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
