# Load the base dataset 
qsum <- read.csv('data/quest_meta.csv')[,-1] # get rid of index variable from pandas 

# Specify some basic data info
GR_ids = data.frame(
  'GR1001'= c('12-20 w','mother', NA), # The health of you and your child
  'GR1002'= c('15-23 w','mother', NA), # De voeding van moeder
  'GR1003'= c('20-25 w','mother', NA), # Feelings and memories
  'GR1004'= c('20-25 w','father', NA), # Health, lifestyle, background and feelings (partner)
  'GR1005'= c('30 w',   'mother', NA), # Living conditions
  # Postnatal (actual median age in months until 6y then in years)
  'GR1018'= c('2 m',  'mother', 2.8), # The first two months - your child
  'GR1019'= c('2 m',  'mother', 2.8), # The first two months - mother
  'GR1024'= c('6 m',  'mother', 6.3), # The first six months - mother
  'GR1025'= c('6 m',  'mother', 6.3), # The first six months - your child
  'GR1028'= c('1 y',  'mother', 12.0),# My first year in Generation R
  'GR1060'= c('1 y',  'mother', 12.9),# De voeding van mijn kind - rond de 1e verjaardag
  'GR1029'= c('1.5 y','mother', 18.2),# My 1 / 1.5 year old toddler
  'GR1032'= c('2 y',  'mother', 24.2),# My todler
  'GR1064'= c('2 y',  'mother', 24.9),# De voeding van mijn kind – rond de 2e verjaardag
  'GR1062'= c('2.5 y','mother', 30.7),# My toddler’s development
  'GR1065'= c('3 y',  'mother', 36.2),# My three-year-old child
  'GR1066'= c('3 y',  'father', 36.4),# My three-year-old child (partner)
  'GR1067'= c('4 y',  'mother', 48.3),# My 4-year old child
  'GR1075'= c('5 y',  'mother', 71.4),# The development of my 5/6-year old child – Part I
  'GR1076'= c('5 y',  'mother', 72.6),# The development of my 5/6-year old child – Part II
  'GR1079'= c('6 y',  'teacher',74.9),# Gedragsvragenlijst voor kinderen t/m 18 jaar
  'GR1080'= c('8 y',  'mother', 8.07),# Diet and behavior
  'GR1081'= c('9 y',  'mother', 9.67),# Development of my 9/10 year old child - Part 1
  'GR1082'= c('9 y',  'mother', 9.79),# Development of my 9/10 year old child - Part 2
  'GR1083'= c('9 y',  'father', 9.74),# Development of my 9/10-year old child - Partner
  'GR1084'= c('9 y',  'child',  9.78),# Mijn eerste vragenlijst
  'GR1093'= c('13 y', 'mother',13.49),# My teenager part 1
  'GR1094'= c('13 y', 'mother',13.58),# My teenager part 2
  'GR1095'= c('13 y', 'child', 13.52),# Mijn vragenlijst – Deel 1
  'GR1096'= c('13 y', 'child', 13.71),# Mijn vragenlijst – Deel 2
  'GR1097'= c('13 y', 'mother',13.54))# ? about ENT specialist visit ?

