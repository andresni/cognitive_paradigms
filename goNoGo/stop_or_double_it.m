%                     __
%               _____/ / ____  ____
%              / ___/ __/ __ \/ _  \
%             (__  ) /_/ /_/ / /_/ /
%             ____/\__/\____/ .___/
%                          /_/
%
%    Stop-Signal / Double-response Program
%    Author: Frederick Verbruggen


function stop_or_double_it ()

try
    clear variables; %clear the variables
    clc; %clear the command window
    
    session = subjectinfo(); % get session info
    param = getParameters(); % get some user-defined parameters
    keys = usedkeys();%determine the user-defined response keys
    scr = initialise (param); %initialise psychtoolbox
    instruct (session, scr); %present the instructions
    
    for block = 1:1
        [ran ntrials] = randomise (param); % randomize trials
        message (1, scr); % inform subjects that trials will start
        
        % clear feedback counter and preallocate size
        fb = struct ('rt', 0, 'miss', 0, 'err', 0, 'sr', 0, 'si', 0, 'icd', 0, 'md', 0);
        
        % present the trials
        for t = 1:ntrials
            plot_jpg (scr, 'fix.jpg'); % present fixation cross
            WaitSecs(param.FIX); % wait FIX sec: jitter is added inside trial presentation
            data = present (scr, param, keys, ran(t)); % present the go stim., signals, and check for responses
            %[data fb] = correct (session, ran(t), data, fb); %check if response was correct
            write (session, block, ran(t), data);
%             if ran(t).signal == 1
%                 param = tracking (session, param, data);%do the tracking procedure
%             end
        end
        
        % give the subjects a break after every block (except last one)

    end
    
    message (2, scr); % inform subjects that experiment has ended
    close(scr);
catch
    Screen('CloseAll');
    ListenChar(0);
    ShowCursor;
    rethrow(lasterror);
end
end

%--------------------------------------------------------
% get info about the condition and the subject number
%--------------------------------------------------------
function [session] = subjectinfo()
check = 1;
while check
    session.subject = input ('Enter subject number: ');
    session.condition = input ('Enter condition (1 = S, 2 = D): ');
    
    text = {'stop', 'double'};
    name = sprintf('data/%s-%d.txt', text{session.condition}, session.subject);
    if ~isempty(dir(name));
        fprintf('\nFile already exists! Try again\n');
    else
        check=0;
    end
end
end

%--------------------------------------------------------
% function to read text files
% in future versions, textscan will be used
% (when Octave 3.4+ can be used for psychtoolbox)
%--------------------------------------------------------
function [text] = text_read (name)
fid = fopen(name, 'r');

tmp = 1;
text = {};

while tmp ~= -1
    tmp = fgetl(fid);
    if tmp ~= -1 % omit the last line (end of file; -1)
        if strcmp(strtok(tmp),'%') == 0 % omit lines that are preceded by '% '
            text = [text, cellstr(tmp)];
        end
    end
end

fclose (fid);
end

%--------------------------------------------------------
% get retrieve parameters set by user
% in future versions, textscan will be used (when Octave 3.4+ can be used
% for psychtoolbox)
%--------------------------------------------------------
function [param] = getParameters()
text = text_read ('paramcfg.txt');
for i = 1:length(text);
    [p v] = strtok(char(text{i})); % split the text in two components: name and value
    param.(p) = str2num(char(v)); % need to convert cell to numbers;
end
end

%--------------------------------------------------------
% initialise psychtoolbox
%--------------------------------------------------------
function [scr] = initialise (param) %initialise psychtoolbox

scr.nmbr = 0; % 0 = main screen
ListenChar(2); % we don't want the pressed keys to appear in Matlab from this point on
HideCursor;%hide the cursor

res=NearestResolution(scr.nmbr,1024,640, 60, []);
res.pixelSize = []; % on some windows machines, NearestResolution sets pixelSize to a value which is not supported 

scr.debug = Screen('Preference', 'VisualDebugLevel', 2);
scr.verbos = Screen('Preference', 'Verbosity', 2); % critical errors + warnings
SetResolution(scr.nmbr,1024,768);
[scr.Ptr]=Screen('OpenWindow',scr.nmbr);
[scr.Width, scr.Height]=Screen('WindowSize', scr.Ptr);
scr.xc = scr.Width/2;
scr.yc = scr.Height/2;

