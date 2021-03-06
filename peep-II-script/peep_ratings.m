function peep_ratings
% peep_ratings
%   Gathers ratings about PEEP-II sound scripts and saves to file.
% 

% 2016-01-11 Rick O. Gilmore rick.o.gilmore@gmail.com

% 2016-12-xx rog wrote
%--------------------------------------------------------------------------

% Start diary
diary(sprintf('diary/%s-diary.txt', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF')));

% Running on PTB-3? Abort otherwise.
AssertOpenGL;
clear;
clc;
KbName('UnifyKeyNames');

% Intro remarks
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('This is the PEEP-II rating script.\n\n');

% Load environment, session info

environment = set_rating_environment;
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Loaded environment.\n\n');

load('default_session.mat');
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Loaded default session.\n\n');

% Get session data for this run
session = get_peep_session_data(session, environment);
if ~(check_snd_dir(session.this_family, session.nov_family))
    fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
    fprintf('Error with sound directories. Terminating.\n');
    diary off;
    return;
end

% Initialize status
status.rating_index = 1;
status.snd_index = 1;
status.highlighted_index = 1;
status.continue = 1;

% Create run-specific log file
log_fn = strcat('log/', session.this_family, '-', datestr(now, 'yyyy-mm-dd-HHMM'), '-run-', session.run, '-order-', session.order, '.log');
[log_fid, ~] = fopen(log_fn, 'w');
peep_log_msg('Opened log file: log_fn\n', GetSecs(), log_fid);
environment.log_fid = log_fid;

% Create run-specific event file
csv_fn = strcat('csv/', 'rating-', session.this_family, '-', datestr(now, 'yyyy-mm-dd-HHMM'), '-run-', session.run, '-order-', session.order, '.csv');
[csv_fid, ~] = fopen(csv_fn, 'w');
peep_log_msg('Opened csv file: %s\n', GetSecs(), log_fid);
fprintf(csv_fid, 'fam_id,nov_id,run,order,sound_index,snd_file,happy_rating,angry_rating,sad_rating,scared-rating,how_feel,know_speaker\n');
environment.csv_fid = csv_fid;

% Collect ratings
collect_ratings(session, environment);

% Clear user screen
KbReleaseWait;
peep_log_msg(sprintf('Press any key to clear participant screen and end study.\n\n'), GetSecs(), environment.log_fid);
KbStrokeWait;

% Clean-up
diary off;
fclose('all');
Screen('CloseAll');
clc; % To clear buffer
end

