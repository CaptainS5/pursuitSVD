% generate the participant name list based on data folder names and the excludeList
% controls marked as group=0, patients marked as group=1
% Xiuyun Wu, 02/Nov/2020

clear all; clc; close all;

analysisFolder = pwd;
cd ('..\..\data')
dataRootFolder = pwd; % still need to go into specific folders
subInfo = table();
% excludeOther = {'A082', 'E034', 'E028', 'O070'}; 
% % which ones to exclude besides the incomplete data sets; reasons could be
% % lower sampling rate or too much signal loss

% go through controls first
cd('controls\predict_pursuit_data')
dataPath = pwd;
folderNames = dir(dataPath);
load('excludeList.mat')
for ii = 1:length(folderNames)-3
    subInfo.name{ii, 1} = folderNames(ii+2).name;
    subInfo.group(ii, 1) = 0;
end
% exclude those with incomplete data
for ii=1:length(excludeList)
    idx = find(strcmp(subInfo.name, excludeList{ii}));
    subInfo(idx, :) = [];
end

% go through controls first
cd('..\..\patients\predict_pursuit_data')
dataPath = pwd;
folderNames = dir(dataPath);
load('excludeList.mat')
countN = length(subInfo.name);
for ii = 1:length(folderNames)-3
    subInfo.name{ii+countN, 1} = folderNames(ii+2).name;
    subInfo.group(ii+countN, 1) = 1;
end
% exclude those with incomplete data
for ii=1:length(excludeList)
    idx = find(strcmp(subInfo.name, excludeList{ii}));
    subInfo(idx, :) = [];
end

% exclude those with less than half valid trials, probably due to signal
% loss etc.
cd(analysisFolder)
cd ..
cd('ErrorFiles')
count = 1;
% while count<=length(subInfo.name)
%     idx = find(strcmp(subInfo.name, excludeOther{ii}));
%     subInfo(idx, :) = [];
% end

% cd(analysisFolder)
% save('validObservers.mat', 'subInfo')