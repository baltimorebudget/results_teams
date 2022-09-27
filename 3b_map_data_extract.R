# devtools::install_github("Azure/Microsoft365R")
library(Microsoft365R)
library(AzureAuth)
library(AzureGraph)
library(stringr)

devtools::load_all("G:/Analyst Folders/Sara Brumfield/bbmR")


data <- readxl::read_excel("G:/Fiscal Years/Fiscal 2023/Projections Year/1. July 1 Prepwork/Appropriation File/Fiscal 2023 Appropriation File_With_Positions_WK_Accounts.xlsx", sheet = "FY23 Appropriation File")

total <- max(data$`FY23 Adopted`)
  
df <- data %>% select(`Objective Name`, `Agency ID`, `Agency Name`, `Program ID`, `Program Name`, `Fund Name`, `DetailedFund Name`, `FY23 Adopted`) %>%
  filter(!is.na(`Objective Name`))

#Mayor's Action Plan goals, actions and measures
conn <- sharepointLogin()
lists <- sharepointConnect(conn)$get_list("MAP Action Detail")
mayor_ap <- lists$list_items() 

# test <- mayor_ap %>% select(City_x0020_Service) %>% unnest(col = City_x0020_Service, names_repair = "universal", keep_empty = TRUE)
# test <- mayor_ap %>% select(City_x0020_Service) %>% rowwise() %>%mutate(New = list(unlist(City_x0020_Service)))
# test <- test %>% mutate(`Service IDs` = string_extract(pattern = '(?<=LookupValue[\\d] = ")\\d{3}', string = New))

mayor_ap <- mayor_ap %>%
  select(`ActionUID`, `PillarText`, `Goal_x0020_Text`, `field_0`, `Title`, `field_4`, 
         `City_x0020_Service`, `City_x0020_Service_x003a_Title`, `City_x0020_Service_x003a_Agency`, 
         `Partner_x0020_Agencies`, `PossibleARPAFunding_x003f_`, `ActionOwnerLookupId`)%>%
  rename(Action = Title, Status = field_4, `Action Plan Item Number` = field_0, Index = ActionUID, Goal = `Goal_x0020_Text`) %>%
  filter(PillarText != "REMOVE") %>%
  arrange("PillarText", "Goal", "Action")

mayor_ap <- mayor_ap %>% rowwise() %>% mutate(IDs = as.character(list(unlist(City_x0020_Service))))

mayor_ap <- mayor_ap %>% mutate(`Primary Service ID` = str_extract(string = IDs, pattern = '(?<=LookupValue = ")\\d{3}'),
                                `Additional Service ID` = str_extract(string = IDs, pattern = '(?<=LookupValue1 = ")\\d{3}'),
                                 `Secondary Service ID` = str_extract(string = IDs, pattern = '(?<=LookupValue2 = ")\\d{3}'),
                                `Tertiary Service ID` = str_extract(string = IDs, pattern = '(?<=LookupValue3 = ")\\d{3}'),
                                `Quaternary Service ID` = str_extract(string = IDs, pattern = '(?<=LookupValue4 = ")\\d{3}')) %>%
  select(-IDs)
                                # `Service IDs` = case_when(length(mayor_ap$IDs) == 1 ~
                               #                             mayor_ap$IDs[[2]],
                               #                           # length(mayor_ap$IDs) == 2 ~
                               #                           #   paste(mayor_ap$IDs[[1]][[2]],mayor_ap$IDs[[1]][[4]]),
                               #                           # length(mayor_ap$IDs) == 3 ~
                               #                           #   paste(mayor_ap$IDs[[1]][[2]],mayor_ap$IDs[[1]][[4]],mayor_ap$IDs[[1]][[6]]),
                               #                           # length(mayor_ap$IDs) == 4 ~
                               #                           #   paste(mayor_ap$IDs[[1]][[2]],mayor_ap$IDs[[1]][[4]],mayor_ap$IDs[[1]][[6]],mayor_ap$IDs[[1]][[8]]),
                                                         # TRUE ~ NA))

export_excel(mayor_ap, "SharePoint", "outputs/MAP Action Detail from Sharepoint.xlsx")

