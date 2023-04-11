
library(foreign)

loc <- "\\\\store/department/genr/isi-store/WERKGROEPEN/Data-dictionary/Datawiki_scraping/output/"

# I have separated the files into folders according to their position in the
# datawiki (GeneralData, Questionnaires, Measurements, BiologicalSamples, Environment)
dl <- c(paste0(loc, "GeneralData"), paste0(loc, "Questionnaires"),
        paste0(loc, "Measurements"), paste0(loc, "BiologicalSamples"),
        paste0(loc, "Environment"))
# OR
# basedir <- dirname(file.choose()) # choose any file in the directory of interest

# TODO: These files have different structure ---------------------------------------------------- #
problem <- c(
  "13092019 Metabolomics_Child9_Imputed_FINAL.sav",
  "13092019 Metabolomics_Cordblood_Imputed_FINAL.sav",
  "13092019 Metabolomics_Mother_Imputed_FINAL.sav",
  "20160127_NIH_Analytical results OP metabolites_Child5.sav",
  "GENR_450kmeth.WBCcounts.Houseman.20141031.sav",
  "GENR_450kmeth_release2_5y_Houseman_default_20170501.sav",
  "GENR_450kmeth_release2_5y_Houseman_EosNeu_20170501.sav",
  "GENR_450kmeth_release2_9y_Houseman_default_20170501.sav",
  "GENR_450kmeth_release2_9y_Houseman_EosNeu_20170501.sav",
  "GENR_450kmeth_release2_birth_Bakulski_20170501.sav",
  "GENR_450kmeth_release2_birth_Gervin_20170501.sav",
  "GENR_450kmeth_release2_birth_Houseman_default_20170501.sav",
  "GENR_450kmeth_release2_birth_Houseman_EosNeu_20170501.sav",
  "GENR_450kmeth_WBCcountsBakulski.sav",
  "GENR4_Admixture_08072021.sav",
  "GENR4_nonEU_08072021.sav",
  "GWAS_Ethnicity_probability_Child_07042017.sav",
  "MomS_nonEU_08072021.sav",
  "MomS_PCs_08072021.sav",
  "MomS_PCs_onlyEU_08072021.sav",
  "PCA_Selection GWAv4_revised def_April2021.sav",
  "PCA_Selection GWAv4_revised def_European-April2021.sav",
  "Selection GWAv4_Outcome Child-Mother_April2021.sav",
  "Selection GWAv4_Outcome Pregnancy-Mother_April2021.sav",
  "Selection GWAv4_revised def_European_April2021.sav", 
  "Selection_GWAv4-Child_April2021.sav", "Selection_GWAv4-Mothers_April2021.sav")
# ---------------------------------------------------------------------------------------------- #

ret_cols <- c("orig_file", # name of the sav file where variable is present
              "tot_n",     # number of observations in the file
              "var_name",  # variable name
              "var_label", # variable label (if any)
              "var_type",  # numeric or categorical 
              "levels",    # if categorical, what are the levels, if continuous, basic stats
              "descriptives", # levels or other stats
              "missing",   # numebr of missing values 
              "min",       # minimum value
              "max",       # maximum value
              "mean",      # mean
              "median")    # median

