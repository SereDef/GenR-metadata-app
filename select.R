
# 

searchselection <- function(t, GR_number = 'all', GR_section = 'all', files = '', 
                            variable = '', search_names=T, search_labels=F, ret_n = F) {
  outt <- t
  
  if (GR_number != 'all') { if (GR_number == 'NA') { outt <- outt[ outt$data_source == '', ]
  } else { outt <- outt[ outt$data_source == GR_number, ] } }
  if (GR_section != 'all') { if (GR_section == 'NA') { outt <- outt[ is.na(outt$gr_section) | outt$gr_section == '', ]
  } else { outt <- outt[ outt$gr_section == GR_section, ] } }
  
  if (files != '') { outt <- outt[ grep(files, outt$orig_file, ignore.case = T), ] }
  
  if (variable != '') { if (search_names==T & search_labels==T) {
     outt <- outt[ (grepl(variable, outt$var_name) | grepl(variable, outt$var_label)), ] 
  } else if (search_names==T) { outt <- outt[ grep(variable, outt$var_name), ] 
  } else if (search_labels==T) { outt <- outt[ grep(variable, outt$var_label), ]  }
    }
  
  if (ret_n == T) { return(nrow(outt)) } else { return(outt) }
  
}

generate_numbers <- function(start, end, sublevel=0, sublevel2=0) {
  
  if (is.null(sublevel) | is.na(sublevel))   { sublevel=0 }
  if (is.null(sublevel2) | is.na(sublevel2)) { sublevel2=0 }
  
  nlist <- sprintf("%s",seq(start,end))
  
  if (sublevel>0 ) {
    comb <- expand.grid(first=start:end, second=1:sublevel)
    if (sublevel<10) { nlist <- sprintf("%s.%s", comb$first, comb$second)
    } else if (sublevel<100) { nlist <- sprintf("%s.%02d", comb$first, comb$second) 
    } else { nlist <- sprintf("%s.%03d", comb$first, comb$second) }
  }
  
  nlist <- gsub(" ", "", as.character(format(sort(as.numeric(nlist))), nsmall=2))
  
  if (sublevel2>0) { suffix <- paste0(".", 1:sublevel2)
    replist <- c()
    for (e in nlist) { replist <- c(replist, paste0(rep(e, sublevel2), suffix)) } 
  nlist <- replist }
  
  return(nlist)
}


assign <- function(t, GR_number = 'all', GR_section = 'all', files = '', 
                    variable = '', search_names=T, search_labels=F, 
                    assign_section=NULL, assign_numbers=NULL, 
                    assign_subject=NULL, assign_reporter=NULL, 
                    assign_varcomp=NULL) {
  outt <- t
  
  if (GR_number != 'all') { if (GR_number == 'NA') { outt <- outt[ outt$data_source == '', ]
  } else { outt <- outt[ outt$data_source == GR_number, ] } }
  if (GR_section != 'all') { if (GR_section == 'NA') { outt <- outt[ is.na(outt$gr_section) | outt$gr_section == '', ]
  } else { outt <- outt[ outt$gr_section == GR_section, ] } }
  
  if (files != '') { outt <- outt[ grep(files, outt$orig_file, ignore.case = T), ] }
  
  if (variable != '') { if (search_names==T & search_labels==T) {
    outt <- outt[ (grepl(variable, outt$var_name) | grepl(variable, outt$var_label)), ] 
  } else if (search_names==T) { outt <- outt[ grep(variable, outt$var_name), ] 
  } else if (search_labels==T) { outt <- outt[ grep(variable, outt$var_label), ]  }
  }
  
  if (!is.null(assign_section)) { outt$gr_section <- assign_section }
  if (!is.null(assign_numbers)) { outt$gr_qnumber <- assign_numbers }
  if (!is.null(assign_subject)) { outt$subject  <- assign_subject }
  if (!is.null(assign_reporter)){ outt$reporter <- assign_reporter }
  if (!is.null(assign_varcomp)) { outt$var_comp <- assign_varcomp }
  
  return(outt)
  
}