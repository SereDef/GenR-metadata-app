# Hi, this is a quick set up for the application interface to assign metadata in GenR
# This is still very much work in progress so please if you have any suggestions 
# or you want to help shoot me an email at s.defina@erasmusmc.nl

# Prompt window to select output directory
#dir <- readline('Where do you want to store the output? ')
# while input is not provided keep asking
# while(!file.exists(dir)){
#   dir <- readline('Where do you want to store the output? ')
# }

# Load required r packages
r_pack <- c('shiny', 'reticulate','DT', 'shinyFiles', 'fs') # 'tcltk'
invisible(lapply(r_pack, require, character.only = T));

# Create python virtual environment if it doesnt exist already
if (!'r-reticulate' %in% conda_list()$name) {
  cat('Creating new environment. ')
  conda_create('r-reticulate')
  py_pack <- c('pandas', 'typing')
  for (pack in py_pack) { reticulate::conda_install('r-reticulate', pack) }
}
cat('Python environment all set up. ')
# Use the enviroment 
reticulate::use_condaenv('r-reticulate')

# Load required python packages
# py_pack <- c('pandas', 'typing')
# for (pack in py_pack) {
#   if (!pack %in% reticulate::py_list_packages()$package) { 
#     reticulate::conda_install('r-reticulate', pack) }
# }

# Point to the backend py script the performs the search/assignment
reticulate::source_python('label_metadata.py')
cat('Pyhton source loaded. ')
# Load the base dataset 
qsum <- read.csv('data/quest_meta.csv')[,-1] # get rid of index variable from pandas 

button_style <- 'color: #0C3690; background-color: #B6CCE7; border-color: #0C3690'

################################################################################
# ------------------------------- Define UI ------------------------------------
################################################################################

# The fluidPage function creates a display that automatically adjusts to the dimensions
# of user’s browser window.
  
