% plot velocity traces for predictive pursuit, just have a glance
% also generate csv file for further plotting in R
initializeParas;

groupName = {'baselineAll', 'blankAll'}; %, 'baselineSlow', 'baselineMedium', 'baselineFast', 'blanSlow', 'blankMedium', 'blankFast'};
groupN = [1, 2]; % corresponds to the listed rules... can choose multiple, just list as a vector
% when choosing multiple groupN, will plot each group rule in one figure

% choose which plot to look at now
individualPlots = 0;
averagedPlots = 1;
textFontSize = 8;

%% align target onset, frame data for all trials; upsampling here
for subN = 1:size(eyeTrialData.sub, 1)
    load([analysisFolder, '\eyeTrialDataSub_' eyeTrialData.sub{subN} '.mat']);
    sampleRateSub = max(eyeTrialData.sampleRate(subN, :));
    
    frameLength(subN) = nanmax(eyeTrialData.frameLog.targetOff(subN, :)-eyeTrialData.frameLog.targetOn(subN, :))+1; % only plot until target offset
    if sampleRateSub==500 % upsampling...
        frameLength(subN) = frameLength(subN)*2;
    end
    lengthT = size(eyeTrialDataSub.trial, 2);
    frames{subN} = NaN(lengthT, frameLength(subN));
    
    for trialN = 1:lengthT
        if eyeTrialData.errorStatus(subN, trialN)==0 || eyeTrialData.errorStatus(subN, trialN)==-5
            startI = eyeTrialData.frameLog.targetOn(subN, trialN);
            endI = eyeTrialData.frameLog.targetOff(subN, trialN);
            eyeTrace = eyeTrialDataSub.trial{1, trialN}.DX_interpolSac(startI:endI);
            if sampleRateSub<1000 % upsampling...
                eyeTrace = interp1(eyeTrialDataSub.trial{1, trialN}.timeStamp(startI:endI), eyeTrace, ...
                    eyeTrialDataSub.trial{1, trialN}.timeStamp(startI):eyeTrialDataSub.trial{1, trialN}.timeStamp(endI));
            end
            frames{subN}(trialN, 1:length(eyeTrace)) = eyeTrace;
        end
    end
end
maxFrameLength = max(frameLength);

% plotting parameters
minFrameLength = min(frameLength);
sampleRate = 1000;
framePerSec = 1/sampleRate;
timePoints = [1:minFrameLength]*framePerSec*1000;

%% calculate mean traces
for ii = 1:length(groupN)
    [indiMean{ii}, allMean{ii}, trialNumber{ii}] = getMeanTraces(eyeTrialData, frames, frameLength, speedCons, healthCons, groupN(ii));
end

%% Draw velocity trace plots
for ii = 1:length(groupN)
    % plot mean traces in all probabilities for each participant
    if individualPlots
        switch groupN(ii)
            case 1
                yRange = [-15 15]; % individual context trials
            case 2
                yRange = [-15 15]; % individual pereptual trials
                %             case 3
                %                 yRange = [-7 7];
                %             case 4
                %                 yRange = [-7 7];
                %             case 5
                %                 yRange = [-4 4];
                %             case 6
                %                 yRange = [-7 7];
                %             case 7
                %                 yRange = [-7 7];
                %             case 8
                %                 yRange = [-7 7];
        end
        
        for subN = 1:size(eyeTrialData.sub, 1)
            figure
            for speedN = 1:size(speedCons, 2)
                plot(timePoints, indiMean{ii}{speedN}.left(subN, 1:minFrameLength), '--', 'color', colorSpeed(speedN, :)); %, 'LineWidth', 1)
%                 text(timePoints(end), indiMean{ii}{speedN}.left(subN, end), num2str(trialNumber{ii}{speedN}.left(subN, 1)), 'color', colorSpeed(speedN, :), 'FontSize',textFontSize)
                hold on
                p{speedN} = plot(timePoints, indiMean{ii}{speedN}.right(subN, 1:minFrameLength), 'color', colorSpeed(speedN, :)); %, 'LineWidth', 1);
%                 text(timePoints(end), indiMean{ii}{speedN}.right(subN, end), num2str(trialNumber{ii}{speedN}.right(subN, 1)), 'color', colorSpeed(speedN, :), 'FontSize',textFontSize)
            end
            % blank start and end
            line([600 600], [min(yRange) max(yRange)],'Color','b','LineStyle','--')
            line([1400 1400], [min(yRange) max(yRange)],'Color','b','LineStyle','--')
