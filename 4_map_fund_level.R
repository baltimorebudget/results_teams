.libPaths("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/r_library")
library(stringr)
library(stringi)
library(tidyr)
library(openxlsx)

devtools::load_all("G:/Analyst Folders/Sara Brumfield/bbmR")

df <- readxl::read_excel("G:/Analyst Folders/Sara Brumfield/exp_planning_year/2c_proposals_results_teams/outputs/MAP Action Detail from SharePoint.xlsx", sheet = "SharePoint") %>%
  mutate( `Service Name` = trimws(gsub('[0-9]+,', '', `City Service:Title`), which = "left"),
          `City Agency` = trimws(gsub('[0-9]+,', '', `City Service:Agency`), which = "left")) %>%
separate(col = "City Service:Title", into = c("Service Name 1", "Service Name 2", "Service Name 3",
                                          "Service Name 4"), sep = ", ", remove = TRUE) %>%
  unite(col = "Service IDs", c(`Primary Service ID`, `Additional Service ID`, `Secondary Service ID`, `Tertiary Service ID`, `Quaternary Service ID`), 
                                       sep = ", ", remove = TRUE, na.rm = TRUE) %>%
  select(-IDs, -`City Service`, -`Service Name 1`, -`Service Name 2`, -`Service Name 3`, -`Service Name 4`)

#laura's file
df2 <- readxl::read_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/Agency Guidance/MAP Action Detail_FY23 Funding.xlsx", sheet = "Sheet1") %>%
  mutate(`Action Plan Item Number` = as.character(`Action Plan Item Number`))

df3 <- left_join(df2, df %>% select(`Service IDs`, `Service Name`, `City Agency`, `Action`, `ActionOwnerLookupId`), by = "Action")

write.xlsx(df3, file = "G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/Agency Guidance/MAP Action Detail with Services_FY23 Funding.xlsx")


#fuck this shit======
# test <- df %>% mutate(`City Service` = gsub(pattern = ",", replacement = "", x = df$`City Service`, ignore.case = FALSE),
#                     `# Services` = ceiling(str_count(df$`City Service`, ",") /2),
#                     `Service ID` = strsplit(x = `City Service`, split = " "),
#                     `Test` = gsub(x = `Service ID`, pattern = "[c(),\"]", replacement = ""),
#                     `Test2` = substring(`Test`, regexpr("(^\\d{2,3}) (\\d{2,3}) (\\d{2,3})\\2", `Test`)))
                    # `Service ID` = str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\2"))
                    # `Service ID` = case_when(`# Services` == 1 ~
                    #                          str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\2"),
                    #                          # `# Services` == 2 ~
                    #                          #  c(str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\3"),
                    #                          #    str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\4")),
                    #                          # `# Services` == 3 ~
                    #                          #   c(str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\4"),
                    #                          #     str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\5"),
                    #                          #     str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\6")),
                    #                          # `# Services` == 4 ~
                    #                          #   c(str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\5"),
                    #                          #     str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\6"),
                    #                          #     str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\7"),
                    #                          #     str_extract(df$`City Service`, pattern = "(^\\d{2,3}) (\\d{2,3}) (\\d{2,3}) (\\d{2,3})\7")),
                    #                          TRUE ~ NA))



# df2 <- df %>% 
#   unite("Service IDs", `Service 1`:`Service 7`, sep = ",", remove = TRUE, na.rm = TRUE) %>%
#   separate(col = "Service IDs", into = c("Service ID 1", "Service ID 2", "Service ID 3", "Service ID 4", sep = ", ", remove = FALSE)) %>%
#   mutate( `Service Name` = trimws(gsub('[0-9]+,', '', `Service Name`), which = "left"),
#          `City Service:Agency` = trimws(gsub('[0-9]+,', '', `City Service:Agency`), which = "left")) %>%
#   separate(col = "Service Name", into = c("Service Name 1", "Service Name 2", "Service Name 3",
#                                           "Service Name 4"), sep = ", ", remove = TRUE)
# 
# df3 <- df2 %>% group_by(`PillarText`, `Goal`, `Action Plan Item Number`, `Action`, `Status`,
#                         `Service ID 1`, `Service Name 1`, `Service ID 2`, `Service Name 2`,
#                         `Service ID 3`, `Service Name 3`, `Service ID 4`, `Service Name 4`) %>%
#   summarise(`FY23 Needed` = sum(`FY23_Funding_Needed`, na.rm = TRUE),
#             `FY23 Funded` = sum(`FY23_Funding_Identified`, na.rm = TRUE)) %>%
#   mutate(`Fully Funded` = case_when(`FY23 Needed` <= `FY23 Funded` ~ "Yes",
#                                     TRUE ~ "No"))
# df4 <- df2 %>% group_by(`PillarText`, `Goal`, `Action Plan Item Number`, `Action`) %>%
#   summarise(`FY23 Needed` = sum(`FY23_Funding_Needed`, na.rm = TRUE),
#             `FY23 Funded` = sum(`FY23_Funding_Identified`, na.rm = TRUE)) %>%
#   mutate(`Fully Funded` = case_when(`FY23 Needed` <= `FY23 Funded` ~ "Yes",
#                                     TRUE ~ "No"))
# 
# df5 <- df3 %>% group_by(`Fully Funded`) %>%
#   summarise(Count = n()) %>%
#   mutate(`Percent` = Count / sum(Count))
# 
# export_excel(df3, file_name = "G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/Agency Guidance/Funding by MAP.xlsx", tab_name = "FY23 Funding by Goal and Action")
# export_excel(df4, file_name = "G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/Agency Guidance/Funding by MAP.xlsx", tab_name = "Funding without Service IDs", type = "existing")
# export_excel(df5, file_name = "G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/Agency Guidance/Funding by MAP.xlsx", tab_name = "Percent Funded Crosstab", type = "existing")