library(httr)
library(magrittr)
library(lubridate)
library(assertthat)

##connect to API
connect_fs_api <- function() {
  list(
    key = Sys.getenv("FS_API_KEY"),
    endpoint = httr::oauth_endpoint(
      authorize = Sys.getenv("FS_OAUTH_AUTHORIZE"),
      access = "https://www.formstack.com/api/v2/oauth2/token"),
    app = httr::oauth_app(
      "R",
      key = Sys.getenv("FS_OAUTH_KEY"),
      secret = Sys.getenv("FS_OAUTH_SECRET"),
      redirect_uri = Sys.getenv("FS_OAUTH_REDIR"))
  )
}

api <- connect_fs_api()

##get data from API
form_id = 4871026

get_fs_submissions <- function(api, form_id, query) {
  # query
  httr::GET(paste0("https://www.formstack.com/api/v2/form/", form_id, "/submission.json"),
            add_headers(Authorization = paste("Bearer", api$key, sep = " ")),
            query = c(list(id = form_id,
                           data = 1,
                           per_page = 100), query),
            encode = "json") %>%
    httr::content()
}

extract_fs_submissions <- function(api, form_id, approved_only = FALSE) {
  
  payload <-
    get_fs_submissions(
      api = api,
      form_id = form_id,
      query = list(per_page = 100))
  
  # Then pull data from each of those pages into a master df
  x <- 1:payload$pages
  
  data <- map(x, function(x) {
    raw <- get_fs_submissions(
      api = api,
      form_id = form_id,
      query = list(page = x,
                   per_page = 100,
                   data = 1)) %>%
      extract2("submissions")
    
    time <- raw %>%
      map(extract2, "timestamp") %>%
      unlist()
    
    return(
      list(
        submissions = raw %>% # get only submission data; remove all payload data
          map(extract2, "data")  %>%
      set_names(time),
    approvals = raw %>%
      map(extract2, "approval_status")))
  })

# submissions are organized in lists by page;
# remove this list since we don't care what page each submission was on
submissions <- lapply(data, "[[", "submissions") %>%
  unlist(recursive = FALSE)

approvals <- sapply(data, "[[", "approvals") %>%
  unlist()

df <- map(1:length(submissions), function(x) {
  
  submissions[[x]] %>%
    toJSON() %>%
    fromJSON() %>%
    map(`[`, c("label", "value")) %>%
    bind_rows() %>%
    spread(label, value) %>%
    mutate(Timestamp = ymd_hms(names(submissions[x])))
})

df <- df %>%
  bind_rows() %>%
  mutate(`Approval Status` = approvals)

assert_that(are_equal(payload$total, nrow(df)))

if (approved_only) {
  df <- df %>%
    filter(`Approval Status` == "Approved")
}

return(df)
}



formstack <- extract_fs_submissions(api=api, form_id=form_id)
