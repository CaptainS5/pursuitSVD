% revisit some controversal trials to mark errors
% Xiuyun Wu, Nov/02/2020; edited 11/27/2020
clear all; clc; close all

load('validObserversCompleteData.mat')
% first, to load both the initial screens and later versions
errorFileRawFolder = fullfile('..\ErrorFiles\manuallyMarkingCatchTrials\');
errorFileMainFolder = fullfile('..\ErrorFiles\');
catchTrialDefault = [1, 2, 26, 27, 51, 52, 76, 77, 101, 102, 126, 127]; % the first two trials of each block

% get the index of catch trials identified from the traces
for subN = 1:size(subInfo, 1)
    % load the participant's errorfile
    load([errorFileRawFolder, 'Sub_', subInfo.name{subN}, '_errorFile.mat'])
    % also load the exp log
    if subInfo.group(subN)==1
        dataPath = fullfile('..\..\data\patients\predict_pursuit_data\', subInfo.name{subN}, '\');
    else
        dataPath = fullfile('..\..\data\controls\predict_pursuit_data\', subInfo.name{subN}, '\');
    end
    matFiles = dir([dataPath, '*.mat']);
    for ii = 1:size(matFiles, 1)
        matFileNames{ii} = matFiles(ii).name(end-11:end);
    end
    idxT = find(strcmp(matFileNames, '_predict.mat'));
    logFileName = matFiles(idxT).name;
    log = load([dataPath, logFileName]);
    
    idxT = find(errorStatus==-5);
    ignoreIdx = find(mod(idxT, 25)==1 | mod(idxT, 25)==2); % ignore the default catch trials...
    idxT(ignoreIdx) = [];
    catchIdx{subN} = idxT;
    logIdx(subN, 1:3) = log.catchTrials; 
end

%% first, visualization of the manually identified catch trials
% % show the catch trial idices in a figure
% figure('position', [0, 0, 1300, 600], 'paperOrientation', 'landscape')
% hold on
% xlim([-10, 150])
% ylim([0, size(subInfo, 1)+1])
% yticks([])

% % there are three major groups, mark them by colors
% for subN = 1:size(subInfo, 1)
%     if all(logIdx(subN, :)==[7, 15, 21])
%         textColour = 'k';
%     elseif all(logIdx(subN, :)==[6, 12, 16])
%         textColour = 'b';
%     elseif all(logIdx(subN, :)==[11, 15, 21])
%         textColour = 'g';
%     else
%         textColour = 'm'; % grey
%     end
%     % show the participant ID at the beginning, also the info about catch
%     % trials in the last block
%     textInfo = [subInfo.name{subN}, '(', num2str(logIdx(subN, :)), ')'];
%     text(-10, subN, textInfo, 'color', textColour)
%     % show the idx number of the catch trials in their corresponding blocks
%     modIdx = mod(catchIdx{subN}, 25);
%     modIdx(modIdx==0) = 25;
%     text(catchIdx{subN}, repmat(subN, size(catchIdx{subN})), num2str(modIdx), 'color', textColour)
% end
% 
% % separate blocks...
% for blockN = 1:6
%     line([25*blockN, 25*blockN], [0, size(subInfo, 1)+1], 'lineStyle', '--', 'color', 'b')
% end
% 
% saveas(gcf, 'manuallyMarkedCatchTrials.pdf')

%% after the visual inspection, mark catch trials in errorfiles, and save the list of final observers
% (those whose catch trials can be identified with confidence)

% initialize
subInfoOriginal = subInfo;
subInfo = table;
subExclude = {}; % to record the participant ID and group of the final confirmed ones
counter = 1;
for subN = 1:size(subInfoOriginal, 1)
    % load the participant's errorfile again
    load([errorFileRawFolder, 'Sub_', subInfoOriginal.name{subN}, '_errorFile.mat'])
    % first, "neutralize" all manually marked catch trials
    errorStatus(errorStatus==-5, 1) = 0;
    exclude = 0;    
    
    % get the idx of catch trials for the participant
    if all(logIdx(subN, :)==[7, 15, 21])
        catchIdx = [catchTrialDefault, 11, 15, 21, 31, 37, 47, 56, 64, 71, 83, 87, 95, 106, 115, 120, 132, 140, 146];
    elseif all(logIdx(subN, :)==[6, 12, 16])
        catchIdx = [catchTrialDefault, 11, 15, 19, 39, 43, 47, 56, 60, 68, 85, 91, 95, 107, 111, 115, 131, 137, 141];
    elseif all(logIdx(subN, :)==[11, 15, 21])
        catchIdx = [catchTrialDefault, 10, 15, 22, 31, 36, 47, 58, 65, 72, 83, 90, 95, 107, 112, 121, 136, 140, 146];
    elseif all(logIdx(subN, :)==[10, 16, 20]) % only two people, rather confident about the results
        catchIdx = [catchTrialDefault, 7, 15, 22, 31, 38, 46, 61, 65, 69, 89, 93, 97, 106, 110, 118, 135, 141, 145];
    else % exclude
        exclude = 1;
    end
    
    % then, mark the confirmed catch trials; only mark the "valid trials",
    % ignore the invalid trials;
    if exclude
        subExclude{counter} = subInfoOriginal.name{subN};
        counter = counter+1;
    else
        subInfo = [subInfo; subInfoOriginal(subN, :)];
        idxT = find(errorStatus(catchIdx, 1)==0);
        errorStatus(catchIdx(idxT), 1) = -5;
        save([errorFileMainFolder, 'Sub_', subInfoOriginal.name{subN}, '_errorFile.mat'], 'errorStatus')
    end
    % eventually two controls were excluded, T060 and E068
end
% save('validObserversCatchTrial.mat', 'subInfo')
% save('excludeObserversCatchTrial.mat', 'subExclude')