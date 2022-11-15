% Example name: One-way3SamplesPairwiseStochastic
% Description: this script creates 3 samples of 100 words each from the MRC database file ('MRC.txt')
% The 3 samples will be different on 1 dimension (high, medium, and low 'KFfrequency'), p-value < .05, and matched pairwise on 3 dimension ('letters', 'syllables', and 'phonemes'), p-values > 0.5
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
mySOS = sos('statTestReportStyle','full');

% Adds the two samples to the optimization
mySOS = mySOS.addSample(mySample1);
mySOS = mySOS.addSample(mySample2);
mySOS = mySOS.addSample(mySample3);

% Adds a new constraint: maximize the difference between sample 1 and 2 on average 'KFfrequency', and make the mean of sample 1 < the mean of sample 2
myConstraint = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint','constraintType','soft','fnc','orderedMax','stat','mean','sample1',mySample1,'sample2',mySample2,'s1ColName', 'KFfrequency','s2ColName','KFfrequency','exponent',2,'paired',true,'weight',1);

% Adds a new constraint: maximize the difference between sample 2 and 3 on average 'KFfrequency', and make the mean of sample 2 < the mean of sample 3
myConstraint2 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint2','constraintType','soft','fnc','orderedMax','stat','mean','sample1',mySample2,'sample2',mySample3,'s1ColName', 'KFfrequency','s2ColName','KFfrequency','exponent',2,'paired',true,'weight',1);

% Adds a new constraint: make myConstraint's and myConstraint2's contributions to cost equivalent to ensure that levels (high, medium, and low) are equidistant from each other
myConstraint3 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint3','constraintType','meta','fnc','matchCost','constraint1',myConstraint,'constraint2',myConstraint2);

% Adds a new constraint: match sample 1 and sample 2 on 'letters'
myConstraint4 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint4','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample2,'s1ColName','letters','s2ColName','letters','exponent',2,'paired',true,'weight',1);

