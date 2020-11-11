function [] = updatePlotsPursuit(trial, name)

startFrame = 1;
endFrame = length(trial.eye.X_filt);
green = [77 175 74]./255;

if strcmp(name, 'smoothPursuit')
    %% position over time
    subplot(2,1,1,'replace');
    axis([startFrame endFrame -10 10]);
    hold on;
    xlabel('Time(ms)', 'fontsize', 12);
    ylabel('Position (degree)', 'fontsize', 12);
    % plot eye and target position
    plot(startFrame:endFrame,trial.eye.X_filt(startFrame:endFrame),'Color', green);
    plot(startFrame:length(trial.target.X),trial.target.X(1:end),'Color', green, 'LineStyle', '--');
    plot(startFrame:endFrame,trial.eye.Y_filt(startFrame:endFrame),'b');
    plot(startFrame:length(trial.target.Y),trial.target.Y(1:end),'b', 'LineStyle', '--');
    legend('x eye', 'x target', 'y eye', 'y target');
    % add saccades
    if sum(trial.target.X) == 0
        plot(trial.saccades.onsets,trial.eye.Y_filt(trial.saccades.onsets),'g*');
        plot(trial.saccades.offsets,trial.eye.Y_filt(trial.saccades.offsets),'m*');
    elseif sum(trial.target.Y) == 0
        plot(trial.saccades.onsets,trial.eye.X_filt(trial.saccades.onsets),'g*');
        plot(trial.saccades.offsets,trial.eye.X_filt(trial.saccades.offsets),'m*');
    end
    % indicate blinks
    for i = 1:length(trial.saccades.blinkOnsets)
        line([trial.saccades.blinkOnsets(i) trial.saccades.blinkOffsets(i)], [0 0],'Color','r', 'LineWidth', 2);
    end
    % indicate target on and offset
    line([trial.target.onset trial.target.onset], [-10 10],'Color','k','LineStyle',':');
    line([trial.target.offset trial.target.offset], [-10 10],'Color','k','LineStyle',':');
        
    %% velocity over time
    subplot(2,1,2,'replace');
    axis([startFrame endFrame -25 25]);
    hold on;
    xlabel('Time(ms)', 'fontsize', 12);
    ylabel('Speed (degree/second)', 'fontsize', 12);
    % plot eye and target velocity
    plot(startFrame:endFrame,trial.eye.DX_filt(startFrame:endFrame),'Color', green);
    plot(startFrame:length(trial.target.Xvel),trial.target.Xvel(1:end),'Color', green, 'LineStyle', '--');
    plot(startFrame:endFrame,trial.eye.DY_filt(startFrame:endFrame),'b');
    plot(startFrame:length(trial.target.Yvel),trial.target.Yvel(1:end),'b', 'LineStyle', '--');
    % add saccades
    if sum(trial.target.X) == 0
        plot(trial.saccades.onsets,trial.eye.DY_filt(trial.saccades.onsets),'g*');
        plot(trial.saccades.offsets,trial.eye.DY_filt(trial.saccades.offsets),'m*');
    elseif sum(trial.target.Y) == 0
        plot(trial.saccades.onsets,trial.eye.DX_filt(trial.saccades.onsets),'g*');
        plot(trial.saccades.offsets,trial.eye.DX_filt(trial.saccades.offsets),'m*');
    end
    % indicate blinks
    for i = 1:length(trial.saccades.blinkOnsets)
        line([trial.saccades.blinkOnsets(i) trial.saccades.blinkOffsets(i)], [0 0],'Color','r', 'LineWidth', 2);
    end
    % indicate target on and offset
    line([trial.target.onset trial.target.onset], [-25 25],'Color','k','LineStyle',':');
    line([trial.target.offset trial.target.offset], [-25 25],'Color','k','LineStyle',':');
    