ui <- fluidPage(
  titlePanel(h1('Generation R metadata app', # Add title panel
                              style='font-family:verdana; font-weight: bold; font-size:30pt;
                              color:#0C3690; background-color:#B6CCE7; padding: 10px 20px 10px 30px;')), 
  # Define a sidebar panel and a main panel layout for input and output
  sidebarLayout(# note: optional argument position = 'right' to move the sidebar 
    sidebarPanel(
      tags$head(tags$style('h3 {color:#0C3690;}')), # Color Selection and Assignment pane titles
      fluidRow(
        column(4, 
               fluidRow(style = "width:350px", h3('Selection pane'),
               column(6, shinyDirButton('path_out', 'Select output folder', 
                                        title='Please select a folder when you want to store output', 
                                        style = paste('margin-top: 25px;', button_style))),
               column(6, selectInput('gr_n', label = 'Select data source:', 
                           choices=list('','GR1001'='GR1001','GR1002'='GR1002','GR1003'='GR1003',
                                        'GR1004'='GR1004','GR1005'='GR1005','interview'='interview',
                                        'home-interview'='home-interview','GR1018'='GR1018',
                                        'GR1019'='GR1019','GR1024'='GR1024','GR1025'='GR1025',
                                        'GR1028'='GR1028','GR1029'='GR1029','GR1032'='GR1032',
                                        'GR1060'='GR1060','GR1062'='GR1062','GR1064'='GR1064',
                                        'GR1065'='GR1065','GR1066'='GR1066','GR1067'='GR1067',
                                        'GR1075'='GR1075','GR1076'='GR1076','GR1078'='GR1078',
                                        'GR1079'='GR1079','GR1080'='GR1080','GR1081'='GR1081',
                                        'GR1082'='GR1082','GR1083'='GR1083','GR1084'='GR1084',
                                        'GR1086'='GR1086','GR1093'='GR1093','GR1094'='GR1094',
                                        'GR1095'='GR1095','GR1096'='GR1096','GR1097'='GR1097',
                                        'COVID'='COVID'), selected = NULL)),
                # <ins>Tip</ins>: Use "|" in between words if you want to select multiple strings.'),br(),
               p('Type (part of) the string you want to select.'),
               textInput('selection', label='Search for:', value = ''),
               column(12, selectInput('based_on', label = 'Based on:', choices=list('Variable name'='var_name','Variable label'='var_label',
                                                                         'Questionnaire'='questionnaire','Section'='gr_section',
                                                                         'Question number'='gr_qnumber','Timepoint'='timepoint',
                                                                         'Constructs'='constructs','Original file'='orig_file'), 
                            selected = 'var_name')),
               column(8, selectInput('sel_type', label = 'Search type:', 
                                     choices=list('Contains'='contains','Starts with'='starts','Ends with'='ends','Equal to'='is'), 
                                     selected = 'contains')),
               column(3, h1(),checkboxInput('case_sensy', label = 'Case sensitive', value = F))
               ), # end first fluid row (Selection 1)
               fluidRow(style = "width:350px", p('Include additional selection criteria.'),
               textInput('selection2', label='Also search for:', value = ''),
               selectInput('based_on2', label = 'Based on:', 
                           choices=list('Variable name'='var_name','Variable label'='var_label',
                                        'Data source'='data_source','Questionnaire'='questionnaire',
                                        'Section'='gr_section','Question number'='gr_qnumber','Timepoint'='timepoint',
                                        'Constructs'='constructs','Original file'='orig_file'), 
                                      selected = 'var_name')
               )), # end first column # end second fluidRow (selection 2)
        column(4, fluidRow(style = "width:350px",h3('Assignment pane'),
               p('Type or paste the string you want to assign.'),
               textInput('a_gr_section', label = 'Section', value = NULL),
               textInput('a_gr_qnumber', label = 'Question number(s)', value = NULL),
               p('Genetate a list of numbers and it paste above.'),
               column(6, numericInput('fromn', label = 'From', value = 1)),
               column(6, numericInput('ton',   label = 'To', value = 10)),
               ),# end first fluid row
               fluidRow(style = "width:350px",
               textInput('a_questionnaire', label = 'Questionnaire', value = NULL),
               textInput('a_questionn_ref', label = 'Reference', value = NULL),
               textInput('a_constructs', label = 'Construct(s)', value = NULL)
               )), # end second column # end second fluidRow (Assignment 2)
        column(4,p('You can assign a sigle value to all selected rows or multiple values (one to each row)
                 by separating them with a "; " or a ", ". Note that assigning multiple values only works 
                 if the number of entries matches the number of rows selected!'),
               textInput('a_var_label', label = 'Variable label', value = NULL),
               p('Please select only one of the following options. Select none if the label is not applicable (set to " ").'),
               column(4, checkboxGroupInput('a_subject', label = 'Subject', 
                                            choices = list('child'='child','mother'='mother','partner'='partner','none'=' '), selected = character(0)) ),
               column(4, checkboxGroupInput('a_reporter', label = 'Reporter', 
                                            choices = list('child'='child','mother'='mother','partner'='partner','teacher'='teacher'), selected = character(0)) ),
               column(4, checkboxGroupInput('a_var_comp', label = 'Variable type', 
                                            choices = list('item'='item', 'score'='score','metadata'='meta','ID'='ID'), selected = character(0)) ),
               textInput('a_data_source', label = 'Data source', value = NULL),
               textInput('a_timepoint', label = 'Timepoint', value = NULL),
               br(), actionButton('assign', label = 'Assign', style=button_style, align = 'center'),
        ) # end third column  
      ), # end Fluidrow
      width = 12), # end sidebarPanel 
    
    # Main panel for displaying outputs ----------------------------------------
    mainPanel(
      tabsetPanel(id = 'tabset',
        tabPanel('Selection', br(), 
                 h5('You have selected', 
                    span(textOutput('n_selected', inline=T), style='color:#0C3690'), 
                    'rows.'),
                 br(),
                 h5('Manually selected variables:'), span(textOutput('rows_selected'), sep=', '),
                 br(),
                 h5('Numbers:'), textOutput('n_generated'),
                 textOutput('directorypath'),
                 br(),
                 # textOutput('call'),
                 a('https://generationr.nl/'), # Hyperlink to generation R website
                 img(src = 'generation-r-logo.png', height = 140, 
                     style='display: block; margin-left: auto; margin-right: 0;') 
                 ),
        tabPanel('Check selected', DTOutput('view')), # tableOutput('view'),
        tabPanel('Check assigned', DTOutput('view2')), 
        
      ), # end tabsetPanel
    width = 12) # end mainPanel
  ) # end sidebarLayout
) # end fluidPage


################################################################################
# ------------------ Define server logic to view selected dataset  -------------
################################################################################

server <- function(input, output, session) {
  volumes <- c(Home = fs::path_home(), "R Installation" = R.home(), getVolumes()())
  shinyDirChoose(input, 'path_out', roots = volumes, session = session)
  
  # Display options 
  tab_options <- list(paging = F,    ## paginate the output
                      # pageLength = 20,  ## number of rows to output for each page
                      scrollX = T, scrollY = T,   ## enable scrolling on X and Y axis
                      autoWidth = T, ## use smart column width handling
                      # server = FALSE,   ## use client-side processing (slow)
                      dom = 'BifrtB', ## filter,processing,table,info,pagination control, download buttons
                      buttons = c('csv', 'excel'),
                      columnDefs = list(
                        list(targets = 1, width = '500px'), # label column larger 
                        list(targets = c(14,17), # orig_file and descriptives 
                             render = JS( # if longer that 10 char cut the column
                               "function(data, type, row, meta) {",
                               "return type === 'display' && data.length > 10 ?",
                               "'<span title=\"' + data + '\">' + data.substr(0, 10) + '...</span>' : data;",
                               "}"))))
  
  observe({ # wrap in choice of folder location for storage 
    if (!identical(parseDirPath(volumes, input$path_out), character(0))){
      dir = normalizePath(parseDirPath(volumes, input$path_out))
      
      logfile <- file.path(dir, paste0('Logfile-',Sys.Date(),'.txt'))
      tabfile <- file.path(dir, paste0(input$gr_n, '-', Sys.Date(), ".csv")) # THAT is where emty file comes from
      
      if (!file.exists(logfile)) { file.create(logfile) }
      
      # step 1: select the data_source value and download empty (not assigned table)
      grSelected <- reactive({ assign(qsum, selected = input$gr_n, based_on='data_source') })
      
      # and note it in the log file 
      if(!is.null(input$gr_n)) { # TODO: is.null doesnt work but worry about it later 
        cat(input$gr_n,'# -----------------------------------\n\n', file=logfile, append=T) }
      
      # Created sub-table based on panel input
      getSelection <- reactive({ assign(grSelected(), selected = input$selection,
                                        based_on = input$based_on,
                                        case_sensy = input$case_sensy,
                                        sel_type = input$sel_type, 
                                        and_also = c(input$based_on2, input$selection2), 
                                        download=F) })
      # Display table (check selected)
      output$view <- DT::renderDT({ DT::datatable(getSelection(), 
                                                  editable = 'cell',
                                                  options = tab_options,
                                                  extensions = 'Buttons',
                                                  filter = 'top', ## include column filters at the top
                                                  rownames = F    ## don't show row numbers/names
      ) %>% formatStyle(names(getSelection()), backgroundColor = styleEqual(c('',NA), c('pink','red'))) })
      
      # Overview information 
      output$n_selected   <- renderText({ ifelse(is.null(nrow(getSelection())),'0',nrow(getSelection())) }) # number of rows
      output$n_generated  <- renderText({ paste0(list_numbers(start=input$fromn, end=input$ton),', ') })
      output$rows_selected <- renderText({grSelected()[input$view_rows_selected, 'var_name']})
      
      # Upon clicking "assign"
      ass_data_source <- eventReactive(input$assign,{ unlist(strsplit(input$a_data_source,', ')) })
      ass_var_label  <- eventReactive(input$assign, { unlist(strsplit(input$a_var_label,'; ')) })
      ass_timepoint  <- eventReactive(input$assign, { unlist(strsplit(input$a_timepoint,', ')) })
      ass_reporter   <- eventReactive(input$assign, { input$a_reporter })
      ass_subject    <- eventReactive(input$assign, { input$a_subject })
      ass_var_comp   <- eventReactive(input$assign, { input$a_var_comp }) 
      ass_gr_section <- eventReactive(input$assign, { unlist(strsplit(input$a_gr_section,', ')) })
      ass_gr_qnumber <- eventReactive(input$assign, { unlist(strsplit(input$a_gr_qnumber,', ')) })
      ass_questionnaire <- eventReactive(input$assign, { input$a_questionnaire })
      ass_questionnaire_ref <- eventReactive(input$assign, { input$a_questionnaire_ref })
      ass_constructs <- eventReactive(input$assign, { input$a_constructs })
      
      # Update downloaded CSV file with assigned values 
      observeEvent(input$assign, { assign(grSelected(), 
                                          selected = input$selection, # verbose=True,print_labels=False
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
                                          constructs = ass_constructs(), 
                                          download = tabfile,
                                          full_quest_download = input$gr_n) })
      # Display assigned table 
      output$view2 <- DT::renderDT({ DT::datatable(read.csv(tabfile)[,-1], 
                                                   options = tab_options,
                                                   extensions = 'Buttons',
                                                   filter = 'top', ## include column filters at the top
                                                   rownames = F    ## don't show row numbers/names
      ) %>% formatStyle(names(getSelection()), backgroundColor = styleEqual(c('',NA), c('pink','red'))) })
      
      # Save in the log file 
      observeEvent(input$assign, {
        case_sensy_TF <- ifelse(input$case_sensy == T, 'True', 'False')
        and_also <- ifelse(input$selection2 != '', 
                           paste0(', and_also = ("', input$based_on2,'", "', input$selection2, '")'),'')
        data_source <- ifelse(input$a_data_source!='',paste0(', data_source = "', input$a_data_source,'"'),'')
        timepoint <- ifelse(input$a_timepoint!='',paste0(', timepoint = "', input$a_timepoint,'"'),'')
        reporter <- ifelse(input$a_reporter!='',paste0(', reporter = "', input$a_reporter,'"'),'')
        var_label <- ifelse(input$a_var_label!='',paste0(', var_label = "', input$a_var_label,'"'),'')
        subject <- ifelse(input$a_subject!='',paste0(', subject = "', input$a_subject,'"'),'')
        gr_section <- ifelse(input$a_gr_section!='',paste0(', gr_section = "', input$a_gr_section,'"'),'')
        gr_qnumber <- ifelse(input$a_gr_qnumber!='',paste0(', gr_qnumber = "', input$a_gr_qnumber,'"'),'')
        var_comp <- ifelse(input$a_var_comp!='',paste0(', var_comp = "', input$a_var_comp,'"'),'')
        questionnaire <- ifelse(input$a_questionnaire!='',paste0(', questionnaire = "',input$a_questionnaire,'"'),'')
        questionnaire_ref <- ifelse(input$a_questionnaire_ref!='',paste0(', questionnaire_ref = ',input$a_questionnaire_ref,'"'),'')
        constructs <- ifelse(input$a_constructs!= '', paste0(', constructs = "', input$a_constructs,'"'),'')
      
      log <- paste0('assign(selected = "',input$selection,
                    '", based_on = "', input$based_on,
                    '", case_sensy = ', case_sensy_TF,
                    ', sel_type = "', input$sel_type, 
                    and_also, data_source, timepoint, reporter, var_label, subject,
                    gr_section, gr_qnumber, var_comp, questionnaire, questionnaire_ref,
                    constructs,')','\n# ',nrow(getSelection()))
      
      cat(log, file=logfile, sep ='\n\n\n', append=T) })
    }
  })
} # end server  

  # Upon clicking "assign"
  # input$view_cell_clicked: information about the cell being clicked of the form list(row = row_index, col = column_index, value = cell_value) (example)
  # input$view_rows_current: the indices of rows on the current page
  # input$view_rows_all: the indices of rows on all pages (after the table is filtered by the search strings)
  # input$view_search: the global search string
  # input$view_search_columns: the vector of column search strings when column filters are enabled
  # input$view_state: the state information of the table (a list containing the search string, ordering and paging information; it is available only if the option stateSave = TRUE is applied to the table)
  
  # Manual selection 
  # manual_selected <- reactive(grSelected()[input$view_rows_selected, 'var_name'])

    
################################################################################
# --------------------------- MAKE IT ALIVE & SHINY  ---------------------------
################################################################################
cat('Running application: ')
shinyApp(ui = ui, server = server)
