% use eyeTrialData to do analysis, initialize parameters for the predictive
% pursuit task

clear all; close all; clc

load('validObserversFinal.mat')

% sampleRate = 1000;
% 
% analysisFolder = pwd;
% cd ..
% cd('pursuitPlots')
% pursuitFolder = pwd;
% cd ..
% cd('saccadePlots')
% saccadeFolder = pwd;
% cd ..
% cd('perceptPlots')
% perceptFolder = pwd;
% cd ..
% cd('velocityTraces')
% velTraceFolder = pwd;
% cd ..
% cd('correlationPlots')
% correlationFolder = pwd;
% cd ..
% cd('mausAnalysis')
% mausFolder = pwd;
% cd ..
% cd('slidingWindows')
% slidingWFolder = pwd;
% cd ..
% cd ..
% cd('R')
% RFolder = pwd;
% cd(analysisFolder)
% expAll{1} = load(['eyeTrialData_all_exp1.mat']);
% expAll{2} = load(['eyeTrialData_all_exp2.mat']);
% expAll{3} = load(['eyeTrialData_all_exp3.mat']);
% % expCleanedUp{1} = load(['eyeTrialData_all_cleaned_exp1.mat']);
% % expCleanedUp{2} = load(['eyeTrialData_all_cleaned_exp2.mat']);
% % load(['eyeTrialData_all_set' num2str(setN) '_exp2.mat']);
% 
% % for Exp1
% % probCons = [10 30 50 70 90];
% % probNames{1} = {'10', '30', '50'};
% % probNames{2} = {'50', '70', '90'};
% 
% probCons = [10 50 90];
% probNames{1} = {'10', '50'};
% probNames{2} = {'50', '90'};
% % probNames{1} = {'10', '30', '50'};
% % probNames{2} = {'50', '70', '90'};
% probNames12{1} = {'exp1-50', 'exp1-10', 'exp3-50', 'exp3-10'};
% probNames12{2} = {'exp1-50', 'exp1-90', 'exp3-50', 'exp3-90'};
% 
% dirCons = [-1 1]; % -1=left, 1=right
% dirNames = {'left' 'right'};

% for plotting
for t = 1:size(nameSets{1}, 2) % individual color for scatter plots, can do 10 people
    if t<=2
        markerC(t, :) = (t+2)/4*[77 255 202]/255;
    elseif t<=4
        markerC(t, :) = (t)/4*[70 95 232]/255;
    elseif t<=6
        markerC(t, :) = (t-2)/4*[232 123 70]/255;
    elseif t<=8
        markerC(t, :) = (t-4)/4*[255 231 108]/255;
    elseif t<=10
        markerC(t, :) = (t-6)/4*[255 90 255]/255;
    end
end
colorProb = [8,48,107;198,219,239;8,48,107]/255; % all blue hues
% colorProb = [8,48,107;66,146,198;198,219,239;66,146,198;8,48,107]/255; % all blue hues
% colorProb = [232 113 240; 15 204 255; 255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability