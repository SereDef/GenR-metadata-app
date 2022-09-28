import pandas as pd
import numpy as np
import string
from typing import Union

# Define the input file

GR_ids = {'GR1001':['12-20 w','mother'], # The health of you and your child
          'GR1002':['15-23 w','mother'], # De voeding van moeder
          'GR1003':['20-25 w','mother'], # Feelings and memories
          'GR1004':['20-25 w','father'], # Health, lifestyle, background and feelings (partner)
          'GR1005':['30 w',   'mother'], # Living conditions
 # Postnatal (actual median age in months until 6y then in years)
          'GR1018':['2 m',  'mother', 2.8], # The first two months - your child
          'GR1019':['2 m',  'mother', 2.8], # The first two months - mother
          'GR1024':['6 m',  'mother', 6.3], # The first six months - mother
          'GR1025':['6 m',  'mother', 6.3], # The first six months - your child
          'GR1028':['1 y',  'mother', 12.0],# My first year in Generation R
          'GR1060':['1 y',  'mother', 12.9],# De voeding van mijn kind - rond de 1e verjaardag
          'GR1029':['1.5 y','mother', 18.2],# My 1 / 1.5 year old toddler
          'GR1032':['2 y',  'mother', 24.2],# My todler
          'GR1064':['2 y',  'mother', 24.9],# De voeding van mijn kind – rond de 2e verjaardag
          'GR1062':['2.5 y','mother', 30.7],# My toddler’s development
          'GR1065':['3 y',  'mother', 36.2],# My three-year-old child
          'GR1066':['3 y',  'father', 36.4],# My three-year-old child (partner)
          'GR1067':['4 y',  'mother', 48.3],# My 4-year old child
          'GR1075':['5 y',  'mother', 71.4],# The development of my 5/6-year old child – Part I
          'GR1076':['5 y',  'mother', 72.6],# The development of my 5/6-year old child – Part II
          'GR1079':['6 y',  'teacher',74.9],# Gedragsvragenlijst voor kinderen t/m 18 jaar
          'GR1080':['8 y',  'mother', 8.07],# Diet and behavior
          'GR1081':['9 y',  'mother', 9.67],# Development of my 9/10 year old child - Part 1
          'GR1082':['9 y',  'mother', 9.79],# Development of my 9/10 year old child - Part 2
          'GR1083':['9 y',  'father', 9.74],# Development of my 9/10-year old child - Partner
          'GR1084':['9 y',  'child',  9.78],# Mijn eerste vragenlijst
          'GR1093':['13 y', 'mother',13.49],# My teenager part 1
          'GR1094':['13 y', 'mother',13.58],# My teenager part 2
          'GR1095':['13 y', 'child', 13.52],# Mijn vragenlijst – Deel 1
          'GR1096':['13 y', 'child', 13.71],# Mijn vragenlijst – Deel 2
          'GR1097':['13 y', 'mother',13.54]}# ? about ENT specialist visit ?


