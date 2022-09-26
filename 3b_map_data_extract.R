# devtools::install_github("Azure/Microsoft365R")
library(Microsoft365R)
library(AzureAuth)
library(AzureGraph)

devtools::load_all("G:/Analyst Folders/Sara Brumfield/bbmR")


data <- readxl::read_excel("G:/Fiscal Years/Fiscal 2023/Projections Year/1. July 1 Prepwork/Appropriation File/Fiscal 2023 Appropriation File_With_Positions_WK_Accounts.xlsx", sheet = "FY23 Appropriation File")

total <- max(data$`FY23 Adopted`)
  
df <- data %>% select(`Objective Name`, `Agency ID`, `Agency Name`, `Program ID`, `Program Name`, `Fund Name`, `DetailedFund Name`, `FY23 Adopted`) %>%
  filter(!is.na(`Objective Name`))

#Mayor's Action Plan goals, actions and measures
conn <- sharepointLogin()
lists <- sharepointConnect(conn)$get_list("MAP Action Detail")
mayor_ap <- lists$list_items() %>%
  select(`ActionUID`, `PillarText`, `Goal_x0020_Text`, `field_0`, `Title`, `field_4`, 
         `City_x0020_Service`, `City_x0020_Service_x003a_Title`, `City_x0020_Service_x003a_Agency`, `Partner_x0020_Agencies`, `PossibleARPAFunding_x003f_`)%>%
  rename(Action = Title, Status = field_4, `Action Plan Item Number` = field_0, Index = ActionUID, Goal = `Goal_x0020_Text`) %>%
  filter(PillarText != "REMOVE") %>%
  arrange("PillarText", "Goal", "Action")

export_excel(mayor_ap, "SharePoint", "outputs/MAP Action Detail from Sharepoint.xlsx")

