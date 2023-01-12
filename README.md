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
be shared publicly, but you can find on the [**info wiki**](https://erasmusmc.sharepoint.com/sites/GenRWiki/SitePages/Generation%20R%20Intranet.aspx?csf=1&web=1&e=789FCb). 
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
* [DT](https://cran.r-project.org/web/packages/DT/index.html) (version >= 0.26)

To launch the application, open **RStudio** (or any other R IDE), and paste the following
command in your console (only do this if you need to install the packages I listed above):
```r
install.packages(c("shiny","reticulate","DT"), dependencies = TRUE)
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
like to store the app output (i.e. the files you are going to send to me) and press enter. This can be any folder as long as you remember where it is :) 
> NOTE: if you are using Windows, make sure you separate the folders with `\\`. 

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
The first entry in the **Selection pane** allows you to choose the *"data source"* you are currently working on. 
This is the GR-number of the questionnaire you chose from the [worksheet](https://docs.google.com/spreadsheets/d/1jIF1myCpcJbcd4L0KlbwDbyaSKyToHI_1jagUqtIdT4/edit#gid=0). 
You don't need to select anything here, but It sure helps :slightly_smiling_face: 

If you made a selection, you can immediately see the **number of rows** you have selected reported down in the `Selection` tab. 

Switch to the `Check selected` tab to visualize the portion of metadata table you selected. This is the table you are going to be working on all the time so take a moment to get familiar with it. You will see the following columns:

* **`var_name`** and **`var_label`**: the *variable name* and  *variable label* (i.e., short description) that is sometimes present in the data .sav files. 

* **`timepoint`**: *when* was the variable measured, in child age. This is expressed in *weeks gestation* (`'w'`) for prenatal variables, in *months* (`'m'`) during the first year of life and in *years* (`'y'`) for all subsequent measures.

* **`subject`**: *who* is the information about? 

* **`n_observed`**: *number of observations* (i.e., non-missing values) in the variable. 

* **`data_source`**: which *GR-number* questionnaire, *interview*, or *visit* (e.g., for measurements) is the variable is coming from. This is the columns we just selected on using the first filter. For variables that are *scores* combining multiple data sources, we use the format: "**GR1001-03**".

* **`gr_section`**: the *section* on the GR-number questionnaire (`A` to `K`).

* **`gr_qnumber`**: the *number* of the question / item. 

* **`reporter`**: *who* reported the information? i.e., the person that completed the questionnaire or interview.

* **`var_comp`**: the *variable type* as in: an **item** (i.e., a single question that was directly answered) or a **score** (i.e., a combination of items, for example a subscale total score). Other possible values include **ID** (i.e., for example 'IDC') or **metadata** (for example, child age).

* **`questionnaire`** and **`questionnaire_ref`**: some groups of items correspond to *validated questionnaires / interviews* 
(e.g., Food frequency questionnaire (FDQ)) for which we point to a *reference* (the link to a relevant paper describing the instrument)

* **`constructs`**: *what* is this variable measuring? e.g., 'diet', 'sleep', 'depression'...

* **`var_type`**: *factor*,*numeric*, or *character*.

* **`orig_file`**: the .sav file containing the variable. This is probably cut in the table to save space but if you leave your mouse on the cell for a second you can visualize the full name. 

* **`n_total`**: the total number of observations in the file (including NAs).

* **`n_missing`**: the number of missing values. 

* **`desctiptives`**: some basic descriptives: minimum, 1st quartile, mean, median, 3rd quartile and maximum for continuous variables; and value counts for factors. This is probably cut in the table to save space but if you leave your mouse on the cell for a second you can visualize the full descriptive. 

You can already see that some of these values are already filled in and some you will need to fill (these should be highlighted in pink and red), but more about that in a moment. 

<hr>

Next in the Selection pane you see the **main search bar** (under [**Search for:**]()) with three very useful search settings: 

* [**Based on**](): controls the column you are searching in. Default is `Variable name` but you can change this to any other column in the data table. At the moment the function only supports a single value/column at the time, but do let me know if you need more flexibility.

* [**Search type**](): by default the app returns all the rows that `contain` the string you typed in the search bar, but you may be interested, for example, only in variables that `start with`, `end with`, or are `equal` to your search.

* [**case sensitive**](): by default, the search is <ins>not</ins> case sensitive, but you can change that by ticking this box.

----> Note: besides the default (contains) all other options are case sensitive. I will change this! 

Go ahead and try typing in something and play around with the settings. You should again see resulting table of results in the `Check selected` tab and the number of rows your search resulted in should also be reported in the `Selection` tab.

You can search for **multiple strings** at same time by including a `|` between them. For example you can get variable names containing "internalizing" OR "externalizing" by typing "internalizing**|**externalizing" in the search bar. You can do this as many times as you want (e.g., "internalizing|externalizing|problems|...").

Sometimes one selection criteria is not sufficient to get the rows you are looking for, so you can include additional criteria using the **additional search bar** ([**Also search for:**]()) and the corresponding [**Based on**]() bar. This works as a **"AND"** statement, so, for example, you can search for variable names containing "internalizing" AND GR section == "A".

### <ins>*Tip*</ins>: **regular expressions (`regex` syntax)**
Regular expressions are a set of symbols that can be used to establish rules or regularities in search commands. This is how you can search for something *ending* or *starting with* with a string, for example. But it gets better: you can select something, e.g., *ending with any number* or *any capital letter followed by two numbers* and so on... pretty cool yes.

Here are some useful basic commands that you can leverage to select exactly the rows that you need:
   - **`^`** at the beginning of a string means ***begins with***. For example "^intern"" will get you everything *starting with* "intern". 
   
   - **`$`** at the end of a string means ***ends with***. For example "23$" will give everything *ending with* "23".
   
   - **`[0-9]`** or **`\d`** will give you any digit (from 0 to 9).
   
   - **`[a-z]`** and **`[A-Z]`** are *any lower-case letter* and *any capital letter* respectively, from a to z.
   
   - **`{n}`**,**`{n,}`**,**`{n,m}`** (where **n** and **m** are positive numbers) specify the number of occurrences. So for example, "o{2}" will find all words that contain "oo" (= "o" repeated *exactly* 2 times). "[0-9]{3,}" will give you matches that have *at least* 3 digits. And "\^[0-9]{1,3}[a-z]{1}" will return any row that begins with at least 1 and maximum 3 digits, followed by a single, lowercase letter.
   
There are several [cheatsheets](https://learn.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference) online if you are curious.

Regex is very handy, but can be confusing sometimes, so, if there is some rule that you notice using all the time, let me know, I can add a button to the app and make everyone's life a bit easier.

<hr>

If you have a large number of selected rows and scrolling through the `Check selected` tab becomes annoying, you can click on the **`CSV`** or **`Excel`** button on the top left. This will download a .csv or .xlsx file of the selected table, as save it in the folder that you indicated at the beginning.

## Assignment
Using the entries in the **Assignment pane**, you can change the value of any column in the metadata table, for the rows you have selected. 

For all the assignment text bars, you can either enter a **single value** that will be assigned to all the selected rows, or you can enter **multiple values**, by separating them with a `; `. If you want to assign multiple values, make sure that the number of values you entered corresponds with the number of rows  you selected!

To assign values, simply click on the **`Assign`** button. Now you can check your progress in the  `Check assigned` tab. This will look exactly like the table in `Check selected` but your changes are now saved there. Note that a .csv file with saved changes will also automatically appear in the folder that you indicated at the beginning, if you find that easier to check. 

* [**Section**]() indicates the section on the GR- questionnaire (`A` to `K`). It is a *single capital letter*. I would suggest starting from this column when you work on completing your table, so you can use it in the selection and assignment of other metadata. 

* [**Question number**]() indicates the number of the question / item. This is sometimes  reported in the variable label or even indicated by the variable name, but I find it best to always check the questionnaire PDFs to make sure the number assigned corresponds. <br> Some questions have a more complex, nested structure with two or more levels, but don't worry about that for now. Assign all nested questions to the same number. 
    If you want to assign a series of consecutive numbers to the rows you have selected, it may be useful to use the [**From**]() and [**To**]() bars to generate a list of numbers. You can copy-paste this from the `Selection` tab into the **Question number** bar (and adapt it if needed).
    
> NOTE: when there is a question in the Questionnaire PDF that is <ins>not</ins> in the metadata table, i.e., has not corresponding variable or score, please indicate this in the [issues document](https://docs.google.com/spreadsheets/d/1hCDNHtlB_ksVX5toP3CQIDAVbHS9w8Xi3ZPkW79DIns/edit#gid=0).

* [**Questionnaire**](): some groups of items correspond to validated instruments. Please specify the **full name** of the instrument and its acronym between brackets, for example "Brief Symptoms Interview (BSI)". Please check the [Questionnaires Generation R with refs Aug 2020](https://github.com/SereDef/GenR-metadata-app/blob/main/useful%20files/Questionnaires%20Generation%20R%20with%20refs%20Aug%202020.doc) document, the [GenR_datataxonomy_v4](https://github.com/SereDef/GenR-metadata-app/blob/main/useful%20files/GenR_datataxonomy_v4.xlsx), or in the **referencesquestionnairesgenr** PDFs on the wiki, to identify these. 

* [**Reference**]() should be a **link** to the instrument reference or manual, which you should also find in the documents above. Preferably, this is the **DOI** (preceded by "https://doi.org/"). When this is not available you can use another link to the instrument reference/manual, or to a Generation R paper that describes the instrument. 

* [**Constructs**](). To help make the search more flexible, we also want to tag variables with the *concepts* they are supposed to tap into. For example maternal smoking variables could carry the tags 'smoking','tabacco','cigarettes'. Please include 1-3 terms that you believe apply. Separate terms with `; `. These can be also general, e.g. 'mental health' or more precise, e.g. 'anxiety'. 

* [**Variable label**]() is used to set the value of `var_label`, i.e., the variable description. This is an important part of the data dictionary and a terribly messy one too. Some labels are empty (~15%), some are in Dutch, some are just not understandable (e.g., they use acronyms that are not spelled out or they are just copies of variable names). PLEASE HELP US FIX THIS. 
    - For **items**, the label would normally correspond to the (complete) question that was asked, as you can read it in the PDFs, in English. If this is part of a nested question, please specify the *full* question so that it is understandable on its own. 
    - For **scores**, please use the best description you can find, including both the full name of a score or measure, with its acronym between brackets (when applicable) and measurement unit after a coma (when applicable). For example: `'Body mass index (BMI), kg/m2'`. 
    
* [**Subject**]() chose one of the options, to indicate who is the information about (`'child'`,`'mother'` or `'partner'`). Normally, this value can be assigned by *section* (look at the PDFs to quickly understand who the section is about). If not applicable, please set this to `none`.

* [**Reporter**]() chose one of the options, to indicate the person that completed the questionnaire/interview (`'child'`,`'mother'`, `'partner'` or `'teacher'`). Normally, this value was assigned automatically based on GR-number, but please correct it if you notice a mistake. 

* [**Variable type**]() chose one of the options, to indicate weather the variable is an`'item'` (i.e., a single question that was directly answered), a `'score'` (i.e., a combination of items, for example a subscale total score) or `'metadata'` (for example, child age). Other possible values include `'ID'` (i.e., for example 'IDC').

**Note**: most of the remaining columns are <ins>already assigned</ins> automatically, but please correct them if you spot errors or missing values. These include **`data_source`** and **`timepoint`**, which you can assign in the app, but also: `n_observed`,`var_type`,`orig_file`,`n_total`, `n_missing`, and `desctiptives`. It you notice something wrong with these, please report it in the [issues document](https://docs.google.com/spreadsheets/d/1hCDNHtlB_ksVX5toP3CQIDAVbHS9w8Xi3ZPkW79DIns/edit#gid=0).

Anything else that you can't find information about or you are just not sure, note it in the [issues document](https://docs.google.com/spreadsheets/d/1hCDNHtlB_ksVX5toP3CQIDAVbHS9w8Xi3ZPkW79DIns/edit#gid=0) se we can look into it together, or ask datamanagement for help. 

<hr>

Thank you so much for helping and good luck with the assignment! Please remember that if anything isn't working very well or you just would like it to be more efficient, feel free to ask, maybe I can help.

Cheers!


