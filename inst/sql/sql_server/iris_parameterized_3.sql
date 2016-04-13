/*********************************************************************************
# Copyright 2015 Observational Health Data Sciences and Informatics
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
********************************************************************************/
/************************
last revised: April 2016  author:  Vojtech Huser
*************************/


--insert into achilles_results(analysis_id,count_value)
with t1 as 	(
	  select analysis_id,sum(count_value) as all_cnt from @results_database_schema.achilles_results where analysis_id in (401,601,701,801,1801) group by analysis_id
  	),
t2 as (
			select analysis_id,count_value as concept_zero_cnt from @results_database_schema.achilles_results where analysis_id in (401,601,701,801,1801) and stratum_1 = 0
			),
added as (
    --count of unmapped rows (analysis xxxx98)
    select t2.analysis_id+97 as analysis_id,t2.Concept_zero_cnt as count_value  from t2
    UNION
    --percentage of unmapped rows (analysis xxx99)
    select t1.analysis_id+98 as analysis_id,((1.0*concept_zero_cnt)/all_cnt)*100 as count_value from t1 left outer join t2 on t1.analysis_id = t2.analysis_id
)
--select * from added;
--end of simmulated results and start of the rule
--ruleid 27 warning: significant portion of data is unmapped
--INSERT INTO @results_database_schema.ACHILLES_HEEL_results (analysis_id,ACHILLES_HEEL_warning,rule_id,record_count)
SELECT DISTINCT or1.analysis_id,
--edit line below  if this is made into format analysis one day
--	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; count (n=' + cast(or1.count_value as VARCHAR) + ') should not be > 0' AS ACHILLES_HEEL_warning,
  'WARNING: percentage of unmapped rows exceeds threshold (concept_0 rows)' as ACHILLES_HEEL_warning,
	27 as rule_id,
	or1.count_value
--FROM @results_database_schema.ACHILLES_results or1
FROM added  or1
--INNER JOIN @results_database_schema.ACHILLES_analysis oa1	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (499,699,799,899,1899)
--the intended threshold is 1 percent, this value is there to get pilot data from early adopters
	AND or1.count_value >= 0.05;
