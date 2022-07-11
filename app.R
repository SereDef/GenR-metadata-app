# Hi, this is a quick set up for the application interface to search in GenR
# This is still very much work in progress so please if you have any suggestions 
# or you want to help shoot me an email at s.defina@erasmusmc.nl

# import the libraries we are going to need
library(shiny)

# point to the script the does the search 
source("select.R")
# point to the dataframe with all data 
qsum <- read.csv("data/quest_meta.csv")

################################################################################
# ----------------------- Define UI for dataset viewer app  --------------------
################################################################################

# The function fluidPage creates a display that automatically adjusts to the 
# dimensions of user’s browser window. You lay out the user interface of the app 
# by placing elements in the fluidPage function.
  
ui <- fluidPage(titlePanel(h1("Generation R metadata app", # Add title panel
                              style='font-family:verdana; font-weight: bold; font-size:30pt;
                              color:#0C3690; background-color:#B6CCE7;
                              padding: 10px 20px 10px 30px;')), 
  
  sidebarLayout( # Define a sidebar panel and a main panel layout 
                 # with input and output definitions respectively 
                 # note: optional argument position = "right"to move the sidebar 
    
    # Main panel for displaying inputs -----------------------------------------
    sidebarPanel( 
      p("Hello, welcome and thank you for your help. Let's try to label some Generation R data."),
      # Display Input widgets next to labels
      # tags$head( tags$style(type="text/css", "label{ display: table-cell; text-align: right; vertical-align: top; } .form-group { display: table-row;}")),
      tags$head( tags$style('h3 {color:#0C3690;}') ),
      fluidRow(
        column(4, h3('Selection pane'),
               selectInput("GR_number", label = "GR-number", 
                           choices = list("all"="all", "GR1001"="GR1001", "GR1002"="GR1002", "GR1003"="GR1003", "GR1004"="GR1004", "GR1005"="GR1005", 
                                          "GR1018"="GR1018", "GR1019"="GR1019", "GR1024"="GR1024", "GR1025"="GR1025", "GR1028"="GR1028", "GR1060"="GR1060", 
                                          "GR1029"="GR1029", "GR1062"="GR1062", "GR1032"="GR1032", "GR1064"="GR1064", "GR1065"="GR1065", "GR1066"="GR1066", 
                                          "GR1067"="GR1067", "GR1075"="GR1075", "GR1076"="GR1076", "GR1079"="GR1079", "GR1080"="GR1080", "GR1081"="GR1081", 
                                          "GR1082"="GR1082", "GR1083"="GR1083", "GR1084"="GR1084", "GR1093"="GR1093", "GR1094"="GR1094", "GR1095"="GR1095", 
                                          "GR1096"="GR1096", "GR1097"="GR1097", "COVID"="COVID", "NA"="NA"), selected = "all"),
               selectInput("GR_section", label = "GR-section", 
                           choices = list("all"="all", "NA"="NA", "A"="A", "B"="B", "C"="C", "D"="D", "E"="E", "F"="F", "G"="G", "H"="H", "I"="I", "J"="J", "K"="K"), 
                           selected = "all"),
               p("Type (part of) the file name you want to select. This one is case sensitive."),
               textInput("orig_file", label = "Filename", value = ""),
               p("Type (part of) the variable name or label you want to select."),
               textInput("var_name", label="Variable", value = ""),
               checkboxInput("var_name_t", label = "Variable name", value = T),
               checkboxInput("var_label_t", label = "Variable label", value = F),
        ), # end first column
        column(4, h3("Assignment pane"),
               selectInput("a_GR_section", label = "GR-section", 
                           choices = list("none"="none", "A"="A", "B"="B", "C"="C", "D"="D", "E"="E", "F"="F", "G"="G", "H"="H", "I"="I", "J"="J", "K"="K"), 
                           selected = "all"),
               textInput("a_numbers", label = "Question number(s)", value = ""),
               p("You can genetate an approximate list and it paste above."),
               column(6, numericInput("fromn", label = "From", value = 1)),
               column(6, numericInput("ton",   label = "To", value = 10)),
               column(6, numericInput("sub1", label = "Sub-quest 1", value = NULL)),
               column(6, numericInput("sub2", label = "Sub-quest 2", value = NULL)),
               
               column(4, radioButtons("a_subject", label = "Subject", 
                                      choices = list("child"=1,"mother"=2,"partner"=3), selected = character(0)) ),
               column(4, radioButtons("a_reporter", label = "Reporter", 
                                      choices = list("child"=1,"mother"=2,"partner"=3), selected = character(0)) ),
               column(4, radioButtons("varcomp", label = "Variable type", 
                                      choices = list("item" =1, "score"=2), selected = character(0)) ),
        ), # end second column
        column(4, br(),br(),br(),
               textInput("questionnaire", label = "Questionnaire", value = "Name [abbreviaiton] if applicable..."),
               textInput("questionn_ref", label = "Reference", value = "DOI if applicable..."),
               textInput("constructs", label = "Construct(s)", value = "Describe what it measures..."),
               radioButtons("focus_cohort", label = "Focus cohort", 
                            choices = list("No" = 1, "Yes" = 2), selected = 1),
               br(),br(),
               actionButton("undo", label = "Undo selection", style="display: block; margin-left: auto; margin-right: auto;"),br(),
               actionButton("action", label = "Assign", style="display: block; margin-left: auto; margin-right: 2;
                            color: #0C3690; background-color: #B6CCE7; border-color: #0C3690"),
        ) # end third column  
      ), # end Fluidrow
      width = 12), # end Sidebarpanel 
    
    # Main panel for displaying outputs ----------------------------------------
    mainPanel(
      tabsetPanel(
        tabPanel("Selection", br(), 
                 
                 h5("You have selected:", span(textOutput("sel_GR_number", inline=T), style="color:#0C3690"), ' - ', 
                    span(textOutput("sel_GR_section", inline=T), style="color:#0C3690"), ' section.'),
                 h5("Seraching for files containing:", span(textOutput("sel_orig_file", inline=T), style="color:#0C3690")),
                 h5("Seraching for variables containing:", span(textOutput("sel_var_name", inline=T), style="color:#0C3690")),
                 br(),
                 h5("Output has", span(textOutput("n_selected", inline=T), style="color:#0C3690"), " rows"),
                 br(),
                 h5("Numbers:"), textOutput("n_generated"),
                 br(),
                 a("https://generationr.nl/"), # Hyperlink to generation R website
                 img(src = "generation-r-logo.png", height = 140, 
                     style="display: block; margin-left: auto; margin-right: 0;") 
                 ),
        
        tabPanel("Check",
                 tableOutput("view")
                 ) 
                 
      ), # end tabsetPanel
    width = 12) # end mainPanel
  ) # end Sidebarlayout
) # end Fluidpage



################################################################################
# ------------------ Define server logic to view selected dataset  -------------
################################################################################

server <- function(input, output) {
  
    # You can access the value of the widget with input$select, e.g.
    output$sel_GR_number <- renderText({ input$GR_number })
    output$sel_GR_section <- renderText({ input$GR_section })
    output$sel_orig_file <- renderText({ input$orig_file })
    output$sel_var_name <- renderText({ input$var_name })
    
    output$view <- renderTable({ searchselection(t = qsum, 
                                 GR_number = input$GR_number, 
                                 GR_section = input$GR_section, 
                                 files = input$orig_file, 
                                 variable = input$var_name, search_names=input$var_name_t, search_labels=input$var_label_t) })
    
    output$n_selected <- renderText({ searchselection(t = qsum, 
                                 GR_number = input$GR_number, 
                                 GR_section = input$GR_section, 
                                 files = input$orig_file, 
                                 variable = input$var_name, search_names=input$var_name_t, search_labels=input$var_label_t,
                                 ret_n =T) })
    
    output$n_generated <- renderText({ paste0(generate_numbers(start=input$fromn, end=input$ton, sublevel=input$sub1, sublevel2=input$sub2), ', ') })
}
    
################################################################################
# --------------------------- MAKE IT ALIVE & SHINY  ---------------------------
################################################################################

shinyApp(ui = ui, server = server)

