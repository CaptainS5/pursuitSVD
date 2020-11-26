% analyze data of the four eye tests (excluding predictive pursuit) from
% the excel sheets; visualize and do individual t-tests to compare
% difference between the patient and control group
% currently just do the plotting

% drafted by XiuyunWu, 10/09/2020; edited 11/24/2020. xiuyunwu5@gmail.com
clear all; close all; clc

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

tasks = {'pursuit'}; 
% should be one or more (separate by comma or space) from the five tasks: 
% 'pro-saccades', 'anti-saccades', 'micro-saccades', '1 minute saccades', 'pursuit'

dependentVariables{1} = {'gain'}; 
% For each task you input to "tasks", following the same order, input
%   the dependent variables (names as they appear in the excel sheet) to look at 
%   in the corresponding cell in dependentVariables.
% For example, if you have tasks = {'pro-saccades', 'pursuit'}, you
%   should have two cells in dependentVariables; 
% dependentVariables{1}={'dependent variable 1 for pro-saccades', 'dependent variable 2 for pro-saccades', etc.}
% dependentVariables{2}={'dependent variable 1 for pursuit', 'dependent variable 2 for pursuit', etc.}

independentVariables{1} = {'speed', 'patient', 'track_direction'}; 
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

%% load data
analysisFolder = pwd;
dataPath = fullfile('..\..\results\organized excel sheets\');
plotSavePath = fullfile('..\..\results\');

sheetNames = sheetnames([dataPath, 'SVD_eyeMovement_results.xlsx']);
for ii=1:length(sheetNames)
    data{ii} = readtable([dataPath, 'SVD_eyeMovement_results.xlsx'], 'sheet', ii);
end
% the i_th cell in data contains the i_th sheet in the excel, corresponding
% to the i_th name in sheetNames

%% visualize data, loop through each dependent variable in each task
for taskN = 1:length(tasks)
    % initialize
    independentAll = {}; % unique values of each independent variable
    levelIndependentAll = []; % number of levels for each independent variable
    dataCons = table; % all columns of independent variables from the data
    % the below one will remain empty if no subplots are needed
    independentGroups = table;
    
    % find the correct cell in data
    cellIdx = find(strcmp(sheetNames, tasks{taskN}));
    dataT = data{cellIdx}; % all data for the current task
    % for pursuit, exclude data with the speed other than 9/22
    if strcmp(tasks{taskN}, 'pursuit')
        idxT = find(dataT.speed~=9 & dataT.speed~=22);
        dataT(idxT, :) = [];
        % also replace direction strings with numbers
        track_directionTemp = dataT.track_direction;
        dataT.track_direction = [];
        idx = find(strcmp(track_directionTemp, 'x'));
        dataT.track_direction(idx, 1) = 0;
        idx = find(strcmp(track_directionTemp, 'y'));
        dataT.track_direction(idx, 1) = 1;
    end
    
    % manage the independent variables, also prepare for plotting
    for ii = 1:length(independentVariables{taskN})
        % get all condition columns from data and put into a different table,
        % to work as a look-up table later
        if ~isempty(independentVariables{taskN}{ii})
            dataCons.(independentVariables{taskN}{ii}) = dataT.(independentVariables{taskN}{ii});
            % get the unique level values for each independent variable
            independentAll{ii} = unique(dataCons.(independentVariables{taskN}{ii}));
            % the level numbers for all independent variables
            levelIndependentAll(ii, 1) = length(independentAll{ii});
        else % just fill in the space
            dataCons.empty(:, 1) = NaN;
            % get the unique level values for each independent variable
            independentAll{ii} = NaN;
            % the level numbers for all independent variables
            levelIndependentAll(ii, 1) = NaN;
        end
    end
    
    % conditions regarding subplots, excluding the last two variables
    if length(independentVariables{taskN})>2 % need to have subplots
        % create a table with all combination of the independent variables
        [outputCell{1:length(independentVariables{taskN})-2}] = ndgrid(independentAll{1:length(independentVariables{taskN})-2});
        
        % sort and reshape all arrays, to put them together into the table
        for ii = 1:length(independentVariables{taskN})-2
            independentGroups.(independentVariables{taskN}{ii})(:, 1) = reshape(outputCell{ii}, [], 1);
        end
        
        % subplot grid number
        subplotN1 = levelIndependentAll(end-2, 1);
        subplotN2 = prod(levelIndependentAll(1:end-2))/subplotN1;
    else % no need for actual subplots, just do one plot
        subplotN1 = 1;
        subplotN2 = 1;
    end
    
    for dependentN = 1:length(dependentVariables{taskN})
        figure % create a new figure for each dependent variable
        % get the unique values for the independent variable(s) in each plot
        if length(independentVariables{taskN})==1 
            var1All = unique(dataT.(independentVariables{taskN}{end}));
            var2All = [];
        elseif isempty(independentVariables{taskN}{end})
            var1All = unique(dataT.(independentVariables{taskN}{end-1}));
            var2All = [];
        else %
            var1All = unique(dataT.(independentVariables{taskN}{end-1}));
            var2All = unique(dataT.(independentVariables{taskN}{end}));
        end
        
        for subplotN = 1:subplotN1*subplotN2 % loop through each subplot
            subplot(subplotN1, subplotN2, subplotN)
            hold on
            % find the corresponding data of the dependent variable under the current condition
            if isempty(independentGroups)% just one plot
                dataPlot = dataT;
            else              
                idx = find(all(dataCons{:, 1:end-2}==independentGroups{subplotN, :}, 2));
                dataPlot = dataT(idx, :);
                % show the condition on title
                titleName = [independentVariables{taskN}{1}, ' ', num2str(independentGroups{subplotN, 1})];
                if size(independentGroups, 2)>1
                    for ii = 2:size(independentGroups, 2)
                        titleName = [titleName, ', ', independentVariables{taskN}{ii+1}, num2str(independentGroups{subplotN, ii})];
                    end
                end
                title(titleName)
            end
            
            % calculate mean and std for each bar
            clear idx
            for var1N = 1:length(var1All)
                if isempty(var2All)
                    if length(independentVariables{taskN})==1
                        idx{1, var1N} = find(dataPlot.(independentVariables{taskN}{end})==var1All(var1N));
                    else
                        idx{1, var1N} = find(dataPlot.(independentVariables{taskN}{end-1})==var1All(var1N));
                    end
                    yMean(1, var1N) = nanmean(dataPlot.(dependentVariables{taskN}{dependentN})(idx{1, var1N}, 1));
                    ySTD(1, var1N) = nanstd(dataPlot.(dependentVariables{taskN}{dependentN})(idx{1, var1N}, 1));
                else
                    for var2N = 1:length(var2All)
                        idx{var2N, var1N} = find(dataPlot.(independentVariables{taskN}{end-1})==var1All(var1N) & ...
                            dataPlot.(independentVariables{taskN}{end})==var2All(var2N));
                        yMean(var2N, var1N) = nanmean(dataPlot.(dependentVariables{taskN}{dependentN})(idx{var2N, var1N}, 1));
                        ySTD(var2N, var1N) = nanstd(dataPlot.(dependentVariables{taskN}{dependentN})(idx{var2N, var1N}, 1));
                    end
                end
            end
            
            % plot grouped bars
%             X = categorical(var1All);
            bP = bar(var1All, yMean, 'EdgeColor', 'none');
            
            ngroups = size(yMean, 1);
            nbars = size(yMean, 2);
            barWidth = min(0.8, nbars/(nbars+1.5))/(2*nbars); % I actually have no idea what this is...
            for ii = 1:ngroups
                bP(ii).FaceAlpha = 0.5;
                xtips = bP(ii).XEndPoints;
                ytips = bP(ii).YEndPoints;
                % errorbar
                errorbar(xtips, ytips, ySTD(ii, :), 'k', 'linestyle', 'none');
                for jj = 1:nbars
                    % individual data points for each bar
                    X = xtips(jj).*ones(size(idx{ii, jj}));
                    scatter(X, dataPlot.(dependentVariables{taskN}{dependentN})(idx{ii, jj}),'jitter','on','jitterAmount', 0.7*barWidth)
                end
            end
            
            if ~isempty(var2All)
                for ii = 1:length(var2All)
                    legendNames{ii} = [independentVariables{taskN}{end}, ' ', num2str(var2All(ii))];
                end
                legend(legendNames, 'location', 'best')
            end
            if length(independentVariables{taskN})==1
                xlabel(independentVariables{taskN}{end})
            else
                xlabel(independentVariables{taskN}{end-1})
            end
            xticks(var1All)
            xticklabels(num2str(var1All))
            ylabel(dependentVariables{taskN}{dependentN})
            if customYRange
                ylim(yRange{taskN}(:, dependentN))
            end
        end
        
        % define the pdf name and save the figure
        independentNames = independentVariables{taskN}{1};
        for ii = 2:length(independentVariables{taskN})
            independentNames = [independentNames, 'BY', independentVariables{taskN}{ii}];
        end
        fileName = [plotSavePath, tasks{taskN}, '_', dependentVariables{taskN}{dependentN}, '_', independentNames, '.pdf'];
        saveas(gcf, fileName)
    end
end

%% t-test / ANOVA
% to be added...