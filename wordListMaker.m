%% 
% Make 18 lists of 10 words each
% Lists should be matched on 2 dimensions
% Frequency and Syllable count

clear

% Add SOS to path
addpath(genpath("/Users/farhan/Desktop/Baycrest Documents/Aphasia_Study/" + ...
    "Aphasia_STM_stim_generation/stim_creation"));

% Set a random seed
setSeed(107);

% for samp = 1:size(p.sampcomb,2)
% Create a population from the sos_input wordlist file
inputTextPath = "sos_input.txt";
lemmaPopulation = population('sos_input.txt','name','lemmaPopulation', ...
    'isHeader',true,'isFormatting',true);

% Create 18 samples of 10 words each
wordList0 = sample(18, 'name', 'wordList0', 'outFile', 'wordList0.txt');
wordList1 = sample(18, 'name', 'wordList1', 'outFile', 'wordList1.txt');
wordList2 = sample(18, 'name', 'wordList2', 'outFile', 'wordList2.txt');
wordList3 = sample(18, 'name', 'wordList3', 'outFile', 'wordList3.txt');
wordList4 = sample(18, 'name', 'wordList4', 'outFile', 'wordList4.txt');
wordList5 = sample(18, 'name', 'wordList5', 'outFile', 'wordList5.txt');
wordList6 = sample(18, 'name', 'wordList6', 'outFile', 'wordList6.txt');
wordList7 = sample(18, 'name', 'wordList7', 'outFile', 'wordList7.txt');
wordList8 = sample(18, 'name', 'wordList8', 'outFile', 'wordList8.txt');
wordList9 = sample(18, 'name', 'wordList9', 'outFile', 'wordList9.txt');

% Link samples to population from which samples would be drawn
wordList0.setPop(lemmaPopulation);
wordList1.setPop(lemmaPopulation);
wordList2.setPop(lemmaPopulation);
wordList3.setPop(lemmaPopulation);
wordList4.setPop(lemmaPopulation);
wordList5.setPop(lemmaPopulation);
wordList6.setPop(lemmaPopulation);
wordList7.setPop(lemmaPopulation);
wordList8.setPop(lemmaPopulation);
wordList9.setPop(lemmaPopulation);

% Create a new SOS optimazation
mySOS = sos();

% Add the 10 samples to the optimization
mySOS = mySOS.addSample(wordList0);
mySOS = mySOS.addSample(wordList1);
mySOS = mySOS.addSample(wordList2);
mySOS = mySOS.addSample(wordList3);
mySOS = mySOS.addSample(wordList4);
mySOS = mySOS.addSample(wordList5);
mySOS = mySOS.addSample(wordList6);
mySOS = mySOS.addSample(wordList7);
mySOS = mySOS.addSample(wordList8);
mySOS = mySOS.addSample(wordList9);

% Create the constrains
% The lists should be matched on Zipfvalue

sampcomb = combnk(1:10,2);

% Combine all samples into a list
samples = [wordList0, wordList1, wordList2, wordList3, wordList4, wordList5,... 
    wordList6, wordList7, wordList8, wordList9];

% , wordList10, wordList11,... 
%     wordList12, wordList13, wordList14, wordList15, wordList16, wordList17,...
%     wordList18];

% Function to establish the constrain
% Match two samples based on the selected varName
constraintMinFunc = @(nameConc, firstSamp, secondSamp, varName)...
    mySOS.addConstraint('sosObj', mySOS, 'name', nameConc,...
    'constraintType', 'soft', 'fnc', 'min', 'stat', 'mean',...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', varName, 'S2ColName', varName,...
    'exponent', 2, 'paired', true, 'weight', 1);


% Match the 18 lists for Zipfvalue and syllables
for samp = 1:size(sampcomb, 2)
    fprintf('========= For Samples %1.f and %1.f =========\n', sampcomb(1,samp), sampcomb(2,samp));
    disp(sampcomb(1,samp))
    disp(sampcomb(2,samp))

    s1 = samples(sampcomb(1,samp)); % randomly obtain a list from the 18
    s2 = samples(sampcomb(2,samp)); % Randomly obtain another list from the 18
           
    % Generate a name for this constrain
    matchConstraintName = [num2str(sampcomb(1,samp)), 'vs', num2str(sampcomb(2,samp))];
    
    % Match the two lists on 'cmu_sylls'
    constraintMinFunc(['syllableConstraint' matchConstraintName], s1, s2, 'syllables');

    % Match the two lists on 'Zipfvalue'
    constraintMinFunc(['frequencyConstraint' matchConstraintName], s1, s2, 'Zipfvalue');
end

% Fill the 18 lists with randomly selected words from the population
mySOS.initFillSamples();

% Normalize the values with dimensions of interest
mySOS.normalizeData();