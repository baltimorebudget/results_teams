data <- readxl::read_excel("G:/Fiscal Years/Fiscal 2023/Planning Year/7. Council/1. Line Item Reports/line_items_2022-06-24_Final.xlsx", sheet = "Details")

total <- max(data$`FY23 Proposal`)
  
data <- data %>% select(`Objective Name`, `Agency Name`, `Program ID`, `Program Name`, `FY22 Adopted`, `% - Change vs Adopted`, `FY23 CLS`, `FY23 Proposal`) %>%
  filter(!is.na(`Objective Name`))