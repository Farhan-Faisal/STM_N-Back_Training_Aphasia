################################################################################
# RUNNING STATS ON STIM AFTER CHANGES WERE MADE
# Specifically: Running ANOVA to make sure our Zipf, length, and bigram
# frequency values haven't changed drastically.
################################################################################


data <- read.csv("../2017-02-29_fixed-words-for-stats.csv", header = TRUE,
                 stringsAsFactors = FALSE)

str(data)
data$run <- as.factor(data$run)
data$cond <- as.factor(data$cond)
data$list <- as.factor(data$list)


aovZipf <- aov(Zipfvalue ~ cond * list * run + Error(run / list), data = data) # diffs
# Error: run
# Df Sum Sq Mean Sq
# run  4  1.325  0.3313
# 
# Error: run:list
# Df Sum Sq Mean Sq
# list      6 0.0803 0.01339
# list:run 24 2.1374 0.08906
# 
# Error: Within
#                 Df Sum Sq Mean Sq F value  Pr(>F)    
# cond             3 149.59   49.86 723.758 < 2e-16 ***
# cond:list       18   1.35    0.07   1.085 0.36130    
# cond:run        12   2.00    0.17   2.417 0.00423 ** 
# cond:list:run   72   5.05    0.07   1.018 0.43755    
# Residuals     1260  86.81    0.07                    
# ---
#       Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1


aovlen <- aov(LEN_L ~ cond * list * run + Error(run / list), data = data) # diffs
# Error: run
# Df    Sum Sq   Mean Sq
# run  4 2.213e-28 5.533e-29
# 
# Error: run:list
# Df    Sum Sq   Mean Sq
# list      6 3.320e-28 5.533e-29
# list:run 24 1.328e-27 5.533e-29
# 
# Error: Within
#                 Df    Sum Sq   Mean Sq F value Pr(>F)
# cond             3 1.700e-28 5.533e-29       1  0.392
# cond:list       18 1.000e-27 5.533e-29       1  0.457
# cond:run        12 6.600e-28 5.533e-29       1  0.446
# cond:list:run   72 3.980e-27 5.533e-29       1  0.480
# Residuals     1260 6.972e-26 5.533e-29    


aovBF <- aov(BF_TP ~ cond * list * run + Error(run / list), data = data) # diffs
# Error: run
# Df Sum Sq Mean Sq
# run  4   1474   368.6
# 
# Error: run:list
# Df Sum Sq Mean Sq
# list      6  703.3   117.2
# list:run 24 2742.6   114.3
# 
# Error: Within
#                 Df  Sum Sq Mean Sq F value Pr(>F)    
# cond             3  562871  187624 194.514 <2e-16 ***
# cond:list       18   14278     793   0.822  0.675    
# cond:run        12    1946     162   0.168  0.999    
# cond:list:run   72   52936     735   0.762  0.929    
# Residuals     1260 1215368     965                   
# ---
#       Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1


################################################################################
# LOOKING AT THE OLD NUMBERS FOR COMPARISON
################################################################################

olddata <- read.csv("../2017-02-27_old-words.csv", header = TRUE, 
                    stringsAsFactors = FALSE)

oldaovZipf <- aov(Zipfvalue ~ cond_code * list * run + Error(run/list), olddata)
# Error: run
# Df Sum Sq Mean Sq
# run  4  1.144  0.2859
# 
# Error: run:list
# Df  Sum Sq Mean Sq
# list      1 0.00312 0.00312
# list:run  4 0.15278 0.03820
# 
# Error: Within
#                       Df Sum Sq Mean Sq  F value Pr(>F)    
# cond_code             1 120.76  120.76 1327.551 <2e-16 ***
# cond_code:list        1   0.03    0.03    0.370 0.5429    
# cond_code:run         4   0.85    0.21    2.330 0.0542 .  
# cond_code:list:run    4   0.27    0.07    0.743 0.5629    
# Residuals          1380 125.53    0.09                    
# ---
#       Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

