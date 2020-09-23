function [trial] = readoutTrialPursuit(ascFile, eyeData, currentSubject, target, log, task)

if strcmp(task, 'smoothPursuit')
    trial.number = str2double(ascFile(end-5:end-4));
elseif strcmp(task, 'predictivePursuit')
    trial.number = str2double(ascFile(end-6:end-4));
end
name = evalin('base', 'name');
%% get eyeData for this trial
trial.eye.X = eyeData.X;
trial.eye.Y = eyeData.Y;

trial.eye.DX = eyeData.DX;
trial.eye.DY = eyeData.DY;

trial.eye.DDX = eyeData.DDX;
trial.eye.DDY = eyeData.DDY;

trial.eye.DX_filt = eyeData.DX_filt;
trial.eye.DY_filt = eyeData.DY_filt;

trial.eye.DDX_filt = eyeData.DDX_filt;
trial.eye.DDY_filt = eyeData.DDY_filt;

trial.eye.DDDX = eyeData.DDDX;
trial.eye.DDDY = eyeData.DDDY;

if strcmp(name, 'smoothPursuit')
    if xor(abs(mean(eyeData.X_filt(1:target.onset))) > 2, abs(mean(eyeData.Y_filt(1:target.onset))) > 2)
        trial.eye.X_offset = eyeData.X_filt(target.onset);
        trial.eye.Y_offset = eyeData.Y_filt(target.onset);
    else
        trial.eye.X_offset = mean(eyeData.X_filt(1:target.onset));
        trial.eye.Y_offset = mean(eyeData.Y_filt(1:target.onset));
    end
end

trial.eye.X_filt = eyeData.X_filt;%-trial.eye.X_offset;
trial.eye.Y_filt = eyeData.Y_filt;%- trial.eye.Y_offset;

%% read log info   
trial.log.subject = currentSubject;
trial.length = length(eyeData.X_filt);

%% store target info

if strcmp(name, 'smoothPursuit')
    trial.target.onset = target.onset;
    trial.target.offset = target.offset;
    trial.target.X = target.Xdeg;
    trial.target.Y = target.Ydeg;
    trial.target.Xvel = target.Xvel;
    trial.target.Yvel = target.Yvel;
    trial.target.Xpix = target.Xpixel;
    trial.target.Ypis = target.Ypixel;
    trial.target.speed = ceil(max(sqrt(trial.target.Xvel.^2+trial.target.Yvel.^2)));
    trial.target.maxima = target.cycle.maxima;
    trial.target.minima = target.cycle.minima;
    trial.target.crossings = target.cycle.crossing;
elseif strcmp(name, 'predictivePursuit')
    trial.target.onset = target.onset;
    trial.target.offset = target.offset;
    trial.target.X = target.Xdeg;
    trial.target.Y = target.Ydeg;
    trial.target.Xvel = target.Xvel;
    trial.target.Yvel = target.Yvel;
    trial.target.Xpix = target.Xpxl;
    trial.target.Ypix = target.Ypxl;
    trial.target.speed = ceil(max(sqrt(trial.target.Xvel.^2+trial.target.Yvel.^2)));
    
    blankStartFrames = ms2frames(log.blank(1)*1000); % from target onset
    blankEndFrames = ms2frames(log.blank(2)*1000);
    trial.log.blankStart = target.onset+blankStartFrames;
    trial.log.blankEnd = target.onset+blankEndFrames;
    if isempty(find(log.noBlank==trial.number))
        trial.log.blank=1;
    else
        trial.log.blank=0;
    end
end

end