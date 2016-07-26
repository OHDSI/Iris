#' @title Execute OHDSI Iris
#'
#' @details
#' This function executes OHDSI Iris.
#' Iris computes some basic parameters about a dataset.
#'
#' @return
#' Study results are placed in CSV format files in specified local folder and returned
#' as an R object class \code{OhdsiStudy} when sufficiently small.  The properties of an
#' \code{OhdsiStudy} may differ from study to study.

#' @param dbms              The type of DBMS running on the server. Valid values are
#' \itemize{
#'   \item{"mysql" for MySQL}
#'   \item{"oracle" for Oracle}
#'   \item{"postgresql" for PostgreSQL}
#'   \item{"redshift" for Amazon Redshift}
#'   \item{"sql server" for Microsoft SQL Server}
#'   \item{"pdw" for Microsoft Parallel Data Warehouse (PDW)}
#'   \item{"netezza" for IBM Netezza}
#' }
#' @param user				The user name used to access the server. If the user is not specified for SQL Server,
#' 									  Windows Integrated Security will be used, which requires the SQL Server JDBC drivers
#' 									  to be installed.
#' @param domain	    (optional) The Windows domain for SQL Server only.
#' @param password		The password for that user
#' @param server			The name of the server
#' @param port				(optional) The port on the server to connect to
#' @param cdmSchema  Schema name where your patient-level data in OMOP CDM format resides
#' @param cdmVersion     Define the OMOP CDM version used:  currently support 4 and 5.  Default = 4
#' @param file	(Optional) Name of local file to place results; makre sure to use forward slashes (/)
#'
#' @examples \dontrun{
#' # Run study
#' execute(dbms = "postgresql",
#'         user = "joebruin",
#'         password = "supersecret",
#'         server = "myserver",
#'         cdmSchema = "cdm_schema",
#'         cdmVersion = 4)
#'
#' # Email result file
#' email(from = "collaborator@@ohdsi.org",
#'       dataDescription = "CDM4 Simulated Data")
#' }
#'
#' @importFrom DBI dbDisconnect
#' @export
execute <- function(dbms, user = NULL, domain = NULL, password = NULL, server,
                    port = NULL,
                    cdmSchema,
                    cdmVersion = 5,
                    file) {
    #check version
    if (cdmVersion == 4) {
        stop("Iris was extended in 2016 to accomodate CDM v5 tables. Iris officialy only supports CDM v5.")
    }

    # Open DB connection
    connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                    server = server,
                                                                    user = user,
                                                                    domain = domain,
                                                                    password = password,
                                                                    schema = cdmSchema,
                                                                    port = port)
    conn <- DatabaseConnector::connect(connectionDetails)
    if (is.null(conn)) {
        stop("Failed to connect to db server.")
    }

    # Record start time
    start <- Sys.time()

    # Load, render and translate SQL
    sql <- SqlRender::loadRenderTranslateSql(sqlFilename =  "iris_parameterized.sql",
                                             dbms = dbms,
                                             packageName = "Iris",
                                             cdmSchema = cdmSchema,
                                             cdmVersion = cdmVersion)

    writeLines("Executing Iris ...")
    result <- DatabaseConnector::querySql(conn, sql)

    # Execution duration
    executionTime <- Sys.time() - start
    writeLines(paste("Execution time:", format(executionTime)))

    # List of R objects to save
    objectsToSave <- c(
    	"result",
        "executionTime"
    	)

    # Results are small, so print to screen; should provide users with a sense of accomplishment
    print(result)

    # Save results to disk
    if (missing(file)) file <- getDefaultStudyFileName()
    saveOhdsiStudy(list = objectsToSave, file = file)

    # Clean up
    DBI::dbDisconnect(conn)

    # Package and return result if return value is used
    result <- mget(objectsToSave)
    class(result) <- "OhdsiStudy"
    invisible(result)
}