Priority(param.PRIOR); % use this if you want to increase priority but still allow keyboard responses

scr.FGCLR = [255 255 255]; % forefround color = white
scr.BGCLR = [0 0 0]; % background color = grey
end

%--------------------------------------------------------
% define keys 
%--------------------------------------------------------
function [key] = usedkeys()
text = text_read ('keycfg.txt');
for i = 1:length(text);
    [p v] = strtok(char(text{i})); % split the text in two components: name and value
    UsedKeys.(p) = char((strtrim(v))); % remove white spaces & convert to character;
end

KbName('UnifyKeyNames');
key.a  = KbName(UsedKeys.LEFT);
key.b  = KbName(UsedKeys.RIGHT);
key.double = KbName(UsedKeys.DOUBLE);
key.esc = KbName(UsedKeys.ESCAPE);
end

%--------------------------------------------------------
% present the instructions
%--------------------------------------------------------
function instruct (session, scr)

% determine the instruct file
if session.condition == 1; file = sprintf ('stop_instructions.txt');
else file = sprintf ('double_instructions.txt');
end

text = text_read (file); %open the file

% Present the start instructions on the screen
Screen('TextFont',scr.Ptr,'Ariel');
Screen('TextSize',scr.Ptr,14);
Screen('FillRect',scr.Ptr,scr.BGCLR);
for line=1:length(text)
    Screen('DrawText',scr.Ptr,text{line},25,line*30, scr.FGCLR);
end

%Screen('FillRect',scr.xc,scr.BGCLR);
img = Screen ('MakeTexture',scr.Ptr, imread ('go1.jpg'));
Screen ('DrawTexture', scr.Ptr, img, [],[0 scr.yc scr.xc scr.Height]);
img = Screen('MakeTexture',scr.Ptr,imread('go2.jpg'));
Screen('DrawTexture',scr.Ptr,img,[],[scr.xc scr.yc scr.Width scr.Height]);
Screen('DrawText',scr.Ptr,'Respond to this',scr.xc/3,scr.yc);
Screen('DrawText',scr.Ptr,'but not this',scr.xc*1.33,scr.yc);
Screen('Flip',scr.Ptr);

% wait until a key is pressed
KbWait();
end

%--------------------------------------------------------
% create a random list for the block
% in future versions, reset(RandStream.getDefaultStream,sum(100*clock))will be used
% to reset the rand status (when Octave 3.4+ can be used for psychtoolbox)
% %--------------------------------------------------------
function [ran ntrials] = randomise (param)
NSIGNAL = 3; % 3/4 of the trials are signal trials
NSTIM = 2; % 2 different stimuli
NREP = param.NBLOCKS; % repeat design 12 times
ntrials = NSIGNAL * NSTIM * NREP; % total #trials per block

rand('state', sum(100*clock)); % set rand-status
ran = struct ('stim', 0, 'signal', 0); % reset ran
list = randperm (ntrials); % make a random list

%determine stimuli and signals
for i = 1:ntrials
    ra=randi(4);
    if ra<=NSIGNAL
        ran(i).stim = 1; % determine stimuli
    else
        ran(i).stim = 2;
    end
    
    ran(i).signal = 0; % determine signals
end
end

%--------------------------------------------------------
% general functions for ploting the jpeg
%--------------------------------------------------------
function [Sec Onset Stamp] = plot_jpg (scr, jpgname)
Screen('FillRect',scr.Ptr,scr.BGCLR);
img = Screen ('MakeTexture', scr.Ptr, imread (jpgname));
Screen ('DrawTexture', scr.Ptr, img);
[Sec Onset Stamp] = Screen('Flip',scr.Ptr);
end

%--------------------------------------------------------
% function for trial presentation
%--------------------------------------------------------
function [data] = present (scr, param, key, ran)
data = struct ('rt', zeros(1,2), 'resp', zeros(1,2), 'correct', 0, 'ssd', 0, 'true_ssd', 0, 'spd', 0); %reset data structure
tmp = struct ('signal', 0, 'keys', 0, 'clrsign', 0, 'clrstim', 0, 'usrnpt', 1); %reset tmp structure
KeysPressed = [0 0];%required for disabling pressed keys

go_name = sprintf ('go%d.jpg', ran.stim); %determine name go file

