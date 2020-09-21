%% Convert edf to asc for SVD project, the predictive pursuit task
close all
clear all

%% NEXT TIME FOR CONVERSION CHECK HOW MUCH HEADER SHOULD BE SKIPPED!!! IMPORTANT TO ACTUALLY GET THE RIGHT TARGET INDEX!!!
startFolder = [pwd '\']; % where the edf2asc program is
dataPath = fullfile(pwd,'..','data\controls\predict_pursuit_data\');
folderNames = dir(dataPath);
currentSubject = {};


%% Loop over all subjects
for i = 3:length(folderNames)
    currentSubject{i-2} = folderNames(i).name;
    
    currentFolder = [dataPath currentSubject{i-2}];
    cd(currentFolder);
    
    [res, stat] = system([startFolder 'edf2asc -y ' currentFolder '\*.edf']);
    
    cd(startFolder);
    ascfiles = dir([currentFolder '\*.asc']);
    
    targetPosition = table();    
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