% Xiuyun Wu, 11/02/2019
% getting the raw processed eye data... will be much more convenient for
% later analysis; roughly from fixation onset to target offset
% run this after getting the errorfiles

clear all; close all; clc

load('validObservers.mat') % load the name list for all participants
subStartI = [1];

cd ..
analysisPath = pwd; % folder for the eye movement preprocessing codes
cd ('..\data')
dataRootFolder = pwd; % still need to go into specific folders

% parameters for SVD testing at icord
sampleRate = 1000;
screenSizeX = 40.6;
screenSizeY = 30.4;
screenResX = 1600; 
screenResY = 1200;
distance = 83.5;

% saccade algorithm threshold 
saccadeThreshold = 400; % acceleration

%% All trials
for setN = 1:length(subStartI)
    if subStartI(setN)>1 % if starting halway, load the current eyeTrialDataAll
        cd([analysisPath '\analyzePredictivePursuit'])
        load(['eyeTrialData_all.mat'])
    else
        clear eyeTrialData
    end
    
    for subN = subStartI(setN):length(subInfo.name)
        % go to the sub folder
        currentSubject = subInfo.name{subN};
        if subInfo.group(subN, 1)==0 % the control group
            cd([dataPath, '\controls\', currentSubject])
        elseif subInfo.group(subN, 1)==1 % the patient group
            cd([dataPath, '\patients\', currentSubject])
        end
        currentSubjectPath = pwd;
        % get file lists
        eyeFiles = dir('*.asc');
        matFiles = dir('*.mat');
        % load files
        load('targetPosition.mat');
        for ii = 1:size(matFiles, 1)
            matFileNames{ii} = matFiles(ii).name(end-11:end);
        end
        logIdx = find(strcmp(matFileNames, '_predict.mat'));
        logFileName = matFiles(logIdx).name;
        log = load(logFileName);
        % error file
        cd(analysisPath);
        errorFilePath = fullfile(analysisPath,'\ErrorFiles\');
        load([errorFilePath 'Sub_' currentSubject '_errorFile.mat']);
        
        clear eyeTrialDataSub
        
        % 
        for currentTrial = 1:size(errorStatus, 1)
            eyeTrialData.sub{subN, currentTrial} = currentSubject;
            eyeTrialData.group(subN, currentTrial) = subInfo.group(subN, 1);
            eyeTrialData.trialIdx(subN, currentTrial) = currentTrial;
            if
                eyeTrialData.trialType(subN, currentTrial) = 0; % 0-no blank, catch trial; 1-valid trial
            else
                eyeTrialData.trialType(subN, currentTrial) = 1;
            end
            % to get target info
            eyeTrialData.speed(subN, currentTrial) = ; % 
            eyeTrialData.targetDir(subN, currentTrial) = ; % 
            eyeTrialData.errorStatus(subN, currentTrial) = errorStatus(currentTrial, 1);
            if errorStatus(currentTrial, 1)==0
                analyzeTrial;
                
                eyeTrialData.frameLog.fixationOn(subN, currentTrial) = trial.log.trialStart;
                eyeTrialData.frameLog.fixationOff(subN, currentTrial) = trial.log.fixationOff;
                eyeTrialData.frameLog.rdkOn(subN, currentTrial) = trial.log.targetOnset;
                eyeTrialData.frameLog.rdkOff(subN, currentTrial) = trial.log.trialEnd;
                
                eyeTrialData.pursuit.APvelocityX(subN, currentTrial) = trial.pursuit.APvelocityX;
                eyeTrialData.pursuit.APvelocityX_interpol(subN, currentTrial) = trial.pursuit.APvelocityX_interpol;
                eyeTrialData.pursuit.onset(subN, currentTrial) = trial.pursuit.onset; % visually driven pursuit onset
                eyeTrialData.pursuit.onsetSteadyState(subN, currentTrial) = trial.pursuit.onsetSteadyState;
                eyeTrialData.pursuit.onsetTrue(subN, currentTrial) = trial.pursuit.onsetTrue; % original onset, could be earlier than visual stimulus onset
                eyeTrialData.pursuit.openLoopStartFrame(subN, currentTrial) = trial.pursuit.openLoopStartFrame;
                eyeTrialData.pursuit.openLoopEndFrame(subN, currentTrial) = trial.pursuit.openLoopEndFrame;
                eyeTrialData.pursuit.initialMeanVelocityX(subN, currentTrial) = trial.pursuit.initialMeanVelocityX;
                eyeTrialData.pursuit.initialPeakVelocityX(subN, currentTrial) = trial.pursuit.initialPeakVelocityX;
                eyeTrialData.pursuit.initialMeanAccelerationX(subN, currentTrial) = trial.pursuit.initialMeanAccelerationX;
                eyeTrialData.pursuit.initialPeakAccelerationX(subN, currentTrial) = trial.pursuit.initialPeakAccelerationX;
                eyeTrialData.pursuit.closedLoopMeanVelX(subN, currentTrial) = trial.pursuit.closedLoopMeanVelX;
                eyeTrialData.pursuit.gainX(subN, currentTrial) = trial.pursuit.gainX;
                eyeTrialData.pursuit.gainX_interpol(subN, currentTrial) = trial.pursuit.gainX_interpol;
                eyeTrialData.pursuit.initialVelChangeX(subN, currentTrial) = -nanmean(trial.DX_noSac( (trial.pursuit.openLoopStartFrame-ms2frames(5)) : (trial.pursuit.openLoopStartFrame+ms2frames(5)) )) ...
                    +nanmean(trial.DX_noSac( (trial.pursuit.openLoopEndFrame-ms2frames(5)) : (trial.pursuit.openLoopEndFrame+ms2frames(5)) ));
                
                %             eyeTrialData.saccades.X.number(subN, currentTrial) = trial.saccades.X_right.number;
                %             eyeTrialData.saccades.X.meanAmplitude(subN, currentTrial) = trial.saccades.X.meanAmplitude;
                %             eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = trial.saccades.X.maxAmplitude;
                %             eyeTrialData.saccades.X.meanDuration(subN, currentTrial) = trial.saccades.X.meanDuration;
                %             eyeTrialData.saccades.X.sumAmplitude(subN, currentTrial) = trial.saccades.X.sacSum;
                %             eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = trial.saccades.X.peakVelocity;
                %             eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = trial.saccades.X.meanVelocity;
                %             eyeTrialData.saccades.X.onsets_pursuit{subN, currentTrial} = trial.saccades.X.onsets_pursuit;
                %             eyeTrialData.saccades.X.offsets_pursuit{subN, currentTrial} = trial.saccades.X.offsets_pursuit;
                %
                % record saccades in both directions...
%                 if trial. log.rdkDir>0 || (trial.log.rdkDir==0 && trial.pursuit.closedLoopMeanVelX>=0)% first use rdk dir to judge, then see pursuit; trial.pursuit.closedLoopMeanVelX>=0 % right ward pursuit
                    eyeTrialData.saccades.X_right.number(subN, currentTrial) = trial.saccades.X_right.number;
                    eyeTrialData.saccades.X_right.meanAmplitude(subN, currentTrial) = trial.saccades.X_right.meanAmplitude;
                    %                 eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = trial.saccades.X_right.maxAmplitude;
                    eyeTrialData.saccades.X_right.meanDuration(subN, currentTrial) = trial.saccades.X_right.meanDuration;
                    eyeTrialData.saccades.X_right.sumAmplitude(subN, currentTrial) = trial.saccades.X_right.sumAmplitude;
                    %                 eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = trial.saccades.X_right.peakVelocity;
                    %                 eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = trial.saccades.X_right.meanVelocity;
                    eyeTrialData.saccades.X_right.onsets_pursuit{subN, currentTrial} = trial.saccades.X_right.onsets_pursuit;
                    eyeTrialData.saccades.X_right.offsets_pursuit{subN, currentTrial} = trial.saccades.X_right.offsets_pursuit;
%                 elseif trial. log.rdkDir<0 || (trial.log.rdkDir==0 && trial.pursuit.closedLoopMeanVelX<0)
                    eyeTrialData.saccades.X_left.number(subN, currentTrial) = trial.saccades.X_left.number;
                    eyeTrialData.saccades.X_left.meanAmplitude(subN, currentTrial) = trial.saccades.X_left.meanAmplitude;
                    %                 eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = trial.saccades.X_left.maxAmplitude;
                    eyeTrialData.saccades.X_left.meanDuration(subN, currentTrial) = trial.saccades.X_left.meanDuration;
                    eyeTrialData.saccades.X_left.sumAmplitude(subN, currentTrial) = trial.saccades.X_left.sumAmplitude;
                    %                 eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = trial.saccades.X_left.peakVelocity;
                    %                 eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = trial.saccades.X_left.meanVelocity;
                    eyeTrialData.saccades.X_left.onsets_pursuit{subN, currentTrial} = trial.saccades.X_left.onsets_pursuit;
                    eyeTrialData.saccades.X_left.offsets_pursuit{subN, currentTrial} = trial.saccades.X_left.offsets_pursuit;
%                 end
%                 if ~isnan(eyeTrialData.saccades.X.sumAmplitude(subN, currentTrial))
%                     eyeTrialData.pursuit.gainSacSumAmpX(subN, currentTrial) = eyeTrialData.pursuit.gainX(subN, currentTrial)+eyeTrialData.saccades.X.sumAmplitude(subN, currentTrial)/10;
%                 else
%                     eyeTrialData.pursuit.gainSacSumAmpX(subN, currentTrial) = eyeTrialData.pursuit.gainX(subN, currentTrial);
%                 end
                
                eyeTrialDataSub.trial{1, currentTrial}.eyeX_filt = trial.eyeX_filt; % for velocity traces
                eyeTrialDataSub.trial{1, currentTrial}.eyeY_filt = trial.eyeY_filt;
                eyeTrialDataSub.trial{1, currentTrial}.eyeDX_filt = trial.eyeDX_filt;
                eyeTrialDataSub.trial{1, currentTrial}.eyeDY_filt = trial.eyeDY_filt;
                eyeTrialDataSub.trial{1, currentTrial}.X_noSac = trial.X_noSac;
                eyeTrialDataSub.trial{1, currentTrial}.Y_noSac = trial.Y_noSac;
                eyeTrialDataSub.trial{1, currentTrial}.DX_noSac = trial.DX_noSac;
                eyeTrialDataSub.trial{1, currentTrial}.DY_noSac = trial.DY_noSac;
                eyeTrialDataSub.trial{1, currentTrial}.X_interpolSac = trial.X_interpolSac;
                eyeTrialDataSub.trial{1, currentTrial}.Y_interpolSac = trial.Y_interpolSac;
                eyeTrialDataSub.trial{1, currentTrial}.DX_interpolSac = trial.DX_interpolSac;
                eyeTrialDataSub.trial{1, currentTrial}.DY_interpolSac = trial.DY_interpolSac;
            else
                eyeTrialData.frameLog.fixationOn(subN, currentTrial) = NaN;
                eyeTrialData.frameLog.fixationOff(subN, currentTrial) = NaN;
                eyeTrialData.frameLog.rdkOn(subN, currentTrial) = NaN;
                eyeTrialData.frameLog.rdkOff(subN, currentTrial) = NaN;
                
                eyeTrialData.pursuit.APvelocityX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.APvelocityX_interpol(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.onset(subN, currentTrial) = NaN; % visually driven pursuit onset
                eyeTrialData.pursuit.onsetSteadyState(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.onsetTrue(subN, currentTrial) = NaN; % original onset, could be earlier than visual stimulus onset
                eyeTrialData.pursuit.openLoopStartFrame(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.openLoopEndFrame(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.initialMeanVelocityX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.initialPeakVelocityX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.initialMeanAccelerationX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.initialPeakAccelerationX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.closedLoopMeanVelX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.gainX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.gainX_interpol(subN, currentTrial) = NaN;
%                 eyeTrialData.pursuit.gainSacSumAmpX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.initialVelChangeX(subN, currentTrial) = NaN;
                
                eyeTrialData.saccades.X_right.number(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_right.meanAmplitude(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_right.meanDuration(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_right.sumAmplitude(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_right.onsets_pursuit{subN, currentTrial} = NaN;
                eyeTrialData.saccades.X_right.offsets_pursuit{subN, currentTrial} = NaN;
                
                eyeTrialData.saccades.X_left.number(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_left.meanAmplitude(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_left.meanDuration(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_left.sumAmplitude(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_left.onsets_pursuit{subN, currentTrial} = NaN;
                eyeTrialData.saccades.X_left.offsets_pursuit{subN, currentTrial} = NaN;
                
                eyeTrialDataSub.trial{1, currentTrial} = NaN; % for velocity traces
            end
        end
        cd([analysisPath '\analyzePredictivePursuit'])
        save(['eyeTrialDataSubExp' num2str(expN) '_' names{subN} '.mat'], 'eyeTrialDataSub');
    end
    save(['eyeTrialData_all.mat'], 'eyeTrialData');
end