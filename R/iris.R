###########################################################
# R script for IRIS   
# 
#                                                         #
###########################################################

# Install necessary packages if needed
#install.packages("devtools")
require(devtools)
#next line prevents problem with previous version of SqlRender
#remove.packages("SqlRender")
#install_github("ohdsi/SqlRender")
#install_github("ohdsi/DatabaseConnector")



# Load libraries
require(SqlRender)
require(DatabaseConnector)
packageVersion("SqlRender")
packageVersion("DatabaseConnector")

###########################################################
# Parameters: Please change these to the correct values:  #
###########################################################

useInterimTables = 1  #change to 0  (zero) if you have no write access to any schema. later variable result schema variable will be ignored (can be set to anything) if useInterimTables is set to zero
folder        = "C:/d/sandA" # Folder containing the R and SQL files, use forward slashes
cdmSchema     = "ccae_cdm4"
resultsSchema = "results"  #ignored if useInterimTable is 0

sourceName    = "CCAE"
dbms          = "postgresql"      # Should be "sql server", "oracle", "postgresql" or "redshift"



# If you want to use R to run the SQL and extract the results tables, please create a connectionDetails 
# object. See ?createConnectionDetails for details on how to configure for your DBMS.

connectionDetails <- createConnectionDetails(dbms     = dbms,
                                             user     = "postgres", 
                                             password = "F1r3starter", 
                                             server   = "localhost/ohdsi")
#example for redshift
# connectionDetails <- createConnectionDetails(dbms=dbms
#                                              ,server="omop-datasets.redacted.redshift.amazonaws.com/redacted"
#                                              ,user="redacted"
#                                              ,password="redacted"
#                                              ,port="5439")


###########################################################
# End of parameters. Make no changes after this           #
###########################################################



setwd(folder)

#source("HelperFunctions.R")

# Create the parameterized SQL files:
inputFile <- "..\inst\sql\sql_server\iris_parameterized.sql"
studyName <-'iris'  #does not need changing
outputFile <- paste(studyName,"-autoTranslate-",dbms,".sql",sep="")

parameterizedSql <- readSql(inputFile)
renderedSql <- renderSql(parameterizedSql, cdmSchema=cdmSchema, resultsSchema=resultsSchema, studyName = studyName, sourceName=sourceName,useInterimTables=useInterimTables )$sql
#sourceDialect should not be changed

translatedSql <- translateSql(renderedSql, sourceDialect = "sql server", targetDialect = dbms)$sql
writeSql(translatedSql,outputFile)
writeLines(paste("Created file '",outputFile,"'",sep=""))


#this code only facilitates distribution of SQL code
                otherDialect<-'oracle'
                outputFileOther <- paste(studyName,"-autoTranslate-",otherDialect,".sql",sep="")
                translatedSqlOther <- translateSql(renderedSql, sourceDialect = "sql server", targetDialect = otherDialect)$sql
                writeSql(translatedSqlOther,outputFileOther)

                
                otherDialect<-'postgresql'
                outputFileOther <- paste(studyName,"-autoTranslate-",otherDialect,".sql",sep="")
                translatedSqlOther <- translateSql(renderedSql, sourceDialect = "sql server", targetDialect = otherDialect)$sql
                writeSql(translatedSqlOther,outputFileOther)

                
                otherDialect<-'ms sql'
                outputFileOther <- paste(studyName,"-autoTranslate-",otherDialect,".sql",sep="")
                #translatedSqlOther <- translateSql(renderedSql, sourceDialect = "sql server", targetDialect = otherDialect)$sql
                writeSql(renderedSql,outputFileOther)



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#if you don't want to execute the code -  you can end here and just use the outputFile "manually"

# Execute the SQL:
.jinit()  #this tiny step resolves optional issues with JVM
conn <- connect(connectionDetails)


executeSql(conn,readSql(outputFile))

dbDisconnect(conn)

#--end of code



