% Xiuyun Wu, 11/02/2019
% getting the raw processed eye data... will be much more convenient for
% later analysis; roughly from fixation onset to target offset
% run this after getting the errorfiles

clear all; close all; clc

subStartI = 1; % start with which sub in subInfo.name
if subStartI>1 % if starting halway, load the current eyeTrialDataAll
    load(['eyeTrialData_all.mat'])
else
    clear eyeTrialData
end

load('validObserversFinal.mat') % load the name list for all participants
subInfo(17, :) = []; % temporarily exclude one participant having weird
% speeds--A049, patient; need to go back later to see what was wrong...

% the paths are a little bit messy, since the eye processing functions
% still cd into the directories, but I'm trying to not actually go in...
cd ..
analysisPath = pwd;
cd('..\data\controls\predict_pursuit_data\')
dataControlFolder = pwd;
cd('..\..\patients\predict_pursuit_data\')
dataPatientFolder = pwd;
errorFileFolder = [analysisPath, '\ErrorFiles\'];
cd(analysisPath)
name = 'predictivePursuit';

% parameters for SVD testing at icord
screenSizeX = 40.6;
screenSizeY = 30.4;
screenResX = 1600;
screenResY = 1200;
distance = 83.5;

% saccade algorithm threshold
saccadeThreshold = 300; % acceleration

%% All trials
for subN = subStartI:length(subInfo.name)
    % go to the sub folder
    currentSubject = subInfo.name{subN};
    if subInfo.group(subN, 1)==0 % the control group
        currentSubjectFolder = [dataControlFolder, '\', currentSubject, '\'];
        dataPath = dataControlFolder;
    elseif subInfo.group(subN, 1)==1 % the patient group
        currentSubjectFolder = [dataPatientFolder, '\', currentSubject, '\'];
        dataPath = dataPatientFolder;
    end
    
    % get file lists
    eyeFiles = dir([currentSubjectFolder, '*.asc']);
    matFiles = dir([currentSubjectFolder, '*.mat']);
    % load files
    load([currentSubjectFolder 'targetPosition.mat']);
    for ii = 1:size(matFiles, 1)
        matFileNames{ii} = matFiles(ii).name(end-11:end);
    end
    logIdx = find(strcmp(matFileNames, '_predict.mat'));
    logFileName = matFiles(logIdx).name;
    log = load([currentSubjectFolder, logFileName]);
    % error file
    load([errorFileFolder 'Sub_' currentSubject '_errorFile.mat']);
    
    clear eyeTrialDataSub
    
    for currentTrial = 1:size(errorStatus, 1)
        eyeTrialData.sub{subN, currentTrial} = currentSubject;
        eyeTrialData.group(subN, currentTrial) = subInfo.group(subN, 1);
        eyeTrialData.trialIdx(subN, currentTrial) = currentTrial;
        eyeTrialData.errorStatus(subN, currentTrial) = errorStatus(currentTrial, 1);
        
        if errorStatus(currentTrial, 1)==0 || errorStatus(currentTrial, 1)==-5 % valid pursuit or catch trials
            if errorStatus(currentTrial, 1)==-5
                eyeTrialData.trialType(subN, currentTrial) = 0; % 0-no blank, catch trial; 1-valid trial
                eyeTrialData.frameLog.blankStart(subN, currentTrial) = NaN;
                eyeTrialData.frameLog.blankEnd(subN, currentTrial) = NaN;
            elseif errorStatus(currentTrial, 1)==0
                eyeTrialData.trialType(subN, currentTrial) = 1;
            end
            
            analyzeTrialPursuit;
            
            % target info
            eyeTrialData.sampleRate(subN, currentTrial) = sampleRate;
            eyeTrialData.speed(subN, currentTrial) = trial.target.speed;
            if trial.target.X(1, 1)>0 % start from the right
                eyeTrialData.targetDir(subN, currentTrial) = -1; % left moving target
            elseif trial.target.X(1, 1)<0 % start from the left
                eyeTrialData.targetDir(subN, currentTrial) = 1; % right moving target
            end
            
            eyeTrialData.frameLog.targetOn(subN, currentTrial) = trial.target.onset;
            eyeTrialData.frameLog.targetOff(subN, currentTrial) = trial.target.offset;
            if errorStatus(currentTrial, 1)==0
                eyeTrialData.frameLog.blankStart(subN, currentTrial) = trial.log.blankStart;
                eyeTrialData.frameLog.blankEnd(subN, currentTrial) = trial.log.blankEnd;
            end
            
            %                 eyeTrialData.pursuit.APvelocityX(subN, currentTrial) = trial.pursuit.APvelocityX;
            %                 eyeTrialData.pursuit.APvelocityX_interpol(subN, currentTrial) = trial.pursuit.APvelocityX_interpol;
            %                 eyeTrialData.pursuit.onset(subN, currentTrial) = trial.pursuit.onset; % visually driven pursuit onset
            %                 eyeTrialData.pursuit.onsetSteadyState(subN, currentTrial) = trial.pursuit.onsetSteadyState;
            %                 eyeTrialData.pursuit.onsetTrue(subN, currentTrial) = trial.pursuit.onsetTrue; % original onset, could be earlier than visual stimulus onset
            %                 eyeTrialData.pursuit.openLoopStartFrame(subN, currentTrial) = trial.pursuit.openLoopStartFrame;
            %                 eyeTrialData.pursuit.openLoopEndFrame(subN, currentTrial) = trial.pursuit.openLoopEndFrame;
            %                 eyeTrialData.pursuit.initialMeanVelocityX(subN, currentTrial) = trial.pursuit.initialMeanVelocityX;
            %                 eyeTrialData.pursuit.initialPeakVelocityX(subN, currentTrial) = trial.pursuit.initialPeakVelocityX;
            %                 eyeTrialData.pursuit.initialMeanAccelerationX(subN, currentTrial) = trial.pursuit.initialMeanAccelerationX;
            %                 eyeTrialData.pursuit.initialPeakAccelerationX(subN, currentTrial) = trial.pursuit.initialPeakAccelerationX;
            %                 eyeTrialData.pursuit.closedLoopMeanVelX(subN, currentTrial) = trial.pursuit.closedLoopMeanVelX;
            %                 eyeTrialData.pursuit.gainX(subN, currentTrial) = trial.pursuit.gainX;
            %                 eyeTrialData.pursuit.gainX_interpol(subN, currentTrial) = trial.pursuit.gainX_interpol;
            %                 eyeTrialData.pursuit.initialVelChangeX(subN, currentTrial) = -nanmean(trial.DX_noSac( (trial.pursuit.openLoopStartFrame-ms2frames(5)) : (trial.pursuit.openLoopStartFrame+ms2frames(5)) )) ...
            %                     +nanmean(trial.DX_noSac( (trial.pursuit.openLoopEndFrame-ms2frames(5)) : (trial.pursuit.openLoopEndFrame+ms2frames(5)) ));
            %
            %                 %             eyeTrialData.saccades.X.number(subN, currentTrial) = trial.saccades.X_right.number;
            %                 %             eyeTrialData.saccades.X.meanAmplitude(subN, currentTrial) = trial.saccades.X.meanAmplitude;
            %                 %             eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = trial.saccades.X.maxAmplitude;
            %                 %             eyeTrialData.saccades.X.meanDuration(subN, currentTrial) = trial.saccades.X.meanDuration;
            %                 %             eyeTrialData.saccades.X.sumAmplitude(subN, currentTrial) = trial.saccades.X.sacSum;
            %                 %             eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = trial.saccades.X.peakVelocity;
            %                 %             eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = trial.saccades.X.meanVelocity;
            %                 %             eyeTrialData.saccades.X.onsets_pursuit{subN, currentTrial} = trial.saccades.X.onsets_pursuit;
            %                 %             eyeTrialData.saccades.X.offsets_pursuit{subN, currentTrial} = trial.saccades.X.offsets_pursuit;
            %                 %
            %                 % record saccades in both directions...
            % %                 if trial. log.rdkDir>0 || (trial.log.rdkDir==0 && trial.pursuit.closedLoopMeanVelX>=0)% first use rdk dir to judge, then see pursuit; trial.pursuit.closedLoopMeanVelX>=0 % right ward pursuit
            %                     eyeTrialData.saccades.X_right.number(subN, currentTrial) = trial.saccades.X_right.number;
            %                     eyeTrialData.saccades.X_right.meanAmplitude(subN, currentTrial) = trial.saccades.X_right.meanAmplitude;
            %                     %                 eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = trial.saccades.X_right.maxAmplitude;
            %                     eyeTrialData.saccades.X_right.meanDuration(subN, currentTrial) = trial.saccades.X_right.meanDuration;
            %                     eyeTrialData.saccades.X_right.sumAmplitude(subN, currentTrial) = trial.saccades.X_right.sumAmplitude;
            %                     %                 eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = trial.saccades.X_right.peakVelocity;
            %                     %                 eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = trial.saccades.X_right.meanVelocity;
            %                     eyeTrialData.saccades.X_right.onsets_pursuit{subN, currentTrial} = trial.saccades.X_right.onsets_pursuit;
            %                     eyeTrialData.saccades.X_right.offsets_pursuit{subN, currentTrial} = trial.saccades.X_right.offsets_pursuit;
            % %                 elseif trial. log.rdkDir<0 || (trial.log.rdkDir==0 && trial.pursuit.closedLoopMeanVelX<0)
            %                     eyeTrialData.saccades.X_left.number(subN, currentTrial) = trial.saccades.X_left.number;
            %                     eyeTrialData.saccades.X_left.meanAmplitude(subN, currentTrial) = trial.saccades.X_left.meanAmplitude;
            %                     %                 eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = trial.saccades.X_left.maxAmplitude;
            %                     eyeTrialData.saccades.X_left.meanDuration(subN, currentTrial) = trial.saccades.X_left.meanDuration;
            %                     eyeTrialData.saccades.X_left.sumAmplitude(subN, currentTrial) = trial.saccades.X_left.sumAmplitude;
            %                     %                 eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = trial.saccades.X_left.peakVelocity;
            %                     %                 eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = trial.saccades.X_left.meanVelocity;
            %                     eyeTrialData.saccades.X_left.onsets_pursuit{subN, currentTrial} = trial.saccades.X_left.onsets_pursuit;
            %                     eyeTrialData.saccades.X_left.offsets_pursuit{subN, currentTrial} = trial.saccades.X_left.offsets_pursuit;
            % %                 end
            % %                 if ~isnan(eyeTrialData.saccades.X.sumAmplitude(subN, currentTrial))
            % %                     eyeTrialData.pursuit.gainSacSumAmpX(subN, currentTrial) = eyeTrialData.pursuit.gainX(subN, currentTrial)+eyeTrialData.saccades.X.sumAmplitude(subN, currentTrial)/10;
            % %                 else
            % %                     eyeTrialData.pursuit.gainSacSumAmpX(subN, currentTrial) = eyeTrialData.pursuit.gainX(subN, currentTrial);
            % %                 end
            
            eyeTrialDataSub.trial{1, currentTrial}.timeStamp = eyeData.timeStamp; % for velocity traces
            eyeTrialDataSub.trial{1, currentTrial}.eyeX_filt = trial.eye.X_filt; % for velocity traces
            eyeTrialDataSub.trial{1, currentTrial}.eyeY_filt = trial.eye.Y_filt;
            eyeTrialDataSub.trial{1, currentTrial}.eyeDX_filt = trial.eye.DX_filt;
            eyeTrialDataSub.trial{1, currentTrial}.eyeDY_filt = trial.eye.DY_filt;
            eyeTrialDataSub.trial{1, currentTrial}.X_noSac = trial.X_noSac;
            eyeTrialDataSub.trial{1, currentTrial}.Y_noSac = trial.Y_noSac;
            eyeTrialDataSub.trial{1, currentTrial}.DX_noSac = trial.DX_noSac;
            eyeTrialDataSub.trial{1, currentTrial}.DY_noSac = trial.DY_noSac;
            eyeTrialDataSub.trial{1, currentTrial}.X_interpolSac = trial.X_interpolSac;
            eyeTrialDataSub.trial{1, currentTrial}.Y_interpolSac = trial.Y_interpolSac;
            eyeTrialDataSub.trial{1, currentTrial}.DX_interpolSac = trial.DX_interpolSac;
            eyeTrialDataSub.trial{1, currentTrial}.DY_interpolSac = trial.DY_interpolSac;
        else
            eyeTrialData.trialType(subN, currentTrial) = NaN; % just an invalid trial...
            eyeTrialData.speed(subN, currentTrial) = NaN; %
            eyeTrialData.targetDir(subN, currentTrial) = NaN; %
            
            eyeTrialData.frameLog.targetOn(subN, currentTrial) = NaN;
            eyeTrialData.frameLog.targetOff(subN, currentTrial) = NaN;
            eyeTrialData.frameLog.blankStart(subN, currentTrial) = NaN;
            eyeTrialData.frameLog.blankEnd(subN, currentTrial) = NaN;
            
            %                 eyeTrialData.pursuit.APvelocityX(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.APvelocityX_interpol(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.onset(subN, currentTrial) = NaN; % visually driven pursuit onset
            %                 eyeTrialData.pursuit.onsetSteadyState(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.onsetTrue(subN, currentTrial) = NaN; % original onset, could be earlier than visual stimulus onset
            %                 eyeTrialData.pursuit.openLoopStartFrame(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.openLoopEndFrame(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.initialMeanVelocityX(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.initialPeakVelocityX(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.initialMeanAccelerationX(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.initialPeakAccelerationX(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.closedLoopMeanVelX(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.gainX(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.gainX_interpol(subN, currentTrial) = NaN;
            % %                 eyeTrialData.pursuit.gainSacSumAmpX(subN, currentTrial) = NaN;
            %                 eyeTrialData.pursuit.initialVelChangeX(subN, currentTrial) = NaN;
            %
            %                 eyeTrialData.saccades.X_right.number(subN, currentTrial) = NaN;
            %                 eyeTrialData.saccades.X_right.meanAmplitude(subN, currentTrial) = NaN;
            %                 %             eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = NaN;
            %                 eyeTrialData.saccades.X_right.meanDuration(subN, currentTrial) = NaN;
            %                 eyeTrialData.saccades.X_right.sumAmplitude(subN, currentTrial) = NaN;
            %                 %             eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = NaN;
            %                 %             eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = NaN;
            %                 eyeTrialData.saccades.X_right.onsets_pursuit{subN, currentTrial} = NaN;
            %                 eyeTrialData.saccades.X_right.offsets_pursuit{subN, currentTrial} = NaN;
            %
            %                 eyeTrialData.saccades.X_left.number(subN, currentTrial) = NaN;
            %                 eyeTrialData.saccades.X_left.meanAmplitude(subN, currentTrial) = NaN;
            %                 %             eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = NaN;
            %                 eyeTrialData.saccades.X_left.meanDuration(subN, currentTrial) = NaN;
            %                 eyeTrialData.saccades.X_left.sumAmplitude(subN, currentTrial) = NaN;
            %                 %             eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = NaN;
            %                 %             eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = NaN;
            %                 eyeTrialData.saccades.X_left.onsets_pursuit{subN, currentTrial} = NaN;
            %                 eyeTrialData.saccades.X_left.offsets_pursuit{subN, currentTrial} = NaN;
            
            eyeTrialDataSub.trial{1, currentTrial} = NaN; % for velocity traces
        end
    end
    save([analysisPath '\analyzePredictivePursuit\eyeTrialDataSub_' currentSubject '.mat'], 'eyeTrialDataSub');
end
save([analysisPath '\analyzePredictivePursuit\eyeTrialData_all.mat'], 'eyeTrialData');
