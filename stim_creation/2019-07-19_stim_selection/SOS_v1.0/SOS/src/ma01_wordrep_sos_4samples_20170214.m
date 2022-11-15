%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Tiffany Deschamps and Priyanka Shah-Basak
% Date written: January 16, 2017
% Latest update by Tiffany Deschamps on January 17, 2017.
% Latest update by Priyanka Shah-Basak on February 14, 2017.

% Example Scripts from SOS manual:
%
% Description:
% This script was written to create a stimulus list for a visual word repetition task.
% The goal is to create four lists with 350 words, satisfying these four conditions:
%     List 1: "lowFreqOneSyll" = low-frequency, one-syllable words
%     List 2: "lowFreqThreeSyll" = low-frequency, three-syllable words
%     List 3: "highFreqOneSyll" = high-frequency, one-syllable words
%     List 4: "highFreqThreeSyll" = high-frequency, three-syllable words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the SOS procedure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
addpath(genpath('/rri_disks/artemis/meltzer_lab/NIBS_treatment/meg/behavioural_data/wordrep_paradigm/stim_creation/2019-07-19_stim_selection/SOS output'));
% Set a random seed
setSeed(29);

% Create population (master word list)
wordrep_Population = population('2019-07-16_visual_wordrep_masterlist1.txt', ...
	'name', 'wordrep_Population', 'isHeader', true, 'isFormatting', true);

% Specify parameters for the samples 
p.nsample   = 1:4; 
p.nsampcnt1 = 350;
p.nsampcnt2 = 350; %(1200 - (p.nsampcnt1*2))/2;
p.sampcomb  = combnk(p.nsample,2)';
p.optmethod = 'GREEDY'; %EXP
p.niter = 100000;
 

% Create samples (conditions)
lowFreq1Syll = sample(p.nsampcnt1, 'name', 'lowFreq1Syll', ...
	'outFile', ['lowfreq_1syll_' p.optmethod '.txt']); % n = 358 from population
lowFreq3Syll = sample(p.nsampcnt2, 'name', 'lowFreq3Syll', ...
	'outFile', ['lowfreq_3syll_' p.optmethod '.txt']); % n = 1707
highFreq1Syll = sample(p.nsampcnt1, 'name', 'highFreq1Syll', ...
	'outFile', ['highfreq_1syll_' p.optmethod '.txt']); % n = 328
highFreq3Syll = sample(p.nsampcnt2, 'name', 'highFreq3Syll', ...
	'outFile', ['highfreq_3syll_' p.optmethod '.txt']); % n = 753

% Link samples to population
lowFreq1Syll.setPop(wordrep_Population);
lowFreq3Syll.setPop(wordrep_Population);
highFreq1Syll.setPop(wordrep_Population);
highFreq3Syll.setPop(wordrep_Population);

% Create new SOS optimization
GreedySOS = sos('maxIt', p.niter);
% optional arguments: ('reportInterval, 100, 'stopFreezeIt', 100, 'statInterval', 500, ...
% 'blockSize', 100, 'statTestReportStyle', 'full');

% Add samples to SOS optimization
GreedySOS.addSample(lowFreq1Syll);
GreedySOS.addSample(lowFreq3Syll);
GreedySOS.addSample(highFreq1Syll);
GreedySOS.addSample(highFreq3Syll);

%% HARD CONSTRAINTS - 
%SYLLABLES
% lowFreq1Syll gets only one-syllable words
HardSyllConstraint1 = GreedySOS.addConstraint('sosObj', GreedySOS, ...
	'name', 'HardSyllConstraint1', 'constraintType', 'hard', 'fnc', 'ceiling', ...
	'sample1', lowFreq1Syll, 's1ColName', 'cmu_sylls', 'value', 1);
% highFreq1Syll gets only one-syllabe words
HardSyllConstraint2 = GreedySOS.addConstraint('sosObj', GreedySOS, ...
	'name', 'HardSyllConstraint2', 'constraintType', 'hard', 'fnc', 'ceiling', ...
	'sample1', highFreq1Syll, 's1ColName', 'cmu_sylls', 'value', 1);
% lowFreq3Syll gets only three-syllable words
HardSyllConstraint3 = GreedySOS.addConstraint('sosObj', GreedySOS, ...
	'name', 'HardSyllConstraint3', 'constraintType', 'hard', 'fnc', 'floor', ...
	'sample1', lowFreq3Syll, 's1ColName', 'cmu_sylls', 'value', 3);
