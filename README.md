# Iris
IRIS provides a high-level descriptive summary of a population within a OMOP CDM-compliant database

This version 1.0 uses CDM v4 but in fact will also run on CDM v5.
In terms of database engines - We tested the package on Postgres, MS SQL with no errors. For Oracle, there is a known bug and known fix for it. 

Future versions may use the NOTES table and will include an option to generate SQL for CDM v5 or for CDM v4.

#How to use it?


##R mode

```R
install.packages("devtools")
devtools::install_github("OHDSI/SqlRender")
devtools::install_github("ODHSI/DatabaseConnector")
devtools::install_github("OHDSI/Iris")
?Iris::execute # To get extended help

# Run study
Iris::execute(dbms = "postgresql",      # Change to participant settings
              user = "joebruin",
              password = "supersecret",
              server = "myserver",
              cdmSchema = "cdm_schema",
              cdmVersion = 4)

# Email results file
Iris::email(from = "collaborator@ohdsi.org",         # Change to participant email address
      dataDescription = "CDM4 Simulated Data") # Change to participant data description
```

To reload saved results in `R`

```R
# Load (or reload) study results
results <- Iris::loadOhdsiStudy(verbose = TRUE)
```

#Sample output:

    MEASURE     RESULT     EXPLANATION
    G1     141,805,491        count of patients
    G2     20,328,289,601     count of events
    D2     90,024,522         count of patients with at least 1 Dx and 1 Rx
    D3     112,148,500        count of patients with at least 1 Dx and 1 Proc
    D4     5,939,621          count of patients with at least 1 Obs, 1 Dx and 1 Rx
    D5     277,975            count of deceased patients


Relevant  IRIS forum discussion is here http://forums.ohdsi.org/t/short-and-quick-way-to-describe-your-cdm-dataset/251