%             line([50 50], [min(yRange) max(yRange)],'Color','r','LineStyle','--')
            legend([p{:}], speedNames, 'Location', 'NorthWest')
            if eyeTrialData.group(subN, 1)==0
                healthSub = 'control';
            else
                healthSub = 'patient';
            end
            title([groupName{groupN(ii)}, ' ', eyeTrialData.sub{subN}, ' ', healthSub])
            xlabel('Time (ms)')
            ylabel('Horizontal eye velocity (deg/s)')
            xlim([1 minFrameLength])
            ylim(yRange)
            box off
            saveas(gcf, [velTraceFolder, '\individuals\velTrace_l&r_', groupName{groupN(ii)}, '_' eyeTrialData.sub{subN} '.pdf'])
        end
    end
    
    % plot mean traces of all participants in all probabilities
    if averagedPlots
        switch groupN(ii)
            case 1
                yRange = [-15 15]; %
            case 2
                yRange = [-15 15]; % average pereptual trials
                %             case 3
                %                 yRange = [-4 4];
                %             case 4
                %                 yRange = [-4 4];
                %             case 5
                %                 yRange = [-4 4];
                %             case 6
                %                 yRange = [-4 4];
                %             case 7
                %                 yRange = [-4 4];
                %             case 8
                %                 yRange = [-4 4];
        end
        
        for healthN = 1:2 % plot average of patients and controls separately
            figure
            for speedN = 1:size(speedCons, 2)
                plot(timePoints, allMean{ii}{speedN, healthN}.left, '--', 'color', colorSpeed(speedN, :)); %, 'LineWidth', 1)
                hold on
                p{speedN} = plot(timePoints, allMean{ii}{speedN, healthN}.right, 'color', colorSpeed(speedN, :)); %, 'LineWidth', 1);
            end
            line([600 600], [min(yRange) max(yRange)],'Color','b','LineStyle','--')
            line([1400 1400], [min(yRange) max(yRange)],'Color','b','LineStyle','--')
            legend([p{:}], speedNames, 'Location', 'NorthWest')
            title([groupName{groupN(ii)}, ' ', healthNames{healthN}])
            xlabel('Time (ms)')
            ylabel('Horizontal eye velocity (deg/s)')
            xlim([1 minFrameLength])
            ylim(yRange)
            box off
            saveas(gcf, [velTraceFolder, '\velTrace_l&r_', groupName{groupN(ii)}, '_', healthNames{healthN}, '_all.pdf'])
        end
    end
end

%% generate csv files, each file for one probability condition
% % each row is the mean velocity trace of one participant
% % use the min frame length--the lengeth where all participants have
% % valid data points
% % cd(RsaveFolder)
% % averaged traces
% for ii = 1:length(groupN)
%     for probNmerged = 1:probTotalN
%         velTAverageSub = [];
%         for binN = 1:2
%             if binN==1
%                 dataTemp = indiMean{ii}{probNmerged}.left(:, (maxFrameLength-minFrameLength+1):end);
%             else
%                 dataTemp = indiMean{ii}{probNmerged}.right(:, (maxFrameLength-minFrameLength+1):end);
%             end
%             for subN = 1:size(eyeTrialData.sub, 2)
%                 velTAverageSub((binN-1)*length(eyeTrialData.sub)+subN, :) = dataTemp(subN, :);
%             end
%         end
%         csvwrite(['velocityTrace_' groupName{groupN(ii)} '_exp' num2str(expN) '_prob' num2str(probCons(probNmerged+probTotalN-1)), '.csv'], velTAverageSub)
%     end
% end

%%
function [indiMean, allMean, trialNumber] = getMeanTraces(eyeTrialData, frames, frameLength, speedCons, healthCons, groupN)
% calculate mean traces
% indiMean: each row is one participant
% allMean: averaged across participants
% trialNumber: corresponds to indiMean, the trial number for each element

maxFrameLength = max(frameLength);
minFrameLength = min(frameLength);

for speedN = 1:size(speedCons, 2)
    % first initialize; if a participant doesn't have the corresponding
    % prob condition, then the values remain NaN and will be ignored later
    indiMean{speedN}.left = NaN(length(eyeTrialData.sub), maxFrameLength);
    indiMean{speedN}.right = NaN(length(eyeTrialData.sub), maxFrameLength);
    
    for subN = 1:size(eyeTrialData.sub, 1)
        tempLength = frameLength(subN);
        switch groupN
            case 1 % baseline all
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==-5 & eyeTrialData.speed(subN, :)==speedCons(speedN) ...
                    & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.targetDir(subN, :)==-1);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==-5 & eyeTrialData.speed(subN, :)==speedCons(speedN) ...
                    & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.targetDir(subN, :)==1);
            case 2 % blank all
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.speed(subN, :)==speedCons(speedN) ...
                    & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.targetDir(subN, :)==-1);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.speed(subN, :)==speedCons(speedN) ...
                    & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.targetDir(subN, :)==1);
                %             case 3 % baseline slow
                %                 leftIdx = find(eyeTrialData.errorStatus(subN, :)==-5 & eyeTrialData.speed(subN, :)==speedCons(speedN) & eyeTrialData.trialType(subN, :)==0);
                %                 rightIdx = find(eyeTrialData.errorStatus(subN, :)==-5 & eyeTrialData.speed(subN, :)==speedCons(speedN) & eyeTrialData.trialType(subN, :)==0);
                %             case 4 % baseline medium
                %                 leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0);
                %                 rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0);
                %         case 5 % baseline fast
                %             leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 ...
                %                 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==0);
                %             rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 ...
                %                 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==1);
                %         case 6 % blank slow
                %             leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 ...
                %                 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==0);
                %             rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 ...
                %                 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==1);
                %         case 7 % blank medium
                %             leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)==0 ...
                %                 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==0);
                %             rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)==0 ...
                %                 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==1);
                %         case 8 % blank fast
                %             leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                %                 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==0);
                %             rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                %                 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==1);
        end
        
        % individual mean traces
        indiMean{speedN}.left(subN, 1:tempLength) = nanmean(frames{subN}(leftIdx, :), 1);
        indiMean{speedN}.right(subN, 1:tempLength) = nanmean(frames{subN}(rightIdx, :), 1);
        
        trialNumber{speedN}.left(subN, 1) = length(leftIdx);
        trialNumber{speedN}.right(subN, 1) = length(rightIdx);
    end
    
    % collapsed all participants
    for healthN = 1:2 % controls and patients separately
        idxT = find(eyeTrialData.group(:, 1)==healthCons(healthN)); 
        allMean{speedN, healthN}.left = nanmean(indiMean{speedN}.left(idxT, 1:minFrameLength), 1);
        allMean{speedN, healthN}.right = nanmean(indiMean{speedN}.right(idxT, 1:minFrameLength), 1);
    end
end
end