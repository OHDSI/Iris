#' @title Execute OHDSI Iris
#'
#' @details
#' This function executes OHDSI Iris and emails the results directly to Vojtech Huser.
#' Iris ...  (GIVE SOME DETAILS).
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
                    cdmVersion = 4,
                    file) {
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

# Package must provide a default gmail address to receive result files
#' @keywords internal
getDestinationAddress <- function() { return("nobody@gmail.com") }

# Package must provide a default result file name
#' @keywords internal
getDefaultStudyFileName <- function() { return("OhdsiIris.rda") }

# Packge must provide default email subject
#' @keywords internal
getDefaultStudyEmailSubject <- function() { return("OHDSI Iris Results") }
