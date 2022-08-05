.libPaths("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/r_library")
library(markdown)
library(knitr)
library(scales)
library(tidyverse)
library(openxlsx)
library(dplyr)

#comes from Budget Book; Scorecard API
pms <- readxl::read_excel("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/GIT/agency_detail_py/budget_data/PM_Data.xlsx") %>%
  mutate(`Service ID` = as.numeric(`Service ID`)) %>%
  select(-`Extra PM Table`, -`Type`)

#comes from Scorecard's custom report: Program Notes
impacts <- readxl::read_excel("Program Notes.xlsx", skip = 2) %>%
  fill(`Title`, .direction = "down") %>%
  drop_na(`Note Text`) %>%
  select(`Title`, `Note Text`) %>%
  mutate(`Service ID` = as.numeric(substr(`Title`, start = 9, stop = 11))) %>%
  filter(!is.na(`Service ID`)) %>%
  mutate(`Answer` = case_when(substr(`Note Text`, start = 3, stop = 3) == ":" ~ "",
                                       TRUE ~ `Note Text`),
         `Note Text` = case_when(`Note Text` == `Answer` ~ "",
                                 TRUE ~ `Note Text`)) 

impacts["Note Text"][impacts["Note Text"] == ""] <- NA
impacts <- impacts %>%  
  fill(`Note Text`, .direction = "down") %>%
  rename(`Service Question` = `Note Text`, `Service Name` = `Title`) %>%
  group_by(`Service ID`, `Service Name`, `Service Question`) %>% 
  mutate(`Agency Response` = paste0(`Answer`, collapse = " "),
         `Question #` = as.numeric(substr(`Service Question`, start = 2, stop = 2)),
         `Agency Response` = case_when(`Agency Response` == "" ~ "No answer provided by agency.",
                                      TRUE ~ `Agency Response`)) %>%
  select(`Service ID`, `Service Name`, `Question #`,`Service Question`, `Agency Response`) %>%
  distinct()


#from Scorecard's custom report Story Behind the Curve
story <- readxl::read_excel("Story Behind the Curve.xlsx", skip = 5) %>%
  select(`Agency`, `Service`, `PM`, `Note Text`) %>%
  mutate(`Service ID` = as.numeric(substr(`Service`, start = 9, stop = 11))) %>%
  filter(!is.na(`Service ID`)) %>%
  filter(!duplicated(paste(`Service ID`, `PM`))) %>%
  select(`Service ID`, `PM`, `Note Text`) %>%
  group_by(`Service ID`, `PM`) %>%
  mutate(`Story` = paste0(`Note Text`, collapse = "\\n")) %>%
  ungroup() %>%
  select(-`Note Text`) %>%
  drop_na(`Service ID`)

for (i in unique(pms$`Service ID`)) {
  rmarkdown::render("service_pages.Rmd", 
                    output_file = paste0(unique(data$`Objective Name`[data$`Program ID`==i]), "-", i, " Results Teams Data.pdf"))
}