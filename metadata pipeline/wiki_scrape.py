import requests
from bs4 import BeautifulSoup
import pandas as pd

# Link to the Generation R data wiki
page = requests.get('https://epi-wiki.erasmusmc.nl/wiki/genrwiki/index.php/DataWiki_Generation_R')

# Parse the html main page
soup = BeautifulSoup(page.content, "html.parser")

# Ignore all links and text before the actual files. This relies on the assumption that the last useless line is:
# "For additional information see also: Draaiboek Generation R Wiki"
start_from = soup.find(string='For additional information see also: ')
main = start_from.find_all_next(['h2', 'h3', 'p'])

# Initiate empty dataframe to store scraped info
df = pd.DataFrame(columns=['Period', 'Data-type', 'Sub-heading1', 'Sub-heading2', 'Files'])

for line in main:
    # Period headings in the page are kept within <h2> elements.
    if line.name == 'h2':
        period = line.text
    # I am only interested in the data under headings "... (Phase X)"
    if 'Phase' not in period:
        continue  # skip to the next line

    # Sub-headings in the page are kept within <h3> elements.
    if line.name == 'h3':
        data_type = line.text

    # Links and general file-names in the page are kept within <p> elements.
    if line.name == 'p':
        if 'Add this file to your basket' in line.text:
            df = df.append({'Period': period, 'Data-type': data_type, 'Sub-heading1': '', 'Sub-heading2': '',
                            'Files': line.text.strip('\n')},
                           ignore_index=True)
        else:
            sub_link = line.find('a')
            # if link.has_attr('href'): # does not work
            try:
                # Open new page and parse it
                link = 'https://epi-wiki.erasmusmc.nl/' + sub_link['href']
                new_page = requests.get(link)
                sub_soup = BeautifulSoup(new_page.content, "html.parser")
                # Extract title for Sub-heading1
                title = sub_soup.find("h1", id="firstHeading")
                # Extract content
                results = sub_soup.find("div", class_="mw-parser-output")
                sub_file = results.find_all('p')
                # initiate Sub-heading 2 variable as empty
                sub2 = ''
                for f in sub_file:
                    # If element on the new_page is bold, set Sub-heading 2 and skip to next line
                    if f.find('b'):
                        sub2 = f.text.strip('\n')
                        continue
                    # Finally, add line to the output dataframe
                    df = df.append({'Period': period, 'Data-type': data_type,
                                    'Sub-heading1': title.text, 'Sub-heading2': sub2, 'Files': f.text.strip('\n')},
                                   ignore_index=True)
            except:
                pass  # Do i need this ?

# Cleaning up =========================================================
# Remove "Add this file to your basket" and separate filenames from PIs
df[['Files', 'PIs']] = df['Files'].str.split('Add this file to your basket', expand=True)
# If no PI is specifies file is marked as "General"
df['PIs'] = df['PIs'].replace('', 'General')
# Files not directly downloadable from the wiki are trickier
df.loc[df.Files.str.contains(' PI:'), ['Files', 'PIs']] = df.loc[df.Files.str.contains(' PI:'), 'Files'].str.split(' PI: ', expand=True)

# df.loc[df.Files.str.contains('available', na=False),]
# df.loc[df.PIs.isnull(),]
# df.loc[df.Files.str.contains('PI:'),]
# df.loc[df.Files.str.contains('request'),]

df.to_csv('DATAWIKI_scrape.csv')
