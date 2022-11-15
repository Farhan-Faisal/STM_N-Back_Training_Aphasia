% - initializes the flags which control the verbosity of output
%
% copyright 2009-2012 Blair Armstrong, Christine Watson, David Plaut
%
%    This file is part of SOS
%
%    SOS is free software: you can redistribute it and/or modify
%    it for academic and non-commercial purposes
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.  For commercial or for-profit
%    uses, please contact the authors (sos@cnbc.cmu.edu).
%
%    SOS is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with SOS (see COPYING.txt).
%    If not, see <http://www.gnu.org/licenses/>.



function  initVerbosePrint()
    %% initializes the verbose printing parameters
    % the idea is that different verbosity flags could allow for different
    % styles of output, though currently flags are always ==1 and this
    % outputs to stdout
    %
    % each parameter indicates a specific print function, so it is possible
    % to suppress or activate individual messages to create a custom level
    % of verbosity.  
    
    global verbosityFlags;
    
    if(isempty(verbosityFlags))
        verbosityFlags = struct( ...
            'setSeed_set',1,...
            'population_constructor_startObjCreation',1, ...
            'population_constructor_fileExists',1,...
            'population_constructor_endObjCreation',1, ...
        ...
            'sample_constructor_startObjCreation',1, ...
            'sample_constructor_fileExists',1,...
            'sample_constructor_endObjCreation', 1, ...
            'sample_setPop_end',1,...
            'sample_lockAll_end',1,...
            'sample_unlockAll_end',1,...
        ...
            'dataFrame_readDataFrameData_reading',1, ...
            'dataFrame_readDataFrameData_HeaderPresent',1, ...
            'dataFrame_readDataFrameData_FormattingPresent',1, ...
            'dataFrame_readDataFrameData_DoneReadingData',1, ...
            'dataFrame_readDataFrameData_HeaderAbsent',1, ...
            'dataFrame_readDataFrameData_FormattingAbsent',1, ...
            'dataFrame_writeData_done',1,...
            'dataFrame_overlap_percent',1,...
        ...
            'sos_constructor_startObjCreation',1, ...
            'sos_constructor_endObjCreation', 1, ...
            'sos_parseConstructor_defaultMaxIt',1, ...
            'sos_parseConstructor_pSwapFunction',1,...
            'sos_parseConstructor_targSampleCandSelectMethod',1,...
            'sos_parseConstructor_feederdfCandSelectMethod',1,...
            'sos_parseConstructor_reportInterval',1,...
            'sos_parseConstructor_stopFreezeIt',1,...
            'sos_parseConstructor_statReports',1,...
            'sos_addSample_NoPopForSampleWarn',1, ...
            'sos_addSample_SampleAlreadyAddedWarn',1, ...
            'sos_addSample_sampleAdded',1, ...
            'sos_initFillSamples_start',1,...
            'sos_normalizeData_start',1, ...
            'sos_normalizeData_noVarWarn',1,...
            'sos_initCost_startInit',1,...
            'sos_initCost_indivHardCost',1,...
            'sos_initCost_totalHardCost',1,...
            'sos_initCost_indivSoftCost',1,...
            'sos_initCost_totalSoftCost',1,...
            'sos_initCost_indivMetaCost',1,...
            'sos_initCost_totalMetaCost',1,...
            'sos_initCost_totalSoftMetaCost',1,... 
            'sos_dispCost_start',1,...
            'sos_dispCost_indivHardCost',1,...
            'sos_dispCost_totalHardCost',1,...
            'sos_dispCost_indivSoftCost',1,...
            'sos_dispCost_totalSoftCost',1,...
            'sos_dispCost_indivMetaCost',1,...
            'sos_dispCost_totalMetaCost',1,...
            'sos_dispCost_totalSoftMetaCost',1,...
            'sos_dispCost_warnCostNaN',1,...
            'sos_optimize_begin',1,...
            'sos_optimize_startOptimization',1,...
            'sos_optimize_resetFreezeIt',1,...
            'sos_optimize_reportHeader',1,...
            'sos_optimize_report',1,...
            'sos_optimize_endMaxIt',1,...
            'sos_optimize_endstopFreezeIt',1,...
            'sos_optimize_endallStatsPass',1,...
            'sos_optimize_endUserGuiInterrupt',1,...
            'sos_setAnnealSchedule_defaultAnneal',1,...
            'sos_writeSamples_begin',1, ...
            'sos_writePopulations_begin',1,...
            'sos_addttest_end',1,...
            'sos_addztest_end',1,...
            'sos_addkstest_end',1,...
            'sos_doStatTests_begin',1,...
            'sos_deltaCostPercentiles_Header',1,...
            'sos_deltaCostPercentiles_Scores',1,...
            'sos_deltaCostPercentiles_deltaCost95',1,...
            'sos_createHistory_alreadyCreated',1,...
            'sos_createPlots_alreadyCreated',1,...
        ...
            'hardBoundConstraint_Constructor_endObjCreation',1, ...
            'hardBoundConstraint_initCost',1, ...
        ...
            'softDistanceConstraint_Constructor_endObjCreation',1,...
        ...
            'softEntropyConstraint_Constructor_endObjCreation',1,...
        ...
            'softMatchCorrelConstraint_Constructor_endObjCreation',1,...
        ...
            'softMetaConstraint_Constructor_endObjCreation',1,...
        ...
            'randSampleCandidateSelection_const',1, ...
        ...
            'randPopulationCandidateSelection_const',1, ...
        ...
            'randPopulationAndSampleCandidateSelection_const',1, ...
        ...
            'greedyAnneal_constructor_startObjCreation',1,...
        ...
            'expAnneal_constructor_startObjCreation',1, ...
            'expAnneal_anneal_calibration',1, ...
            'expAnneal_anneal_dropTemp',1,... 
            'expAnneal_anneal_pthermalEquil',1, ...
            'expAnneal_numSteps_nStep',1,...
            'expAnneal_numSteps_Warn',1,...
            'expAnneal_maxpDecrease_maxpDecrease',1,...
        ...
            'sosttest_ruIndependentSamplettest',1, ... 
            'sosttest_runPairedSamplettest',1, ...
            'sosttest_runSingleSamplettest',1, ...
        ...
             'sosCorrelTest_runMatchCorrelztest',1,...
        ...
             'soskstest_runMatchUniformkstest',1,...
        ...
            'sosHistory_constructor_end',1,...
            'sosHistory_bufferedHistoryWrite_end',1, ...
            'sosHistory_enableBufferedHistoryWrite_end',1,...
            'sosHistory_disableBufferedHistoryWrite_end',1, ...
            'sosHistory_writeHistory_begin',1, ...
        ... 
            'sosPlots_constructor_end',1, ...
        ...    
        ...
        ... % GUI COMMAND OUTPUTS
            'sos_gui_runScript_CallBack_runScript',1, ...
            'sos_gui_cmdWindow_CallBack_runcmd',1, ...
            'sosGui_writeDF',1, ...
            'sosGui_links2p',1, ...
            'sosGui_simpleCmd',1,...
            'sosGui_addSample',1, ...
            'sosGui_setFeederdfCandMethod',1, ...
            'sosGui_initFillSamples',1, ...
            'sosGui_normalizeData',1,...
            'sosGui_setgreedyAnneal',1,...
            'sosGui_greedyAnneal',1,...
            'sosGui_initCost',1,...
            'sosGui_doStats',1,...
            'sosGui_createHistory',1,...
            'sosGui_enableBufferedHistory',1,...
            'sosGui_disableBufferedHistory',1,...
            'sosGui_dispCost',1,...
            'sosGui_deltaCostDeciles',1,...
            'sosGui_writeSamples',1,...
            'sosGui_writePopulations',1,...
            'sosGui_writeAll',1,...
            'sosGui_optimize',1,...
        ...
            'setSeed_Dialog_Set',1, ...
        ... 
            'createPop_Dialog_Create',1, ...
        ...
            'createSample_Dialog_Create',1, ...
        ...
            'calculateOverlapDialog_calculateOverlap',1, ...
        ...
            'createSOSDialog_createSOS', 1, ...
        ...
            'expAnneal_Dialog_createExpAnneal',1, ...
        ...
            'numSteps_Dialog_calculate',1, ...
        ...
            'maxpDecrease_Dialog_calculate',1, ...
        ...
            'createHardBoundConstraint_Dialog_create',1, ...
        ...
            'createSingleSampleSoftDistanceConstraint_Dialog_create',1, ...
        ...
            'createTwoSampleSoftDistanceConstraint_Dialog_create',1, ...
        ... 
            'createSoftMatchCorrelConstraint_Dialog_create',1,...
        ...
            'createSoftEntropyConstraint_Dialog_create',1, ...
        ...
            'createSoftMetaConstraint_Dialog_create',1, ...
        ...
            'createsinglesamplettest_Dialog_create',1, ...
        ...
            'create2samplettest_Dialog_create',1, ...
        ...
            'createMatchCorrelztest_Dialog_create',1,...
        ...
            'createMatchUniformkstest_Dialog_create',1,...
        ...
            'setBufferedHistoryOutfile_Dialog_create',1, ...
        ...
            'saveHistory_Dialog_save',1, ...
        ...
            'createPlots_Dialog_create',1 ...
            );
    end;


end
