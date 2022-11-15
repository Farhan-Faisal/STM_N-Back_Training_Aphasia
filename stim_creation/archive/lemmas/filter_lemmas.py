# -*- coding: utf-8 -*-
"""
This reads in a list of words with statistics, and checks which words are lemmas, and 
outputs a new list consisting only of the lemma words.
"""

from __future__ import division
import nltk, re, pprint, numpy, os, sys
import string
import scipy 
from scipy import mean
from nltk.stem import WordNetLemmatizer
wnl = WordNetLemmatizer()

workdir = '/Users/meltzerj/Desktop/projects_rotman/NIBS_treatment/wordrep_dev/'
infilename = 'goodwords_1-3sylls.csv'
inlines = open(workdir + infilename,'r').readlines()[1:]  #skip header line with [1:]

outfilename = 'lemmas_goodwords_1-3sylls.csv'
outfile = open(workdir + outfilename,'w')
 
for thisline in inlines:
    thefields = thisline.split(',')
    theword = thefields[2]
    if thefields[11] == 'Noun':
        thelemma = wnl.lemmatize(theword,pos='n')
    elif thefields[11] == 'Verb':
        thelemma = wnl.lemmatize(theword,pos='v')
    else:
        continue
    if (theword == thelemma):
        outfile.write(thisline)
        
outfile.close()
