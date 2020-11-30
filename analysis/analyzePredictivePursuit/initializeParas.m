% use eyeTrialData to do analysis, initialize parameters for the predictive
% pursuit task

clear all; close all; clc

load(['eyeTrialData_all.mat']);
% to get the speeds... temporarily exclude one participant having weird
% speeds--A049, patient; need to go back later to see what was wrong...
for subN = 1:size(eyeTrialData.sub, 1)
    speedsTmp = eyeTrialData.speed(subN, :);
    speedsTmp(isnan(speedsTmp)) = [];
    speedsSub(subN, :) = unique(speedsTmp);
end
eyeTrialData.speed(abs(eyeTrialData.speed-6)<2) = 6;
eyeTrialData.speed(abs(eyeTrialData.speed-10)<2) = 10;
eyeTrialData.speed(abs(eyeTrialData.speed-14)<2) = 14;
speedCons = [6, 10, 14];
speedNames = {'speed 6', 'speed 10', 'speed 14'};
 
analysisFolder = pwd;
velTraceFolder = ['..\velocityTraces'];

healthCons = [0, 1];
healthNames = {'controls', 'patients'};

% % for plotting
% for t = 1:size(nameSets{1}, 2) % individual color for scatter plots, can do 10 people
%     if t<=2
%         markerC(t, :) = (t+2)/4*[77 255 202]/255;
%     elseif t<=4
%         markerC(t, :) = (t)/4*[70 95 232]/255;
%     elseif t<=6
%         markerC(t, :) = (t-2)/4*[232 123 70]/255;
%     elseif t<=8
%         markerC(t, :) = (t-4)/4*[255 231 108]/255;
%     elseif t<=10
%         markerC(t, :) = (t-6)/4*[255 90 255]/255;
%     end
% end
colorSpeed = [8,48,107;66,146,198;198,219,239]/255; % all blue hues
% colorProb = [232 113 240; 15 204 255; 255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability