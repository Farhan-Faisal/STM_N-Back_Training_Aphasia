% Example name:One-way3SamplesGroupwiseStochastic
% Description: this script creates 3 samples of 100 words each from the MRC database file ('MRC.txt')
% The 3 samples will be different on 1 dimension (high, medium, and low 'KFfrequency'), p-value < .05, and matched on 3 dimension ('letters', 'syllables', and 'phonemes'), p-values > 0.5
% The optimization uses the stochastic method of annealing

% Sets the random seed
setSeed(123);

% Creates a new population from the MRC database file
myPopulation = population('MRC.txt','name','myPopulation','isHeader',true,'isFormatting',true);

% Creates a new sample of 100 words that can be saved as 'mySample1.txt'
mySample1 = sample(100,'name','mySample1','outFile','mySample1.txt');

% Links the sample to the population from which its items will be drawn
mySample1.setPop(myPopulation);

% Creates a second new sample of 100 words that can be saved as 'mySample2.txt'
mySample2 = sample(100,'name','mySample2','outFile','mySample2.txt');

% Links the sample to the population from which its items will be drawn
mySample2.setPop(myPopulation);

% Creates a third new sample of 100 words that can be saved as 'mySample3.txt'
mySample3 = sample(100,'name','mySample3','outFile','mySample3.txt');

% Links the sample to the population from which its items will be drawn
mySample3.setPop(myPopulation);

% Creates a new SOS optimization
mySOS = sos();

% Adds the two samples to the optimization
mySOS = mySOS.addSample(mySample1);
mySOS = mySOS.addSample(mySample2);
mySOS = mySOS.addSample(mySample3);

% Adds a new constraint: maximize the difference between sample 1 and 2 on average 'KFfrequency', and make the mean of sample 1 < the mean of sample 2
myConstraint = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint','constraintType','soft','fnc','orderedMax','stat','mean','sample1',mySample1,'sample2',mySample2,'s1ColName', 'KFfrequency','s2ColName','KFfrequency','exponent',2,'paired',false,'weight',1);

% Adds a new constraint: maximize the difference between sample 2 and 3 on average 'KFfrequency', and make the mean of sample 2 < the mean of sample 3
myConstraint2 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint2','constraintType','soft','fnc','orderedMax','stat','mean','sample1',mySample2,'sample2',mySample3,'s1ColName', 'KFfrequency','s2ColName','KFfrequency','exponent',2,'paired',false,'weight',1);

% Adds a new constraint: make myConstraint's and myConstraint2's contributions to cost equivalent to ensure that levels (high, medium, and low) are equidistant from each other
myConstraint3 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint3','constraintType','meta','fnc','matchCost','constraint1',myConstraint,'constraint2',myConstraint2);

% Adds a new constraint: match sample 1 and sample 2 on average 'letters'
myConstraint4 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint4','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample2,'s1ColName','letters','s2ColName','letters','exponent',2,'paired',false,'weight',1);

% Adds a new constraint: match sample 2 and sample 3 on average 'letters'
myConstraint5 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint5','constraintType','soft','fnc','min','stat','mean','sample1',mySample2,'sample2',mySample3,'s1ColName','letters','s2ColName','letters','exponent',2,'paired',false,'weight',1);

% Adds a new constraint: match sample 1 and sample 3 on average 'letters'
myConstraint6 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint6','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample3,'s1ColName','letters','s2ColName','letters','exponent',2,'paired',false,'weight',1);

% Adds a new constraint: match sample 1 and sample 2 on average 'syllables'
myConstraint7 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint7','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample2,'s1ColName','syllables','s2ColName','syllables','exponent',2,'paired',false,'weight',1);

% Adds a new constraint: match sample 2 and sample 3 on average 'syllables'
myConstraint8 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint8','constraintType','soft','fnc','min','stat','mean','sample1',mySample2,'sample2',mySample3,'s1ColName','syllables','s2ColName','syllables','exponent',2,'paired',false,'weight',1);

% Adds a new constraint: match sample 1 and sample 3 on average 'syllables'
myConstraint9 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint9','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample3,'s1ColName','syllables','s2ColName','syllables','exponent',2,'paired',false,'weight',1);