oldaovlen <- aov(LEN_L ~ cond_code * list * run + Error(run/list), olddata)
# Error: run
# Df    Sum Sq   Mean Sq
# run  4 2.213e-28 5.533e-29
# 
# Error: run:list
# Df    Sum Sq   Mean Sq
# list      1 1.245e-28 1.245e-28
# list:run  4 4.980e-28 1.245e-28
# 
# Error: Within
#                       Df    Sum Sq   Mean Sq F value  Pr(>F)   
# cond_code             1 1.000e-28 9.960e-29   1.834 0.17589   
# cond_code:list        1 2.200e-28 2.241e-28   4.126 0.04241 * 
# cond_code:run         4 4.000e-28 9.960e-29   1.834 0.11985   
# cond_code:list:run    4 9.000e-28 2.241e-28   4.126 0.00251 **
#       Residuals          1380 7.495e-26 5.431e-29                   
# ---
#       Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

oldaovBF <- aov(BF_TP ~ cond_code * list * run + Error(run/list), olddata)
# Error: run
# Df Sum Sq Mean Sq
# run  4   1998   499.5
# 
# Error: run:list
# Df Sum Sq Mean Sq
# list      1   5.64    5.64
# list:run  4 214.12   53.53
# 
# Error: Within
#                       Df  Sum Sq Mean Sq F value Pr(>F)    
# cond_code             1  109642  109642  84.821 <2e-16 ***
# cond_code:list        1     345     345   0.267  0.606    
# cond_code:run         4     942     236   0.182  0.948    
# cond_code:list:run    4    5802    1451   1.122  0.344    
# Residuals          1380 1783812    1293                   
# ---
#       Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1


################################################################################
# GETTING A TABLE OF ZIPFVALUE MEANS - LIST x RUN
################################################################################

group_data <- group_by(data, list, run)
meanstbl <- summarize(group_data, Zipfmean = mean(Zipfvalue))
print(meanstbl, n = 35)

ggplot(meanstbl, aes(run, Zipfmean)) + geom_point() + facet_grid(~ list)

group_cond <- group_by(data, run, cond)
condmeanstbl <-summarize(group_cond, Zipfmean = mean(Zipfvalue))
ggplot(condmeanstbl, aes(run, Zipfmean)) + geom_point() + facet_grid(~ cond)



################################################################################
# SAME ANOVAs, AFTER REORDERING SOME RUNS
################################################################################

reordered <- read.csv("../2017-02-29_reordered-runs-for-stats.csv", header = TRUE,
                      stringsAsFactors = FALSE)

aovZipf <- aov(Zipfvalue ~ cond * list * run + Error(run / list), reordered) # diffs


group_data <- group_by(reordered, list, run)
meanstbl <- summarize(group_data, Zipfmean = mean(Zipfvalue))
print(meanstbl, n = 35)

ggplot(meanstbl, aes(run, Zipfmean)) + geom_point() + facet_grid(~ list)

group_cond <- group_by(reordered, run, cond)
condmeanstbl <-summarize(group_cond, Zipfmean = mean(Zipfvalue))
ggplot(condmeanstbl, aes(run, Zipfmean)) + geom_point() + facet_grid(~ cond)




aovlen <- aov(LEN_L ~ cond * list * run + Error(run / list), reordered) # only cond diffs
# Error: run
# Df Sum Sq Mean Sq
# run  4  1.647  0.4118
# 
# Error: run:list
# Df Sum Sq Mean Sq
# list      6  2.617  0.4362
# list:run 24 11.183  0.4660
# 
# Error: Within
# Df Sum Sq Mean Sq  F value Pr(>F)    
# cond             3   5021  1673.5 1280.921 <2e-16 ***
#       cond:list       18     26     1.5    1.126  0.320    
# cond:run        12     12     1.0    0.765  0.687    
# cond:list:run   72     47     0.6    0.497  1.000    
# Residuals     1260   1646     1.3  

aovBF <- aov(BF_TP ~ cond * list * run + Error(run / list), reordered) # only condition diffs
# Error: run
# Df Sum Sq Mean Sq
# run  4  717.1   179.3
# 
# Error: run:list
# Df Sum Sq Mean Sq
# list      1  15.24   15.24
# list:run  4 287.61   71.90
# 
# Error: Within
# Df  Sum Sq Mean Sq F value Pr(>F)    
# cond             3  562871  187624 200.021 <2e-16 ***
#       cond:list        3    2733     911   0.971  0.405    
# cond:run        12    6164     514   0.548  0.884    
# cond:list:run   12    3825     319   0.340  0.982    
# Residuals     1360 1275707     938                   
# ---
#       Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1