% highFreq3Syll gets only three-syllable words
HardSyllConstraint4 = GreedySOS.addConstraint('sosObj', GreedySOS, ...
	'name', 'HardSyllConstraint4', 'constraintType', 'hard', 'fnc', 'floor', ...
	'sample1', highFreq3Syll, 's1ColName', 'cmu_sylls', 'value', 3);


% FREQUENCY
p.zipfvalcutoff = 3.65;
% lowFreqOneSyll gets only words with Zipfvalue lower than 2.6
HardFreqConstraint1 = GreedySOS.addConstraint('sosObj', GreedySOS, ...
	'name', 'HardFreqConstraint1', 'constraintType', 'hard', 'fnc', 'ceiling', ...
	'sample1', lowFreq1Syll, 's1ColName', 'Zipfvalue', 'value', p.zipfvalcutoff); %2.6 %Zipfvalue_ncat - 1
% lowFreqThreeSyll gets only words with Zipfvalue lower than 2.6
HardFreqConstraint2 = GreedySOS.addConstraint('sosObj', GreedySOS, ...
	'name', 'HardFreqConstraint2', 'constraintType', 'hard', 'fnc', 'ceiling', ...
	'sample1', lowFreq3Syll, 's1ColName', 'Zipfvalue', 'value', p.zipfvalcutoff); %Zipfvalue_ncat - 1
% highFreqOneSyll gets only words with Zipfvalue greater than 2.7
HardFreqConstraint3 = GreedySOS.addConstraint('sosObj', GreedySOS, ...
	'name', 'HardFreqConstraint3', 'constraintType', 'hard', 'fnc', 'floor', ...
	'sample1', highFreq1Syll, 's1ColName', 'Zipfvalue', 'value', p.zipfvalcutoff); %Zipfvalue_ncat - 2
% highFreqThreeSyll gets only words with Zipfvalue greater than 2.7
HardFreqConstraint4 = GreedySOS.addConstraint('sosObj', GreedySOS, ...
	'name', 'HardFreqConstraint4', 'constraintType', 'hard', 'fnc', 'floor', ...
	'sample1', highFreq3Syll, 's1ColName', 'Zipfvalue', 'value', p.zipfvalcutoff); %Zipfvalue_ncat - 2

%% SOFT CONSTRAINTS

%%
% MAXIMIZING FREQUENCY BETWEEN FREQUENCY CONDITIONS
maxWeight = 1;
p.constraintMaxFunc = @(nameConc, firstSamp, secondSamp, varName) GreedySOS.addConstraint('sosObj', GreedySOS, 'name',nameConc, ...
    'constraintType', 'soft',...
    'fnc', 'orderedMax', 'stat', 'mean',...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', varName, 's2ColName', varName,...
    'exponent', 2, 'paired', true, 'weight', maxWeight);

%SoftFreqMaxConstraint1 = p.constraintMaxFunc('SoftFreqMaxConstraint1', lowFreq1Syll, highFreq1Syll, 'Zipfvalue');
%SoftFreqMaxConstraint2 = p.constraintMaxFunc('SoftFreqMaxConstraint2', lowFreq3Syll, highFreq3Syll, 'Zipfvalue');
%SoftFreqMaxConstraint3 = p.constraintMaxFunc('SoftFreqMaxConstraint3', lowFreq1Syll, highFreq3Syll, 'Zipfvalue');
%SoftFreqMaxConstraint4 = p.constraintMaxFunc('SoftFreqMaxConstraint4', lowFreq3Syll, highFreq1Syll, 'Zipfvalue');

%%
% MINIMIZING FREQUENCY WITHIN FREQUENCY CONDITIONS
matchWeight = 100;
p.constraintMinFunc = @(nameConc, firstSamp, secondSamp, varName) GreedySOS.addConstraint('sosObj', GreedySOS,...
    'name', nameConc, 'constraintType', 'soft',...
    'fnc', 'min', 'stat', 'mean',...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', varName, 's2ColName', varName,...
    'exponent', 2, 'paired', false, 'weight', matchWeight);
%change paired to 'true' in all cases - and ttests to paired
% - 'Zipfvalue'
SoftFreqMinConstraint1 = p.constraintMinFunc('SoftFreqMinConstraint1', lowFreq1Syll, lowFreq3Syll, 'Zipfvalue');
SoftFreqMinConstraint2 = p.constraintMinFunc('SoftFreqMinConstraint2', highFreq1Syll, highFreq3Syll, 'Zipfvalue');

