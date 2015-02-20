# Iris
IRIS provides a high-level descriptive summary of a population within a OMOP CDM-compliant database

This early version 0.1 uses CDM v4 but in fact will also run on CDM v5

Future versions may use the NOTES table and will include an option to generate SQL for CDM v5 or for CDM v4.

#How to use it?

##Simple mode:
Login to your database
Grab the SQL code for your database engine and run it.

##R mode
Use the R script


Sample output:

MEASURE     RESULT     EXPLANATION
G1     141,805,491        count of patients
G2     20,328,289,601     count of events
D2     90,024,522         count of patients with at least 1 Dx and 1 Rx
D3     112,148,500        count of patients with at least 1 Dx and 1 Proc
D4     5,939,621          count of patients with at least 1 Obs, 1 Dx and 1 Rx
D5     277,975            count of deceased patients


Relevant  IRIS forum discussion is here http://forums.ohdsi.org/t/short-and-quick-way-to-describe-your-cdm-dataset/251
