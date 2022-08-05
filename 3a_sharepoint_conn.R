#' connection to graph api
#'
#' using secret to connect to graph API
#'
#' @return  graph API connection object
#' @export
#' 
sharepointLogin <- function(){
  AzureGraph::create_graph_login(tenant = "bmore", 
                                 app=Sys.getenv("GRAPH_APP_ID"), 
                                 password=Sys.getenv("GRAPH_SECRET") )
}


#' connection to MORP sharepoint
#'
#' connects to MORP sharepoint
#'
#' @param conn graph api connection object
#' @return  connection object for MORP sharepoint
#' @export
#' 
sharepointConnect <- function(conn){
  
  require(Microsoft365R)
  conn$get_sharepoint_site(site_url = "https://bmore.sharepoint.com/sites/Mayor'sActionPlan/")
}


#' connection to MORP sharepoint document library
#'
#' connection to MORP sharepoint document library
#'
#' @param conn graph api connection object
#' @return  connection object for MORP sharepoint doc
#' @export
#' 
sharepointDocConnect <- function(conn){
  conn$get_sharepoint_site(site_url = "https://bmore.sharepoint.com/sites/Mayor'sActionPlan/")$get_drive()
}



#' read doc from sharepoint library
#'
#' connection to MORP sharepoint document library in subfolder "Data resources/automated_data_cache"
#'
#' @param csv_file name of file you want
#' @param sp_doc_conn sharepoint Doc connection
#' @return  connection object for MORP sharepoint doc
#' @export
#' 
sharepointReader <- function(csv_file, sp_doc_conn){
  
  whole_path <- paste0("output/",
                       csv_file)
  
  on.exit( try(unlink(csv_file)), add = T)
  sp_doc_conn$get_item(whole_path)$download()
  
  
  df <- read_csv(csv_file, lazy = F)
  
  
  return(df)
}

