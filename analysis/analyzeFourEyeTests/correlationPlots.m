% Analyze data of the four eye tests (excluding predictive pursuit) from
%   the excel sheets; visualize the correlation between eye movement measures
%   and cognitive/clinical scores, with fitted correlation line and stats
% Note that we are simply using Pearson correlation now, could modify if
%   necessary
% you may need to change the directory for the data path in line 69-70

% XiuyunWu, edited 12/11/2020. xiuyunwu5@gmail.com
clear all; close all; clc

%% indicate here which data to plot--only modify in this section
% Output figures (will be saved as emfs):
% There will be one figure for each pair of dependent variable (defined in "dependentVariables")
%   and independent variable (defined in "independentVariables"), in each task (defined in "tasks");
% The plot(s) will be scatter plot(s) with color indicating the patient
%   group defined in "SVD_eyeMovement_results_newPursuitResults.xlsx"; x
%   axis will be the independent variable and y axis will be the dependent variable.
% To make it easier, input eye movement measures as dependent variables,
%   and cognitive/clinical measurements such as MoCA as independent
%   variables. Dependent variables are for each task, but independent
%   variables are the same for all tasks.

tasks = {'pursuit', 'pro-saccades'};
% should be one or more (separate by comma or space) from the five tasks:
% 'pro-saccades', 'anti-saccades', 'micro-saccades', '1 minute saccades', 'pursuit'

pickConsPursuit = {'targetSpeed', 'trackDirection'};
% If you have input 'pursuit' into "tasks", define here which variables you
%   want to separately plot for the data.
% Could be 'targetSpeed' and/or 'trackDirection'; for the variables that
%   you input here, data of each unique value of the variable will be plotted
%   in different subplots; for the variables not input here, the values will be averaged.
% If don't want to input any variables and just want the averaged values of all, please input 'none'

dependentVariables{1} = {'gain'};
dependentVariables{2} = {'latency'};
% For each task you input to "tasks", following the same order, input
%   the dependent variables (names as they appear in the excel sheet) to look at
%   in the corresponding cell in dependentVariables.
% For example, if you have tasks = {'pro-saccades', 'pursuit'}, you
%   should have two cells in dependentVariables;
% dependentVariables{1}={'dependent variable 1 for pro-saccades', 'dependent variable 2 for pro-saccades', etc.}
% dependentVariables{2}={'dependent variable 1 for pursuit', 'dependent variable 2 for pursuit', etc.}

independentVariables = {'MoCA', 'SAGE'};
% These should be continuous variables, and the names should match what it
%   is in the masterdata excel sheet (sheetNamesMaster)
% For convenience these will be ploted for all tasks, you don't need to
% input separately for each task

customAxisRange = 0; % 0-no, 1-yes
% Set the number to indicate if you want the plot to have automatic square
%   axis or custom axis range; could first set to 0 to check what range
%   would be reasonable, and to avoid missing data points in the plot.
% If set to 1, you need to define the x and y ranges you want to use for each
%   indepedent variable, and each dependent variable in each task below
xRange = [60 20 0;
    90 30 25];
% Each column is one independent variable, the first row is the min x axis
%   value, the second row is the max x axis value
yRange{1} = [0;
    1.5];
% Each cell is one task following the order in "tasks", and within each cell,
%   each column is one dependent variable, the first row is the min y axis
%   value, the second row is the max y axis value

