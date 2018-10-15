function write_events(samplerate, trial_length, duration);

%% function write_events(samplerate);
%%
%% Writes a text file with times (in seconds) at which a new trial starts
%% Trials that contain artefacts, as defined in a separate *.evt file, are skipped
%%
%% Input:
%% samplerate in Hz
%% trial_length in samples
%% duration [seconds] of the recording
%% Date: October 2018

%% intialisation
if nargin < 1,
    samplerate = [];
end
if nargin < 2
    trial_length = [];
end
if nargin < 3
    duration = [];
end

if isempty(samplerate)
    samplerate = 600; % Hz
end
if isempty(trial_length)
    trial_length = 4096;
end
if isempty(duration)
    duration = str2num(input('please type the total length of the data (in seconds; e.g., 300)\n','s'));
    % duration = 300; % seconds
end

%% Get the latencies at which the trials start
%event = ([1:4096:duration*samplerate]-1) /samplerate;
event = ([1:trial_length:duration*samplerate]-1) /samplerate;

%% Get info about bad data segemets
[filename, pathname, filterindex] = uigetfile('*.evt','Pick an event-file');
bad = importdata([pathname,filename]);
bad_segments = bad.data


a=event';
%b = event'+6.8267;
%b = event' + (trial_length/samplerate);
b = event' + ((trial_length-1)/samplerate);% used (trial_length-1), otherwise the last sample of the previous trial is the same sample as the start of the next trial 
c = [a b];
all_events = c
d = c;
% %for i = 1:length(c)-1
%for i = 1:size(c,1)-1
% for i = 1:size(c,1), % Also check the last trial!
% 
%     for j = 1:length(bad.data)
% 
%         if c(i,1) < bad.data(j,1) && c(i,2) > bad.data(j,1) ...
%                 || c(i,1) < bad.data(j,2) && c(i,2) > bad.data(j,2) % bad segment falls between two trials
%             %
%             %         c(i,1) > bad.data(j,1) && c(i,2) < bad.data(j,2) |
%             d(i,:) = nan;
%         elseif c(i,1) > bad.data(j,1) && c(i,2) < bad.data(j,2) ...
%                 || c(i,1) < bad.data(j,1) && c(i,2) > bad.data(j,2) % bad segment falls within/includes a complete trial
%             
%             d(i,:) = nan;
%         else
%             ;
%         end
%        
%     end
% end

%for i = 1:length(c)-1
for i = 1:size(c,1) % Also check the last trial!

    for j = 1:length(bad.data)

        if c(i,1) > bad.data(j,1) && c(i,1) < bad.data(j,2) ...
                || c(i,1) < bad.data(j,1) && c(i,2) > bad.data(j,1) % bad segment starts before trial and ends somewhere after the start of the trial, or the bad segment starts somewhere within the trial
            d(i,:) = nan;
         else
            ;
        end
       
    end
    
end


d(:,2) = [];
d = d(~isnan(d));
clean_events = d

fprintf('%d clean trials from %d total trials \nPlease be aware that %0.1f trials are prefered for stable SAM beamforming', length(d), length(c), 3*60*samplerate/trial_length)

fileID = fopen([pathname,'clean_trials.txt'],'w');
fprintf(fileID,'%6.4f\n',d);
fclose(fileID)











