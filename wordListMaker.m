%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author name: Farhan Bin Faisal		   
% Date written: November 10, 2022			   

% Example scripts used from SOS manual: 
% One-way3SamplesGroupwiseStochastic.m and
% EntropySampleMatchingGreedy.m 

% Description: 
% 1) The goal is to create 18 samples (lists) of 10 words matched on
%        Zipfvalue (frequency), and syllables (number of syllables)
% 2) The optimization currently uses the greedy method of annealing to demonstrate SOS functionality
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

% Add SOS to path
addpath(genpath("/Users/farhan/Desktop/Baycrest Documents/Aphasia_Study/" + ...
    "Aphasia_STM_stim_generation/stim_creation"));

%%%%%%%%%%%%%%%%%%%%%%%%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
randomSeedValue = 107;
nIterations = 10000;
nSamples = 18;
nItems = 10;
outputDirectory = ['/Users/farhan/Desktop/Baycrest Documents/Aphasia_Study/' ...
    'Aphasia_STM_stim_generation/Syllable_Project/wordLists/'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set a random seed
setSeed(107);

% Create a population from the sos_input wordlist file
lemmaPopulation = population('sos_input.txt','name','lemmaPopulation', ...
    'isHeader',true,'isFormatting',true);

% Create 18 samples of 10 words each
% Link each sample to population
samples(1:nSamples, 1)  = sample(nItems, 'name', 'x', 'outFile', 'y');
for i = 1:nSamples
    tempSampleName = ['wordList', num2str(i)];
    tempOutputName = ['wordList', num2str(i), '.txt'];

    samples(i) = sample(nItems, 'name', tempSampleName, 'outFile', ...
        [outputDirectory, tempOutputName]);
    samples(i).setPop(lemmaPopulation);
end


% Create a new SOS optimazation
GreedySOS = sos('maxIt', nIterations);

% Add the 18 samples to the optimization
for i = 1:nSamples
    GreedySOS = GreedySOS.addSample(samples(i));
end

% Function to establish the constrain
constraintMinFunc = @(nameConc, firstSamp, secondSamp, varName) GreedySOS.addConstraint('sosObj', GreedySOS, 'name', nameConc,...
    'constraintType', 'soft', 'fnc', 'min', 'stat', 'mean',...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', varName, 'S2ColName', varName,...
    'exponent', 2, 'paired', true, 'weight', 1);


constraintFreqFloorFunc = @(nameConc, sample) GreedySOS.addConstraint('sosObj', ...
    GreedySOS, 'name', nameConc, 'constraintType', 'hard', 'fnc', 'floor', ...
    'sample1', sample, 's1ColName', 'Zipfvalue', 'value', 4.0);

constraintSyllFloorFunc = @(nameConc, sample) GreedySOS.addConstraint('sosObj', ...
    GreedySOS, 'name', nameConc, 'constraintType', 'hard', 'fnc', 'floor', ...
    'sample1', sample, 's1ColName', 'syllables', 'value', 1.0);


% Establish the freq and zipvalue range xonstrains for the 18 lists
for samp = 1:nSamples
    freqConstraintName = ['freqConstraint',  num2str(samp)];
    syllConstraintName = ['syllConstraint',  num2str(samp)];

    constraintFreqFloorFunc(freqConstraintName, samples(samp));
    constraintSyllFloorFunc(syllConstraintName, samples(samp));
end


% This variable will enable creating contraints to match all possible
% combination of 2 samples among the 18 samples
sampcomb = combnk(1:nSamples,2)';

% Match the 18 lists for Zipfvalue and syllables
s1= [];
s2= [];
for samp = 1:size(sampcomb,2)
    fprintf('========= For Samples %1.f and %1.f =========\n', sampcomb(1,samp), sampcomb(2,samp));
    s1 = samples(sampcomb(1,samp));
    s2 = samples(sampcomb(2,samp));
    
    matchConstraintName = [num2str(sampcomb(1,samp)), 'vs', num2str(sampcomb(2,samp))];

    % Match the two lists on 'cmu_sylls'
    constraintMinFunc(['cmu_syllsConstraint' matchConstraintName], s1, s2, 'syllables');

    % Match the two lists on 'Zipfvalue'
    constraintMinFunc(['ZipfvalueConstraint' matchConstraintName], s1, s2, 'Zipfvalue');
end

% Create TTest to see whether the lists are matched on freq and cmusyll
myTTest = @(testName, s1, s2, varName) GreedySOS.addttest('name', testName, 'type', ...
    'independent', 'sample1', s1, 'sample2', s2, 's1ColName', varName, ...
    's2ColName', varName, 'desiredpvalCondition', '=>', 'desiredpVal', 0.05);

% Fill the 18 lists with randomly selected words from the population
GreedySOS.initFillSamples();

% Normalize the values with dimensions of interest
GreedySOS.normalizeData();

% Add the TTests
for samp = 1:size(sampcomb,2)
    fprintf('========= TTest for Samples %1.f and %1.f =========\n', sampcomb(1,samp), sampcomb(2,samp));
    s1 = samples(sampcomb(1,samp));
    s2 = samples(sampcomb(2,samp));
    
    freqTestName = [num2str(sampcomb(1,samp)), 'vs', num2str(sampcomb(2,samp)), '_ZipfValue'];
    syllTestName = [num2str(sampcomb(1,samp)), 'vs', num2str(sampcomb(2,samp)), '_syllable'];

    myTTest(freqTestName, s1, s2, 'syllables')
    myTTest(syllTestName, s1, s2, 'Zipfvalue')
end

% Anneal and optimize the SOS
GreedySOS.setAnnealSchedule('schedule', 'greedy');
GreedySOS.optimize();

% Write the samples
GreedySOS.writeSamples();