% - 'BF_TP' and 'LEN_L'
% SoftFreqMinConstraint3 = p.constraintMinFunc('SoftFreqMinConstraint3', lowFreq1Syll, lowFreq3Syll, 'BF_TP');
% SoftFreqMinConstraint4 = p.constraintMinFunc('SoftFreqMinConstraint4', highFreq1Syll, highFreq3Syll, 'BF_TP');
% SoftFreqMinConstraint5 = p.constraintMinFunc('SoftFreqMinConstraint5', lowFreq1Syll, lowFreq3Syll, 'LEN_L');
% SoftFreqMinConstraint6 = p.constraintMinFunc('SoftFreqMinConstraint6', highFreq1Syll, highFreq3Syll, 'LEN_L');

% p.samples = [lowFreq1Syll, lowFreq3Syll, highFreq1Syll, highFreq3Syll];
% p.BFMinConstraint = [];
% p.LENMinConstraint = [];
% %p.sampcombsel = p.sampcomb(:,[5, 1,6,2]);
% p.sampcombsel = p.sampcomb;
% for samp = 1:size(p.sampcombsel,2)
%     fprintf('========= For Samples %1.f and %1.f =========\n', p.sampcombsel(1,samp), p.sampcombsel(2,samp));
%     s1 = p.samples(p.sampcombsel(1,samp));
%     s2 = p.samples(p.sampcombsel(2,samp));
%     constraintName = ['BFMinConstraint', num2str(samp)];
%     p.BFMinConstraint{samp} = p.constraintMinFunc(constraintName, ...
%        s1, s2, ...
%         'BF_TP');
% end
% 
% for samp = 1:size(p.sampcombsel,2)
%     fprintf('========= For Samples %1.f and %1.f =========\n', p.sampcombsel(1,samp), p.sampcombsel(2,samp));
%     s1 = p.samples(p.sampcombsel(1,samp));
%     s2 = p.samples(p.sampcombsel(2,samp));
%     constraintName = ['LENMinConstraint', num2str(samp)];
%     p.LENMinConstraint{samp} = p.constraintMinFunc(constraintName, ...
%         s1, s2, ...
%         'LEN_L');
% end

%% META Constraints
metaWeight = 1;
p.constraintMetaMatchCostNotMinFunc = @(nameCurrentConc, nameConc1, nameConc2) GreedySOS.addConstraint('sosObj',GreedySOS,...
    'name',nameCurrentConc,...
    'constraintType','meta',...
    'fnc','matchCostNotMin','constraint1',nameConc1,'constraint2',nameConc2, ...
    'weight', metaWeight);
p.constraintMetaMatchCostFunc = @(nameCurrentConc, nameConc1, nameConc2) GreedySOS.addConstraint('sosObj',GreedySOS,...
    'name',nameCurrentConc,...
    'constraintType','meta',...
    'fnc','matchCost','constraint1',nameConc1,'constraint2',nameConc2, ...
    'weight', metaWeight);

% % Specify Meta constraints   
% p.freqmaxconstraints = [SoftFreqMaxConstraint1, SoftFreqMaxConstraint2]; %, SoftFreqMaxConstraint3, SoftFreqMaxConstraint4];
% for nconst = 1:size(p.freqmaxconstraints,2)
%     constraintName = ['Meta1freqConstraint', num2str(nconst)];
%     p.constraintMetaMatchCostNotMinFunc(constraintName, SoftFreqMinConstraint1, p.freqmaxconstraints(nconst));
%     constraintName = ['Meta2freqConstraint', num2str(nconst)];
%     p.constraintMetaMatchCostNotMinFunc(constraintName, SoftFreqMinConstraint2, p.freqmaxconstraints(nconst));      
% end
% 
% %p.BFMinConstraint; p.LENMinConstraint
% for nconst = 1:size(p.BFMinConstraint,2)
%     constraintName = ['MetaBFFreq1Constraint', num2str(nconst)];
%     p.constraintMetaMatchCostNotMinFunc(constraintName, p.BFMinConstraint{nconst}, SoftFreqMaxConstraint1);
%     constraintName = ['MetaBFFreq2Constraint', num2str(nconst)];
%     p.constraintMetaMatchCostNotMinFunc(constraintName, p.BFMinConstraint{nconst}, SoftFreqMaxConstraint2);
%     
%     
%     constraintName = ['MetaLENFreq1Constraint', num2str(nconst)];
%     p.constraintMetaMatchCostNotMinFunc(constraintName, p.LENMinConstraint{nconst}, SoftFreqMaxConstraint1);
%     constraintName = ['MetaLENFreq2Constraint', num2str(nconst)];
%     p.constraintMetaMatchCostNotMinFunc(constraintName, p.LENMinConstraint{nconst}, SoftFreqMaxConstraint2);      
% end