# Construct the main assignment funtion. It takes only one obligatory argument: selected.
def assign(q, selected: Union[str, list],  # var_type, n_observed, orig_file, n_total, n_missing, descriptives
           based_on: str = 'orig_file',
           case_sensy=False,
           sel_type='contains',  # 'ends', 'starts', 'is'
           and_also: tuple = None,
           verbose=False,
           print_labels=False,
           download = None,
           # assignment arguments
           data_source: str = None,
           timepoint: Union[str, list] = None,
           reporter: Union[str, list] = None,
           var_label: Union[str, list] = None,
           subject: Union[str, list] = None,
           gr_section: Union[str, list] = None,
           gr_qnumber: Union[str, list] = None,
           var_comp: Union[str, list] = None,
           questionnaire: Union[str, list] = None,
           questionnaire_ref: Union[str, list] = None,
           constructs: Union[str, list] = None):
    # SELECTION --------------------------------------------------
    if based_on not in q.columns:
        print('There is no column called \"', based_on, '\"', sep='')
        return None

    selection = '|'.join(selected) if isinstance(selected, list) else selected  # define the selection

    if sel_type == 'contains':  # fix using regex i think
        sel = q[based_on].str.contains(selection, na=False, case=case_sensy)  # perform the selection
    elif sel_type == 'starts':
        sel = q[based_on].str.startswith(selection, na=False)  # perform the selection
    elif sel_type == 'ends':
        sel = q[based_on].str.endswith(selection, na=False)  # perform the selection
    elif sel_type == 'is':
        sel = q[based_on] == selection  # perform the selection

    if and_also:  # additional constraints
        sel = (sel & q[and_also[0]].str.contains(and_also[1], na=False, case=case_sensy))

    data = q.loc[sel,]

    if len(data) < 1:
        if verbose:
            print('Your selection (', selection, ') resulted in 0 rows!', sep='')
        return None
    else:
        if verbose:
            print(len(data), 'rows selected.')
        if print_labels:
            print(list(q.loc[sel, 'var_label']))

    # ASSIGNMENT -------------------------------------------------
    if data_source:
        if data_source in GR_ids.keys():
            q.loc[sel, ['data_source', 'timepoint', 'reporter']] = data_source, GR_ids[data_source][0], \
                                                                   GR_ids[data_source][1]
        else:
            q.loc[sel, 'data_source'] = data_source

    def match_length(arg, name):
        if isinstance(arg, list) and len(arg) != len(data):
            print('The number of rows (', len(data), ') and assigned values (', len(arg), ') of ', name,
                  ' do not match', sep='')
            return False
        else:
            return True

    if timepoint:
        if not match_length(timepoint, 'timepoint'):
            return None
        q.loc[sel, 'timepoint'] = timepoint

    if reporter:
        if not match_length(reporter, 'reporter'):
            return None
        q.loc[sel, 'reporter'] = reporter

    if gr_section:
        if not match_length(gr_section, 'gr_section'):
            return None
        q.loc[sel, 'gr_section'] = gr_section

    if gr_qnumber:
        if not match_length(gr_qnumber, 'gr_qnumber'):
            return None
        q.loc[sel, 'gr_qnumber'] = gr_qnumber

    if subject:
        if not match_length(subject, 'subject'):
            return None
        q.loc[sel, 'subject'] = subject

    if var_label:
        if not match_length(var_label, 'var_label'):
            return None
        q.loc[sel, 'var_label'] = var_label

    if var_comp:
        if not match_length(var_comp, 'var_comp'):
            return None
        q.loc[sel, 'var_comp'] = var_comp

    if questionnaire:
        if not match_length(questionnaire, 'questionnaire'):
            return None
        q.loc[sel, 'questionnaire'] = questionnaire

    if questionnaire_ref:
        if not match_length(questionnaire_ref, 'questionnaire_ref'):
            return None
        q.loc[sel, 'questionnaire_ref'] = questionnaire_ref

    if constructs:
        if not match_length(constructs, 'constructs'):
            return None
        q.loc[sel, 'constructs'] = constructs

    # Do not assign specific sources to ID variables
    ids = ['IDM', 'idm', 'MOTHER', 'IDC']

    for id_var in ids:
        q.loc[q['var_name'] == id_var, 'var_comp'] = 'ID'
        q.loc[q['var_name'] == id_var, ['timepoint', 'data_source', 'gr_section', 'gr_qnumber', 'reporter',
                                        'questionnaire', 'questionnaire_ref', 'constructs']] = ' '
        sbj = 'child' if id_var == 'IDC' else 'mother'
        q.loc[q['var_name'] == id_var, 'var_comp'] = sbj

    other = ['GENDER', 'FUPFASE2', 'ETHNM', 'INTAKE', 'intake']  # add age
    for other_var in other:
        q.loc[q['var_name'] == other_var, ['timepoint', 'data_source', 'gr_section', 'gr_qnumber', 'reporter',
                                           'questionnaire', 'questionnaire_ref', 'constructs', 'var_comp']] = ' '
        sbj = 'child' if other_var in ['GENDER', 'FUPFASE2'] else 'mother'
        q.loc[q['var_name'] == other_var, 'var_comp'] = sbj

    show = q.loc[sel,] # .set_index('var_name')

    if download:
        show.to_csv(download)
            
    return (show)


def list_numbers(start, end, lvl1=None, lvl2=None):
    main = [str(i) for i in range(start, end + 1)]
    if lvl1:
        sub1 = list(string.ascii_lowercase)[:lvl1]
        numb = []
        for m in main:
            for s in sub1:
                numb.append(m + "." + s)

        if lvl2:
            sub2 = [str(i) for i in range(1, lvl2 + 1)]
            numb2 = []
            for m in numb:
                for s in sub2:
                    numb2.append(m + "." + s)
            return (numb2)
        else:
            return (numb)
    else:
        return (main)
    
