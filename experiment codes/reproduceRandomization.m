% trying to reproduce the catch trials...
% run this script right after starting matlab

% pursuit
orderHor=randperm(4/2);
orderVer=randperm(4/2)+4/2;

% pro-saccade block
order = randperm(40);
for ii = 1:40
    rand;
end

% anti-saccade block
order = randperm(40);
for ii = 1:40
    rand;
end

% predictive pursuit
randperm(6);
trialsPerCond = 20;
for jj=1:6   
    
    catchTrials=sort(ceil(rand(1,3)*(trialsPerCond-3))+5); %random trials between 6 and number of trials-3 (always have at least 3 test trials after a catch trial)
    
    while any( (catchTrials(2:end) - catchTrials(1:(end-1))) <=3) % make sure there is at least 3 test trials between the 'random' catch trials
        catchTrials=sort(ceil(rand(1,3)*(trialsPerCond-3))+5);
        
    end
    noBlank= [1 2 catchTrials] %indexes without any blank
end