% %p.BFMinConstraint; 
% for nconst = 1:size(p.BFMinConstraint,2)
%     constraintName = ['MetaBFFreq1Constraint', num2str(nconst)];
%     p.constraintMetaMatchCostFunc(constraintName, p.BFMinConstraint{nconst}, SoftFreqMinConstraint1);
%     constraintName = ['MetaBFFreq2Constraint', num2str(nconst)];
%     p.constraintMetaMatchCostFunc(constraintName, p.BFMinConstraint{nconst}, SoftFreqMinConstraint2);
% end    
% %p.LENMinConstraint
% for nconst = 1:size(p.LENMinConstraint,2)
%     constraintName = ['MetaLENFreq1Constraint', num2str(nconst)];
%     p.constraintMetaMatchCostFunc(constraintName, p.LENMinConstraint{nconst}, SoftFreqMinConstraint1);
%     constraintName = ['MetaLENFreq2Constraint', num2str(nconst)];
%     p.constraintMetaMatchCostFunc(constraintName, p.LENMinConstraint{nconst}, SoftFreqMinConstraint2);      
% end
% 


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finish setting up the SOS procedure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% fill samples with items selected randomly from the population
GreedySOS.initFillSamples();

% normalize the values of the dimensions of interest
GreedySOS.normalizeData();


%% test the frequency minimization constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the t-tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ttesttype = 'paired'; %'independent'
p.ttestDiffFunc = @(nameTest, firstSamp, secondSamp, varName, pval) GreedySOS.addttest('name',nameTest,...
    'type',ttesttype,...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', 'Zipfvalue', 's2ColName', 'Zipfvalue',...
    'desiredpvalCondition', '<=', 'desiredpval', pval);

p.ttestMatchFunc = @(nameTest, firstSamp, secondSamp, varName, pval) GreedySOS.addttest('name',nameTest,...
    'type', ttesttype,...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', varName, 's2ColName', varName,...
    'desiredpvalCondition', '=>', 'desiredpval', pval);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run the t-tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test Zipfvalue - lowFreqOneSyll vs. lowFreqThreeSyll - PASS: p > 0.2
p.ttestMatchFunc('Zipfvaluettest1', lowFreq1Syll, lowFreq3Syll, 'Zipfvalue', 0.9);
p.ttestMatchFunc('Zipfvaluettest2', highFreq1Syll, highFreq3Syll, 'Zipfvalue', 0.9);    
% test the frequency maximization constraints
p.ttestDiffFunc('Zipfvaluettest3', lowFreq1Syll, highFreq1Syll, 'Zipfvalue', 0.05) % test Zipfvalue - lowFreqOneSyll vs. highFreqOneSyll - PASS: p < 0.05
p.ttestDiffFunc('Zipfvaluettest4', lowFreq3Syll, highFreq3Syll, 'Zipfvalue', 0.05) % test Zipfvalue - lowFreqThreeSyll vs. highFreqThreeSyll - PASS: p < 0.05

% test the bigram frequency and word length minimization constraints
% p.samples = [lowFreq1Syll, lowFreq3Syll, highFreq1Syll, highFreq3Syll];
% for samp = 1:size(p.sampcomb,2)
%     fprintf('========= For Samples %1.f and %1.f =========\n', p.sampcomb(1,samp), p.sampcomb(2,samp));
%     pp = 0.3; %pvalue cutoff
%     s1 = p.samples(p.sampcomb(1,samp));
%     s2 = p.samples(p.sampcomb(2,samp));
%     matchTestName = [num2str(p.sampcomb(1,samp)), 'vs', num2str(p.sampcomb(2,samp))];
%     p.ttestMatchFunc(['BF_TPttest' matchTestName], s1, s2, 'BF_TP', pp); % test bigram frequency across all conditions
%     p.ttestMatchFunc(['LEN_Lttest' matchTestName], s1, s2, 'LEN_L', pp); % test word length across all conditions
% end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do the optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch p.optmethod
    case 'GREEDY'
% Specifies the type of optimization (default: 'greedy')
    GreedySOS.setAnnealSchedule('schedule','greedy');
    GreedySOS.optimize();
    GreedySOS.writeSamples();
    GreedySOS.deltaCostPercentiles
    
    %expAnneal.maxpDecrease(GreedySOS.deltaCost, 0.00025424,80)
    
    case 'EXP'
   
    StochasticSOS = GreedySOS;
    StochasticSOS.setAnnealSchedule('schedule', 'exp') %, 'pDecrease', 0.255870);
    StochasticSOS.optimize()
    StochasticSOS.writeSamples();
    
    otherwise
        warning('Select appropriate optimization method.')
end

%sos_gui();