# execute2 <- function(connectionDetails,
#                     cdmVersion = 5,
#                     file = 'iris2results.ohdsi') {
#     #check version
#     if (cdmVersion == 4) {
#         stop("Iris was extended in 2016 to accomodate CDM v5 tables. Iris officialy only supports CDM v5.")
#     }
#
#
#     conn <- DatabaseConnector::connect(connectionDetails)
#     if (is.null(conn)) {
#         stop("Failed to connect to db server.")
#     }
#
#     # Record start time
#     start <- Sys.time()
#
#     # Load, render and translate SQL
#     sql <- SqlRender::loadRenderTranslateSql(sqlFilename =  "iris_parameterized_2.sql",
#                                              dbms = connectionDetails$dbms,
#                                              packageName = "Iris",
#                                              cdmSchema = connectionDetails$schema,
#                                              cdmVersion = cdmVersion)
#
#     writeLines(paste("Executing Iris Two on",connectionDetails$schema,"..."))
#     result <- DatabaseConnector::querySql(conn, sql)
#
#     # Execution duration
#     executionTime <- Sys.time() - start
#     writeLines(paste("Execution time:", format(executionTime)))
#
#     # List of R objects to save
#     objectsToSave <- c(
#         "result",
#         "executionTime"
#     )
#
#     # Results are small, so print to screen; should provide users with a sense of accomplishment
#     print(result)
#
#     # Save results to disk
#     if (missing(file)) file <- getDefaultStudyFileName()
#     saveOhdsiStudy(list = objectsToSave, file = file)
#
#     # Clean up
#     DBI::dbDisconnect(conn)
#
#     # Package and return result if return value is used
#     result <- mget(objectsToSave)
#     class(result) <- "OhdsiStudy"
#     invisible(result)
# }
#


#' @title Execute Iris Part  (testing new components)
#'
#' @details
#' This function executes a logical part of Iris (easier for testing of multiple parts)
#' @importFrom DBI dbDisconnect
#' @export
executePart <- function(part=1,connectionDetails,
                     cdmVersion = 5,
                     file = 'iris2results.ohdsi') {
    #check version
    if (cdmVersion == 4) {stop("Iris was extended in 2016 to accomodate CDM v5 tables. Iris officialy only supports CDM v5.")
    }


    conn <- DatabaseConnector::connect(connectionDetails)
    if (is.null(conn)) {
        stop("Failed to connect to db server.")
    }

    # Record start time
    start <- Sys.time()


    #get file name of the part
    fname=paste0('iris_parameterized_',part,'.sql')

    # Load, render and translate SQL

    sql <- SqlRender::loadRenderTranslateSql(sqlFilename =  fname,
                                             dbms = connectionDetails$dbms,
                                             packageName = "Iris",
                                             cdmSchema = connectionDetails$schema,
                                             cdm_database_schema = connectionDetails$schema,
                                             cdmVersion = cdmVersion,
                                             oracleTempSchema = connectionDetails$oracleTempSchema,
                                             target_database_schema=connectionDetails$target_database_schema,
                                             results_database_schema=connectionDetails$target_database_schema
                                             )

    #TODO ... suport parameters passed from initial function

    #cat(sql,file=paste0(connectionDetails$dbms,'-',fname))
    writeLines(paste("Executing Iris Part",part,'on',connectionDetails$schema,"..."))
    result <- DatabaseConnector::querySql(conn, sql)

    # Execution duration
    executionTime <- Sys.time() - start
    writeLines(paste("Execution time:", format(executionTime)))

    # List of R objects to save
    #objectsToSave <- c(        "result",        "executionTime"    )

    # Results are small, so print to screen; should provide users with a sense of accomplishment
    writeLines("Top few rows of result")
    print(head(result))
    result$dataset=connectionDetails$schema
    # Save results to disk
    write.csv(result,paste0(connectionDetails$schema,'-iris_part-',part,'.csv'),na='',row.names=F)
    #if (missing(file)) file <- getDefaultStudyFileName()
    #saveOhdsiStudy(list = objectsToSave, file = file)

    # Clean up
    DBI::dbDisconnect(conn)

    # Package and return result if return value is used
    #result <- mget(objectsToSave)
    #class(result) <- "OhdsiStudy"
    result
}


