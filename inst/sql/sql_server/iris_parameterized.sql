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

WITH
iris_person AS ( --- CTE
    select
        CAST('02G2' AS VARCHAR) AS measure,
        CAST(a.cnt AS BIGINT) AS result,
        CAST('count of patients' AS VARCHAR) AS explanation
    FROM (
	    select COUNT_BIG(*) cnt from @cdmSchema.person
    ) a
),

iris_event AS ( --- CTE
    select
        CAST('01G1' AS VARCHAR) AS measure,
        CAST(a.cnt AS BIGINT) AS result,
        CAST('count of events' AS VARCHAR) AS explanation
    FROM (
        select
            (select COUNT_BIG(*)   from @cdmSchema.person)
            +(select COUNT_BIG(*)  from @cdmSchema.observation)
            +(select COUNT_BIG(*)  from @cdmSchema.condition_occurrence)
            +(select COUNT_BIG(*)  from @cdmSchema.drug_exposure)
            +(select COUNT_BIG(*)  from @cdmSchema.visit_occurrence)
            +(select COUNT_BIG(*)  from @cdmSchema.death)
            +(select COUNT_BIG(*)  from @cdmSchema.procedure_occurrence) cnt
    ) a
),

iris_dx_rx AS ( --- CTE
    select
        CAST('D2' AS VARCHAR) AS measure,
        CAST(a.cnt AS BIGINT) AS result,
        CAST('count of patients with at least 1 Dx and 1 Rx' AS VARCHAR) AS explanation
    FROM (
        select COUNT_BIG(*) cnt from (
            select distinct person_id from @cdmSchema.condition_occurrence
            intersect
            select distinct person_id from @cdmSchema.drug_exposure
        ) b
    ) a
),

iris_dx_proc AS ( --- CTE
    select
        CAST('D3' AS VARCHAR) AS measure,
        CAST(a.cnt AS BIGINT) AS result,
        CAST('count of patients with at least 1 Dx and 1 Proc' AS VARCHAR) AS explanation
    FROM (
        select COUNT_BIG(*) cnt from (
            select distinct person_id from @cdmSchema.condition_occurrence
            intersect
            select distinct person_id from @cdmSchema.procedure_occurrence
        ) b
    ) a
),

iris_obs_dx_rx AS ( --- CTE
    select
        CAST('D4' AS VARCHAR) AS measure,
        CAST(a.cnt AS BIGINT) AS result,
        CAST('count of patients with at least 1 Obs, 1 Dx and 1 Rx' AS VARCHAR) AS explanation
    FROM (
        select COUNT_BIG(*) cnt from (
            select distinct person_id from @cdmSchema.observation
            intersect
            select distinct person_id from @cdmSchema.condition_occurrence
            intersect
            select distinct person_id from @cdmSchema.drug_exposure
        ) b
    ) a
),

iris_dead AS ( --- CTE
    select
        CAST('D5' AS VARCHAR) AS measure,
        CAST(a.cnt AS BIGINT) AS result,
        CAST('count of deceased patients' AS VARCHAR) AS explanation
    FROM (
        select COUNT_BIG(*) cnt from @cdmSchema.death
    ) a
)

-- a single select returns concatenated CTEs

SELECT * FROM (
    SELECT * FROM iris_person
    UNION ALL
    SELECT * FROM iris_event
    UNION ALL
    SELECT * FROM iris_dx_rx
    UNION ALL
    SELECT * FROM iris_dx_proc
    UNION ALL
    SELECT * FROM iris_obs_dx_rx
    UNION ALL
    SELECT * FROM iris_dead
) concat ORDER BY measure
;