elseif strcmp(name, 'predictivePursuit')
    cutOffTime = 150; % ms
    %% position over time
    yRangePos = [-15 15];
    subplot(2,2,1,'replace');
    axis([startFrame endFrame yRangePos]);
    hold on;
    xlabel('Time(ms)', 'fontsize', 12);
    ylabel('Position (degree)', 'fontsize', 12);
    % plot eye and target position
    plot(startFrame:endFrame,trial.eye.X_filt(startFrame:endFrame),'Color', green);
    plot(startFrame:length(trial.target.X),trial.target.X(1:end),'Color', green, 'LineStyle', '--');
    plot(startFrame:endFrame,trial.eye.Y_filt(startFrame:endFrame),'b');
    plot(startFrame:length(trial.target.Y),trial.target.Y(1:end),'b', 'LineStyle', '--');
    legend({'x eye', 'x target', 'y eye', 'y target'}, 'location', 'best');
    % add saccades
    if nansum(trial.target.X) == 0
        plot(trial.saccades.Y.onsets,trial.eye.Y_filt(trial.saccades.Y.onsets),'go');
        plot(trial.saccades.Y.offsets,trial.eye.Y_filt(trial.saccades.Y.offsets),'m*');
    elseif nansum(trial.target.Y) == 0
        plot(trial.saccades.X.onsets,trial.eye.X_filt(trial.saccades.X.onsets),'go');
        plot(trial.saccades.X.offsets,trial.eye.X_filt(trial.saccades.X.offsets),'m*');
    end
    % indicate blinks
    for i = 1:length(trial.saccades.blinkOnsets)
        line([trial.saccades.blinkOnsets(i) trial.saccades.blinkOffsets(i)], [0 0],'Color','r', 'LineWidth', 2);
    end
    % indicate target on and offset
    line([trial.target.onset trial.target.onset], yRangePos,'Color','k','LineStyle','--');
    line([trial.target.offset trial.target.offset], yRangePos,'Color','k','LineStyle','--');
    line([trial.target.offset-cutOffTime trial.target.offset-cutOffTime], yRangePos,'Color','k','LineStyle','-.');
    % indicate blank start and end
    if trial.log.blank==1
        line([trial.log.blankStart trial.log.blankStart], yRangePos,'Color','b','LineStyle','--');
        line([trial.log.blankEnd trial.log.blankEnd], yRangePos,'Color','b','LineStyle','--');
    end
        
    %% velocity over time
    yRangeVel = [-25 25];
    subplot(2,2,2,'replace');
    axis([startFrame endFrame yRangeVel]);
    hold on;
    xlabel('Time(ms)', 'fontsize', 12);
    ylabel('Speed (degree/second)', 'fontsize', 12);
    % plot eye and target velocity
    plot(startFrame:endFrame,trial.eye.DX_filt(startFrame:endFrame),'Color', green);
    plot(startFrame:length(trial.target.Xvel),trial.target.Xvel(1:end),'Color', green, 'LineStyle', '--');
    plot(startFrame:endFrame,trial.eye.DY_filt(startFrame:endFrame),'b');
    plot(startFrame:length(trial.target.Yvel),trial.target.Yvel(1:end),'b', 'LineStyle', '--');
    % add saccades
    if nansum(trial.target.X) == 0
        plot(trial.saccades.Y.onsets,trial.eye.DY_filt(trial.saccades.Y.onsets),'go');
        plot(trial.saccades.Y.offsets,trial.eye.DY_filt(trial.saccades.Y.offsets),'m*');
    elseif nansum(trial.target.Y) == 0
        plot(trial.saccades.X.onsets,trial.eye.DX_filt(trial.saccades.X.onsets),'go');
        plot(trial.saccades.X.offsets,trial.eye.DX_filt(trial.saccades.X.offsets),'m*');
    end
    % indicate blinks
    for i = 1:length(trial.saccades.blinkOnsets)
        line([trial.saccades.blinkOnsets(i) trial.saccades.blinkOffsets(i)], [0 0],'Color','r', 'LineWidth', 2);
    end
    % indicate target on and offset
    line([trial.target.onset trial.target.onset], yRangeVel,'Color','k','LineStyle','--');
    line([trial.target.offset trial.target.offset], yRangeVel,'Color','k','LineStyle','--');
    line([trial.target.offset-cutOffTime trial.target.offset-cutOffTime], yRangeVel,'Color','k','LineStyle','-.');
    % indicate blank start and end
    if trial.log.blank==1
        line([trial.log.blankStart trial.log.blankStart], yRangeVel,'Color','b','LineStyle','--');
        line([trial.log.blankEnd trial.log.blankEnd], yRangeVel,'Color','b','LineStyle','--');
    end
    
    %% acceleration over time
    yRangeAcc = [-1000 1000];
    subplot(2,2,3,'replace');
    axis([startFrame endFrame yRangeAcc]);
    hold on;
    xlabel('Time(ms)', 'fontsize', 12);
    ylabel('Acceleration (degree/second^2)', 'fontsize', 12);
    % plot eye and target velocity
    plot(startFrame:endFrame,trial.eye.DDX_filt(startFrame:endFrame),'Color', green);
    plot(startFrame:endFrame,trial.eye.DDY_filt(startFrame:endFrame),'b');
    % add saccades
    if nansum(trial.target.X) == 0
        plot(trial.saccades.Y.onsets,trial.eye.DDY_filt(trial.saccades.Y.onsets),'go');
        plot(trial.saccades.Y.offsets,trial.eye.DDY_filt(trial.saccades.Y.offsets),'m*');
    elseif nansum(trial.target.Y) == 0
        plot(trial.saccades.X.onsets,trial.eye.DDX_filt(trial.saccades.X.onsets),'go');
        plot(trial.saccades.X.offsets,trial.eye.DDX_filt(trial.saccades.X.offsets),'m*');
    end
    % indicate blinks
    for i = 1:length(trial.saccades.blinkOnsets)
        line([trial.saccades.blinkOnsets(i) trial.saccades.blinkOffsets(i)], [0 0],'Color','r', 'LineWidth', 2);
    end
    % indicate target on and offset
    line([trial.target.onset trial.target.onset], yRangeAcc, 'Color','k','LineStyle','--');
    line([trial.target.offset trial.target.offset], yRangeAcc,'Color','k','LineStyle','--');
    % indicate blank start and end
    if trial.log.blank==1
        line([trial.log.blankStart trial.log.blankStart], yRangeAcc,'Color','b','LineStyle','--');
        line([trial.log.blankEnd trial.log.blankEnd], yRangeAcc,'Color','b','LineStyle','--');
    end
    
    %% jerk over time
    yRangeJerk = [-30000 30000];
    subplot(2,2,4,'replace');
    axis([startFrame endFrame yRangeJerk]);
    hold on;
    xlabel('Time(ms)', 'fontsize', 12);
    ylabel('Jerk (degree/second^3)', 'fontsize', 12);
    % plot eye and target velocity
    plot(startFrame:endFrame,trial.eye.DDDX(startFrame:endFrame),'Color', green);
    plot(startFrame:endFrame,trial.eye.DDDY(startFrame:endFrame),'b');
    % add saccades
    if nansum(trial.target.X) == 0
        plot(trial.saccades.Y.onsets,trial.eye.DDDY(trial.saccades.Y.onsets),'go');
        plot(trial.saccades.Y.offsets,trial.eye.DDDY(trial.saccades.Y.offsets),'m*');
    elseif nansum(trial.target.Y) == 0
        plot(trial.saccades.X.onsets,trial.eye.DDDX(trial.saccades.X.onsets),'go');
        plot(trial.saccades.X.offsets,trial.eye.DDDX(trial.saccades.X.offsets),'m*');
    end
    % indicate blinks
    for i = 1:length(trial.saccades.blinkOnsets)
        line([trial.saccades.blinkOnsets(i) trial.saccades.blinkOffsets(i)], [0 0],'Color','r', 'LineWidth', 2);
    end
    % indicate target on and offset
    line([trial.target.onset trial.target.onset], yRangeJerk, 'Color','k','LineStyle','--');
    line([trial.target.offset trial.target.offset], yRangeJerk,'Color','k','LineStyle','--');
    % indicate blank start and end
    if trial.log.blank==1
        line([trial.log.blankStart trial.log.blankStart], yRangeJerk,'Color','b','LineStyle','--');
        line([trial.log.blankEnd trial.log.blankEnd], yRangeJerk,'Color','b','LineStyle','--');
    end
    
end
end