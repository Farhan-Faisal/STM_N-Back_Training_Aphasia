%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Author name: Priyanka Shah-Basak			   
% Date written: January 6, 2017				   
% Latest update by Priyanka Shah-Basak on January 25, 2017  

% Example scripts used from SOS manual: 
% One-way3SamplesGroupwiseStochastic.m and
% EntropySampleMatchingGreedy.m 

% Description: 
% 1) The example scripts are modified for the purposes of creating matched word lists for a word repetition (reading) task
% 2) The goal is to create 7 samples (lists) of 200 words matched on
% Zipfvalue (frequency), Dom_PoS_SUBTLEX (noun/verb), cmu_sylls (number of syllables), BP_TK and LEN_L
% 3) The optimization currently uses the greedy method of annealing to demonstrate SOS functionality
% 4) The functionality for stochastic optimization can be enabled.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
worddir = '/rri_disks/artemis/meltzer_lab/NIBS_treatment/meg/behavioural_data/wordrep_paradigm/stim_creation/2019-07-19_stim_selection/SOS output/';
% Sets the random seed
setSeed(107);

%Create a new population %'Master_wordlist_sostext.txt'
includeverbs = 'no'; % or options: 'yes' or 'no'

    wordrep_Population = population('2019-07-18_visual_wordrep_masterlist1.txt', ...
        'name', 'wordrep_Population', 'isHeader',true, 'isFormatting', true);

% Specify parameters for the samples nsamples
p.nsample = 1:7; 
p.sampcomb = combnk(p.nsample,2)';
p.sampnval = 200;
p.optmethod = 'EXP';
p.niter = 1000000;

% Creates new samples of 200 words 
Sample1 = sample(p.sampnval,'name','Sample1','outFile',['wordrepSample1' p.optmethod '.txt']);
Sample2 = sample(p.sampnval,'name','Sample2','outFile',['wordrepSample2' p.optmethod '.txt']);
Sample3 = sample(p.sampnval,'name','Sample3','outFile',['wordrepSample3' p.optmethod '.txt']);
Sample4 = sample(p.sampnval,'name','Sample4','outFile',['wordrepSample4' p.optmethod '.txt']);
Sample5 = sample(p.sampnval,'name','Sample5','outFile',['wordrepSample5' p.optmethod '.txt']);
Sample6 = sample(p.sampnval,'name','Sample6','outFile',['wordrepSample6' p.optmethod '.txt']);
Sample7 = sample(p.sampnval,'name','Sample7','outFile',['wordrepSample7' p.optmethod '.txt']);

% Link the samples to the population from which items will be drawn
Sample1.setPop(wordrep_Population);
Sample2.setPop(wordrep_Population);
Sample3.setPop(wordrep_Population);
Sample4.setPop(wordrep_Population);
Sample5.setPop(wordrep_Population);
Sample6.setPop(wordrep_Population);
Sample7.setPop(wordrep_Population);

% Creates a new SOS optimization
GreedySOS = sos('maxIt', p.niter); %'maxIt', 1000000
%'reportInterval',100,...
%     'stopFreezeIt',100,'statInterval', 500,...
%     'blockSize', 100, 'statTestReportStyle','full');

% Add the samples to the optimization
GreedySOS.addSample(Sample1);
GreedySOS.addSample(Sample2);
GreedySOS.addSample(Sample3);
GreedySOS.addSample(Sample4);
GreedySOS.addSample(Sample5);
GreedySOS.addSample(Sample6);
GreedySOS.addSample(Sample7);
% Combine all samples 
p.samples = [Sample1, Sample2, Sample3, Sample4, Sample5, Sample6, Sample7];

%% Setup the parameters and functions 
% Maximize the difference between samples based on 'Zipfvalue' - optional
p.constraintMaxFunc = @(nameConc, firstSamp, secondSamp) GreedySOS.addConstraint('sosObj', GreedySOS, 'name',nameConc, ...
    'constraintType', 'soft',...
    'fnc', 'orderedMax', 'stat', 'mean',...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', 'Zipfvalue', 's2ColName', 'Zipfvalue',...
    'exponent', 2, 'paired', true, 'weight', 1);

% Meta constraint - conditional=matchCostNotMin 
p.constraintMetaFunc = @(nameCurrentConc, nameConc1, nameConc2) GreedySOS.addConstraint('sosObj',GreedySOS,...
    'name',nameCurrentConc,...
    'constraintType','meta',...
    'fnc','matchCost','constraint1',nameConc1,'constraint2',nameConc2, ...
    'weight', 100);

% To match on: cmu_sylls, Zipfvalue
p.constraintEntMaxMatchFunc = @(nameConc, firstSamp, varName, n) GreedySOS.addConstraint('sosObj', GreedySOS,...
    'name', nameConc, 'constraintType', 'soft',...
    'fnc', 'maxEnt',...
    'sample1', firstSamp,...
    's1ColName', varName,...
    'pdSpread', 'allItems',...
    'nbin', n, ...
    'weight', 100);

% To match on: numDom_PoS_SUBTLEX, BF_TP, LEN_L
p.constraintMatchFunc = @(nameConc, firstSamp, secondSamp, varName) GreedySOS.addConstraint('sosObj', GreedySOS,...
    'name', nameConc, 'constraintType', 'soft',...
    'fnc', 'min', 'stat', 'mean',...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', varName, 's2ColName', varName,...
    'exponent', 2, 'paired', true, 'weight', 1);


%% Run

for samp = 1:length(p.nsample)
   fprintf('========= For Samples %1.f =========\n', samp);
    % Syllables - entropy match 50/50
