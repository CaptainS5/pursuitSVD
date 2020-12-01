% analyze data of the four eye tests (excluding predictive pursuit) from
% the excel sheets; visualize and do individual t-tests to compare
% difference between the patient and control group

% drafted by XiuyunWu, 10/09/2020, xiuyunwu5@gmail.com
% implemented by Vriti Bhagat, date, email
clear all; close all; clc

<<<<<<< Updated upstream
=======
%% indicate here which data to plot--only modify in this section
% Output figures (will be saved as pdfs):
% There will be one figure for each dependent variable (defined in "dependentVariables")
%   in each task (defined in "tasks"); 
% the plot(s) will be bar plot(s) with errorbars and individual data points.
% You will define the independent variables in "independentVariables" to
% decide how to do the plots:
%   If there is only one independent variable, it's a simple bar plot;
%   If there are two independent variables, it will be a grouped bar plot,
%       with the first variable being the main group on the x axis, and the
%       second variable grouped within each first variable and indicated in the
%       legend;
%   If there are more than two independent variables, subplots will be created; 
%       each subplot will be one unique combination of all variables
%       excluding the last two; the last two variables will be plotted as
%       grouped bars in each subplot. For example, if you have "speed", "patient", and
%       "track_directions", you will have two subplots, each showing the
%       data of one speed; within each plot, the x axis will be
%       patient/control (1/0), and track_direction will be grouped within
%       each patient/control value;
%   The last variable could be set to '', just an empty string, in which
%       case each subplot will only have one independent variable; this
%       could be handy if you don't want to have grouped bars, but simple
%       bars for a subset of the data. For example, if you want to plot
%       the gain only for vertical tracking in pursuit, grouped by
%       patient/control, set "independentVariables" to {'track_direction',
%       'patient', ''}, then you will have one subplot for horizontal
%       tracking, one subplot for vertical tracking, each with two bars of
%       patients/controls.
%
% *"track_direction" in "pursuit", 'x' and 'y' are replaced by numbers: 
%   0=x, 1=y

tasks = {'1 minute saccade', 'micro-saccades'}; 
% should be one or more (separate by comma or space) from the five tasks: 
% 'pro-saccades', 'anti-saccades', 'micro-saccades', '1 minute saccades', 'pursuit'


dependentVariables{1} = {'goalReached', 'accuracy', 'noCorrectiveSaccades', 'correctedAccuracy', 'correctivex_amplitude', 'noBlinks'}
dependentVariables{2} = {'MSNo', 'MSCumulativeAmplitude', 'MSMeanAmp', 'SNo', 'SCumulativeAmplitude', 'SMeanAmplitude'}
% For each task you input to "tasks", following the same order, input
%   the dependent variables (names as they appear in the excel sheet) to look at 
%   in the corresponding cell in dependentVariables.
% For example, if you have tasks = {'pro-saccades', 'pursuit'}, you
%   should have two cells in dependentVariables; 
% dependentVariables{1}={'dependent variable 1 for pro-saccades', 'dependent variable 2 for pro-saccades', etc.}
% dependentVariables{2}={'dependent variable 1 for pursuit', 'dependent variable 2 for pursuit', etc.}
 

independentVariables{1} = {'patient'}; 
independentVariables{2} = {'patient'}; 
% currently these are assumed to be categorical variables
% Similarly, input the independent variables you want for each task 
%   in different cells in independentVariables.
% Feel free to add variables into the excel sheet, in which way you can
%   have more independent/dependent variables to plot; just make sure for
%   whatever variables you define above, they exist in the excel data sheet.
% For example, if you have new groupings of people based on their SVD scores, 
%   you can add a column in the corresponding sheet in excel named as 'SVD score group', 
%   then you can just put 'SVD score group' into independentVariables. Note that
%   for the current script, the added independent variables should be categorical, and should be numbers.

% For the original excel sheet:
% For pro-saccades, anti-saccades, and 1 minute saccades, the independent
%   variable could only be 'patient' (0-control, 1-patient);
% For micro-saccades, the independent variables could be 'patient' and/or 'task'
% For pursuit, the independent variables could be 'patient' and/or
%   'track_direction' and/or 'speed'

customYRange = 0; % 0-no, 1-yes
% If set to 1, you need to define the y ranges you want to use for each
%   dependent variable in each task below
yRange{1} = [0; 
             1.5];
% Each cell is one task following the order in "tasks", and within each cell,
%   each column is one dependent variable, the first row is the min y axis
%   value, the second row is the max y axis value

>>>>>>> Stashed changes
%% load data
analysisFolder = pwd;
dataPath = fullfile('..\..\results\organized excel sheets\');
cd(dataPath)

for ii=1:1
data{ii} = readtable('SVD_eyeMovement_results.xlsx');%--modify to read each sheet
end

%% visualize data
for sheetN=1:1
    for ii = 4:size(data{sheetN}, 2)
        for groupN = 1:2
            idx = find(data{sheetN}.patient==groupN-1);
            y(groupN) = nanmean(data{sheetN}{idx, ii});
        end     
        
        figure
        subplot(1, 2, 1)
        bar(y)
        hold on
        % errorbar
    end
end

%% t-test / ANOVA
% ttest
% anova