tic;
WaitSecs(rand/param.SSD); %this is the jitter!!!!! between 0 and 100 ms
data.ssd=toc;

[StartSec] = plot_jpg (scr, go_name); %plot the go stimulus on the screen


while GetSecs - StartSec < param.MAXRT
    lapse = GetSecs - StartSec;
    [keyIsDown,secs,keyCode] = KbCheck;
    
    if keyCode(key.esc)
        close(scr); % immediately stop program if abort-key is pressed
    end
    
    % determine RT and which key is pressed
    if (keyIsDown && tmp.usrnpt <= 2)
        data.rt(tmp.usrnpt) = secs - StartSec;
        
        % convert key codes to 1-3
        if keyCode(key.a); data.resp(tmp.usrnpt) = 1;
        elseif keyCode(key.b); data.resp(tmp.usrnpt) = 2;
        elseif keyCode(key.double); data.resp(tmp.usrnpt) = 3;
        else data.resp(tmp.usrnpt) = 9;
        end
        
        % disable pressed key
        tmp_keys = find(keyCode); % to avoid that program crashes when 2 keys are pressed sim.
        KeysPressed(tmp.usrnpt) = tmp_keys(1);
        DisKeys = nonzeros(KeysPressed);
        DisableKeysForKbCheck(DisKeys);
        
        % update response counter
        tmp.usrnpt = tmp.usrnpt + 1;
        plot_jpg(scr,'fix.jpg');
        %WaitSecs(0.1);

    end
    
    % present signal after soa
    if lapse>param.SPT
        plot_jpg(scr,'fix.jpg');
    end
    
    % remove signal after signal presentation time

    
    % wait 1 ms to avoid CPU hogging
    WaitSecs (.001);
end

%release all keys again
DisableKeysForKbCheck([]);
end

%--------------------------------------------------------
% function to check if response was correct
%--------------------------------------------------------
function [data fb] = correct (session, ran, data, fb)
if (ran.signal == 0)
    if (data.resp(1) == ran.stim && data.resp(2) == 0)
        data.correct = 4; % correct ns response
        tmp = length(fb.rt);
        fb.rt(tmp+1) = data.rt(1); %add RT to the structure
    else
        if (data.resp(1) == 0) % missed response
            data.correct = 1;
            fb.miss = fb.miss +1;
        else
            if (data.resp(2) == 0)
                data.correct = 2; % incorrect response
                fb.err =fb.err +1;
            else
                data.correct = 3; % incorrect dual response
                fb.icd =fb.icd +1;
            end
        end
    end
else
    if session.condition == 1 % stop condition
        if data.rt(1) == 0
            data.correct = 4; % signal-inhibit
            fb.si = fb.si + 1;
        else
            data.correct = 3; % signal-respond
            fb.sr = fb.sr + 1;
        end
    else
        if (data.resp(1) == ran.stim && data.resp(2) == 3) % correct
            data.correct = 4;
        elseif (data.resp(2) == 0) % dual response too slow
            data.correct = 3;
            fb.md =fb.md +1;
        elseif (data.resp(1) == 0) % missed first & second response
            data.correct = 1;
            fb.miss =fb.miss +1;
        else % misc. error
            data.correct = 2;
            fb.err =fb.err +1;
        end
    end
end
end

%--------------------------------------------------------
% function to do the staircase tracking
%--------------------------------------------------------
function [param] = tracking (session, param, data)
SSRTsim = 0.0225;

if session.condition == 1
    if data.rt(1) == 0
        param.SSD = param.SSD + 0.050;
    else
        param.SSD = param.SSD - 0.050;
    end
else
    if data.rt(1) > SSRTsim + param.SSD
        param.SSD =param.SSD + 0.050;
    else
        param.SSD = param.SSD - 0.050;
    end
end

% limit SSD: 0.050 < SSD < (MAXRT - 0.050)
if param.SSD  < .050
    param.SSD = .050;
elseif param.SSD  > (param.MAXRT - 0.050)
    param.SSD  = (param.MAXRT - 0.050);
else
    param.SSD = param.SSD;
end
end

%--------------------------------------------------------
% function to write the data to a file
%--------------------------------------------------------
function write (session, block, ran, data)

text = {'stop', 'double'};
name = sprintf('data/%s-%d.txt', text{session.condition}, session.subject);

