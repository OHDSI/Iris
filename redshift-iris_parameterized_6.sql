/*********************************************************************************
# Copyright 2015 Observational Health Data Sciences and Informatics
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
********************************************************************************/
/************************
last revised: April 2016  author:  Vojtech Huser
*************************/
--achilles_share_level_1








SET search_path TO  nih;

select analysis_id, parameter, cast(count_value as VARCHAR) as value from
--select * from
(


select 516 as analysis_id,'count of deceased' as parameter , sum(count_value) AS count_value from achilles_results where analysis_id = 501 group by analysis_id
	  union
--	  select 516 as analysis_id,'count of deceased' as parameter , sum(count_value) as all_cnt from achilles_results where analysis_id = 501 group by analysis_id;
    select analysis_id, 'count of persons' as parameter, count_value as value from achilles_results where analysis_id = 1
union
    select analysis_id, 'count of providers' as parameter, count_value from achilles_results where analysis_id = 300

) numerical
UNION

select null as analysis_id, 'measurement data start month' as parameter ,cast(min(stratum_1) as VARCHAR) as value from (
    select stratum_1
    --,count_value,count_value*100.0/    (select sum(count_value) from achilles_results where analysis_id = 1820 group by analysis_id) as ratio
    from achilles_results where analysis_id = 1820
    --exclude outlier months, months that contain less than 0.01 percent of overal data
    and (count_value*100.0/    (select sum(count_value) from achilles_results where analysis_id = 1820 group by analysis_id)) > 0.01
    --
    ) a
UNION
select null as analysis_id, 'measurement data end  month' as parameter ,cast(max(stratum_1) as VARCHAR) as value from (
    select stratum_1
    from achilles_results where analysis_id = 1820
    --exclude outlier months, months that contain less than 0.01 percent of overal data
    and (count_value*100.0/    (select sum(count_value) from achilles_results where analysis_id = 1820 group by analysis_id)) > 0.01
    --
    ) a
order by analysis_id , parameter
;
