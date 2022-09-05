# GENERATION R metadata app 
Hi, this repository contains a [shiny](http://shiny.rstudio.com/) application that can search and label variables in [**Generation R**](https://generationr.nl/) data. First of all, thank you so much for helping us constructing the data dictionary! You can read about how to launch and use the application down here. If you have any questions / feedback / bugs to report, please write me ([s.defina@erasmusmc.nl](s.defina@erasmusmc.nl)) :D

## Setting up and launching the app
The app requires [R](http://cran.r-project.org/) (version >= 4.0.3) and the following packages:
* [shiny](http://cran.r-project.org/package=shiny) (version >= 1.6.0)
* [reticulate](https://rstudio.github.io/reticulate/) (version >= 1.26)
These packages can be installed using the following function call:
```r
install.packages(c("shiny","reticulate"), dependencies = TRUE)
```

and then the app can be directly invoked using the command:
```r
shiny::runGitHub("GenR-metadata-app", "SereDef", ref="main", launch.browser = T)
```
This will automatically load these packages and the data overview files that are needed. 
The argument ```launch.browser = T``` makes the app open in the default browser. 
If that is not desired, the argument can simply be removed.

## Useful files 
On the wiki you can find the PDFs of the questionnaires and some references, also refer to the folder for other resources. 

## Quick tutorial 

P.S. This very much still a work in progress, so please feel free to write me with any suggestions 
and comments!