% if the file does not exist yet, then add data labels
if ~exist(name, 'file')
    fpo = fopen(name, 'a');
    fprintf(fpo, 'block\t');
    fprintf(fpo, 'stim\t');
    fprintf(fpo, 'signal\t');
    fprintf(fpo, 'reqSSD\t');
    fprintf(fpo, 'correct\t');
    fprintf(fpo, 'resp1\t');
    fprintf(fpo, 'resp2\t');
    fprintf(fpo, 'rt1\t');
    fprintf(fpo, 'rt2\t');
    fprintf(fpo, 'trueSSD\t');
    fprintf(fpo, 'spd\n');
else
    fpo = fopen(name, 'a');
end

% write data to the file
fprintf(fpo, '%d\t', block);
fprintf(fpo, '%d\t', ran.stim);
fprintf(fpo, '%d\t', ran.signal);
fprintf(fpo, '%.0f\t', 1000 * data.ssd);
fprintf(fpo, '%.0f\t', data.correct);
fprintf(fpo, '%.0f\t', data.resp(1));
fprintf(fpo, '%.0f\t', data.resp(2));
fprintf(fpo, '%.0f\t', 1000 * data.rt(1));
fprintf(fpo, '%.0f\t', 1000 * data.rt(2));
fprintf(fpo, '%.0f\t', 1000 * data.true_ssd);
fprintf(fpo, '%.0f\n', 1000 * data.spd);

fclose (fpo);

end

%--------------------------------------------------------
% function to present feedback during blocks
%--------------------------------------------------------
function feedback (session, scr, param, fb)
% calculate some means
meanRT1 = 1000 * mean(nonzeros(fb.rt));
prespond = 100 * fb.sr/(fb.sr+fb.si);

% present feedback
Screen('TextSize',scr.Ptr,16);
Screen('FillRect',scr.Ptr,scr.BGCLR);

text{1} = sprintf ('RESULTS NO-SIGNAL TRIALS:');
text{2} = sprintf (' - Mean RT response no-signal trials = %.0f ms', meanRT1);
text{3} = sprintf (' - Number of incorrect responses = %.0f ', fb.err);
text{4} = sprintf (' - Number of missed responses = %.0f ', fb.miss);
text{5} = sprintf ('RESULTS SIGNAL TRIALS:');
if session.condition == 1
    text{6} = sprintf (' - Percentage failed stops = %.0f', prespond);
else
    text{6} = sprintf (' - Number of missed 2nd responses = %.0f', fb.md);
end

for line=1:length(text)
    Screen('DrawText',scr.Ptr,text{line},25,line*30, scr.FGCLR);
end


% start counter
for s = param.PAUSETM:-1:1
    Screen('FillRect',scr.Ptr,scr.BGCLR, [0, (length(text) + 1) * 30, scr.Width, scr.Height]);
    sec = sprintf ('(seconds left to wait: %d)', s);
    DrawFormattedText (scr.Ptr, sec, 25, (length(text) + 2) * 30, scr.FGCLR);
    Screen('Flip',scr.Ptr, 0, 1);
    WaitSecs (1.000);
end

% remove the info of the screen
Screen('FillRect',scr.Ptr,scr.BGCLR);
DrawFormattedText (scr.Ptr, 'press a key to continue', 'center', 'center', scr.FGCLR);
Screen('Flip', scr.Ptr);
KbWait();

% clear the screen again
Screen('FillRect',scr.Ptr,scr.BGCLR);
Screen('Flip', scr.Ptr);
end

%--------------------------------------------------------
% present text messages on screen
%--------------------------------------------------------
function message (code, scr)
textmessage = {'Get ready', 'End of the experiment'};
Screen('FillRect',scr.Ptr,scr.BGCLR);
Screen('TextSize',scr.Ptr,48);
DrawFormattedText (scr.Ptr, textmessage{code}, 'center', 'center', scr. FGCLR);
Screen('Flip',scr.Ptr);
WaitSecs (2.000);
end

%----------------------------------------------------------------
% close Psychtoolbox, enable keyboard output & mouse cursor again
%----------------------------------------------------------------
function close(scr)
Screen('CloseAll');
Screen('Preference', 'VisualDebugLevel', scr.debug);
Screen('Preference', 'Verbosity', scr.verbos);
ListenChar(0);
ShowCursor;
clear all;
end


