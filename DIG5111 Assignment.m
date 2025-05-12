% =========================================================================
% AUDIO COMPARISON TOOL - SECTION 1: Load and Prepare Audio Signals
% =========================================================================
% This section prompts the user to select two audio files and loads them
% into MATLAB for further analysis. The signals are converted to mono (if
% stereo) to simplify initial comparison.
% =========================================================================

% Clear environment
clear;
clc;

% --- Select and load first audio file ---
[file1, path1] = uigetfile('*.wav', 'Select the FIRST audio file to compare');
if isequal(file1, 0)
    error('User cancelled file selection.');
end
[x1, fs1] = audioread(fullfile(path1, file1));

% --- Select and load second audio file ---
[file2, path2] = uigetfile('*.wav', 'Select the SECOND audio file to compare');
if isequal(file2, 0)
    error('User cancelled file selection.');
end
[x2, fs2] = audioread(fullfile(path2, file2));

% --- Check that both files have the same sample rate ---
if fs1 ~= fs2
    error('Sample rates of the two audio files do not match!');
end

% --- Convert stereo to mono if needed ---
if size(x1, 2) == 2
    x1 = mean(x1, 2); % Average the two channels
end
if size(x2, 2) == 2
    x2 = mean(x2, 2);
end

% Display message to user
disp('Both audio files loaded successfully and converted to mono if needed.');
