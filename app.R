library(shiny)
library(shinydashboard) 
library(plotly)
library(shinyWidgets)
library(tidyr)
source('testing.R')
source("get_entities.R")

ui <- dashboardPage(
  dashboardHeader(title = "Proyecto Mentzer"),
  dashboardSidebar(sidebarMenu(
    menuItem(tabName = "home", text = "Home", icon = icon("home")),
    menuItem(tabName = "another", text = "Another Tab", icon = icon("heart"))
  )),
  dashboardBody(
    fluidRow(
      box(plotlyOutput("timeseries"), width = 9, height = 500),
      box(width = 3,
        title = "Controles",
        pickerInput(
          inputId = "Id008",
          label = "Elegir entidad", 
          choices = regions$name,
          multiple = TRUE,
          selected = "Distrito Capital",
          options =  list("tick-icon" = "glyphicon glyphicon-ok-sign"),
          choicesOpt = list(
            subtext = entities$type

        )),
      pickerInput(
        inputId = "Id010",
        label = "Elegir ISP", 
        choices = isp$name,
        multiple = TRUE,
        options =  list("tick-icon" = "glyphicon glyphicon-ok-sign"),
        choicesOpt = list(
          subtext = entities$type
          
        ))
      ,
       airDatepickerInput(
         inputId = "Id009",
         timepicker = TRUE,
         range = TRUE,
         todayButton = TRUE
       ),
      materialSwitch(
        inputId = "Id006",
        label = "Moving Average", 
        status = "primary",
        right = TRUE
      ),
      materialSwitch(
        inputId = "Id007",
        label = "Normalize", 
        status = "primary",
        right = TRUE
      )),
      box(textOutput("text"))
      
      
    )
  )
)

server <- function(input, output) {
  
  
test_dataframe <- reactive({
  
  req((isTruthy(input$Id008)|| isTruthy(input$Id010))
      ,length(input$Id009) == 2)
  
  extract_df(region_input=input$Id008,
             date_list = input$Id009,
             normalize_bool= input$Id007,
             moving_average = input$Id006,
             isp_req = input$Id010)})


# output$text<- renderPrint(input$Id010)



output$text<- renderPrint(input$Id010)
  output$timeseries <- renderPlotly({
    
    plot_ly(test_dataframe(),
            x= ~date,
            y= ~values,
            color = ~entityName,
            type = 'scatter',
            mode = 'lines+markers') %>% 
      layout(height = 480, legend = list( y = -0.2, orientation = 'h'),
             xaxis = list(visible = 'FALSE',title = "Time(UTC)"),
             yaxis = list(rangemode = 'tozero',title = "#/24s Up (%)")
             )

  })
}
shinyApp(ui, server)