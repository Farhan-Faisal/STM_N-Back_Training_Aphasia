################################################################################
# CODE TO CREATE A LIST OF WORDS FOR REPLACING BAD WORDS IN WORD REP TASK
################################################################################

# load in the population of words that the word rep task list was created from
population <- read.table("../2017-02-27_updated_population_allvars_lemmatized_manualcheck.txt", 
                         header = TRUE, stringsAsFactors = FALSE)

# load in the subpopulation of words including in the word rep task list
subpopulation <- read.table("../2017-02-27_subpopulation_allvars.txt",
                            header = TRUE, stringsAsFactors = FALSE)

## remove subpopulation words from population

# loop over subpopulation list
for (i in 1:length(subpopulation$Word.s)) {
      # print progress
      print(cat("Processing item ", i,
                       round((i / length(subpopulation$Word.s) * 100), 3),
                       "% completed"))
      # look for subpop word in population list, remove if present
      for (j in 1:length(population$Word.s)) {
            if (subpopulation$Word.s[i] == population$Word.s[j]) {
                  population <- population[-j, ]
                  break
            }
      }
}

# write the extra words out to a text file
write.table(population, "../extra_words.txt")




################################################################################
# What if we just take the bad words out of the population and try to create
# a new subpopulation?
################################################################################
# load in the population of words that the word rep task list was created from
population <- read.table("../2017-02-27_updated_population_allvars_lemmatized_manualcheck.txt", 
                         header = TRUE, stringsAsFactors = FALSE)

# load in the list of bad words from the current task list
badwords <- read.csv("../2017-03-28_badwords_from_stimuli.csv", header = TRUE)


## remove the bad words words from population

# loop over subpopulation list
for (i in 1:length(badwords$Word)) {
      # print progress
      print(cat("Processing item ", i,
                round((i / length(badwords$Word) * 100), 3),
                "% completed"))
      # look for subpop word in population list, remove if present
      for (j in 1:length(population$Word.s)) {
            if (badwords$Word[i] == population$Word.s[j]) {
                  population <- population[-j, ]
                  break
            }
      }
}

# write out new edited population
table(population$cmu_sylls.f, population$Zipfvalue_cat.s)
##     high low
##   1  752 324
##   3  349 402