# =============================================================================================== #
for (basedir in dl) {
    files <- list.files(basedir, pattern = "*.sav") # get all the files in the directory
    
    ret_frame <- data.frame(matrix(ncol = length(ret_cols), nrow = 0, dimnames = list(NULL, ret_cols)))
    
    # loop throu all the files in the folder, read them in, extract the relevant information
    for (f in files) {
      if (!f %in% problem) {
        # read in the file
        dat <- foreign::read.spss(file.path(basedir, f), use.value.labels = T, to.data.frame = T)
        
        # fix a problem with open question (Which medicines 1_past 6 months)
        # if ('Q01MED02' %in% colnames(dat)) {dat$Q01MED02 <- NA}
        for (c in colnames(dat)) {
          if(class(dat[,c]) == 'factor' & length(levels(dat[,c])) > 17) {
             dat[,c] <- NA
             dat[,c] <- as.character(dat[,c])
          }
        }
  
        # extract the relevant information and bind them into a temporary dataframe
        temp <- data.frame(
          "orig_file" = rep(gsub(".sav", "", f), ncol(dat)), # file name
              "tot_n" = rep(nrow(dat), ncol(dat)),           # number of rows in the file
           "var_name" = attr(dat, "names"),                  # column (i.e. variable) names
          "var_label" = attr(dat, "variable.labels"),        # column (i.e. variable) labels
           "var_type" = sapply(dat, class),                  # class (continuous or factor)
             "levels" = as.character(unname(sapply(dat, levels))),  # levels (only for factors)
       "descriptives" = as.character(unname(sapply(dat, summary))), # basic statistics
            "missing" = unname(colSums(is.na(dat))),         # number of missing values
                "min" = rep(NA, ncol(dat)),   # minimum value
                "max" = rep(NA, ncol(dat)),   # maximum value
               "mean" = rep(NA, ncol(dat)),   # mean
             "median" = rep(NA, ncol(dat)) )  # median

        temp$var_label <- gsub(",", "\\,", temp$var_label) # for csv sake
        # add range, mean and median for numeric variables
        for (c in colnames(dat)) {
          if (class(dat[,c])=='numeric'){
              temp[temp$var_name==c,'min']    <- min(dat[,c], na.rm=T)
              temp[temp$var_name==c,'max']    <- max(dat[,c], na.rm=T)
              temp[temp$var_name==c,'mean']   <- mean(dat[,c], na.rm=T)
              temp[temp$var_name==c,'median'] <- median(dat[,c], na.rm=T)
          }
        }

        # bind the file dataframe to the the others
        ret_frame <- rbind(ret_frame, temp)
      }

    }

    # if not a factor, set levels to the statistic name
    levels(ret_frame$levels)[levels(ret_frame$levels)=='NULL'] <- 'c("Min.", "1st Qu.", "Median", "Mean", "3rd Qu.", "Max.")'

    # save file as csv
    df <- apply(ret_frame, 2, as.character)
    write.csv(df, paste0(basedir, '_all_columns.csv'), row.names=F)

    cat(paste("\n", basedir, "\n", "Total number of variables:", nrow(ret_frame),
              "of wich unique: ", length(unique(ret_frame$var_name)), "\n"))

    # some variables are repeated, list them --------------------------------------
    clean_frame <- data.frame(matrix(ncol = length(ret_cols), nrow = 0, dimnames = list(NULL, ret_cols)))

    for (v in unique(ret_frame$var_name)) {
      t <- ret_frame[ret_frame$var_name == v, ] # get only single variable entries
      if (nrow(t) > 1) {
        orig_file <- paste(t$orig_file, collapse="; ") # paste all file names together
        f <- t[t$tot_n == max(t$tot_n), ]    # get the row(s) with max number of observation
        f <- f[f$missing == min(f$missing),] # further, those with minimum number of missing
        t <- cbind(orig_file, f[1,-1])       # copy the first row
        # Signal an issue
        if (nrow(f) > 1 & any(duplicated(f[,-1])[2:length(duplicated(f[,-1]))]) == F){
          cat(paste("Problem (not duplicate):", f$var_name[1], '\n')) }
      }
      clean_frame <- rbind(clean_frame, t)
    }

    # for (v in unique(ret_frame$var_name)) {
    #   t <- ret_frame[ret_frame$var_name == v, ]
    #   if (nrow(t) > 1) {
    #     rep_frame <- rbind(rep_frame, t)
    #   }
    # }

    df_clean <- apply(clean_frame, 2, as.character)
    write.csv(df_clean, paste0(basedir, '_clean.csv'), row.names=F)
}
