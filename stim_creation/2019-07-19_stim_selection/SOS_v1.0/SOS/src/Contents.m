% - automatically generated list of SOS m-files
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

% SRC
%
% Files
%   calculateOverlap_Dialog                         - M-file for calculateOverlap_Dialog.fig
%   create2samplettest_Dialog                       - M-file for create2samplettest_Dialog.fig
%   createHardBoundConstraint_Dialog                - M-file for createHardBoundConstraint_Dialog.fig
%   createPlots_Dialog                              - M-file for createPlots_Dialog.fig
%   createPop_Dialog                                - M-file for createPop_Dialog.fig
%   createSample_Dialog                             - M-file for createSample_Dialog.fig
%   createSingleSampleSoftDistanceConstraint_Dialog - M-file for createSingleSampleSoftDistanceConstraint_Dialog.fig
%   createsinglesamplettest_Dialog                  - M-file for createsinglesamplettest_Dialog.fig
%   createSoftEntropyConstraint_Dialog              - M-file for createSoftEntropyConstraint_Dialog.fig
%   createSoftMetaConstraint_Dialog                 - M-file for createSoftMetaConstraint_Dialog.fig
%   createSOS_dialog                                - M-file for createSOS_dialog.fig
%   createTwoSampleSoftDistanceConstraint_Dialog    - M-file for createTwoSampleSoftDistanceConstraint_Dialog.fig
%   dataFrame                                       - Creates a dataframe object.  Parent of population and sample.
%   expAnneal                                       - Provides support for exponentially decaying temperature annealing
%   expAnneal_Dialog                                - M-file for expAnneal_Dialog.fig
%   genericAnneal                                   - Abstract interface for all annealing objects
%   genericConstraint                               - Class defines general functionality of constraint objects
%   genericFeederCandidateSelection                 - abstract interface defining required methods for selecting feeder items
%   genericPopulationCandidateSelection             - abstract class; for possible future versions.
%   genericpSwapFunction                            - Abstract interface defining required methods for swap objects
%   genericSampleCandidateSelection                 - abstract interface defining required methods for sampleCandidateSelection methods
%   getdfName                                       - returns the string label of the dataframe (techically and more generally now, the
%   getPopupMenuName                                - retrieves the string representation of the selection in a popup menu
%   greedyAnneal                                    - greedy annealing
%   hardBoundConstraint                             - creates and supports hardBoundConstraints
%   hardConstraint                                  - Abstract interface defining properties and functions common to all hardConstraints
%   initVerbosePrint                                - initializes the verbose printing parameters
%   logisticpSwapFunction                           - Creates and provides support for selecting swap probabilities based on the logistic function
%   maxpDecrease_Dialog                             - M-file for maxpDecrease_Dialog.fig
%   NaNArray                                        - 
%   nullArray                                       - 
%   numSteps_Dialog                                 - M-file for numSteps_Dialog.fig
%   openDoors                                       - tries to open the pod bay doors
%   plt                                             - plt.m:   An alternative to plot and plotyy (version 11May10) by Paul Mennen
%   population                                      - creates and manipulates population objects
%   randPopulationAndSampleCandidateSelection       - selects a neighbor item from a sample's population or other children samples of that pop.
%   randPopulationCandidateSelection                - Randomly selects an item from the targetSample's population to swap into the sample.
%   randSampleCandidateSelection                    - randomly select an item from one of the samples as a candidate for a swap.
%   sample                                          - creates and supports sample objects
%   saveHistory_Dialog                              - M-file for saveHistory_Dialog.fig
%   seconds2human                                   - outputs time in human readable format.  Slightly modified version of Rody P.S. Oldenhuis's version
%   setBufferedHistoryOutfile_Dialog                - M-file for setBufferedHistoryOutfile_Dialog.fig
%   setSeed                                         - Sets the seed for the random number generator.  
%   setSeed_Dialog                                  - M-file for setSeed_Dialog.fig
%   setVerbosePrintVerbosity                        - sets the verbosity for a particular field to manipulate whether and how it is output
%   setVerbosity                                    - depreciated in latest version.  
%   softConstraint                                  - Abstract interface defining properties and functions common to all softConstraints
%   softDistanceConstraint                          - creates and supports soft distance constraints
%   softEntropyConstraint                           - creates and supports soft entropy constraints
%   softMetaConstraint                              - creates and supports soft meta constraints.
%   sos                                             - Creates and supports optimization objects
%   sos_gui                                         - M-file for sos_gui.fig
%   sosHistory                                      - records and provides writing support for detailed optimization history data
%   sosPlots                                        - plots detailed history data
%   sosttest                                        - runs user-specified t-tests and tests user hypotheses on their outcomes
%   validatePositiveInteger                         - validates that the string represents a positive integern
%   validateProbability                             - validates that the string represents a propability
%   validateRealNumber                              - validates that the string represents a real number
%   validFileName                                   - Checks whether <fileName> is a string reference to an existing file.
%   validFileNameOrNull                             - Checks whether <fileName> is a string reference to an existing file.
%   validLogical                                    - checks whether l is a variable of type 'logical'
%   validString                                     - checks whether str is a string object
%   validStringOrNull                               - checks whether str is a string object or is null
%   verbosePrint                                    - the main output driver for SOS information.  