%     constraintName = ['cmu_sylls', num2str(samp), 'EntropyConstraint'];
%     Constraint1 = p.constraintEntMaxMatchFunc(constraintName,p.samples(samp), 'cmu_sylls',4);
    
    % Maximize the difference within a sample based on 'Zipfvalue' using entropy
    constraintName = ['Zipfvalue_ncat1', num2str(samp), 'EntropyConstraint']; %Zipfvalue_ncat
    Constraint2 = p.constraintEntMaxMatchFunc(constraintName,p.samples(samp), 'cond_code',7); %Zipfvalue_ncat1
        
    %Meta function to ensure the lists are matched by cmu_sylls before
    %maximizing the difference in Zipfvalue/frequency   
%     p.constraintMetaFunc([constraintName,'Meta'],...
%          Constraint1, Constraint2);
%      
%     % Entropy constraint to match Dom_PoS_SUBTLEX 
%     if strcmp(includeverbs, 'yes') 
%         constraintName = ['Dom_PoS_SUBTLEX', num2str(samp), 'EntropyConstraint'];
%         Constraint3 = p.constraintEntMaxMatchFunc(constraintName,p.samples(samp), 'numDom_PoS_SUBTLEX');     
%     end
end  

% Match by mean for all other variables
s1= [];
s2= [];
for samp = 1:size(p.sampcomb,2)
    fprintf('========= For Samples %1.f and %1.f =========\n', p.sampcomb(1,samp), p.sampcomb(2,samp));
    s1 = p.samples(p.sampcomb(1,samp));
    s2 = p.samples(p.sampcomb(2,samp));
            
    matchConstraintName = [num2str(p.sampcomb(1,samp)), 'vs', num2str(p.sampcomb(2,samp))];
    % Match the two lists on 'BF_TP'
    p.constraintMatchFunc(['BF_TPConstraint', matchConstraintName], s1, s2, 'BF_TP'); 
    % Match the two lists on 'LEN_L'
    p.constraintMatchFunc(['LEN_LConstraint', matchConstraintName], s1, s2, 'LEN_L'); 

end

% Fill the samples with items selected randomly from the population
GreedySOS.initFillSamples();

% Normalize the values of dimensions of interest 
GreedySOS.normalizeData();

%% Setup for statistical tests
ttesttype = 'paired'; %'paired'
% Independent t-tests
p.ttestMatchFunc = @(nameTest, firstSamp, secondSamp, varName) GreedySOS.addttest('name',nameTest,...
    'type', ttesttype,...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', varName, 's2ColName', varName,...
    'desiredpvalCondition', '=>', 'desiredpval', 0.3);

% For uniform distribution within a sample - optional
p.kstestMatchFunc = @(nameTest, firstSamp, varName) GreedySOS.addkstest('name',nameTest,...
    'type', 'matchUniform',...
    'sample1', firstSamp, ...
    's1ColName', varName, ...,
    'pdSpread', 'allItems',...
    'desiredpvalCondition', '<=', 'desiredpval', 0.05);

% currently not used
p.ttestDiffFunc = @(nameTest, firstSamp, secondSamp) GreedySOS.addttest('name',nameTest,...
    'type',ttesttype,...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', 'Zipfvalue', 's2ColName', 'Zipfvalue',...
    'desiredpvalCondition', '<=', 'desiredpval', 0.05);

%% Run TTests

% %Optional
% for samp = 1:length(p.samples)
%     p.kstestMatchFunc(['cmu_syllsEntropy' num2str(samp)], p.samples(samp), 'cmu_sylls');
% end

for samp = 1:size(p.sampcomb,2)
    fprintf('========= For Samples %1.f and %1.f =========\n', p.sampcomb(1,samp), p.sampcomb(2,samp));
    s1 = p.samples(p.sampcomb(1,samp));
    s2 = p.samples(p.sampcomb(2,samp));

    %Independent samples t-test to determine whether the lists are matched between sample pairs on 
    %Zipfvalue, numDom_PoS_SUBTLEX, BF_TP, LEN_L, p-value > 0.5
    matchTestName = [num2str(p.sampcomb(1,samp)), 'vs', num2str(p.sampcomb(2,samp))];
    p.ttestMatchFunc(['Zipfvalue' matchTestName], s1, s2, 'Zipfvalue');
%    p.ttestMatchFunc(['Dom_PoS_SUBTLEX' matchTestName], s1, s2, 'numDom_PoS_SUBTLEX');
    p.ttestMatchFunc(['cmu_sylls' matchTestName], s1, s2, 'cmu_sylls');
    p.ttestMatchFunc(['BF_TP' matchTestName], s1, s2, 'BF_TP');
    p.ttestMatchFunc(['LEN_L' matchTestName], s1, s2, 'LEN_L');

end

%% SOS optimization
switch p.optmethod
    case 'GREEDY'
% Specifies the type of optimization (default: 'greedy')
    GreedySOS.setAnnealSchedule('schedule','greedy');
    GreedySOS.optimize();
    GreedySOS.writeSamples();
    GreedySOS.deltaCostPercentiles
    %expAnneal.maxpDecrease(GreedySOS.deltaCost, 0.00119333,10)
    
    case 'EXP'
   
    StochasticSOS = GreedySOS;
    StochasticSOS.setAnnealSchedule('schedule', 'exp', 'pDecrease', 0.321347);
    StochasticSOS.optimize()
    StochasticSOS.writeSamples();
    
    otherwise
        warning('Select appropriate optimization method.')
end
        
%sos_gui();

