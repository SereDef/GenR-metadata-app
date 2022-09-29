# GENERATION R ~ metadata app 
Hi, this is a [shiny](http://shiny.rstudio.com/) application that can search and label variables in [**Generation R**](https://generationr.nl/) data. First of all, thank you so much for helping us constructing the data dictionary! 
You can read about how to launch and use the application down here. 

P.S. This very much still a work in progress, so if you have any questions / feedback / bugs to report 
please feel free to flag them here or write me ([s.defina@erasmusmc.nl](s.defina@erasmusmc.nl)) :D

## Useful files 
Before you do anything, remember to keep track of the time you spend labeling data, as this will count for your
**general tasks**. Now, the first thing you want to do is to pick a chunk of data from this [list](https://docs.google.com/spreadsheets/d/1jIF1myCpcJbcd4L0KlbwDbyaSKyToHI_1jagUqtIdT4/edit#gid=0). I recommend starting with a questionnaire that you have worked with or you know a little bit and don't forget to write your name down next to it, so others will know that you are taking care of it. 

Finding out the (correct!) information about GenR data is not always straightforward unfortunately. 
One thing you will probably need to have a look at are the PDFs of the questionnaires, which cannot
be shared publicly, but you can find on the **info wiki**. 
We also tried to put together some additional resources / overviews that can help you out, so make sure 
you keep and eye on the [**useful files**](https://github.com/SereDef/GenR-metadata-app/tree/main/useful%20files) 
folder on this repo, and if you feel lost at any point, don't be afraid to ask me or other colleagues.
These files include:
* [GenR_datataxonomy_v4](https://github.com/SereDef/GenR-metadata-app/blob/main/useful%20files/GenR_datataxonomy_v4.xlsx): an overview of the available data manually compiled by Nathalie for the CD2 project. This is not complete (and is being updated by Yuchan) but contains a lot of useful info about instrument names, references and measurement timepoints...
* [Questionnaires Generation R with refs Aug 2020](https://github.com/SereDef/GenR-metadata-app/blob/main/useful%20files/Questionnaires%20Generation%20R%20with%20refs%20Aug%202020.doc): a word doc listing (some of) the references and instrument names for all questionnaires up to age 17y. These are not always clearly linked to a specific section or number, so you may need to take a guess by looking at the questions on the PDF / variable labels.
* [DataWiki_files](https://github.com/SereDef/GenR-metadata-app/blob/main/useful%20files/DataWiki_files_120922.xlsx): an excel sheet with the location of each file on the data wiki and the PIs for each file. May be useful for labeling or finding data.
* more specific files such as: [GenR_17yr_Measures](https://github.com/SereDef/GenR-metadata-app/blob/main/useful%20files/GenR_17yr_Measures.xlsx) and [available_biomarkers_in_full_cohort](https://github.com/SereDef/GenR-metadata-app/blob/main/useful%20files/available_biomarkers_in_full_cohort_1-11-2018.pdf)

Please keep in mind that all of these resources are not necessarily complete and may contain errors. Please contact me if you spot any of them. I also created a shared [document](https://docs.google.com/spreadsheets/d/1hCDNHtlB_ksVX5toP3CQIDAVbHS9w8Xi3ZPkW79DIns/edit#gid=0) where you can list any issues you may encounter, also for others to be aware of it. 

Ok, let's see if we can get this application started. 

## Setting up and launching the app
The app requires [R](http://cran.r-project.org/) (version >= 4.0.3) and the following packages:
* [shiny](http://cran.r-project.org/package=shiny) (version >= 1.6.0)
* [reticulate](https://rstudio.github.io/reticulate/) (version >= 1.26)

To launch the application, open **RStudio** (or any other R IDE), and paste the following
command in your console (only do this if you need to install the packages I listed above):
```r
install.packages(c("shiny","reticulate"), dependencies = TRUE)
```
Once you have the right packages, the app can be directly invoked using the command:
```r
shiny::runGitHub("GenR-metadata-app", "SereDef", ref="main", launch.browser = T)
```
This will automatically load these packages and the data overview files that are needed. 
The argument `launch.browser = T` makes the app open in the default browser. 
If you don't like that, simply remove the argument.

Pretty soon you should see the message `Where do you want to store the output?` 
appearing in the console. Please type or paste the path to the folder where you would 
like to store the app output and press enter. This can be any folder as long as you remember where it is :) 

Once you entered the path, you should see a `logfile-DATE.txt` appearing in the folder you chose. 
This is empty for now, but will be filled in as you assign metadata to variables. This is also the
only file that I need you to return to me after you are done with your "data chunk", so don't delete it
or your work will be lost!

## Optional: Python tutorial
Note that if are handy or what to get familiar with Pyhton, the assignment can also be performed via [this notebook](https://github.com/SereDef/GenR-metadata-app/blob/main/Python%20tutorial/Quesitionnaire_metadata.ipynb) (you will need to have `pyhton`, `jupyter notebook` and a few other packages installed, see the instructions in the notebook). Please also feel free to contact me if you need help setting this up. 

# TUTORIAL 
Now that the application is running in your browser, you should see two main panes: 
a [**Selection pane**]() and an [**Assignment pane**](), with a bunch of options you can set up. 
If you scroll down a wee bit can also notice three tabs: `Selection`, `Check selected` and `Check assigned`. 
Let's start with how to select data. 

## Selection
The first entry in the Section pane allows you to choose the *"data source"* you are currently working on. 
This is the GR-number of the questionnaire you chose from the [worksheet](https://docs.google.com/spreadsheets/d/1jIF1myCpcJbcd4L0KlbwDbyaSKyToHI_1jagUqtIdT4/edit#gid=0). 
You do not need to select anything here, but It sure helps :) 

If you made a selection, you can immediately see **number of rows** you have selected reported down in the
`Selection` tab. 

........

Next you see the **main search bar**, with three very useful search settings: 
* [**Based on**](): controls the column you are searching in. Default is `Variable name` but you can change this to any other column in the data table. 
* [**search type**](): by default the app returns all the rows that `contain` the string you entered in the search bar, but you may be interested, for example, only in variables that `start with`, `end with`, or are `equal` to some value. 
* [**case sensitive**](): by default, the search is <ins>not</ins> case sensitive, but you can change that by ticking this box.

Go ahead and try typing in something under [**Search for**]() and play around with the settings. 

> note you can search for multiple strings at the same time if you separate them with a `|` 
Choose your selection criteria by entering a string (e.g., something) or a list of strings (e.g., something, something else). Separate elements in lists using commas. 

 case sensitive box.

You can base your selection on any column in the metadata dataframe. Default is 'orig_file', which holds the names of the original .sav files. You can change this to any column in the dataset, for example var_name for selecting based on variable names, or var_label if you want to use variable labels. At the moment the function only supports a single value of based_on, but do let me know if you need more flexibility.

Additionally, by default the function will search for any row containing the strings you entered in selected. You may want to select rows that start / end with or correspond exactly to the string you entered, and you can do that by ticking the appropriate box. Note: besides the default, contains, all other options are case sensitive.

When a single selection criterium is not enough, for example if you want to select not only questionnare GR1001 but also section A (data_source = 'GR1001' and gr_section = 'A'), use the second set of selection criteria. This time you string. 

#### <ins>Tip time</ins>: regular expressions (`regex` syntax)
If nose around the assign function you may notice how it uses regular espression to make the search more flexible. These are small symbols that can are used to establish rules or regularities. In other words you not only can search for something _containing_ 'feed' but also for example everything **ending** with or **beginning** with 'feed'. It gets better, you can say select something _ending with any number_ or _any capital letter followed by two numbers_ and so on... pretty cool yes. 

Here are some useful basic commands that you can leverage:
   - if you want to set the condition a bit more flexibly, for example select section A or B you can put a | in between the values, like this: 'A|B'. You can do this as many times as you want.
   - '^_' means "begins with". For example '^Bre' will get you everything starting with 'Bre'. 
   - '_\\$$' means "ends with". For example '23\\$' will give everything ending with '23'.

After you give some selection option you can see some info about your selection in the spare under the main panel (number of rows selected) and you can visualize the selected table in the selected pane. you can also download a vsv file if that is 

As usual, if soemthing is not working quite right or you need more flexibility in selection, let me know. but for now let's move on to assigning some values.

## Assignment
You can change the value of any column you like for the rows you have selected.

**Note**: most of these three columns are <ins>already assigned</ins> automatically but please correct them if you spot errors or missing values.
* **`data_source`**: this specifies the *source* of the variable. <br> For Questionnaire data this will be either a GR-id or a "interview". If you assign a GR-id that is included in the `GR_ids` dictionary defined above, the function will automatically assign also `timepoint` and `reporter`. If the data source is new, however, please specify those manually. <br> For variables that are _scores_ combining multiple data sources, I tipically use the format `'GR1001-03'`.

    For measurements and other data, `data_source` can take values such as e.g., blood, urine, DXA scan, brain MRI ... (<font color='red'>*specify standard*</font>). 

* **`timepoint`**: when whas the value measured in child age. This is expressed in *weeks gestation* (`'w'`) for prenatal variables, in *months* (`'m'`) during the first year of life and in *years* (`'y'`) for all subsequent measures. There is a space in between the number and the time unit, see for instance the values specified in `GR_ids`. <font color='red'>*Note that this is not always reflecting the median age of the measurement.*</font>

* **`reporter`**: the person that completed the questionnaire / interview. It can take the following values: `'mother'`,`'father'`,`'child'`,`'teacher'`, `'mother & father'` (for combined scores). If not applicable, please set this value to `' '`.

> **Tip**: in python arguments are *positional* so you don't have to specify their name if you input them in the correct order. So for example you can simply specify the data source as the fifth argument. But of course spelling it out makes it clearer.

These are the values that, more commonly will need to be assigned: 

* **`gr_section`**: this indicates the section on the questionnaire (`A` to `K`). It is a single capital letter. I would suggest starting from this column when you work on completing your table, so you can use them in the selection and assignment of other metadata. 


* **`gr_qnumber`**: indicates the number of the question / item. Note that this is also a _string_. This is sometimes indicated by the variable name or label, but I find it best to always check the questionnaire PDFs to make sure the number assigned corresponds. <br> Some questions have a more complex, nested structure with two or more levels. We encode this as follows: the first level is number and that is normally explicitly indicated on the PDF. For the second level we will use letters. Additional levels get numbers again. Levels are separated by a dot. <br> For example: 
    You don't need to type this yourself every time, you can use the `list_numbers()` function instead. This takes two obligatory arguments, `start` and `end` which you can use to indicate the range of numbers.


* **`var_label`**: variable description. This is an important part of the dictionary and a terribly messy one too. Some labels are not there (~15%), some are in Dutch, some are just not understandable (e.g., they use acromyms that are not spelled out or they are just copies of variable names). PLEASE HELP US FIX THIS. 
    - For **items**, the label would normally correspond to the (complete) question that was asked, in English, as you can read it in the PDFs. If this is part of a nested question please specify the full question so that it is understandable on its own. 
    - For **scores**, please use the best description you can find, including both the full name of a score or measure and its acromym (when applicable) and measurement unit (when applicable). Example of the format: `'Body mass index (BMI), kg/m2'`. 
    Again, you don't need to do this one by one, you can use lists. For instance you can set the argument `print_labels = True` in the assign function to have a list of the variable labels in your selection. You can copy paste this, edit and assign it. 


* **`subject`**: who is the information about? It can take the following values: `'mother'`,`'father'`,`'child'`, `'family'`. If not applicable, please set this value to `' '`. Normally this is value can be assigned by section (look at the PDFs to quickly understand who the section is about). If you are unsure, feel free to ask me. 


* **`var_comp`**: this indicates if the variable is an `'item'` (i.e., a single question that was directly answered) or a `'score'` (i.e., a combination of items, for example a subscale total score). Other possible values include `'ID'` (i.e., for example 'IDC') or '`metadata'` (for example, child age).


* **`questionnaire`** and **`questionnaire_ref`**: some groups of items correspond to validates questionnaires / interviews. You can find most of these in the document 'Questionnaires Generation R with refs 2021', the 'GenR measumeremnt overview' and 'datataxonomy' spreadsheets or in the 'referencesquestionnairesgenr' PDFs. Please specify `questionnaire` as the full name of the instrument and its acronym at the end between brackets. `questionnaire_ref` should be a link to the instrument reference or manual. Preferably, this is the DOI (preceded by 'https://doi.org/'). When this is not available you can use another link to the reference, or to a Generation R paper that describes the instrument. 


* **`constructs`**: what is this variable measuring? To help make the search more flexible, we also want to tag varaiables with the concepts they are supposet to tap into. For example maternal smoking variables could carry the tags 'smoking','tabacco','cigarettes'. Please include 1-3 terms that you believe apply, thi can be also general e.g. 'psychopatology'. Separate terms with ';'.

* **other stuff**: `n_observed`,`var_type`,`orig_file`,`n_total`, `n_missing`, `desctiptives`.

