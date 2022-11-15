# -*- coding: utf-8 -*-
"""
Created on Mon Feb 13 11:21:12 2017

@author: tdeschamps

This script lemmatizes the nouns pulled from SUBTLEX, then pulls syllable info
for those words from the CMU dictionary.
"""

# import packages
import pandas as pd, nltk
from nltk.stem import WordNetLemmatizer
wnl = WordNetLemmatizer()

# load data
cmudict = nltk.corpus.cmudict.dict() # load CMU dictionary
nouns = pd.read_csv('C:\\Users\\tdeschamps\\Documents\\NIBS_treatment\\word_rep_paradigm\\stimuli_creation\\2017-02-09_stim_selection\\data\\goodnouns.csv', index_col = 'Word') # load nouns

# LEMMATIZE NOUNS
lemmas = [] # empty list to work with

# loop over words in nouns
for row in nouns.itertuples():
      # lemmatize the word
      word = index
      lemma = wnl.lemmatize(word, pos = 'n')
      # if the word and the lemma are identical, add freq info to temporary list
      if (word == lemma):
            info = row
            lemmas.append(info)
 
# convert list to a dataframe
newnouns = pd.DataFrame(lemmas, columns = ['Word', 'Unnamed', 'FREQcount', 'CDcount', 'FREQlow', 'Cdlow', 'SUBLTLWF', 'Lg10WF', 'SUBTLCD', 'Lg10CD', 'Dom_PoS_SUBTLEX', 'Freq_dom_PoS_SUBTLEX', 'Percentage_dom_PoS', 'All_PoS_SUBTLEX', 'All_freqs_SUBTLEX', 'Zipfvalue'])
 
# FIND SYLLABLE INFO FOR LEMMAS
words = newnouns['Word'] # list of words to work with
infolist = [] # empty list to work with

# loop over words in newnouns
for word in words:
      # find syllables if word is in the CMU dictionary
      if word in cmudict:
            pronunciation = cmudict[word][0]
            string = ' '.join(pronunciation)
            sylls = string.count('0') + string.count('1') + string.count('2')
      else:
            continue
      # add word and syllable number to temporary list
      info = [word, sylls]
      infolist.append(info)

# convert list to a dataframe
infodf = pd.DataFrame(infolist, columns = ['Word', 'CMUSylls'])

# set indices on both temporary dataframes (for merging)
infodf.set_index('Word')
newnouns.set_index('Word')

# merge dataframes
newdf = pd.merge(newnouns, infodf, how = 'inner', on = 'Word')                      

# write to csv, to import into R to continue working with
newdf.to_csv('C:\\Users\\tdeschamps\\Documents\\NIBS_treatment\\word_rep_paradigm\\stimuli_creation\\2017-02-09_stim_selection\\data\\word_rep_pop_sylls.csv')                    