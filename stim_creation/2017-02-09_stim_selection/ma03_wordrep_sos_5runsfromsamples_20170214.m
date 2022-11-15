%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Author name: Priyanka Shah-Basak			   
% Date written: January 6, 2017				   
% Latest update by Priyanka Shah-Basak on January 26, 2017  

% Example scripts used from SOS manual: 
% One-way3SamplesGroupwiseStochastic.m and
% EntropySampleMatchingGreedy.m 

% Description: 
% 1) The example scripts are modified for the purposes of creating matched word lists for a word repetition (reading) task
% 2) The goal is to create 5 samples (lists) of 200 words matched on
% Zipfvalue (frequency), Dom_PoS_SUBTLEX (noun/verb), cmu_sylls (number of syllables), BP_TK and LEN_L
% 3) The optimization currently uses the greedy method of annealing to demonstrate SOS functionality
% 4) The functionality for stochastic optimization can be enabled.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

%% Jittered ISI (for fixation)
%A(randperm(length(A)))
% nreq     = 1400;
% isirange = 3200:50:3500;
% isi      = repmat(isirange,1,round(nreq/length(isirange)));
% jittered = isi(randperm(length(isi)));
% size(jittered)
% trimjitt = jittered(1:nreq);
% size(trimjitt)
% open('trimjitt')
% dlmwrite('jitteredISI1400,txt',trimjitt,'\t')%% 

%% SOS with population containing jittered_ISI column
addpath(genpath('/rri_disks/artemis/meltzer_lab/NIBS_treatment/wordrep_paradigm/stim_creation/SOS'));
for nmastlist = 1:7
setSeed(nmastlist);
p.samplein  = int2str(nmastlist);
%Create a new population 
%includeverbs = 'no'; % or options: 'yes' or 'no'

wordrep_Population = population(['2017-02-27_visual_wordrep_masterlist' p.samplein '.txt'], 'name', 'wordrep_Population', 'isHeader',true, 'isFormatting', true);
% Specify parameters for the samples nsamples
p.nsample   = 1:5; 
p.sampcomb  = combnk(p.nsample,2)';
p.nsampcnt  = 40;
p.optmethod = 'GREEDY'; %'EXP'
p.niter     = 100000;
p.pmatch    = 0.2; 
% Creates new samples of 40 words 
Sample1 = sample(p.nsampcnt,'name','Sample1','outFile',['wordrep_masterlist' p.samplein '_' p.optmethod '_run1.txt']);
Sample2 = sample(p.nsampcnt,'name','Sample2','outFile',['wordrep_masterlist' p.samplein '_' p.optmethod '_run2.txt']);
Sample3 = sample(p.nsampcnt,'name','Sample3','outFile',['wordrep_masterlist' p.samplein '_' p.optmethod '_run3.txt']);
Sample4 = sample(p.nsampcnt,'name','Sample4','outFile',['wordrep_masterlist' p.samplein '_' p.optmethod '_run4.txt']);
Sample5 = sample(p.nsampcnt,'name','Sample5','outFile',['wordrep_masterlist' p.samplein '_' p.optmethod '_run5.txt']);


% Link the samples to the population from which items will be drawn
Sample1.setPop(wordrep_Population);
Sample2.setPop(wordrep_Population);
Sample3.setPop(wordrep_Population);
Sample4.setPop(wordrep_Population);
Sample5.setPop(wordrep_Population);


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

% Combine all samples 
p.samples = [Sample1, Sample2, Sample3, Sample4, Sample5];

%% Setup the parameters and functions 
% Maximize the difference between samples based on 'Zipfvalue' - optional
maxWeight = 1;
p.constraintMaxFunc = @(nameConc, firstSamp, secondSamp) GreedySOS.addConstraint('sosObj', GreedySOS, 'name',nameConc, ...
    'constraintType', 'soft',...
    'fnc', 'orderedMax', 'stat', 'mean',...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', 'Zipfvalue', 's2ColName', 'Zipfvalue',...
    'exponent', 2, 'paired', true, 'weight', maxWeight);

% Meta constraint - conditional=matchCostNotMin 
metaWeight = 1; 
p.constraintMetaFunc = @(nameCurrentConc, nameConc1, nameConc2) GreedySOS.addConstraint('sosObj',GreedySOS,'name',nameCurrentConc,...
    'constraintType','meta',...
    'fnc','matchCostNotMin','constraint1',nameConc1,'constraint2',nameConc2, ...
    'weight', metaWeight);

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
p.constraintMinFunc = @(nameConc, firstSamp, secondSamp, varName) GreedySOS.addConstraint('sosObj', GreedySOS,...
    'name', nameConc, 'constraintType', 'soft',...
    'fnc', 'min', 'stat', 'mean',...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', varName, 'S2ColName', varName,...
    'exponent', 2, 'paired', true, 'weight', 1);


