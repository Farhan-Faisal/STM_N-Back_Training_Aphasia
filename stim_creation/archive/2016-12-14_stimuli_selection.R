################################################################################
#  STIMULI SELECTION FOR WORD REPETITION EXPERIMENT FOR NIBS TREATMENT STUDY   #
#  2016-12-14                                                                  #
################################################################################

################################################################################
# THE PLAN:
# 1. Extract nouns and verbs from SUBTLEX-US corpus.
# 2. Enter nouns and verbs into N-WATCH to retrieve additional linguistic 
#    features (plan to extract all features N-WATCH offers).
# 3. Combine frequency norms from SUBTLEX-US and linguistic info from N-WATCH.
# 4. Extract one-syllable words and three-syllable words from this new database.
# 5. Divide the data to create lists of words that roughly fit into these 
#    conditons:
#    a. high-frequency one-syllable words
#    b. low-frequency one-syllable words
#    c. high-frequency three-syllable words
#    d. low-frequency three-syllable words
# 6. Sample data to create a stimulus list of 400 words, 100 in each condition,
#    with two lists of 50 words in each condition, all matched on various 
#    linguistic factors (AoA, # of phonemes, concreteness, etc).
# 7. Maybe we can come up with 2000 words, 500 in each condition, with 10 lists
#    of 50 words in each condition, all matched on various linguistic factors?
################################################################################


################################################################################
# STEP 1 - EXTRACT NOUNS AND VERBS FROM SUBTLEX-US CORPUS                      #
################################################################################

# Load the SUBTLEX-US corpus, which contains word frequency data collected from
# the subtitles of American films and television shows.
library(openxlsx)
list.files("./data")
subtlexus <- read.xlsx("./data/SUBTLEX-US frequency list with PoS and Zipf information.xlsx",
                       sheet = 1)

# Extract all nouns that are only used as nouns from the SUBTLEX-US corpus.
nouns <- subtlexus[ which(subtlexus$Dom_PoS_SUBTLEX == "Noun" & 
                                 subtlexus$All_PoS_SUBTLEX == "Noun"), ]

# Extract all verbs that are only used as verbs from the SUBTLEX-US corpus.
verbs <- subtlexus[which(subtlexus$Dom_PoS_SUBTLEX == "Verb" &
                               subtlexus$All_PoS_SUBTLEX == "Verb"), ]

# Combine nouns and verbs into a single data frame and write to .xlsx
nounsandverbs <- rbind(nouns, verbs)
write.csv(nounsandverbs, file = "subtlexus_nounsandverbs.csv")

################################################################################
# STEP 2 - ENTER NOUNS AND VERBS INTO N-WATCH, RETRIEVE LING INFO              #
################################################################################

# This step will be completed outside of R, in the N-WATCH program.

#####
# NOTE: N-WATCH doesn't like words that are less than 2 letters long, or more
# than 12 letters long. It also doesn't calculate bigram frequencies for words
# more than 10 letters long. So, I'm subsetting the data to only include
# words between 3 and 10 letters long.
#####

goodnounsandverbs <- subset(nounsandverbs, nchar(Word) >= 3 & nchar(Word) <= 10)
write.csv(goodnounsandverbs, file = "subtlexus_nounsandverbs_3-10chars.csv")

#####
# NOTE: N-WATCH has trouble with computing ALL of the linguistic features for
# all ~30,000 words, so the first one I extracted was the number of syllables.
# Using the number of syllables, I can limit the list of words I give N-WATCH
# to only words that fit our syllable-length criteria (1 vs. 3). Hopefully
# N-WATCH can handle that new list?
#####

# load the syllable info
list.files("./")
numsylls <- read.delim("./n-watch_numsylls.txt")

# append the syllable info to the 'goodnounsandverbs' data frame
numsylls <- numsylls[1:29959, ] # remove last empty row
goodnounsandverbs <- cbind(goodnounsandverbs, syllables = numsylls$LEN_S)
goodnounsandverbs$syllables <- as.character(goodnounsandverbs$syllables)
goodnounsandverbs$syllables <- as.numeric(goodnounsandverbs$syllables)

# this code loses A LOT of data
# # subset only 1- and 3-syllable words
# rightnounsandverbs <- subset(goodnounsandverbs, syllables == 1 | syllables == 3)
# write.csv(rightnounsandverbs, 
#           file = "subtlexus_nounsandverbs_3-10chars_1-3sylls.csv")


#####
# NOTE: N-WATCH only gave us information on number of syllables for 12874 of
# the 29959 words that were 3-10 letters long, so we're going to use the CMU
# Dictionary to estimate the number of syllables.
#####

# read in the CMU dictionary
cmudict <- read.delim("./cmudict-edited.txt", header = FALSE)

# this separates the word from the pronunciation
cmudictsep <- cmudict %>% separate(V1, into = c("word", "pronunciation"), 
                                   sep = " ", extra = "merge", fill = "right")
write.csv(cmudictsep, file = "cmudict.csv")

# now, we have to find a way to count the number of syllables
# to do this, we're going to count the number of digits in the character
# string in the pronunciation column, then input that digit into a new column
# called "numsyll"

cmudict <- cmudictsep # moves separated data to old name
cmudict[, "syllables"] <- NA # add a syllables column

# this counts the numbers of digits in the pronunciation and saves the result
# in the syllable column
for (i in 1:length(cmudict$pronunciation)) {
      # count number of digits in CMU pronunciation (digits = syllables)
      syllnum <- as.numeric(length(unlist(regmatches(cmudict$pronunciation[i], 
                                                     gregexpr("[0-9]", 
                                                              cmudict$pronunciation[i])))))
      # write number of syllables into cmudict
      cmudict$syllables[i] <- syllnum
}

# translate upper case to lower case to make matching easier
cmudict$word <- tolower(cmudict$word)
write.csv(cmudict, file = "cmudict_syllables.csv") # write file to csv


# lookup words from goodnounsandverbs in cmudict, extract number of syllables,
# then write number of syllables into goodnounsandverbs
goodnounsandverbs[, "cmu_syllss"] <- NA

# define the vector of letter indices in the dict
#indexvec <- data.frame(word = c("a", "b", "c"), index = c(1, 2, 3))
letters <- c("a","b","c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
             "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")
indices <- c(1, 7236, 16918, 27611, 35349, 40052, 45296, 51003, 57445, 60833,
             62502, 66658, 72166, 81695, 84900, 87882, 96128, 96584, 103912, 
             117905, 123540, 125340, 127670, 132056, 132135, 132863)

for (i in 1:length(goodnounsandverbs$Word)) {
      cat(paste0(round((i / length(goodnounsandverbs$Word) * 100), 3), "% completed"))
      # look at first letter
      fletter <- substring(goodnounsandverbs$Word[i], 1, 1)
      
      # find position in the alphabet of first letter
      indx <- match(fletter,letters)
      
      # this is going to be the index at which to start
      jstart <- indices[indx]
      
      # loop over dict
      for (j in jstart:length(cmudict$word)) {
            if (goodnounsandverbs$Word[i] == cmudict$word[j]) {
                  syllnum <- cmudict$syllables[j]
                  goodnounsandverbs$cmu_syllss[i] <- syllnum
                  break
            } 
      }
}
write.csv(goodnounsandverbs, file = "goodwords_cmusyllables.csv") # write file

################################################################################
# STEP 3 - COMBINE FREQUENCY NORMS WITH OTHER LING INFO FROM N-WATCH           #
################################################################################
