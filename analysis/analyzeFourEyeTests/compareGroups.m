% analyze data of the four eye tests (excluding predictive pursuit) from
% the excel sheets; visualize and do individual t-tests to compare
% difference between the patient and control group

% drafted by XiuyunWu, 10/09/2020, xiuyunwu5@gmail.com
% implemented by Vriti Bhagat, date, email
clear all; close all; clc

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