%% Run
for samp = 1:length(p.nsample)
   fprintf('========= For Samples %1.f =========\n', samp); 
   constraintName = ['cond_code', num2str(samp), 'EntropyConstraint']; %Zipfvalue_ncat
   p.constraintEntMaxMatchFunc(constraintName,p.samples(samp), 'cond_code',5); %Zipfvalue_ncat1
end
% Match by mean 
s1= [];
s2= [];
for samp = 1:size(p.sampcomb,2)
    fprintf('========= For Samples %1.f and %1.f =========\n', p.sampcomb(1,samp), p.sampcomb(2,samp));
    s1 = p.samples(p.sampcomb(1,samp));
    s2 = p.samples(p.sampcomb(2,samp));
            
    matchConstraintName = [num2str(p.sampcomb(1,samp)), 'vs', num2str(p.sampcomb(2,samp))];
    % Match the two lists on 'cmu_sylls'
    %p.constraintMinFunc(['cmu_syllsConstraint' matchConstraintName], s1, s2, 'cmu_sylls');
    % Match the two lists on 'Zipfvalue'
    %p.constraintMinFunc(['ZipfvalueConstraint' matchConstraintName], s1, s2, 'cond_code'); %
    % Match the two lists on 'BF_TP'
    p.constraintMinFunc(['BF_TPConstraint' matchConstraintName], s1, s2, 'BF_TP'); %match sample 1 and sample 2
    % Match the two lists on 'LEN_L'
    p.constraintMinFunc(['LEN_LConstraint' matchConstraintName], s1, s2, 'LEN_L'); %match sample 1 and sample 2

end

% Fill the samples with items selected randomly from the population
GreedySOS.initFillSamples();

% Normalize the values of dimensions of interest 
GreedySOS.normalizeData();

%% Setup for statistical tests

% Independent/paired t-tests
ttesttype = 'independent'; %'paired' or 'independent'
p.ttestMatchFunc = @(nameTest, firstSamp, secondSamp, varName, pval) GreedySOS.addttest('name',nameTest,...
    'type', ttesttype,...
    'sample1', firstSamp, 'sample2', secondSamp,...
    's1ColName', varName, 's2ColName', varName,...
    'desiredpvalCondition', '=>', 'desiredpval', pval);

% For uniform distribution within a sample - optional
p.kstestMatchFunc = @(nameTest, firstSamp, varName) GreedySOS.addkstest('name',nameTest,'type', 'matchUniform',...
    'sample1', firstSamp, ...
    's1ColName', varName, ...,
    'pdSpread', 'allItems',...
    'desiredpvalCondition', '<=', 'desiredpval', 0.05);

% currently not used
p.ttestDiffFunc = @(nameTest, firstSamp, secondSamp) GreedySOS.addttest('name',nameTest,'type','independent',...
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

    %t-test to determine whether the lists are matched between sample pairs on 
    %Zipfvalue, numDom_PoS_SUBTLEX, BF_TP, LEN_L, p-value > 0.5
    matchTestName = [num2str(p.sampcomb(1,samp)), 'vs', num2str(p.sampcomb(2,samp))];
    p.ttestMatchFunc(['Zipfvalue' matchTestName], s1, s2, 'cond_code', 1); %Zipfvalue
    %p.ttestMatchFunc(['cmu_sylls' matchTestName], s1, s2, 'cmu_sylls', 1);
    p.ttestMatchFunc(['BF_TP' matchTestName], s1, s2, 'BF_TP', p.pmatch);
    p.ttestMatchFunc(['LEN_L' matchTestName], s1, s2, 'LEN_L', p.pmatch);

end

%% SOS optimization
switch p.optmethod
    case 'GREEDY'
% Specifies the type of optimization (default: 'greedy')
    GreedySOS.setAnnealSchedule('schedule','greedy');
    GreedySOS.optimize();
    GreedySOS.writeSamples();
    GreedySOS.deltaCostPercentiles
    %expAnneal.maxpDecrease(GreedySOS.deltaCost, 0.00276063,10)
    
    case 'EXP'
   
    StochasticSOS = GreedySOS;
    StochasticSOS.setAnnealSchedule('schedule', 'exp', 'pDecrease', 0.144743);
    StochasticSOS.optimize()
    StochasticSOS.writeSamples();
    
    otherwise
        warning('Select appropriate optimization method.')
end
        
%sos_gui();

end



