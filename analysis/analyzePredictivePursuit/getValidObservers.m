% generate the participant name list based on data folder names and the excludeList
% controls marked as group=0, patients marked as group=1
% Xiuyun Wu, 02/Nov/2020; edited 11/27/2020

clear all; clc; close all;

errorFileFolder = ['..\ErrorFiles\'];
load('validObserversCatchTrial.mat')
subExclude = table;

% these were before clicking through all trials... now we can just base on
% who has the final errorfiles
% =========================================================================
% dataControlFolder = ['..\..\data\controls\predict_pursuit_data\'];
% dataPatientFolder = ['..\..\data\patients\predict_pursuit_data\'];

% % go through controls first
% folderNames = dir(dataControlPath);
% load([dataControlPath, 'excludeList.mat'])
% for ii = 1:length(folderNames)-3
%     subInfo.name{ii, 1} = folderNames(ii+2).name;
%     subInfo.group(ii, 1) = 0;
% end
% % exclude those with incomplete data
% for ii=1:length(excludeList)
%     idx = find(strcmp(subInfo.name, excludeList{ii}));
%     subInfo(idx, :) = [];
% end
% 
% % go through controls first
% folderNames = dir(dataPatientPath);
% load([dataPatientPath, 'excludeList.mat'])
% countN = length(subInfo.name);
% for ii = 1:length(folderNames)-3
%     subInfo.name{ii+countN, 1} = folderNames(ii+2).name;
%     subInfo.group(ii+countN, 1) = 1;
% end
% % exclude those with incomplete data
% for ii=1:length(excludeList)
%     idx = find(strcmp(subInfo.name, excludeList{ii}));
%     subInfo(idx, :) = [];
% end
% cd(analysisFolder)
% save('validObserversCompleteData.mat', 'subInfo')
% =========================================================================

% exclude those with less than half valid trials, probably due to signal
% loss etc.
fileNames = dir([errorFileFolder, '*.mat']);
for subN = 1:length(fileNames)
    load([errorFileFolder, fileNames(subN).name])
    subName = fileNames(subN).name(5:8);
    infoIdx = find(strcmp(subInfo.name, subName));
    
    validN = length(find(errorStatus==0));
    trialTotalN = length(errorStatus)-30; % number of total pursuit trials
    
    if validN<=trialTotalN/2 % exclude
        subExclude = [subExclude; subInfo(infoIdx, :)];
        subInfo(infoIdx, :) = [];
    end
end

save('validObserversFinal.mat', 'subInfo')
save('excludeObserversSignalLoss.mat', 'subExclude')