%% load data
analysisFolder = pwd;
dataPath = fullfile('..\..\results\organized excel sheets\');
plotSavePath = fullfile('..\..\results\');

% loading eye data
sheetNames = sheetnames([dataPath, 'SVD_eyeMovement_results_newPursuitResults.xlsx']);
for ii=1:length(sheetNames)
    data{ii} = readtable([dataPath, 'SVD_eyeMovement_results_newPursuitResults.xlsx'], 'sheet', ii);
end
% the i_th cell in data contains the i_th sheet in the excel, corresponding
% to the i_th name in sheetNames

% Loading cognitive scoring etc. into one table, mark the control & patient
%   groups and clean up unnecessary rows
% Although we don't need the information of control/patient in dataMaster,
%   just adding it there... the "patient" info is obtained from the eye
%   movement file
dataMaster = table;
sheetNamesMasterData = sheetnames([dataPath, 'SVD_CRFsMasterDataSheet_JF.xlsx']);
for ii=1:length(sheetNamesMasterData)
    dTmp = readtable([dataPath, 'SVD_CRFsMasterDataSheet_JF.xlsx'], 'sheet', ii);
    if strcmp(sheetNamesMasterData(ii), 'controls')
        dTmp.patient(:, 1) = 0;
        dataMaster = [dataMaster; dTmp];
    elseif strcmp(sheetNamesMasterData(ii), 'patients')
        dTmp.patient(:, 1) = 1;
        dataMaster = [dataMaster; dTmp];
    end
end
% clean up the IDs...
dataMaster(find(strcmp(dataMaster.ID, '')), :) = []; % delete the extra rows
idx = find(strlength(dataMaster.ID)>4);
for ii = 1:length(idx)
    dataMaster.ID{idx(ii)} = dataMaster.ID{idx(ii)}(1:4);
end

% prepare color for plotting each group defined in the "patient" column in eye
% data sheets
colorPlot = [15 204 255; 255 182 135; 232 113 240; 137 126 255; 113 204 100]/255;

excludeList = {'E034', 'A082', 'E028', 'O070'};
% participants with weird speed in the pursuit task, and also abnormal latency in saccade tasks

%% visualize data, loop through each pair of dependent&independent variable in each task
for taskN = 1:1%:length(tasks)
    % find the correct cell in data
    cellIdx = find(strcmp(sheetNames, tasks{taskN}));
    dataEye = data{cellIdx}; % all data for the current task
    
    % for all tasks, exclude participants with weird speed in the pursuit
    % task (they would also have abnormal latency in saccade tasks)
    for excludeN = 1:length(excludeList)
        idx = find(strcmp(dataEye.subjectID, excludeList{excludeN}));
        dataEye(idx, :) = [];
    end
    % for pursuit, exclude data with the speed other than 9/22
    if strcmp(tasks{taskN}, 'pursuit')
        %         idxT = find(dataT.speed~=9 & dataT.speed~=22);
        %         dataT(idxT, :) = [];
        
        % for the pursuit task, separately plot the data for each parameter
        %   conditions (targetSpeed and/or trackDirection)
        % prepare the conditions for each subplot
        if ~strcmp(pickConsPursuit{1}, 'none')
            % initialize the parameters needed for identifying different groups
            % of pursuit data to be plotted in each subplot
            paraPursuitValues = {};
            levelParaAll = [];
            paraPursuitGroups = table;
            dataCons = table;
            
            for ii = 1:length(pickConsPursuit)
                % get all parameters in data
                dataCons.(pickConsPursuit{ii}) = dataEye.(pickConsPursuit{ii});
                % get the unique values for each parameter
                paraPursuitValues{ii} = unique(dataEye.(pickConsPursuit{ii}));
                % the level numbers for all parameters
                levelParaAll(ii, 1) = length(paraPursuitValues{ii});
            end
            if ii>1 % more than one parameters
                [outputCell{1:length(paraPursuitValues)}] = ndgrid(paraPursuitValues{:});
                % sort and reshape all arrays, to put them together into the table
                for ii = 1:length(pickConsPursuit)
                    paraPursuitGroups.(pickConsPursuit{ii})(:, 1) = reshape(outputCell{ii}, [], 1);
                end
            else
                paraPursuitGroups.(pickConsPursuit{ii}) = paraPursuitValues{1};
            end
            
            % subplot grid number
            subplotN1 = levelParaAll(end, 1);
            subplotN2 = prod(levelParaAll)/subplotN1;
        else
            subplotN1 = 1;
            subplotN2 = 1;
        end
    elseif strcmp(tasks{taskN}, 'micro-saccades')
        % get rid of the NaN task lines...
        dataEye(isnan(dataEye.task), :) = [];
        % for the saccade tasks including micro-saccades, simply
        % initialize the subplot number to be 1
        subplotN1 = 1;
        subplotN2 = 1;
    else % for rest of the saccade tasks, initialize the subplot number
        subplotN1 = 1;
        subplotN2 = 1;
    end
    
    % get the "patient" group values
    patientGroups = unique(dataEye.patient);
    for ii = 1:length(patientGroups)
        legendNames{ii} = ['patient ', num2str(patientGroups(ii))];
    end
    
    % loop through dependent variables to plot
    for dependentN = 1:length(dependentVariables{taskN})
        for independentN = 1:length(independentVariables)
            figure % create a new figure for each dependent variable
            for subplotN = 1:subplotN1*subplotN2 % loop through each subplot
                subplot(subplotN1, subplotN2, subplotN)
                hold on
                % initialize
                dataXAll = [];
                dataYAll = [];
                
                % scatter plot, one time per "patient" group
                for patientN = 1:length(patientGroups)
                    % initialize
                    dataX = [];
                    dataY = [];
                    
                    % find the corresponding data of the dependent variable under the current condition
                    if strcmp(tasks{taskN}, 'pursuit')
                        if ~strcmp(pickConsPursuit{1}, 'none')
                            idx = find(dataEye.patient==patientGroups(patientN) & ...
                                all(dataCons{:, :}==paraPursuitGroups{subplotN, :}, 2));
                            
                            % show the parameter condition on titlem just
                            % generate titleName once
                            if patientN==1
                                yParaNames = [pickConsPursuit{1}, ' ', num2str(paraPursuitGroups{subplotN, 1})];
                                if length(pickConsPursuit)>1
                                    for ii = 2:length(pickConsPursuit)
                                        yParaNames = [yParaNames, ', ', pickConsPursuit{ii}, ' ', num2str(paraPursuitGroups{subplotN, ii})];
                                    end
                                end
                            end
                        else % just find the patient group
                            idx = find(dataEye.patient==patientGroups(patientN));
                        end
                        dataTemp = dataEye(idx, :);
                        
                        if length(dataTemp.subjectID)~=length(unique(dataTemp.subjectID))% need to average for each participant
                            subIDs = unique(dataTemp.subjectID);
                            for subN = 1:length(subIDs)
                                dataY(subN, 1) = nanmean(dataTemp.(dependentVariables{taskN}{dependentN})(strcmp(dataTemp.subjectID, subIDs{subN}), 1));
                            end
                        else % no need to average
                            dataY = dataTemp.(dependentVariables{taskN}{dependentN});
                            % get the subjectID so we could search for their corresponding
                            % independent variable values
                            subIDs = dataTemp.subjectID;
                        end
                    else  % just one plot for the saccade tasks
                        idx = find(dataEye.patient==patientGroups(patientN));
                        dataY = dataEye.(dependentVariables{taskN}{dependentN})(idx, 1);
                        % get the subjectID so we could search for their corresponding
                        % independent variable values
                        subIDs = dataEye.subjectID(idx, 1);
                    end
                    
                    % now find the corresponding independent variable values
                    for subN = 1:length(subIDs)
                        idx = find(strcmp(dataMaster.ID, subIDs{subN}));
                        if ~isempty(idx)
                            dataX(subN, 1) = dataMaster.(independentVariables{independentN})(idx, 1);
                        else
                            dataX(subN, 1) = NaN;
                        end
                    end
                    % scatter plots of the dots
                    scatter(dataX, dataY, 'MarkerEdgeColor', colorPlot(patientN, :))
                    % save for later use in the correlation analysis
                    dataXAll = [dataXAll; dataX];
                    dataYAll = [dataYAll; dataY];
                end
                % ignore NaN values...
                idx = find(isnan(dataXAll) | isnan(dataYAll));
                dataXAll(idx) = [];
                dataYAll(idx) = [];
                
                % plot a fitted line
                coeffs = polyfit(dataXAll, dataYAll, 1);
                fittedLine = refline(coeffs);
                fittedLine.LineStyle = '--';
                
                % run Pearson correlation and show stats on title
                [rho,pval] = corr(dataXAll, dataYAll);
                titleName = ['r=', num2str(rho, 2), ',p=', num2str(pval, 2)];
                title(titleName)
                
                legend(legendNames, 'location', 'best')
                xlabel(independentVariables{independentN})
                ylabel([dependentVariables{taskN}{dependentN}, '\newline (', yParaNames, ')'])
                if customAxisRange
                    xlim(xRange(:, independentN))
                    ylim(yRange{taskN}(:, dependentN))
                end
%                 axis square
            end
            
            % define the output file name and save the figure
            fileName = [plotSavePath, 'scatter_', tasks{taskN}, '_', dependentVariables{taskN}{dependentN}, 'BY', independentVariables{independentN}, '.emf'];
            saveas(gcf, fileName)
        end
    end
end