% Adds a new constraint: match sample 1 and sample 2 on average 'phonemes'
myConstraint10 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint10','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample2,'s1ColName','phonemes','s2ColName','phonemes','exponent',2,'paired',false,'weight',1);

% Adds a new constraint: match sample 2 and sample 3 on average 'phonemes'
myConstraint11 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint11','constraintType','soft','fnc','min','stat','mean','sample1',mySample2,'sample2',mySample3,'s1ColName','phonemes','s2ColName','phonemes','exponent',2,'paired',false,'weight',1);

% Adds a new constraint: match sample 1 and sample 3 on average 'phonemes'
myConstraint12 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint12','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample3,'s1ColName','phonemes','s2ColName','phonemes','exponent',2,'paired',false,'weight',1);

% Fills the samples with items selected randomly from the population
mySOS.initFillSamples();

% Normalizes the values of dimensions of interest 
mySOS.normalizeData();

% Creates an independent samples t-test; test "passes" if average 'KFfrequency' differs between sample 1 and sample 2, p < .05 
mySOS.addttest('name','myTTest','type','independent', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'KFfrequency', 's2ColName', 'KFfrequency', 'desiredpvalCondition', '<=', 'desiredpval', 0.05);

% Creates an independent samples t-test; test "passes" if average 'KFfrequency' differs between sample 2 and sample 3, p < .05 
mySOS.addttest('name','myTTest2','type','independent', 'sample1', mySample2, 'sample2', mySample3, 's1ColName', 'KFfrequency', 's2ColName', 'KFfrequency', 'desiredpvalCondition', '<=', 'desiredpval', 0.05);

% Creates an independent samples t-test: test "passes" if average 'letters' is  matched between sample 1 and sample 2, p > 0.5
mySOS.addttest('name','myTTest3','type', 'independent', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'letters', 's2ColName', 'letters', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Creates an independent samples t-test: test "passes" if average 'letters' is  matched between sample 2 and sample 3, p > 0.5
mySOS.addttest('name','myTTest4','type', 'independent', 'sample1', mySample2, 'sample2', mySample3, 's1ColName', 'letters', 's2ColName', 'letters', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Creates an independent samples t-test: test "passes" if average 'letters' is  matched between sample 1 and sample 3, p > 0.5
mySOS.addttest('name','myTTest5','type', 'independent', 'sample1', mySample1, 'sample2', mySample3, 's1ColName', 'letters', 's2ColName', 'letters', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Creates an independent samples t-test: test "passes" if average 'syllables' is  matched between sample 1 and sample 2, p > 0.5
mySOS.addttest('name','myTTest6','type', 'independent', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'syllables', 's2ColName', 'syllables', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Creates an independent samples t-test: test "passes" if average 'syllables' is  matched between sample 2 and sample 3, p > 0.5
mySOS.addttest('name','myTTest7','type', 'independent', 'sample1', mySample2, 'sample2', mySample3, 's1ColName', 'syllables', 's2ColName', 'syllables', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Creates an independent samples t-test: test "passes" if average 'syllables' is  matched between sample 1 and sample 3, p > 0.5
mySOS.addttest('name','myTTest8','type', 'independent', 'sample1', mySample1, 'sample2', mySample3, 's1ColName', 'syllables', 's2ColName', 'syllables', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Creates an independent samples t-test: test "passes" if average 'phonemes' is  matched between sample 1 and sample 2, p > 0.5
mySOS.addttest('name','myTTest9','type', 'independent', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'phonemes', 's2ColName', 'phonemes', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Creates an independent samples t-test: test "passes" if average 'phonemes' is  matched between sample 2 and sample 3, p > 0.5
mySOS.addttest('name','myTTest10','type', 'independent', 'sample1', mySample2, 'sample2', mySample3, 's1ColName', 'phonemes', 's2ColName', 'phonemes', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Creates an independent samples t-test: test "passes" if average 'phonemes' is  matched between sample 1 and sample 3, p > 0.5
mySOS.addttest('name','myTTest11','type', 'independent', 'sample1', mySample1, 'sample2', mySample3, 's1ColName', 'phonemes', 's2ColName', 'phonemes', 'desiredpvalCondition', '=>', 'desiredpval', 0.5);

% Specifies the type of optimization (default: 'greedy')
mySOS.setAnnealSchedule('schedule','exp');

% Starts the SOS GUI
sos_gui();
