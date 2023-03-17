#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)

allPitches <- read.csv("pitchSpeeds.csv")
poptimeData <- read.csv("poptimeData.csv")
runnerData <- read.csv("runnerData.csv")


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Steal Success Probability"),
  
  # Sidebar with a slider input for lead distance 
  sidebarLayout(
    sidebarPanel(
      selectInput("pitcher", "Select Pitcher:", unique(allPitches$player_name)),
      selectInput("catcher", "Select Catcher:", unique(poptimeData$catcher)),
      selectInput("runner", "Select Runner:", unique(runnerData$full_name)),
      sliderInput("leadDist",
                  "Lead Distance:",
                  min = 0,
                  max = 90,
                  value = 5,
                  step = 5)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("ecdfPlot"),
      textOutput("pitchSpeed"),
      textOutput('stealSuccess')
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  pitchSpeed <- reactive({
    catcher_ru <- input$catcher
    
    runner_ru <- input$runner
    
    catcherData <- poptimeData %>%
      filter(catcher == catcher_ru)
    
    poptime <- catcherData$pop_2b_sba[1]
    
    dist_to_run <- 90 - input$leadDist
    
    stealerData <- runnerData %>%
      filter(full_name == toString(runner_ru))
    
    colToPull <- names(stealerData[endsWith(names(stealerData), paste('0', toString(dist_to_run), sep = ''))])
    
    stealTime <- stealerData[colToPull][[1,1]]
    
    pitchTime <- stealTime - (poptime + 1)
    
    pitchSpeed <- as.double(round((90/pitchTime)/1.467, digits = 1))
    
    pitchSpeed
    
  })
  
  output$pitchSpeed <- renderText({
    
      output <- paste('Max Pitch Speed to make it:', toString(pitchSpeed()), 'MPH')
      
      output
      
  })
  
  pitchECDF <- reactive({
    
    x <- allPitches %>%
      filter(player_name == input$pitcher)
    
    output <- ecdf(x$release_speed)
    
    output
    
  })
  
  output$ecdfPlot <- renderPlot({
    
    plot(pitchECDF(), col = 'darkgray',
         xlab = 'Pitch Speed',
         main = paste('Pitch Speed ECDF', input$pitcher))
    abline(v = pitchSpeed())
    
  })
  
  output$stealSuccess <- renderText({
    
    prob <- pitchECDF()(pitchSpeed())
    
    output <- paste('Probability of pitch below', toString(pitchSpeed()), ':', toString(round(prob * 100, 2)), '%')
    
    output
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