% Adds a new meta-constraint that prevents frequency differences between sample 1 and sample 2 from being maximized before sample 1 and sample 2 are matched on letters
metaConstraint1 = mySOS.addConstraint('name', 'metaConstraint1', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint4, 'constraint2', myConstraint, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new meta-constraint that prevents frequency differences between sample 2 and sample 3 from being maximized before sample 1 and sample 2 are matched on letters
metaConstraint2 = mySOS.addConstraint('name', 'metaConstraint2', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint4, 'constraint2', myConstraint2, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new constraint: match sample 2 and sample 3 on 'letters'
myConstraint5 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint5','constraintType','soft','fnc','min','stat','mean','sample1',mySample2,'sample2',mySample3,'s1ColName','letters','s2ColName','letters','exponent',2,'paired',true,'weight',1);

% Adds a new meta-constraint that prevents frequency differences between sample 1 and sample 2 from being maximized before sample 2 and sample 3 are matched on letters
metaConstraint3 = mySOS.addConstraint('name', 'metaConstraint3', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint5, 'constraint2', myConstraint, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new meta-constraint that prevents frequency differences between sample 2 and sample 3 from being maximized before sample 2 and sample 3 are matched on letters
metaConstraint4 = mySOS.addConstraint('name', 'metaConstraint4', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint5, 'constraint2', myConstraint2, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new constraint: match sample 1 and sample 3 on 'letters'
myConstraint6 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint6','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample3,'s1ColName','letters','s2ColName','letters','exponent',2,'paired',true,'weight',1);

% Adds a new meta-constraint that prevents frequency differences between sample 1 and sample 2 from being maximized before sample 1 and sample 3 are matched on letters
metaConstraint5 = mySOS.addConstraint('name', 'metaConstraint5', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint6, 'constraint2', myConstraint, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new meta-constraint that prevents frequency differences between sample 2 and sample 3 from being maximized before sample 1 and sample 3 are matched on letters
metaConstraint6 = mySOS.addConstraint('name', 'metaConstraint6', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint6, 'constraint2', myConstraint2, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new constraint: match sample 1 and sample 2 on 'syllables'
myConstraint7 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint7','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample2,'s1ColName','syllables','s2ColName','syllables','exponent',2,'paired',true,'weight',1);

% Adds a new meta-constraint that prevents frequency differences between sample 1 and sample 2 from being maximized before sample 1 and sample 2 are matched on syllables
metaConstraint7 = mySOS.addConstraint('name', 'metaConstraint7', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint7, 'constraint2', myConstraint, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new meta-constraint that prevents frequency differences between sample 2 and sample 3 from being maximized before sample 1 and sample 2 are matched on syllables
metaConstraint8 = mySOS.addConstraint('name', 'metaConstraint8', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint7, 'constraint2', myConstraint2, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new constraint: match sample 2 and sample 3 on average 'syllables'
myConstraint8 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint8','constraintType','soft','fnc','min','stat','mean','sample1',mySample2,'sample2',mySample3,'s1ColName','syllables','s2ColName','syllables','exponent',2,'paired',true,'weight',1);

% Adds a new meta-constraint that prevents frequency differences between sample 1 and sample 2 from being maximized before sample 2 and sample 3 are matched on syllables
metaConstraint9 = mySOS.addConstraint('name', 'metaConstraint9', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint8, 'constraint2', myConstraint, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new meta-constraint that prevents frequency differences between sample 2 and sample 3 from being maximized before sample 2 and sample 3 are matched on syllables
metaConstraint10 = mySOS.addConstraint('name', 'metaConstraint10', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint8, 'constraint2', myConstraint2, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new constraint: match sample 1 and sample 3 on average 'syllables'
myConstraint9 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint9','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample3,'s1ColName','syllables','s2ColName','syllables','exponent',2,'paired',true,'weight',1);

% Adds a new meta-constraint that prevents frequency differences between sample 1 and sample 2 from being maximized before sample 1 and sample 3 are matched on syllables
metaConstraint11 = mySOS.addConstraint('name', 'metaConstraint11', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint9, 'constraint2', myConstraint, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new meta-constraint that prevents frequency differences between sample 2 and sample 3 from being maximized before sample 1 and sample 3 are matched on syllables
metaConstraint12 = mySOS.addConstraint('name', 'metaConstraint12', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint9, 'constraint2', myConstraint2, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new constraint: match sample 1 and sample 2 on average 'phonemes'
myConstraint10 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint10','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample2,'s1ColName','phonemes','s2ColName','phonemes','exponent',2,'paired',true,'weight',1);

% Adds a new meta-constraint that prevents frequency differences between sample 1 and sample 2 from being maximized before sample 1 and sample 2 are matched on phonemes
metaConstraint13 = mySOS.addConstraint('name', 'metaConstraint13', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint10, 'constraint2', myConstraint, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new meta-constraint that prevents frequency differences between sample 2 and sample 3 from being maximized before sample 1 and sample 2 are matched on phonemes
metaConstraint14 = mySOS.addConstraint('name', 'metaConstraint14', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint10, 'constraint2', myConstraint2, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new constraint: match sample 2 and sample 3 on average 'phonemes'
myConstraint11 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint11','constraintType','soft','fnc','min','stat','mean','sample1',mySample2,'sample2',mySample3,'s1ColName','phonemes','s2ColName','phonemes','exponent',2,'paired',true,'weight',1);

% Adds a new meta-constraint that prevents frequency differences between sample 1 and sample 2 from being maximized before sample 2 and sample 3 are matched on phonemes
metaConstraint15 = mySOS.addConstraint('name', 'metaConstraint15', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint11, 'constraint2', myConstraint, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new meta-constraint that prevents frequency differences between sample 2 and sample 3 from being maximized before sample 2 and sample 3 are matched on phonemes
metaConstraint16 = mySOS.addConstraint('name', 'metaConstraint16', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint11, 'constraint2', myConstraint2, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new constraint: match sample 1 and sample 3 on average 'phonemes'
myConstraint12 = mySOS.addConstraint('sosObj',mySOS,'name','myConstraint12','constraintType','soft','fnc','min','stat','mean','sample1',mySample1,'sample2',mySample3,'s1ColName','phonemes','s2ColName','phonemes','exponent',2,'paired',true,'weight',1);

% Adds a new meta-constraint that prevents frequency differences between sample 1 and sample 2 from being maximized before sample 1 and sample 3 are matched on phonemes
metaConstraint17 = mySOS.addConstraint('name', 'metaConstraint17', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint12, 'constraint2', myConstraint, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Adds a new meta-constraint that prevents frequency differences between sample 2 and sample 3 from being maximized before sample 1 and sample 3 are matched on phonemes
metaConstraint18 = mySOS.addConstraint('name', 'metaConstraint18', 'constraintType', 'meta', 'fnc', 'matchCostNotMin', 'constraint1', myConstraint12, 'constraint2', myConstraint2, 'constraint2costScale', 1.0, 'weight', 1, 'exponent', 2.0);

% Fills the samples with items selected randomly from the population
mySOS.initFillSamples();

% Normalizes the values of dimensions of interest 
mySOS.normalizeData();

% Creates a paired samples t-test; test "passes" if average 'KFfrequency' differs between sample 1 and sample 2, p < .05
mySOS.addttest('name','myTTest','type','paired', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'KFfrequency', 's2ColName', 'KFfrequency', 'desiredpvalCondition', '<=', 'desiredpval', 0.05);

% Creates a paired samples t-test; test "passes" if average 'KFfrequency' differs between sample 2 and sample 3, p < .05
mySOS.addttest('name','myTTest2','type','paired', 'sample1', mySample2, 'sample2', mySample3, 's1ColName', 'KFfrequency', 's2ColName', 'KFfrequency', 'desiredpvalCondition', '<=', 'desiredpval', 0.05);

% Creates a paired samples t-test: test "passes" if average 'letters' is  matched between sample 1 and sample 2, p > 0.5; the test also passes if the means of the two samples are within 0.1 of each other 
mySOS.addttest('name','myTTest3','type', 'paired', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'letters', 's2ColName', 'letters', 'desiredpvalCondition', '=>', 'desiredpval', 0.5, 'thresh', 0.1);

% Creates a paired samples t-test: test "passes" if average 'letters' is  matched between sample 2 and sample 3, p > 0.5; the test also passes if the means of the two samples are within 0.1 of each other 
mySOS.addttest('name','myTTest4','type', 'paired', 'sample1', mySample2, 'sample2', mySample3, 's1ColName', 'letters', 's2ColName', 'letters', 'desiredpvalCondition', '=>', 'desiredpval', 0.5, 'thresh', 0.1);

% Creates a paired samples t-test: test "passes" if average 'letters' is  matched between sample 1 and sample 3, p > 0.5; the test also passes if the means of the two samples are within 0.1 of each other 
mySOS.addttest('name','myTTest5','type', 'paired', 'sample1', mySample1, 'sample2', mySample3, 's1ColName', 'letters', 's2ColName', 'letters', 'desiredpvalCondition', '=>', 'desiredpval', 0.5, 'thresh', 0.1);

% Creates a paired samples t-test: test "passes" if average 'syllables' is  matched between sample 1 and sample 2, p > 0.5; the test also passes if the means of the two samples are within 0.1 of each other 
mySOS.addttest('name','myTTest6','type', 'paired', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'syllables', 's2ColName', 'syllables', 'desiredpvalCondition', '=>', 'desiredpval', 0.5, 'thresh', 0.1);

% Creates a paired samples t-test: test "passes" if average 'syllables' is  matched between sample 2 and sample 3, p > 0.5; the test also passes if the means of the two samples are within 0.1 of each other 
mySOS.addttest('name','myTTest7','type', 'paired', 'sample1', mySample2, 'sample2', mySample3, 's1ColName', 'syllables', 's2ColName', 'syllables', 'desiredpvalCondition', '=>', 'desiredpval', 0.5, 'thresh', 0.1);

% Creates a paired samples t-test: test "passes" if average 'syllables' is  matched between sample 1 and sample 3, p > 0.5; the test also passes if the means of the two samples are within 0.1 of each other 
mySOS.addttest('name','myTTest8','type', 'paired', 'sample1', mySample1, 'sample2', mySample3, 's1ColName', 'syllables', 's2ColName', 'syllables', 'desiredpvalCondition', '=>', 'desiredpval', 0.5, 'thresh', 0.1);

% Creates a paired samples t-test: test "passes" if average 'phonemes' is  matched between sample 1 and sample 2, p > 0.5; the test also passes if the means of the two samples are within 0.1 of each other 
mySOS.addttest('name','myTTest9','type', 'paired', 'sample1', mySample1, 'sample2', mySample2, 's1ColName', 'phonemes', 's2ColName', 'phonemes', 'desiredpvalCondition', '=>', 'desiredpval', 0.5, 'thresh', 0.1);

% Creates a paired samples t-test: test "passes" if average 'phonemes' is  matched between sample 2 and sample 3, p > 0.5; the test also passes if the means of the two samples are within 0.1 of each other 
mySOS.addttest('name','myTTest10','type', 'paired', 'sample1', mySample2, 'sample2', mySample3, 's1ColName', 'phonemes', 's2ColName', 'phonemes', 'desiredpvalCondition', '=>', 'desiredpval', 0.5, 'thresh', 0.1);

% Creates a paired samples t-test: test "passes" if average 'phonemes' is  matched between sample 1 and sample 3, p > 0.5; the test also passes if the means of the two samples are within 0.1 of each other 
mySOS.addttest('name','myTTest11','type', 'paired', 'sample1', mySample1, 'sample2', mySample3, 's1ColName', 'phonemes', 's2ColName', 'phonemes', 'desiredpvalCondition', '=>', 'desiredpval', 0.5, 'thresh', 0.1);

% Specifies the type of optimization (default: 'greedy')
  mySOS.setAnnealSchedule('schedule','exp');

% Starts the SOS GUI
sos_gui();