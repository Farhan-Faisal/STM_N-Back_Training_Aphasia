**______________________________________________________________**
- Author: Farhan Bin Faisal
- Files: preprocess.ipynb, wordListMaker.m, postWuggy.ipynb
- Date Created: 10 November 2022
- Meltzer Lab

**______________________________________________________________**
### RESEARCH POSTER
<img width="712" alt="NBack_Poster" src="https://github.com/user-attachments/assets/6954dd90-7736-46b8-8a3a-655a11c349ad">


**______________________________________________________________**
### EXPERIMENT PARADIGM

The NBAck Training padigm was programmed in JavaScript (using PsychoJS) and hosted on Pavlovia.
A trial run can be accessed [here](https://run.pavlovia.org/MeltzerLab/20_07_2023_nbacktest).
Please input the following credentials
- session: 1
- participantID: 19995

**______________________________________________________________**
### STIMULY GENERATION PIPELINE

#### 1.) preprocess.ipynb
- Loads word csv file into a pandas dataframe
- Filters rows for frequency (4.0 Zipfvalue < 5.0)
- Gets syllables of each word
    - Uses cmudict from nltk
- Filters rows for syllables (1 < syllable < 2)
- Replaces each word with its correcponding lemma
    - Uses WordNetLemmatizer for this
- Discards rows not found in cmudict
- Discards profane words and names
- Formats dataframe into SOS compatible input
- Outputs dataframe as a tab delimited txt file
    - File Named "sos_input.txt"

**______________________________________________________________**
#### 2.) wordListMaker.m
- Uses SOS to make 18 lists of 10 words each
- Lists matched on ZipfValue and syllables
    - Used soft constraints for this
    - Used hard constrains to floor syllable count and frequency
- Lists can be found in the folder "wordLists"

**______________________________________________________________**
#### 3.a) wuggy/postSOS.ipynb
- Generates nonword lists for every wordList
- nonWordLists outputted to folder nonWordList
- Prints filenames of files which contain words that could not be converted to a nonWord automatically
    - Need to generate those pseudowords manually

**______________________________________________________________**
#### 3.b) Wuggy || Generate nonWords manually

- Download from http://crr.ugent.be/programs-data/wuggy
- Settings used:
    - Orthographic english
    - Match syllable length
    - Match word length
    - Match transition frequency
    - Match 2 out of 3 segments
- Manually pass the words that could not be found in lexicon through wuggy
