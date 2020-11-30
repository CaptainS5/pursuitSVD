%% setup data
%% Eye Data
%  eye data have been converted in readEDF
%  first step: read in converted eye data
if currentTrial>size(eyeFiles, 1)
    currentTrial=size(eyeFiles, 1); % do not go further if it's already the last trial
end
ascFile = eyeFiles(currentTrial,1).name;
eyeData = readEyeData(ascFile, dataPath, currentSubject, analysisPath);
[eyeData sampleRate]= processEyeData(eyeData); % equivalent to socscalexy

%% Target data
% set up target file
target = createTargetData(targetPosition, ascFile, eyeData, str2double(currentSubject(end-1:end)), name);

%% setup trial
trial = readoutTrialPursuit(ascFile, eyeData, currentSubject, target, log, name);

%% find saccades
%  jerk thresholds
thresholdMoveDirection = evalin('base', 'saccadeThreshold');
thresholdZero = 200;
% % acceleration thresholds
% thresholdMoveDirection = 500;%evalin('base', 'saccadeThreshold');
% thresholdZero = 300; %just a random number now... don't care anyway evalin('base', 'microSaccadeThreshold');
% % velocity thresholds
% thresholdMoveDirection = 10;%evalin('base', 'saccadeThreshold');
% thresholdZero = evalin('base', 'microSaccadeThreshold');
if nansum(trial.target.X) == 0
    % use acceleration threshold
    [saccades.X.onsets, saccades.X.offsets] = findSaccadesAcc(1, trial.length, trial.eye.DX_filt, trial.eye.DDX_filt, trial.eye.DDDX, thresholdZero);
    [saccades.Y.onsets, saccades.Y.offsets] = findSaccadesAcc(1, trial.length, trial.eye.DY_filt, trial.eye.DDY_filt, trial.eye.DDDY, thresholdMoveDirection);
%     % use velocity threshold
%     [saccades.X.onsets, saccades.X.offsets, saccades.X.isMax] = findSaccades(1, trial.length, trial.eye.DX_filt, trial.eye.DDX_filt, thresholdZero, trial.target.Xvel);
%     [saccades.Y.onsets, saccades.Y.offsets, saccades.Y.isMax] = findSaccades(1, trial.length, trial.eye.DY_filt, trial.eye.DDY_filt, thresholdMoveDirection, trial.target.Yvel);
elseif nansum(trial.target.Y) == 0
    % use acceleration threshold
    [saccades.X.onsets, saccades.X.offsets] = findSaccadesAcc(1, trial.length, trial.eye.DX_filt, trial.eye.DDX_filt, trial.eye.DDDX, thresholdMoveDirection);
    [saccades.Y.onsets, saccades.Y.offsets] = findSaccadesAcc(1, trial.length, trial.eye.DY_filt, trial.eye.DDY_filt, trial.eye.DDDY, thresholdZero);
%     % use velocity threshold
%     [saccades.X.onsets, saccades.X.offsets, saccades.X.isMax] = findSaccades(1, trial.length, trial.eye.DX_filt, trial.eye.DDX_filt, thresholdMoveDirection, trial.target.Xvel);
%     [saccades.Y.onsets, saccades.Y.offsets, saccades.Y.isMax] = findSaccades(1, trial.length, trial.eye.DY_filt, trial.eye.DDY_filt, thresholdZero, trial.target.Yvel);
end
%% analyze saccades
[trial] = analyzeSaccadesPursuit(trial, saccades);

clear saccades;

%% remove saccades (include blinks
trial = removeBlinksSaccades(trial);

%% analyze pursuit
trial = analyzePursuit(trial);

