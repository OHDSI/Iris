This file contains various notes for Iris development


#running Iris just after you executed Achilles or just Achilles Heel

```R
#install Iris (assumes you have  devtools library installed)
devtools::install_github("OHDSI/Iris")

#re-use your connection object and point to the same "results" database but add where the results schema is 
connectionDetails$target_database_schema='results'

#also make sure you original set up of connectionDetails included a parameter called schema. 
#If not add it like this (otherwise the final execute call will fail) (think myCdm)
connectionDetails$schema='cdm5_inst'



#execute experimental parts of Iris by changing the part parameter (e.g., 2) 
#(see the SQL Iris folder to see all experimental parts)

iPart<-Iris:::executePart(part=2,connectionDetails,cdmVersion = 5)
iPart<-Iris:::executePart(part=3,connectionDetails,cdmVersion = 5)


```



#More SQL files
To pilot new ideas quickly (and not let people wait for full Iris results), the SQL code is now split
into more parts. (see SQL folder). To execute just part of Iris, alternative execute functions are used. (internal, so use triple semicolon to get to it)

#Connection data 
Iris plans to use ConnectionDetails method to specify server and login data to various functions.
The beta execute functions already use this method.

Connection data can be in external .R file (and that file can be  outside the project (so you don't upload it to public site accidentaly, for example). See example below



```R
source('c:/d/z_connect.R')
iPart<-Iris:::executePart(part=3,connectionDetails,cdmVersion = 5)

Connecting using Redshift driver
iris_parameterized_3.sql
Executing Iris Part 3 on ccae_v5 ...
Execution time: 3.260972 secs
  ANALYSIS_ID                                                   ACHILLES_HEEL_WARNING RULE_ID COUNT_VALUE
1         499 WARNING: percentage of unmapped rows exceeds threshold (concept_0 rows)      27   0.0648880
2         699 WARNING: percentage of unmapped rows exceeds threshold (concept_0 rows)      27   0.1503383
3         799 WARNING: percentage of unmapped rows exceeds threshold (concept_0 rows)      27   2.2974252

```
We do encourage you to email feedback to vojtech huser at nih dot gov.  (even if you just sucesfully ran the tool)


#Rule notes

--rules

Yes vote 27,iris3," % of unmapped rows,"looks for concept 0 mapped rows in multiple tables and generates output if over a threshold" (not as percentage)

    		 28,iris3,"percentage of deceased patients","for general population this should be over certain threshold"
         32,iris3,"data from < 3 states"  (US centric)
    no vote	 38, data from les than <2 countries  
    ? vote   33,i3,"W:data by 3 digit zip are not recorded in PERSON table  (not global)
    No vote  34,i3,"w:measuremtn rows with no time data are over threshold
    Yes vote 35,TODO, w:new measure added to Achilles,ALL VALUES ARE NON NUMERICAL (strange), indicates "mapping based measurement data"
    36 count   ration providers/patients is too low

