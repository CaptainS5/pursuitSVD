%% Convert edf to asc for SVD project, the predictive pursuit task
close all
clear all

%% NEXT TIME FOR CONVERSION CHECK HOW MUCH HEADER SHOULD BE SKIPPED!!! IMPORTANT TO ACTUALLY GET THE RIGHT TARGET INDEX!!!
startFolder = [pwd '\']; % where the edf2asc program is
dataPath = fullfile(pwd,'..','data\patients\predict_pursuit_data\');
folderNames = dir(dataPath);
if strcmp(folderNames(end).name(end-3:end), '.mat') % if already includes the excludeList file, ignore
    folderNames(end) = [];
end
currentSubject = {};
% if already have the exclude list and needs to rerun, load
load([dataPath, 'excludeList.mat'])
% if not having the exclude list, generate one
% excludeList = {};
% excludeCount = 1;

%% Loop over all subjects
for i = 3:3%3:length(folderNames)
    currentSubject{i-2} = folderNames(i).name;  
    
    currentFolder = [dataPath currentSubject{i-2}];
    cd(currentFolder);
    % first, to figure out if should exclude this participant due to lack
    % of trials or files
    edfFiles = dir([currentFolder '\*.edf']);
    matFiles = dir([currentFolder '\*.mat']);
    logFiles = dir([currentFolder '\SLog*']); % don't actually need this file, can recover everything from eye data and the mat file
    if ~isempty(matFiles)
        for ii = 1:size(matFiles, 1)
            matFileNames{ii} = matFiles(ii).name(end-11:end);
        end
    end
    % if already have the exclude list and needs to rerun, compare and ignore those who should
    % be ignored...
    excludeFlag = 0;
    for ii = 1:size(excludeList, 2)
        if strcmp(excludeList{ii}, currentSubject{i-2})
            excludeFlag = 1;
        end
    end
    if excludeFlag
        continue
    end
    
%     if isempty(matFiles) || size(edfFiles, 1)<150 ...
%             || isempty(find(strcmp(matFileNames, '_predict.mat'))) % the
%             first time, need to identify who should be excluded
%         excludeList{excludeCount} = currentSubject{i-2};
%         excludeCount = excludeCount+1;
%         continue
%     end
    
    [res, stat] = system([startFolder 'edf2asc -y ' currentFolder '\*.edf']);
    
    cd(startFolder);
    ascfiles = dir([currentFolder '\*.asc']);
    
    targetPosition = struct();    
    for j = 1:length(ascfiles)
        ascfile = ascfiles(j).name;
        path = fullfile(currentFolder, ascfile);
        fid = fopen(path);
        allEntries = textscan(fid, '%s %s %s %s %s %s %s %*[^\n]');
        
        frameCount = 1;
        % find info about target position and blank timing? here
        for lineN = 1:size(allEntries{1}, 1)
            if strcmp(allEntries{1}{lineN}, 'MSG')
                if strcmp(allEntries{3}{lineN}, 'TRIALID')
                    trialN = str2num(allEntries{4}{lineN});
                elseif strcmp(allEntries{3}{lineN}, 'GAZE_COORDS') % check the original codes on the pc... but, well...
                    targetPosition.screenX(trialN, 1) = str2num(allEntries{6}{lineN})+1;
                    targetPosition.screenY(trialN, 1) = str2num(allEntries{7}{lineN})+1;
                elseif strcmp(allEntries{3}{lineN}, '!V') && strcmp(allEntries{4}{lineN}, 'TARGET_POS')
                    targetPosition.time(trialN, frameCount) = str2num(allEntries{2}{lineN});
                    targetPosition.posX(trialN, frameCount) = str2num(allEntries{6}{lineN}(2:end-1)); 
                    targetPosition.posY(trialN, frameCount) = str2num(allEntries{7}{lineN}(1:end-1));
                    frameCount = frameCount+1;
                end
            end
        end
        fclose(fid);
    end
    cd(currentFolder)
    save('targetPosition', 'targetPosition')
    
    cd(startFolder)
    [res, stat] = system([startFolder 'edf2asc -y -s -miss 9999 -nflags ' currentFolder '\*.edf']);
end
cd(dataPath)
% save('excludeList.mat', 'excludeList')