# writeLines("- Creating treatment cohort")
# sql <- SqlRender::loadRenderTranslateSql("Treatment.sql",
#                                          "CelecoxibVsNsNSAIDs",
#                                          dbms = connectionDetails$dbms,
#                                          oracleTempSchema = oracleTempSchema,
#                                          cdm_database_schema = cdmDatabaseSchema,
#                                          target_database_schema = workDatabaseSchema,
#                                          target_cohort_table = studyCohortTable,
#                                          cohort_definition_id = 1)
# #write to disk for review
# DatabaseConnector::executeSql(conn, sql)
#


#new function to extract small table (that fit into memory for manual inspection of results)
#' @export
#'
fetchResultsTable <- function (connectionDetails, resultsDatabaseSchema, tableName){
    connectionDetails$schema = resultsDatabaseSchema
    conn <- connect(connectionDetails)


    sql <- paste0("SELECT * FROM ",tableName)
    sql <- renderSql(sql)$sql
    res <- dbGetQuery(conn,sql)
    res
}

#experimental funtion with graphic output
#' @export
#'

doTree <- function(connectionDetails,
                    cdmDatabaseSchema,
                    resultsDatabaseSchema = cdmDatabaseSchema,
                    oracleTempSchema = resultsDatabaseSchema,
                    cdmVersion = 5,
                    outputFolder ='output'
                    ) {

    if (cdmVersion == 4) {
        stop("CDM version 4 not supported")
    }

    if (!file.exists(outputFolder))
        dir.create(outputFolder)

    # cmOutputFolder <- file.path(outputFolder, "cmOutput")
    # if (!file.exists(cmOutputFolder))
    #     dir.create(cmOutputFolder)

#connect
    connectionDetails$schema=resultsDatabaseSchema
    conn <- DatabaseConnector::connect(connectionDetails)

#get query


    sql <- "select stratum_1,
100.0*count_value/(select count_value as total_pts from @results_database_schema.achilles_results r where analysis_id =1) as statistic_value,
'ach_'+CAST(analysis_id as VARCHAR) + ':Percentage' as measure_id
from @results_database_schema.achilles_results
where analysis_id in (3)
    "
    sql <- SqlRender::renderSql(sql,results_database_schema = resultsDatabaseSchema)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    data <- DatabaseConnector::querySql(conn, sql)


#render tree
    names(data) <- tolower(names(data))
    cyear=as.numeric(format(Sys.Date(), "%Y"))
    data$age=cyear-as.numeric(data$stratum_1)

  ggplot2::ggplot(data=data, ggplot2::aes(x=age, y=statistic_value)) + ggplot2::geom_bar(stat="identity") + ggplot2::coord_flip()
  ggplot2::ggsave(file.path(outputFolder, "DemogrPyramid.png"), width = 9, height = 9, dpi= 200)


    # Clean up
    RJDBC::dbDisconnect(conn)
    writeLines("Done")
    output
}



