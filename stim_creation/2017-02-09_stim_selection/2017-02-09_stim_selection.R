################################################################################
# Author: Tiffany Deschamps
# Date: February 10, 2017
# Last updated by Tiffany Deschamps on January 20, 2017
################################################################################

################################################################################
# THE PLAN:
# 1. Extract nouns from SUBTLEX-US corpus.
# 2. Remove words included in Regina's treatment list.
# 3. Perform lemmatization & count syllables in python.
# 4. Extract one-syllable words and three-syllable words from this new list.
# 5. Enter nouns into N-WATCH to get bigram frequency and length.
# 6. Use SOS to sample from this population of nouns to create stimulus lists.
################################################################################

################################################################################
# STEP 1: EXTRACT NOUNS FROM SUBTLEX-US CORPUS
################################################################################

library(openxlsx) # load library with commands to open .xlsx files

# load SUBTLEX-US corpus
list.files("./data")
subtlexus <- read.xlsx("./data/SUBTLEX-US frequency list with PoS and Zipf information.xlsx",
                       sheet = 1)

# extract nouns from subtlexus
nouns <- subset(subtlexus, Dom_PoS_SUBTLEX == "Noun")
write.csv(nouns, file = "nouns.csv")

################################################################################
# STEP 2: REMOVE WORDS ALSO IN TREATMENT LIST
################################################################################

# load treatment words
treatment <- read.xlsx("./data/2017-02-09_baseline_measures_294.xlsx", sheet = 1)

for (i in 1:length(treatment$Target)) {
      # print progress
      print(cat(paste0("Processing item ", i, " of 285, ",
                       round((i / length(treatment) * 100), 3),
                       "% completed")))
      # look for treatment word in nouns list, remove if present
      for (j in 1:length(nouns$Word)) {
            if (treatment$Target[i] == nouns$Word[j]) {
                  nouns <- nouns[-i, ]
                  break
            }
      }
}

################################################################################
# STEP 3: LEMMATIZE NOUNS & GET SYLLABLE INFO IN PYTHON
################################################################################

# take only the nouns that are between 3 and 10 characters long
goodnouns <- subset(nouns, nchar(Word) >= 3 & nchar(Word) <= 10)

# write goodnouns to .csv to use in python script
write.csv(goodnouns, file = "./data/goodnouns.csv")

# the rest of this step happens in python

################################################################################
# STEP 4: EXTRACT 1- AND 3- SYLLABLE WORDS
################################################################################

newnouns <- read.csv("./data/word_rep_pop_sylls.csv", header = TRUE)

rightnouns <- subset(newnouns, CMUSylls == 1 | CMUSylls == 3)

# write rightnouns to be input into N-WATCH to obtain orthographic information
write.csv(rightnouns, file="population_nouns.csv")

################################################################################
# STEP 5: RUN WORDS THROUGH N-WATCH TO GET ORTHOGRAPHIC INFO
################################################################################

# the first part of this step happens in N-WATCH
# select bigram freq (type), length, and neighbourhood count

nwatch <- nwatchvars <- read.table("popnouns_nwatch.txt", header = TRUE)
      
population <- cbind(rightnouns, nwatch[, 2:4])

write.csv(population, file = "2017-02-13_population_allvars.csv")
