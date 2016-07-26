# Iris
IRIS provides a high-level descriptive summary of a population within a OMOP CDM-compliant database

Some Iris measures were incorporated in Achilles version 1.3
This version 1.1 uses CDM v5.
Unlike v1.0, this version makes use of the  Measurement table to go after lab results.

In terms of database engines - we tested the package on Postgres, MS SQL with no errors. For Oracle, there is a known bug and known fix for it (see Issues on GitHub for the fix). 


#How to use it?

The best way to use Iris is as R package and from within R.

##R mode

```R
install.packages("devtools")
devtools::install_github("OHDSI/SqlRender")
devtools::install_github("ODHSI/DatabaseConnector")
devtools::install_github("OHDSI/Iris")
?Iris::execute # To get extended help

# Run study
a<-Iris::execute(dbms = "postgresql",      # Change to participant settings
              user = "joebruin",
              password = "supersecret",
              server = "myserver",
              cdmSchema = "cdm_schema",
              cdmVersion = 4)
#show timing again
a$executionTime

#show results
a$result

#write to a file
write.csv(a$result,file='iris-results.csv',row.names = F)


# Email results file
Iris::email(from = "collaborator@ohdsi.org",         # Change to participant email address
      dataDescription = "CDM4 Simulated Data") # Change to participant data description
```

To reload saved results in `R`

```R
# Load (or reload) study results
results <- Iris::loadOhdsiStudy(verbose = TRUE)
```

#Sample output (for v1.0):

    MEASURE     RESULT     EXPLANATION
    G1     141,805,491        count of patients
    G2     20,328,289,601     count of events
    D2     90,024,522         count of patients with at least 1 Dx and 1 Rx
    D3     112,148,500        count of patients with at least 1 Dx and 1 Proc
    D4     5,939,621          count of patients with at least 1 Obs, 1 Dx and 1 Rx
    D5     277,975            count of deceased patients


Relevant  IRIS forum discussion is here http://forums.ohdsi.org/t/short-and-quick-way-to-describe-your-cdm-dataset/251
