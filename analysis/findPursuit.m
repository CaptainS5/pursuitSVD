% FUNCTION to find pursuit onset by detecting direction change in x/y
% pursuit traces; requires changeDetect.m, evalPWL.m, and ms2frames.m

% history
% ancient past  MS created SOCCHANGE probably in C
% 23-02-09      MS checked and corrected SOCCHANGE
% 07-2012       JE edited socchange.m
% 05-2014       JF edited and renamed function to findPursuit.m
% 13-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% 12-09-202     JF adapted for PD analysis
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
% output: pursuit --> structure containing info about pursuit onset

function [pursuit] = findPursuit(trial)

if trial.target.onset > 50
    startTime = trial.target.onset-50; % when should we start looking for pursuit onset
    endTime = trial.target.onset+200; % this means we stop searching for pursuit onset 250 ms after stimulus onset
else
    startTime = trial.target.onset;
    endTime = trial.target.onset + 250;
end

% x-value: TIME

% this is basically saying there is no pursuit

time = startTime:endTime;
fixationInterval = max([trial.target.onset 151]); % chose an interval before stimulus onset that
% we will use as fixation window; needs to be at least 201 ms
fix_x = mean(trial.eye.DX_filt(trial.target.onset-ms2frames(fixationInterval-50):trial.target.onset-ms2frames(fixationInterval-100)));
fix_y = mean(trial.eye.DY_filt(trial.target.onset-ms2frames(fixationInterval-50):trial.target.onset-ms2frames(fixationInterval-100)));

% 2. calculate 2D vector relative to fixation position
dataxy_tmp = sqrt( (trial.eye.DX_filt-fix_x).^2 + (trial.eye.DY_filt-fix_y).^2 );
XY = dataxy_tmp(time);
% run changeDetect.m
if any(isnan(XY))
    pursuit.onset = NaN;
else
    [cx,cy,ly,ry] = changeDetect(time,XY);
    pursuit.onset = round(cx);
end

end