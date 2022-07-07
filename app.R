.libPaths("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/r_library")
library(shiny)
library(shinyWidgets)
library(DT)
library(tidyverse)
library(openxlsx)

ui <- fluidPage(
  
  # Application title
  titlePanel("Editable Dataframe for Results Teams"),

  fluidRow(
    column(
      width = 6,
  inputPanel(
    selectInput(inputId = "pillar",
      label = "Select Pillar",
      choices = c("", unique(data$`Objective Name`))
    )
    )
  )
  ),
  
  # remaining $

  #   column(
  #     width = 6,
  #     statiCard(
  #       value = (total - sum(data$`FY23 Proposal`)),
  #       subtitle = "Money Left to Allocate in Proposal Phase",
  #       icon = NULL,
  #       left = FALSE,
  #       color = "green",
  #       background = "white",
  #       animate = FALSE,
  #       duration = 2000,
  #       id = NULL
  #     )
  #   )
  #   ),
    
    # main datatable
    fluidRow(
      DTOutput("my_datatable")
    )
  )

server <- function(input, output) {

  #initialize reactive dataframe
  df <- reactiveValues(data =  data %>% select(-`Program ID`, -`FY22 Adopted`, -`% - Change vs Adopted`,))
  
  df2 <- reactive({df2 <- if (input$pillar == "") {df2 <- df$data}
                          else if (input$pillar != "") {droplevels(filter(df$data, `Objective Name` == input$pillar))}
                            })
  
  #output the datatable based on the dataframe (and make it editable)
  output$my_datatable <- DT::renderDataTable({
    req(input$pillar)
    DT::datatable(df2(), editable = TRUE) 
  })
  
  #when there is any edit to a cell, write that edit to the initial dataframe
  #check to make sure it's positive, if not convert
  observeEvent(input$my_datatable_cell_edit, {
    #get values
    info = input$my_datatable_cell_edit
    i = as.numeric(info$row)
    j = as.numeric(info$col)
    k = as.numeric(info$value)
    if(k < 0){ #convert to positive if negative
      k <- k * -1
    }
    
    #write values to reactive
    df$data[i,j] <- k
  })
  
  #render plot
  # output$my_plot <- renderPlot({
  #   req(input$go) #require the input button to be non-0 (ie: don't load the plot when the app first loads)
  #   isolate(v$data) %>%  #don't react to any changes in the data
  #     ggplot(aes(x,y)) +
  #     geom_point() +
  #     geom_smooth(method = "lm")
  # })
  
}

# Run the application 
shinyApp(ui = ui, server = server)