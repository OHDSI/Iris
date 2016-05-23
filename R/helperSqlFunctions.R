#

#' DataSetConnection object to facilitate passing additional server parameters to parametized SQL
#' @export

createDataSetConnectionDetails <-function(connectionDetails,cdmDatabaseSchema,resultsDatabaseSchema,vocabDatabaseSchema=cdmDatabaseSchema,cdmVersion="5",oracleTempSchema=NULL){
    dataSetConnectionDetails<-connectionDetails
    dataSetConnectionDetails$cdmDatabaseSchema=cdmDatabaseSchema
    dataSetConnectionDetails$resultsDatabaseSchema=resultsDatabaseSchema
    dataSetConnectionDetails$vocabDatabaseSchema=vocabDatabaseSchema
    dataSetConnectionDetails$cdmVersion=cdmVersion #idealy this would be read from metadata
    dataSetConnectionDetails$oracleTempSchema=oracleTempSchema
    #set class type here
    dataSetConnectionDetails
}

#' render parametized SQL using parameters from the dataSetConnectionDetails object
#' @export
#'

renderTranslateSql <- function(dataSetConnectionDetails,parameterizedSql,
                                    ...,
                                    oracleTempSchema = NULL) {
#     pathToSql <- system.file(paste("sql/", gsub(" ", "_", dbms), sep = ""),
#                              sqlFilename,
#                              package = packageName)
#
    mustTranslate <- dataSetConnectionDetails$dbms!='sql server'

    renderedSql <- renderSql(parameterizedSql,
                             cdmDatabaseSchema=dataSetConnectionDetails$cdmDatabaseSchema,
                             resultsDatabaseSchema=dataSetConnectionDetails$resultsDatabaseSchema,
                             vocabDatabaseSchema=dataSetConnectionDetails$vocabDatabaseSchema,
                             cdmVersion=dataSetConnectionDetails$cdmVersion,
                              ...)$sql

    if (mustTranslate)
        renderedSql <- translateSql(renderedSql,sourceDialect =  "sql server",
                                    targetDialect = dataSetConnectionDetails$dbms,
                                    oracleTempSchema = dataSetConnectionDetails$oracleTempSchema)$sql

    renderedSql
 }








#' @export
achillesShare <- function (connectionDetails,
                      cdmDatabaseSchema,
                      oracleTempSchema = cdmDatabaseSchema,
                      resultsDatabaseSchema = cdmDatabaseSchema,
                      sourceName = "",
                      cdmVersion = "5",
                      vocabDatabaseSchema = cdmDatabaseSchema){


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
