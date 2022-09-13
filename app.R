# Hi, this is a quick set up for the application interface to search in GenR
# This is still very much work in progress so please if you have any suggestions 
# or you want to help shoot me an email at s.defina@erasmusmc.nl

# Load required r packages
r_pack <- c('shiny', 'reticulate')
invisible(lapply(r_pack, require, character.only = T));

# Load required python packages
py_pack <- c('pandas', 'typing')
for (pack in py_pack) {
  if (!pack %in% py_list_packages()$package) { py_install(pack) }
}

# point to the script the does the search 
# source('select.R')
source_python('label_metadata.py')

logfile <- file.path(getwd(), 'logfile.txt')
if (!file.exists(logfile)){
  file.create(logfile)
}

qsum <- read.csv('data/quest_meta.csv')

################################################################################
# ----------------------- Define UI for dataset viewer app  --------------------
################################################################################

# The function fluidPage creates a display that automatically adjusts to the 
# dimensions of user’s browser window. You lay out the user interface of the app 
# by placing elements in the fluidPage function.
  
ui <- fluidPage(titlePanel(h1('Generation R metadata app', # Add title panel
                              style='font-family:verdana; font-weight: bold; font-size:30pt;
                              color:#0C3690; background-color:#B6CCE7;
                              padding: 10px 20px 10px 30px;')), 
  
  sidebarLayout( # Define a sidebar panel and a main panel layout 
                 # with input and output definitions respectively 
                 # note: optional argument position = 'right'to move the sidebar 
    
    # Main panel for displaying inputs -----------------------------------------
    sidebarPanel( 
      p("Hello, welcome and thank you for your help. Let's try to label some Generation R data."),
      # Display Input widgets next to labels
      # tags$head( tags$style(type='text/css', 'label{ display: table-cell; text-align: right; vertical-align: top; } .form-group { display: table-row;}')),
      tags$head( tags$style('h3 {color:#0C3690;}') ),
      fluidRow(
        column(4, fluidRow(style = "width:350px", h3('Selection pane'),
               p('Type (part of) the variable name or label you want to select.'),
               textInput('selection', label='Search for:', value = ''),
               column(12, selectInput('based_on', label = 'Based on:', choices=list('Variable name'='var_name','Variable label'='var_label',
                                                                         'Timepoint'='timepoint','Questionnaire'='questionnaire',
                                                                         'Constructs'='constructs','Original file'='orig_file'), 
                            selected = 'var_name')),
               column(8, selectInput('sel_type', label = 'Search type:', 
                                     choices=list('Contains'='contains','Starts with'='starts','Ends with'='ends','Equal to'='is'), 
                                     selected = 'contains')),
               column(3, h1(),checkboxInput('case_sensy', label = 'Case sensitive', value = F))
               ), # end first fluid row (selection 1)
               fluidRow(style = "width:350px", p('Include additional selection criteria.'),
               textInput('selection2', label='Also search for:', value = ''),
               selectInput('based_on2', label = 'Based on:', 
                           choices=list('Variable name'='var_name','Variable label'='var_label',
                                        'Data source'='data_source', 'Timepoint'='timepoint','Questionnaire'='questionnaire',
                                        'Constructs'='constructs','Original file'='orig_file'), 
                                      selected = 'data_source')
               )), # end first column # end second fluidRow (selection 2)
        column(4, fluidRow(style = "width:350px",h3('Assignment pane'),
               textInput('a_data_source', label = 'Data source', value = NULL),
               textInput('a_var_label', label = 'Variable label', value = NULL),
               column(4, radioButtons('a_subject', label = 'Subject', 
                                      choices = list('child'='child','mother'='mother','partner'='partner'), selected = character(0)) ),
               column(4, radioButtons('a_reporter', label = 'Reporter', 
                                      choices = list('child'='child','mother'='mother','partner'='partner'), selected = character(0)) ),
               column(4, radioButtons('a_var_comp', label = 'Variable type', 
                                      choices = list('item'='item', 'score'='score'), selected = character(0)) )
               ),# end first fluid row
               fluidRow(style = "width:350px",
               textInput('a_questionnaire', label = 'Questionnaire', value = NULL),
               textInput('a_questionn_ref', label = 'Reference', value = NULL),
               textInput('a_constructs', label = 'Construct(s)', value = NULL)
               )), # end second column # end second fluidRow (Assignment 2)
        column(4, h3(' ~~~~~~~~~~~~~~~~~~ '),
               textInput('a_timepoint', label = 'Timepoint', value = NULL),
               textInput('a_gr_section', label = 'Section', value = NULL),
               textInput('a_gr_qnumber', label = 'Question number(s)', value = NULL),
               p('You can genetate an approximate list and it paste above.'),
               column(6, numericInput('fromn', label = 'From', value = 1)),
               column(6, numericInput('ton',   label = 'To', value = 10)),
                              br(),br(),
               actionButton('undo', label = 'Undo selection', style='display: block; margin-left: auto; margin-right: auto;'),br(),
               downloadButton('download', label = 'Download selected', style='display: block; color: #0C3690; background-color: #B6CCE7; border-color: #0C3690'),br(),
               actionButton('assign', label = 'Assign', style='display: block; margin-left: auto; margin-right: 2;
                            color: #0C3690; background-color: #B6CCE7; border-color: #0C3690'),
        ) # end third column  
      ), # end Fluidrow
      width = 12), # end Sidebarpanel 
    
    # Main panel for displaying outputs ----------------------------------------
    mainPanel(
      tabsetPanel(id = 'tabset',
        tabPanel('Selection', br(), 
                 h5('You have selected', 
                    span(textOutput('n_selected', inline=T), style='color:#0C3690'), 
                    'rows, seraching for', 
                    span(textOutput('selected', inline=T), style='color:#0C3690'), 
                    'in', 
                    span(textOutput('sel_based_on', inline=T), style='color:#0C3690')),
                 br(),
                 h5('Numbers:'), textOutput('n_generated'),
                 br(),
                 # textOutput('call'),
                 a('https://generationr.nl/'), # Hyperlink to generation R website
                 img(src = 'generation-r-logo.png', height = 140, 
                     style='display: block; margin-left: auto; margin-right: 0;') 
                 ),
        tabPanel('Check selected',
                 tableOutput('view'),
                 ), 
        tabPanel('Check assigned',
                 tableOutput('view2'),
                 ), 
      ), # end tabsetPanel
    width = 12) # end mainPanel
  ) # end Sidebarlayout
) # end Fluidpage


################################################################################
# ------------------ Define server logic to view selected dataset  -------------
################################################################################

server <- function(input, output) {
    # Display selected table 
    getSelection <- reactive({
      assign(selected = input$selection,
                     based_on = input$based_on,
                     case_sensy = input$case_sensy,
                     sel_type = input$sel_type, 
                     and_also = c(input$based_on2, input$selection2))
    })
    output$view <- renderTable({ getSelection() })
    
    # TODO: FIX DOWNLOAD??
    # output$download <- downloadHandler(
    #   # Create the download file name
    #   filename = function () { paste("GENR-selected-", Sys.Date(), ".csv", sep='') },
    #   content = function(file) { write.csv(getSelection(), file, row.names = T) },  # put Data() into the download file
    #   contentType = 'text/csv'
    #   ) 
    
    # Overview information 
    output$selected     <- renderText({ input$selection }) # selection criteria
    output$sel_based_on <- renderText({ input$based_on })  # "
    output$n_selected   <- renderText({ nrow(getSelection()) }) # number of rows
    output$n_generated  <- renderText({ paste0(list_numbers(start=input$fromn, end=input$ton),', ') })
    
    # Upon clicking "assign"
    ass_data_source <- eventReactive(input$assign, { unlist(strsplit(input$a_data_source,', ')) })
    ass_var_label <- eventReactive(input$assign, { unlist(strsplit(input$a_var_label,'; ')) })
    ass_timepoint <- eventReactive(input$assign, { unlist(strsplit(input$a_timepoint,', ')) })
    ass_reporter <- eventReactive(input$assign, { input$a_reporter })
    ass_subject <- eventReactive(input$assign, { input$a_subject })
    ass_var_comp <- eventReactive(input$assign, { input$a_var_comp }) 
    ass_gr_section <- eventReactive(input$assign, { unlist(strsplit(input$a_gr_section,', ')) })
    ass_gr_qnumber <- eventReactive(input$assign, { unlist(strsplit(input$a_gr_qnumber,', ')) })
    ass_questionnaire <- eventReactive(input$assign, { input$a_questionnaire })
    ass_questionnaire_ref <- eventReactive(input$assign, { input$a_questionnaire_ref })
    ass_constructs <- eventReactive(input$assign, { input$a_constructs })
    
    # Display assigned table 
    output$view2 <- renderTable({ assign(selected = input$selection, # verbose=True,print_labels=False
                                        based_on = input$based_on,
                                        case_sensy = input$case_sensy,
                                        sel_type = input$sel_type, 
                                        and_also = c(input$based_on2, input$selection2),
                                        data_source = ass_data_source(),
                                        timepoint = ass_timepoint(),
                                        reporter = ass_reporter(),
                                        var_label = ass_var_label(),
                                        subject = ass_subject(),
                                        gr_section = ass_gr_section(),
                                        gr_qnumber = ass_gr_qnumber(),
                                        var_comp = ass_var_comp(),
                                        questionnaire = ass_questionnaire(),
                                        questionnaire_ref = ass_questionnaire_ref(),
                                        constructs = ass_constructs() ) })
                                     
    observeEvent(input$assign, {
      and_also <- ifelse(input$selection2 != '', 
                         paste0(', and_also = (', input$based_on2,', ', input$selection2, ')'),'')
      data_source <- ifelse(input$a_data_source!='',paste0(', data_source = ', input$a_data_source),'')
      timepoint <- ifelse(input$a_timepoint!='',paste0(', timepoint = ', input$a_timepoint),'')
      reporter <- ifelse(input$a_reporter!='',paste0(', reporter = ', input$a_reporter),'')
      var_label <- ifelse(input$a_var_label!='',paste0(', var_label = ', input$a_var_label),'')
      subject <- ifelse(input$a_subject!='',paste0(', subject = ', input$a_subject),'')
      gr_section <- ifelse(input$a_gr_section!='',paste0(', gr_section = ', input$a_gr_section),'')
      gr_qnumber <- ifelse(input$a_gr_qnumber!='',paste0(', gr_qnumber = ', input$a_gr_qnumber),'')
      var_comp <- ifelse(input$a_var_comp!='',paste0(', var_comp = ', input$a_var_comp),'')
      questionnaire <- ifelse(input$a_questionnaire!='',paste0(', questionnaire = ',input$a_questionnaire),'')
      questionnaire_ref <- ifelse(input$a_questionnaire_ref!='',paste0(', questionnaire_ref = ',input$a_questionnaire_ref),'')
      constructs <- ifelse(input$a_constructs!= '', paste0(', constructs = ', input$a_constructs),'')
      
      log <- paste0('assign(selected = ',input$selection,
             ', based_on = ', input$based_on,
             ', case_sensy = ', input$case_sensy,
             ', sel_type = ', input$sel_type, 
             and_also, data_source, timepoint, reporter, var_label, subject,
             gr_section, gr_qnumber, var_comp, questionnaire, questionnaire_ref,
             constructs,')','\n# ',nrow(getSelection()))
      cat(log, file=logfile, sep ='\n\n\n', append=TRUE)
    })
    
}
    
################################################################################
# --------------------------- MAKE IT ALIVE & SHINY  ---------------------------
################################################################################

shinyApp(ui = ui, server = server)
