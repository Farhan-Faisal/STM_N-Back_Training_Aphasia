% Example name: MatchToValueGroupwiseStochastic
% Descriptions: this script creates 2 samples (lists) of 100 words each from the MRC database file ('MRC.txt')
% For 1 sample, 'KFfrequency' values must be > 100, and for the other sample, 'KFfrequency' values must be < 10
% The 2 samples are maximally different on 1 dimension ('KFfrequency'), p < .05, and are matched on 3 dimensions ('letters', 'syllables', and 'phonemes'), p-values > 0.5
% This optimization uses the stochastic method of annealing

clear all
addpath(genpath('/rri_disks/artemis/meltzer_lab/NIBS_treatment/wordrep_paradigm/stim_creation/SOS'));

% Sets the random seed
randomSeed(123)

% Creates a population from the MRC database file with the name 'myPopulation'
myPopulation = population('MRC.txt','name','myPopulation','isHeader',true,'isFormatting',true);

% Creates a sample with 100 words that can be saved with the name 'mySample1.txt'
mySample1 = sample(100,'name','mySample1','outFile','mySample1.txt');

% Links mySample1 to the population file from which its items will be drawn
mySample1.setPop(myPopulation);

% Creates a second sample with 100 words that can be saved with the name 'mySample2.txt'
mySample2 = sample(100,'name','mySample2','outFile','mySample2.txt');

% Links mySample2 to the population file from which its items will be drawn
mySample2.setPop(myPopulation);

% Creates an SOS optimization called 'mySOS'
mySOS = sos();

% Adds the two samples to the 'mySOS' instance of optimization
mySOS = mySOS.addSample(mySample1);
mySOS = mySOS.addSample(mySample2);

% Adds one desired constraint with the name 'myConstraint': maximize the difference between the two lists on 'KFfrequency'
mySOS.addConstraint('sosObj', mySOS, 'name','myConstraint', 'constraintType', 'soft', 'fnc', 'max', 'stat', 'mean', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'KFfrequency', 'S2ColName', 'KFfrequency', 'exponent', 2, 'paired', false, 'weight', 1);

% Adds one desired constraint with the name 'myConstraint2': 'KFfrequency' values in mySample1 must be greater than 100
mySOS.addConstraint('sosObj',mySOS,'name','myConstraint2','constraintType','hard','fnc','floor','sample1',mySample1,'s1ColName','KFfrequency','value',100);

% Adds one desired constraint with the name 'myConstraint3': 'KFfrequency' values in mySample2 must be less than 10
mySOS.addConstraint('sosObj',mySOS,'name','myConstraint3','constraintType','hard','fnc','ceiling','sample1',mySample2,'s1Colname','KFfrequency','value',10);

% Adds one desired constraint with the name 'myConstraint4': match the two lists on 'letters'
mySOS.addConstraint('sosObj', mySOS, 'name','myConstraint4','constraintType', 'soft', 'fnc', 'min', 'stat', 'mean', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'letters', 'S2ColName', 'letters', 'exponent', 2, 'paired', false, 'weight', 1);

% Adds one desired constraint with the name 'myConstraint5': match the two lists on 'syllables'
mySOS.addConstraint('sosObj', mySOS, 'name','myConstraint5','constraintType', 'soft', 'fnc', 'min', 'stat', 'mean', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'syllables', 'S2ColName', 'syllables', 'exponent', 2, 'paired', false, 'weight', 1);

% Adds one desired constraint with the name 'myConstraint6': match the two lists on 'phonemes'
mySOS.addConstraint('sosObj', mySOS, 'name','myConstraint6','constraintType', 'soft', 'fnc', 'min', 'stat', 'mean', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'phonemes', 'S2ColName', 'phonemes', 'exponent', 2, 'paired', false, 'weight', 1);

% Fills the two samples with randomly selected items from the population file
mySOS.initFillSamples();

% Standardizes the values of the dimension(s) of interest
mySOS.normalizeData();

% Creates an independent samples t-test to determine whether or not the lists are different on 'KFfrequency', p-value < .05
mySOS.addttest('name','myTTest','type','independent', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'KFfrequency', 's2ColName', 'KFfrequency', 'desiredpvalCondition', '<=', 'desiredpval', 0.05);

% Creates an independent samples t-test to determine whether or not the lists are matched on 'letters', p-value > 0.5
mySOS.addttest('name','myTTest2','type', 'independent', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'letters', 's2ColName', 'letters', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Creates an independent samples t-test to determine whether or not the lists are matched on 'syllables', p-value > 0.5
mySOS.addttest('name','myTTest3','type', 'independent', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'syllables', 's2ColName', 'syllables', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Creates an independent samples t-test to determine whether or not the lists are matched on 'phonemes', p-value > 0.5
mySOS.addttest('name','myTTest4','type', 'independent', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'phonemes', 's2ColName', 'phonemes', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Determines the type of optimization that will be performed; no specification defaults to "greedy"
mySOS.setAnnealSchedule('schedule','exp');

% Starts the SOS GUI
sos_gui();