# Construct the main assignment funtion. It takes only one obligatory argument: selected.
assign <- function(q, selected, # string or list 
                   based_on='var_name',
                   case_sensy=F,
                   sel_type='contains',  # 'ends', 'starts', 'is'
                   and_also=NULL,
                   print_labels=F,
                   download=NULL, full_quest_download=NULL,
                   # assignment arguments
                   data_source=NULL,
                   timepoint=NULL,
                   reporter=NULL,
                   var_label=NULL,
                   subject=NULL,
                   gr_section=NULL,
                   gr_qnumber=NULL,
                   var_comp=NULL,
                   questionnaire=NULL,
                   questionnaire_ref=NULL,
                   constructs=NULL) {
  # SELECTION --------------------------------------------------
  if (!based_on %in% names(q)) { 
    stop('There is no column called \"', based_on, '\"') # Note: useless here since i pre-specify options 
  } else if (length(selected)>0) {
    selected <- unlist(strsplit(selected, ', '))
    # Define the selection
    if (sel_type == 'is') { 
      selected <- unlist(strsplit(selected, '|', fixed=T)) # In case entered "a|b"
      sel <- which(q[,based_on] %in% selected) # NOTE: always case sensitive
    } else {
      if (sel_type=='starts') { selected <- paste('^', selected, sep='') }
      if (sel_type=='ends')   { selected <- paste(selected, '$', sep='') }
      selection <- paste(selected, collapse='|') 
      sel <- grep(selection, q[,based_on], ignore.case = !case_sensy)
    }
    # Define additional constraints
    if (!is.null(and_also)) { add_sel <- grep(and_also[2], q[,and_also[1]], ignore.case = !case_sensy) # NOTE case sensitive same, and also swap?
    sel <- intersect(sel, add_sel)
    } 
    # Select data
    data <- q[sel,]
    
    if (nrow(data) < 1) { stop('Your selection (', selection, ') resulted in 0 rows!')
    } else { # message(nrow(data), ' rows selected.')
      if (print_labels) { print(list(data$var_label)) } }
    
    # ASSIGNMENT -------------------------------------------------
    if (!is.null(data_source) & !identical(data_source, character(0))) {
      if (data_source %in% names(GR_ids)) {
        q[sel, c('data_source', 'timepoint', 'reporter')] <- c(data_source, GR_ids[1,data_source], GR_ids[2,data_source])
        } else { q[sel, 'data_source'] <- data_source }
    }
   
    # timepoint
    if (!is.null(timepoint) & !identical(timepoint, character(0))) { # if an ass_ argument is given
      if (!length(timepoint) %in% c(1, nrow(data))) { # check its length matches the number of rows (or 1)
        stop('The number of rows (',nrow(data),') and assigned values (',length(timepoint),') of timepoint do not match')
      } else { q[sel, 'timepoint'] <- timepoint } # and assign
    }
    # reporter
    if (!is.null(reporter) & !identical(reporter, character(0))) { # if an ass_ argument is given
      if (!length(reporter) %in% c(1, nrow(data))) { # check its length matches the number of rows (or 1)
        stop('The number of rows (',nrow(data),') and assigned values (',length(reporter),') of reporter do not match')
      } else { q[sel, 'reporter'] <- reporter } # and assign
    }
    # var_label
    if (!is.null(var_label) & !identical(var_label, character(0))) { # if an ass_ argument is given
      if (!length(var_label) %in% c(1, nrow(data))) { # check its length matches the number of rows (or 1)
        stop('The number of rows (',nrow(data),') and assigned values (',length(var_label),') of var_label do not match')
      } else { q[sel, 'var_label'] <- var_label } # and assign
    }
    # subject
    if (!is.null(subject) & !identical(subject, character(0))) { # if an ass_ argument is given
      if (!length(subject) %in% c(1, nrow(data))) { # check its length matches the number of rows (or 1)
        stop('The number of rows (',nrow(data),') and assigned values (',length(subject),') of subject do not match')
      } else { q[sel, 'subject'] <- subject } # and assign
    }
    # gr_section
    if (!is.null(gr_section) & !identical(gr_section, character(0))) { # if an ass_ argument is given
      if (!length(gr_section) %in% c(1, nrow(data))) { # check its length matches the number of rows (or 1)
        stop('The number of rows (',nrow(data),') and assigned values (',length(gr_section),') of gr_section do not match')
      } else { q[sel, 'gr_section'] <- gr_section } # and assign
    }
    # gr_qnumber
    if (!is.null(gr_qnumber) & !identical(gr_qnumber, character(0))) { # if an ass_ argument is given
      if (!length(gr_qnumber) %in% c(1, nrow(data))) { # check its length matches the number of rows (or 1)
        stop('The number of rows (',nrow(data),') and assigned values (',length(gr_qnumber),') of gr_qnumber do not match')
      } else { q[sel, 'gr_qnumber'] <- gr_qnumber } # and assign
    }
    # var_comp
    if (!is.null(var_comp) & !identical(var_comp, character(0))) { # if an ass_ argument is given
      if (!length(var_comp) %in% c(1, nrow(data))) { # check its length matches the number of rows (or 1)
        stop('The number of rows (',nrow(data),') and assigned values (',length(var_comp),') of var_comp do not match')
      } else { q[sel, 'var_comp'] <- var_comp } # and assign
    }
    # questionnaire
    if (!is.null(questionnaire) & !identical(questionnaire, character(0))) { # if an ass_ argument is given
      if (!length(questionnaire) %in% c(1, nrow(data))) { # check its length matches the number of rows (or 1)
        stop('The number of rows (',nrow(data),') and assigned values (',length(questionnaire),') of questionnaire do not match')
      } else { q[sel, 'questionnaire'] <- questionnaire } # and assign
    }
    # questionnaire_ref
    if (!is.null(questionnaire_ref) & !identical(questionnaire_ref, character(0))) { # if an ass_ argument is given
      if (!length(questionnaire_ref) %in% c(1, nrow(data))) { # check its length matches the number of rows (or 1)
        stop('The number of rows (',nrow(data),') and assigned values (',length(questionnaire_ref),') of questionnaire_ref do not match')
      } else { q[sel, 'questionnaire_ref'] <- questionnaire_ref } # and assign
    }
    # constructs
    if (!is.null(constructs) & !identical(constructs, character(0))) { # if an ass_ argument is given
      if (!length(constructs) %in% c(1, nrow(data))) { # check its length matches the number of rows (or 1)
        stop('The number of rows (',nrow(data),') and assigned values (',length(constructs),') of constructs do not match')
      } else { q[sel, 'constructs'] <- constructs } # and assign
    }
    
    # match_length <- function(arg, name) {
    #   if (!is.null(arg) & !identical(arg, character(0))) { # if an ass_ argument is given
    #     if (!length(arg) %in% c(1,nrow(data))) { # check its length matches the number of rows (or 1)
    #       message(, sep='')
    #       stop(0)
    #     } else { q[sel, name] <- arg } # and assign
    #   }
    #   return(q)
    # }
    # if (match_length(timepoint,'timepoint')==0) { stop() }
    # if (match_length(reporter,'reporter')==0) { stop() }
    # if (match_length(gr_section,'gr_section')==0) { stop() }
    # if (match_length(gr_qnumber,'gr_qnumber')==0) { stop() }
    # if (match_length(subject,'subject')==0) { stop() }
    # if (match_length(var_label,'var_label')==0) { stop() }
    # if (match_length(questionnaire,'questionnaire')==0) { stop() }
    # if (match_length(questionnaire_ref,'questionnaire_ref')==0) { stop() }
    # if (match_length(constructs,'constructs')==0) { stop() }
    
    # Do not assign specific sources to ID variables
    # I do it in th python function not really needed here 
    
    # Download the assigned file ---------------------------------------------
    if (!is.null(download)) {
       if (!is.null(full_quest_download)) {
          fullshow = q[grep(full_quest_download, q$data_source),]
          write.csv(fullshow, download)
       } # else { write.csv(q[sel,], download) }
    }
    return (q[sel,])
  } 
}

# Helper: list numbers
list_numbers <- function(start, end) {
  return(as.character(seq(start,end)))
}