#' Prototype inside Iris for AchillesShare
#' @export
achillesShare <- function (connectionDetails,
                      cdmDatabaseSchema,
                      oracleTempSchema = cdmDatabaseSchema,
                      resultsDatabaseSchema = cdmDatabaseSchema,
                      sourceName = "",
                      cdmVersion = "5",
                      vocabDatabaseSchema = cdmDatabaseSchema){

#TODO use the new function renderTranslateSql

    # cdmDatabase <- strsplit(cdmDatabaseSchema ,"\\.")[[1]][1]
    # resultsDatabase <- strsplit(resultsDatabaseSchema ,"\\.")[[1]][1]
    # vocabDatabase <- strsplit(vocabDatabaseSchema ,"\\.")[[1]][1]

#     achillesShareFile='AchillesShare_v5.sql'
#     achillesShareSql <- loadRenderTranslateSql(sqlFilename = achillesShareFile,
#                                           packageName = "Iris",
#                                           dbms = connectionDetails$dbms,
#                                           oracleTempSchema = oracleTempSchema,
#                                           cdm_database = cdmDatabase,
#                                           cdm_database_schema = cdmDatabaseSchema,
#                                           results_database = resultsDatabase,
#                                           results_database_schema = resultsDatabaseSchema,
#                                           source_name = sourceName,
#                                           list_of_analysis_ids = analysisIds,
#                                           createTable = createTable,
#                                           smallcellcount = smallcellcount,
#                                           validateSchema = validateSchema,
#                                           vocab_database = vocabDatabase,
#                                           vocab_database_schema = vocabDatabaseSchema
#     )
    # resultsDatabaseSchema='nih'

    #all fethich of results is from results schema, so switch to it
    #and there is no need for any prefixes in the tiny SQL calls below

    connectionDetails$schema=resultsDatabaseSchema
    conn <- DatabaseConnector::connect(connectionDetails)

    writeLines("Executing Achilles Share")
    a<-querySql(conn,'select count_value from achilles_results where analysis_id = 1;')
    total_pts<-a[1,1]

    # a<-querySql(conn,'select analysis_id, count(*) as cnt from achilles_results group by analysis_id')
    # print(head(a))
    # writeLines("----")
    print(total_pts)

    options(scipen = 999)
    #by # of observation periods
    op<-querySql(conn,'select analysis_id,stratum_1, count_value from achilles_results where analysis_id = 113 order by stratum_1')
    #average number of observation periods
    op$temp<-as.numeric(op$STRATUM_1) * op$COUNT_VALUE
    op_average<-sum(op$temp)/sum(op$COUNT_VALUE)
    op$temp<-NULL



    #print(a)


    #writeLines("---- by year  division")
    population_years<-querySql(conn,'select analysis_id,stratum_1, count_value from achilles_results where analysis_id = 3 order by stratum_1')


    #brief analyses
    brief<-querySql(conn,'select analysis_id,stratum_1, count_value from achilles_results where analysis_id in (0,410,510) order by analysis_id,stratum_1')
    #brief

    #brief distributions
    #brief_dist<-querySql(conn,'select analysis_id,AVG_VALUE,STDEV_VALUE from achilles_results_dist where analysis_id in (103,105,203,403,513)')
    brief_dist<-querySql(conn,'select analysis_id,AVG_VALUE,STDEV_VALUE from achilles_results_dist where analysis_id in (103,105,203,403,513)')
    brief_dist


    #writeLines(paste(total_pts))

    # early beta of PDF output
#     pdf(file=paste0(cdmDatabaseSchema,'-out.pdf'))
#     #print(a)
#     plot(a$STRATUM_1,a$COUNT_VALUE2)
#     dev.off()




    #output is subject to change

    output<-rbind(op,population_years,brief)
    output$statistic_value<-output$COUNT_VALUE/total_pts

    #derived measures
     #percentage of people with exactly one obs period

    one_op<- output[(output$ANALYSIS_ID==113) & (output$STRATUM_1=='1'),4]
    #if null make it NA
    one_op<-ifelse(is.null(one_op),NA,one_op)

    #for level 1 mask true values and wipe small rows
    output$COUNT_VALUE<-NULL
    output<-output[output$statistic_value>0.008,]
    output$ANALYSIS_ID<-output$ANALYSIS_ID+100000

    #mask dataset size into a class

    if (total_pts>100000000) {total_pts_class ='>100M'
        } else if(total_pts>10000000) {total_pts_class = '10-100M'
        } else total_pts_class = '<10M'
    #population size category
    #average for count of observation periods
    output<-rbind(output,
              data.frame(ANALYSIS_ID=110003,STRATUM_1=NA,statistic_value=total_pts_class)
             ,data.frame(ANALYSIS_ID=110004,STRATUM_1=NA,statistic_value=op_average)
             ,data.frame(ANALYSIS_ID=110005,STRATUM_1=NA,statistic_value=one_op)
             )






    # Clean up
    DBI::dbDisconnect(conn)
    writeLines("Done")
    output
}



# Package must provide a default gmail address to receive result files
#' @keywords internal
getDestinationAddress <- function() { return("nobody@gmail.com") }

# Package must provide a default result file name
#' @keywords internal
getDefaultStudyFileName <- function() { return("OhdsiIris.rda") }

# Packge must provide default email subject
#' @keywords internal
getDefaultStudyEmailSubject <- function() { return("OHDSI Iris Results") }
