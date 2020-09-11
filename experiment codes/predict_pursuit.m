function predict_pursuit
%
% ___________________________________________________________________
%
% Estimates acuity thresholds using a staircase procedure for stimuli
% moving at various velocities and presentation durations
% 
% Dimitrios Palidis, 2015, adapted from SR-Research example code
% ___________________________________________________________________

% HISTORY
%

%% SET Paths

subDir='\Users\Display\Documents\MATLAB\SmoothOp\predict_pursuit_data\'; %we will create an output folder here


%% First calculate the number of pixels per degree of angle
sWidth= .4025; %input the width of the screen in m
sHeight= .3025;
distance= .79; %input distance from screen in m
[degreePixelsV, degreePixelsH]=visualAngle(sWidth, sHeight, distance); % this is pixels/degree in both directions

%% Set parameters of stimuli
blank=[.600;1.400];
XedgeBorder=1; %in degrees of visual angle
rampDur=.2;
trialsPerCond=20;
speeds=[6 10 14]; %STAT
 
directions=[0 1];
conditions1=createConditionMatrix( directions,speeds, 1);
conditions1=conditions1(:,randperm(size(conditions1,2)));
fixationTime=.5; % minimum duration of fixation cross before stimulus, 
fixJit=.5; %max of additional random fixation time 
blockSize=80; % trials per block
%% do conversions to pixels
XedgePix=round(XedgeBorder*degreePixelsH);
conditions=conditions1;
conditions(2,:)=round(conditions(2,:)*degreePixelsH);
%% calculate durations 
Pix_SS = get(0,'screensize'); %get pixels
[maxV,mi]=max(conditions(2,:)); %find the fastest one
%duration=(Pix_SS(3)-2*XedgePix)/maxV; % duration= screenwidth/speed (all durations equal length of time it takes longest one to traverse screen
duration=2;
%% initialize stuff
% ntrials=50; %for randomization, this should be fixed
% directions=[zeros(1,ntrials/2) ones(1,ntrials/2)];
% directions= directions(randperm(size(directions,2))); 
% leftRight=[zeros(1,ntrials/2) ones(1,ntrials/2)];
% leftRight= leftRight(randperm(size(leftRight,2)));

if ~IsOctave
    commandwindow;
else
    more off;
end



dummymode = 0;

try
    %%%%%%%%%%
    % STEP 1 %
    %%%%%%%%%%
    
    % Added a dialog box to set your own EDF file name before opening
    % experiment graphics. Make sure the entered EDF file name is 1 to 8
    % characters in length and only numbers or letters are allowed.
    
    [edfFile,outputDir] = inputCreateDirectory(subDir);
    
    fileID = fopen(strcat(outputDir,'\','SLog_',edfFile),'w');
    fprintf(fileID,'%4s %4s %8s %7s %3s \n','trial','velocity','duration','direction','blankStart','blankEnd'); % hmmm.... bug here= =
    %%%%%%%%%%
    % STEP 2 %
    %%%%%%%%%%
    
    % Open a graphics window on the main screen
    % using the PsychToolbox's Screen function.
    screenNumber=max(Screen('Screens'));
    [window, wRect]=Screen('OpenWindow', screenNumber, 0,[],32,2); %#ok<*NASGU>
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [winWidth, winHeight] = WindowSize(window);
    Screen('TextSize', window,100);
    
    % define center
    center=[winWidth/2 winHeight/2];
 
    %%%%%%%%%%
    % STEP 3 %
    %%%%%%%%%%
    
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    
    el=EyelinkInitDefaults(window);
    
    % We are changing calibration to match task background and target
    % this eliminates affects of changes in luminosity between screens
    % no sound and smaller targets
    el.targetbeep = 0;
    el.backgroundcolour = WhiteIndex(el.window);
    el.calibrationtargetcolour= [0 0 0];
    % for lower resolutions you might have to play around with these values
    % a little. If you would like to draw larger targets on lower res
    % settings please edit PsychEyelinkDispatchCallback.m and see comments
    % in the EyelinkDrawCalibrationTarget function
    el.calibrationtargetsize= 2;
    el.calibrationtargetwidth=0.5;
    % call this function for changes to the el calibration structure to take
    % affect
    EyelinkUpdateDefaults(el);
    tool = tool_functions(el);
    %%%%%%%%%%
    % STEP 4 %
    %%%%%%%%%%
    
    % Initialization of the connection with the Eyelink tracker
    % exit program if this fails.
    
    if ~EyelinkInit(dummymode)
        %fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    %%%%%%%%%%
    % STEP 5 %
    %%%%%%%%%%
    
    % SET UP TRACKER CONFIGURATION
    
    Eyelink('command', 'add_file_preamble_text ''Recorded by DVA1.0''');
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    
    % This command is crucial to map the gaze positions from the tracker to
    % screen pixel positions to determine fixation
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
    % set calibration type.
    Eyelink('command', 'calibration_type = HV9');
    Eyelink('command', 'generate_default_targets = YES');
    
    % STEP 5.1 retrieve tracker version and tracker software version
    [v,vs] = Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    vsn = regexp(vs,'\d','match');
    
    if v == 3 && str2double(vsn{1}) == 4 % if EL 1000 and tracker version 4.xx
        
       % remote mode possible add HTARGET ( head target)
        Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT,HTARGET');
        % set link data (used for gaze cursor)
        Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET');
    else
        Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
        % set link data (used for gaze cursor)
        Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    end
    
    % allow to use the big button on the eyelink gamepad to accept the
    % calibration/drift correction target
    Eyelink('command', 'button_function 5 "accept_target_fixation"');
    
       
    %%%%%%%%%%
    % STEP 6 %
    %%%%%%%%%%
    
    % Hide the mouse cursor
    Screen('HideCursorHelper', window);
    % enter Eyetracker camera setup mode, calibration and validation
    EyelinkDoTrackerSetup(el);
    
    %%%%%%%%%%
    % STEP 7 %
    %%%%%%%%%%
    
    % Now starts running individual trials
    % You can keep the rest of the code except for the implementation
    % of graphics and event monitoring
    % Each trial should have a pair of "StartRecording" and "StopRecording"
    % calls as well integration messages to the data file (message to mark
    % the time of critical events and the image/interest area/condition
    % information for the trial)
    
    %% BEGIN TRIALS
    
    % Initialize counters and data storage
    i=1; %trial counter
    ii=ones(1,size(conditions,1)); %condition counter
    correct=zeros(1,size(conditions,1)); %track correct in a row dor each condition
    ascending=zeros(1,size(conditions,1)); % tracks if we are ascending staircase for each condition,1 means ascending 0 descending
    ascending(:)=3; %start out neither ascending or descending
    
    for j=1:length(conditions)
    
        
        catchTrials=sort(ceil(rand(1,3)*(trialsPerCond-3))+5); %random trials between 6 and number of trials-3 (always have at least 3 test trials after a catch trial)
        
        while any( (catchTrials(2:end) - catchTrials(1:(end-1))) <=3) % make sure there is at least 3 test trials between the 'random' catch trials
            catchTrials=sort(ceil(rand(1,3)*(trialsPerCond-3))+5); 
            
        end
        noBlank= [1 2 catchTrials]; %indexes without any blank
        
        for k=1:trialsPerCond+5
            
            if ismember(k,noBlank) %if this trial is a catchtrial
                catchTr=1;
            else
                catchTr=0;
            end
            
            disp(strcat(num2str(i),'begin trial'))
            % open file to record data to
            trnum=sprintf('%3.3d',i);
            trialFile=strcat(edfFile,'_',trnum); %name of edf with trail index
            res = Eyelink('Openfile',trialFile);
            if res~=0
                %fprintf('Cannot create EDF file ''%s'' ', edffilename);
                cleanup;
                return;
            end
            disp(strcat(num2str(i),'file open'))
            % make sure we're still connected.
            if Eyelink('IsConnected')~=1 && ~dummymode
                cleanup;
                return;
            end    

            Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

           

            speed=conditions(2,j);


            % STEP 7.1
            % Sending a 'TRIALID' message to mark the start of a trial in Data
            % Viewer.  This is different than the start of recording message
            % START that is logged when the trial recording begins. The viewer
            %will not parse any messages, events, or samples, that exist in
            % the data file prior to this message.
            Eyelink('Message', 'TRIALID %d', i);

            % This supplies the title at the bottom of the eyetracker display
            Eyelink('command', 'record_status_message "TRIAL %d/%d"', i,8);
            % Before recording, we place reference graphics on the host display
            % Must be in offline mode to transfer image to Host PC
            Eyelink('Command', 'set_idle_mode');
            % clear tracker display and draw box at center
            Eyelink('Command', 'clear_screen %d', 0);


            if conditions(1,j)==1 %Set cross position
                cross=[XedgePix+maxV*rampDur center(2)];
            else
                cross=[winWidth-XedgePix-maxV*rampDur center(2)];
            end

            if conditions(1,j)==1 % set starting position for the ball
                xo =  cross(1)-speed*rampDur;          
                yo =  center(2);
            else
                xo =  cross(1)+speed*rampDur; 
                yo =  center(2);
            end        

            x=xo;
            y=yo;

            WaitSecs(0.1);
            % STEP 7.2
            % Do a drift correction at the beginning of each trial
            % Performing drift correction (checking) is optional for
            % EyeLink 1000 eye trackers. Drift correcting at different
            % locations x and y depending on where the ball will start
            % we change the location of the drift correction to match that of
            % the target start position
            % Note drift correction does not accept fractionals in PTB!
            EyelinkDoDriftCorrection(el,round(cross(1)),round(cross(2)),1);

            % STEP 7.3
            % start recording eye position (preceded by a short pause so that
            % the tracker can finish the mode transition)
            % The paramerters for the 'StartRecording' call controls the
            % file_samples, file_events, link_samples, link_events availability
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.05);
            Eyelink('StartRecording');
            % record a few samples before we actually start displaying
            % otherwise you may lose a few msec of data
            WaitSecs(0.1);

            % get eye that's tracked
            eye_used = Eyelink('EyeAvailable');


            %%%display fixation cross for fixationtime seconds

            %Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('FillRect', window, el.backgroundcolour);
            Screen('DrawLines',window,[-10 10 0 0; 0 0 -10 10],1,[0,0,0],cross);
            Screen('Flip', window);
            WaitSecs(fixationTime);
            jit=fixJit*rand;
            WaitSecs(jit);
            trialTime = GetSecs + duration; 
            sttime = GetSecs;
    %         stim_onseted=0;

            while GetSecs < trialTime

                % STEP 7.4
                % Prepare and show the screen.
                % Enable alpha blending with proper blend-function. We need it
                % for drawing of smoothed points:
                %Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('FillRect', window, el.backgroundcolour); 
                time = (GetSecs-sttime);
                pursuitTime=time;
                if (pursuitTime<=blank(1)) || (pursuitTime>=blank(2)) %if the we are not in blank interval
                   tool.draw_target_gaussian([x-center(1),y-center(2)],[0,0,0])
                elseif catchTr
                    tool.draw_target_gaussian([x-center(1),y-center(2)],[0,0,0])
                end

                Screen('Flip', window);
    %             if stim_onseted==0;
    %                 Eyelink('Message', 'Stim_onset');
    %                 stim_onset=1;
    %             end
                Eyelink('Message', 'SYNCTIME');
                % STEP 7.5
                % send the location of the target at each iteration so that
                % target can be displayed in Dataviewer
                Eyelink('message', '!V TARGET_POS TARG1 (%d, %d) 1 0',floor(x),floor(y));

                %y = y;
                if (conditions(1,j)==1)
                    x =  xo + speed*time;
                else
                    x =  xo - speed*time;
                end

            end

            % STEP 7.6
            % add 100 msec of data to catch final events and blank display
            Screen('FillRect', window, el.backgroundcolour);
            Screen('Flip', window);
            WaitSecs(0.1);
            Eyelink('StopRecording');

            % close and save edf file for trial
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.2);
            Eyelink('CloseFile');


            try
                %fprintf('Receiving data file ''%s''\n', edfFile );
                status=Eyelink('ReceiveFile',trialFile,outputDir,1);
                %status=Eyelink('ReceiveFile',trialFile,strcat(subDir,edfFile),'dest_is_path');
                %movefile(strcat(edfFile,num2str(i)),strcat(pwd,edfFile));
                if status > 0
                   % fprintf('ReceiveFile status %d\n', status);
                end
                if 2==exist(edfFile, 'file')
                    %fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
                end
            catch %#ok<*CTCH>
                %fprintf('Problem receiving data file ''%s''\n', edfFile );
            end
            disp(strcat(num2str(i),'recieved file'))

            %fprintf(fileID,'%1d %6d %1d %2d %5d',i, conditions1(trialCond,1), duration, gapsize(trialCond),directions(i));
            %fprintf(fileID,'%1d %6d %1d %2d %5d %10d %12d %9d \n',i, conditions1(trialCond), duration, gapsize(trialCond),directions(i),gapID(i), response, trialCorrect);

            Screen('FillRect', window, el.backgroundcolour);
            Screen('Flip', window);
            WaitSecs(1.2); % inter-trial-interval
           




            % STEP 7.7
            % Send out necessary integration messages for data analysis
            % See "Protocol for EyeLink Data to Viewer Integration-> Interest
            % Area Commands" section of the EyeLink Data Viewer User Manual
            % IMPORTANT! Don't send too many messages in a very short period of
            % time or the EyeLink tracker may not be able to write them all
            % to the EDF file.
            % Consider adding a short delay every few messages.
            WaitSecs(0.001);
            % Send messages to report trial condition information
            % Each message may be a pair of trial condition variable and its
            % corresponding value follwing the '!V TRIAL_VAR' token message
            % See "Protocol for EyeLink Data to Viewer Integration-> Trial
            % Message Commands" section of the EyeLink Data Viewer User Manual
            WaitSecs(0.001);


            Eyelink('Message', '!V TRIAL_VAR index %d', i);

            % a limitation of the currect ETB only accepts ints as input to
            % messages and commands a possible work around is given below


    %         msg1 = sprintf('!V TRIAL_VAR freq_x %2.3f ', trials(1,i));
    %         msg2 = sprintf('!V TRIAL_VAR freq_y %2.3f ', trials(2,i));
    %         Eyelink('Message', msg1);
    %         Eyelink('Message', msg2);     

            % STEP 7.8
            % Sending a 'TRIAL_RESULT' message to mark the end of a trial in
            % Data Viewer. This is different than the end of recording message
            % END that is logged when the trial recording ends. The viewer will
            % not parse any messages, events, or samples that exist in the data
            % file after this message.
            Eyelink('Message', 'TRIAL_RESULT 0');
        i=i+1;  
        %log=[log;[i conditions1(trialCond,1) duration eccentricity gapsize(trialCond) leftRight(i) directions(i)]]; 
        save(strcat(subDir,edfFile,'\',edfFile,'_predict'));    
        fprintf(fileID,'%1d %6d %1d %2d %5d\n',i, speed, duration, conditions(1,j),blank(1),blank(2));
        
        end
        EyelinkDoTrackerSetup(el);
    end
    fclose(fileID);
    
    %%%%%%%%%%
    % STEP 8 %
    %%%%%%%%%%
    
    % End of Experiment; close the file first
    % close graphics window, close data file and shut down tracker
    
    
    %%%%%%%%%%
    % STEP 9 %
    %%%%%%%%%%
    
    % run cleanup function (close the eye tracker and window).
        cleanup;
    
catch
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    %Eyelink('CloseFile');
    fclose(fileID); %close stimulus log file
    
    try
        %fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            %fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            %fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch %#ok<*CTCH>
        %fprintf('Problem receiving data file ''%s''\n', edfFile );
    end 
    cleanup;
    %fprintf('%s: some error occured\n', mfilename);
    psychrethrow(lasterror); %#ok<*LERR>
    Screen('CloseAll');
end

    function cleanup
        % Shutdown Eyelink:
        Eyelink('Shutdown');
        Screen('CloseAll');
    end

end
