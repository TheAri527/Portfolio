library(png) # For writePNG function
library(shiny)
library(dplyr)
library(ECharts2Shiny)

products =read.csv("products.csv")
products$Chemical.Composition <- products$Chemical.Composition*10
productDistinct = products %>% distinct(Product, Material.Type, Structure)

pieClean <- function(mat) {
  X = subset(products, Product == mat, select = c(Chemical, Chemical.Composition))
  value = rep(X[1,1], X[1,2])
  i = 2
  while(i <= nrow(X)){
    value <- unlist(list(value, rep(X[i,1], X[i,2])))
    i = i+1
  }
  as.character(value)
}

server <- function(input, output, session) {
  observeEvent(pieClean(input$material),{
    output$pie <- renderPieChart(div_id = "test", data = pieClean(input$material))
  })
  output$text <- renderText({ 
    paste("You have selected:", input$material)
  })
  output$type <- renderText({ 
    paste("Material Type:", productDistinct$Material.Type[productDistinct$Product == input$material])
  })
  output$structure <- renderText({ 
    paste0("Structure: ", productDistinct$Structure[productDistinct$Product == input$material])
  })
  # image2 sends pre-rendered images
  output$image2 <- renderImage({
    if (is.null(input$material))
      return(NULL)
    
    if (input$material == "Diamond") {
      return(list(
        src = "images/diamond.jpg",
        contentType = "image/jpeg", 
        width = "200%",
        height = "400px"
      ))
    } else if (input$material == "Steel") {
      return(list(
        src = "images/steel.jpg",
        filetype = "image/jpeg",
        width = "150%",
        height = "270px"
      ))
    } else if (input$material == "Glass") {
      return(list(
        src = "images/glass.jpg",
        filetype = "image/jpeg",
        width = "200%",
        height = "300px"
      ))
    }
    else if (input$material == "Red Brass") {
      return(list(
        src = "images/brass.jpg",
        filetype = "image/jpeg",
        width = "110%",
        height = "300px"
      ))
    }
    else if (input$material == "PET") {
      return(list(
        src = "images/plastic.jpg",
        filetype = "image/jpeg",
        width = "110%",
        height = "300px"
      ))
    }
    else if (input$material == "Nylon") {
      return(list(
        src = "images/nylon.jpg",
        filetype = "image/jpeg",
        width = "150%",
        height = "300px"
      ))
    }
    else if (input$material == "Wood") {
      return(list(
        src = "images/wood.jpg",
        filetype = "image/jpeg",
        width = "250%",
        height = "300px"
      ))
    }
    else if (input$material == "Clay") {
      return(list(
        src = "images/clay.jpg",
        filetype = "image/jpeg",
        width = "250%",
        height = "300px"
      ))
    }
    else if (input$material == "Graphite") {
      return(list(
        src = "images/graphite.jpg",
        filetype = "image/jpeg",
        width = "250%",
        height = "300px"
      ))
    }

  }, deleteFile = FALSE)
}

ui <- fluidPage(
  titlePanel("Chemistry of Materials"),
  
  fluidRow(
    column(2, wellPanel(
      selectInput("material", "Material:", 
                  choices=c("Diamond", "Steel", "Glass", "Red Brass", "PET", "Nylon", "Wood", "Clay", "Graphite"))
    )),
    column(2,
           textOutput("text"),
           textOutput("type"),
           textOutput("structure")
    ),
    column(2, 
           loadEChartsLibrary(),
           tags$div(id="test", style="width:100%;height:400px;"),
           deliverChart(div_id = "test")
    ),
    column(2,
           imageOutput("image2", height = "100px", width = "100%"))
  )
)

shinyApp(ui = ui, server = server)
