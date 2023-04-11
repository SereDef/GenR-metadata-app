import os.path
import glob
import PyPDF2
import re
import pandas as pd
# ignore warnings
# import warnings; warnings.filterwarnings('ignore')

# Define the path to pdf data
pathtodata = input("Enter the path to data: ")
if not os.path.exists(pathtodata):  # check if the path already exists, if not, ask for it again
    pathtodata = input("Not quite, try again: ")


# Get rid of common trash coming out of the pdfs when extracting them
def clean_page(page):
    clean_page = re.sub(u"\u2122", "'", page)     # replace TM character with '
    clean_page = re.sub(r'\n', ' ', clean_page)   # replace all wrap-ups (\n) with spaces
    clean_page = re.sub(r' +', ' ', clean_page)   # replace multiple spaces with one space
    clean_page = re.sub(r'\+.*Page \d+.*\+\s+', '', clean_page)  # clean some other trash up
    return clean_page

# Define some common patterns (https://www.w3schools.com/python/python_regex.asp) to separate text into sections,
# and then section letter, title, description, and questions.

# 1. Separate a questionnaire into sections
questionnaire_split_pattern = re.compile(r'(?=\b[A-Z]\.\s[A-Z]{3,})') # begins with (any) capital letter, followed by
# a dot, and a word in capital letters (at least 3 letters long)

# 2. Separate a section into info (letter. title, description) and questions
section_split_pattern = re.compile(r'(\b[A-Z]\..+?) (\b\d+[a-z]?\.\s[A-Z].*)') # define two groups:
# the first (info section) begins with a letter followed by a dot and anything afterwands
# the second (questions) begins with a digit, possibly a lower case letter, a dot and a word startinng with capital

# 3. Separate section's info section into letter, title, and desctiption
info_split_pattern = re.compile(r'(\b[A-Z]\.) (\b[A-Z\W\s]+\b)(\b[A-Z]+.*)?') # three groups: first a capital letter
# and a dot, then a word or multiple words in capital, third anything that starts with a capital letter

# 4. Separate section's question sections into a list of questions
questions_split_pattern = re.compile(r'(?=\b\d+[a-z]?\.)') # staring with a digit, possibly a lower case letter, dot.

def extract_from_pdfs(file_list: list) -> list:
    """Creates a dictionary of questionnaire name : questionnaire text."""
    questionnaires = []
    for file in file_list:
        with open(file, "rb") as f:
            pdf_reader = PyPDF2.PdfFileReader(f, strict=False)
            q_name = "GR" + file.split("/gr")[1].split("_")[0]
            q_text = ""
            for page in range(pdf_reader.numPages):
                page_object = pdf_reader.getPage(page)
                page_text = page_object.extractText()
                q_text += clean_page(page_text)
            questionnaires.append({"questionnaire": q_name, "text": q_text})
    return questionnaires

def split_questionnaire(questionnaire_text: str) -> list:
    """Divides questionnaire text into a list of sections."""
    sections = re.split(questionnaire_split_pattern, questionnaire_text)
    return [s for s in sections if s]  # remove empty strings from list

def split_section(section_text: str) -> dict:
    """Divides questionnaire sections into a info section and quesitons. Returns a dictionary"""
    split_section = re.findall(section_split_pattern, section_text)[0]
    return {"info": split_section[0], "questions": split_section[1]}

def split_section_info(section_info_text: str) -> dict:
    """Divides info section into letter, title and description (if present). Returns a dictionary"""
    split_section_info = re.findall(info_split_pattern, section_info_text)[0]
    return {
        "letter": split_section_info[0],
        "title": split_section_info[1],
        "description": split_section_info[2],
    }

def split_questions(questions_text: str) -> list:
    """Creates a list of questions."""
    spit_questions = re.split(questions_split_pattern, questions_text)
    return [q for q in spit_questions if q]  # remove empty strings from list

# ---------------------------------------------------------------------------
# Get all pdf files in the folder and sort them by filename
qlist = glob.glob(pathtodata +'*.pdf')
qlist.sort()

questionnaires = extract_from_pdfs(qlist)

for questionnaire in questionnaires:
    questionnaire["merged_sections"] = split_questionnaire(questionnaire["text"])
    questionnaire.pop("text")
    questionnaire["sections"] = []

    for section in questionnaire["merged_sections"]:
        splt_section = split_section(section)

        section_info = split_section_info(splt_section["info"])

        splt_section.update(section_info)
        splt_section.pop("info")

        splt_section["questions"] = split_questions(splt_section["questions"])

        questionnaire["sections"].append(splt_section)
    questionnaire.pop("merged_sections")

# Dictionaries are nice for using neo4j and so on (apparently) but for now I turn the data dictionary into a dataframe
# so the output of the search engine is more readable.
def questionnaires_dict_to_df(questionnaires: dict) -> pd.DataFrame:
    df = pd.DataFrame.from_dict(questionnaires)
    df = df.explode("sections")
    df = pd.concat([df.drop(["sections"], axis=1), df["sections"].apply(pd.Series)], axis=1)
    df = df.explode("questions")
    df[["number", "question"]] = df["questions"].str.split(".", 1, expand=True)

    df["item_subletter"] = df["number"].apply(lambda x: x[-1] if any(char.isalpha() for char in x) else "")
    df["number"] = df["number"].apply(lambda x: re.sub("\D", "", x))

    df.drop("questions", axis=1, inplace=True)

    d = {'questionnaire': 'GR_ID', 'letter': 'section', 'title': 'section_title', 'description': 'section_instructions',
         'number': 'item_nr', 'item_subletter': 'item_subletter', 'question': 'item'}
    df = df.rename(columns=d).reindex(columns=d.values())

    df.reset_index(drop=True, inplace=True)
    return df

# Create the dataframe from dictionary
df = questionnaires_dict_to_df(questionnaires)

# save the dataframe to a csv file
df.to_csv("questionnaires.csv")
