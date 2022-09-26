library(reshape)
library(tidyr)
library(naniar)
devtools::load_all("G:/Analyst Folders/Sara Brumfield/bbmR")

conn <- sharepointLogin()
lists <- sharepointConnect(conn)$get_list("MAP Action Detail")
sharepoint_cols <- unique(lists$list_items())
mayor_ap <- lists$list_items() %>%
  select(`ActionUID`, `PillarText`, `Goal_x0020_Text`, `field_0`, `Title`, `field_4`, `field_30`, `field_31`,
         `City_x0020_Service`, `City_x0020_Service_x003a_Title`, `City_x0020_Service_x003a_Agency`, `Partner_x0020_Agencies`, `PossibleARPAFunding_x003f_`)%>%
  rename(Action = Title, Status = field_4, `Action Plan Item Number` = field_0, Index = ActionUID, Goal = `Goal_x0020_Text`,
         `FY23_Funding_Needed` = field_30, `FY23_Funding_Identified` = field_31,
         `Service Name` = City_x0020_Service_x003a_Title) %>%
  filter(PillarText != "REMOVE") %>%
  arrange("PillarText", "Goal", "Action")

#unpack nested lists
rowwise() %>% 
  mutate(name = paste(
    unlist(
      lapply(str_split(name, ' '), function(x){
        str_sub(x, 1, 3)
      })
    ), 
    collapse = "_"
  ))

#remove lookup ids manually in Excel download
export_excel(mayor_ap, "SharePoint", "outputs/MAP Action Detail from Sharepoint.xlsx")

##funding for Bob
# export_excel(mayor_ap, "FY23 Funding", "outputs/MAP Action Detail_FY23 Funding.xlsx")

df <- readxl::read_excel("outputs/MAP Services Master.xlsx")

#remove lookupids from cols
test <- df %>% select(`PillarText`, `Goal`, `Action`, starts_with("Service")) %>%
  relocate("Service Name", .after = "Action")
# test <- df %>% select(`PillarText`, `Goal`, `Action`, `City Service`, `Service Name`) %>% 
#   separate(`City Service`, into = c("ID1", "ID2", "ID3", "ID4", "ID5", "ID6", "ID7", "ID8"), sep = ", ") 

# test_half <- test %>%
#   mutate(
#          ID4 = case_when(!is.na(ID8) ~ "",
#                          TRUE ~ ID4),
#          ID3 = case_when(!is.na(ID7) ~ "",
#                          TRUE ~ ID3),
#          ID2 = case_when(!is.na(ID6) ~ "",
#                          TRUE ~ ID2),
#          ID1 = case_when(!is.na(ID5) ~ "",
#                          TRUE ~ ID1))

#first value is lookup value
test2 <- df %>% cbind(df[1:4], stack(df[5:10]))

test3 <- test2[, c(12:16)]  %>%
  mutate(values = as.numeric(values)) %>%
  filter(!is.na(values)) %>%
  distinct() 

test3 %>% group_by(`PillarText`) %>%
  summarise(n())

test4 <- data %>% select(`Program ID`, `Program Name`) %>% distinct()

test5 <- right_join(test3, test4, by = c("values"="Program ID")) %>%
  filter(!is.na(`Program Name`)) %>%
  rename(`AP Pillar` = `PillarText`, `Service ID` = values)

svcs <- test5 %>% filter(!is.na(test5$`AP Pillar`)) %>% select(`Service ID`) %>% distinct()

dim(svcs)

export_excel(test5, "Services not in MAP", "outputs/Services not in MAP.xlsx")

##Scorecard PMs=====
pms <- readxl::read_excel("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/GIT/agency_detail_py/budget_data/PM_Data.xlsx") %>%
  mutate(`Service ID` = as.numeric(`Service ID`)) %>%
  select(`Service ID`, `Service Name`, `Measure`) %>%
  filter(!duplicated(Measure))

svcs <- pms %>% select(`Service ID`) %>% distinct()

df <- data.frame(svcs)

df2 <- full_join(df, pms, by = c("Service.ID" = "Service ID")) 

df3 <- full_join(df2, test5, by = c("Service.ID" = "Service ID")) %>%
  select(`Service.ID`, `Program Name`, `Measure`, `Action`, `Goal`) %>%
  rename(`Scorecard Measure` = `Measure`, `Mayor's Action` = `Action`)

df4 <- df3 %>% select(`Service.ID`, `Program Name`, `Scorecard Measure`, `Mayor's Action`, `Goal`) %>%
  group_by(`Service.ID`, `Program Name`, `Scorecard Measure`) %>%
  mutate(`Mayor's Actions` = paste(`Mayor's Action`, collapse = "; AND "),
         `Mayor's Goals` = paste(`Goal`, collapse = "; AND "),
         `Keep Scorecard PM?` = "") %>%
  select(-`Mayor's Action`, -`Goal`) %>%
  distinct() %>%
  relocate("Keep Scorecard PM?", .after = "Scorecard Measure")
  

export_excel(df4, "Scorecard MAP", "outputs/Scorecard MAP.xlsx")