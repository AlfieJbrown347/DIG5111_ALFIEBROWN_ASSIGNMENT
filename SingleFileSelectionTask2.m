% =========================================================================
% DIG5111 - Task 3: Clean task1sig.wav using a low-pass filter
% =========================================================================
% Goal: This script takes a noisy audio file and filters out high-frequency
% noise using a low-pass Butterworth filter. We aim to keep the musical
% parts as clean as possible while removing background hiss.
% =========================================================================

clear;
clc;

fprintf('\nDIG5111 - Task 3: Noise Reduction on task1sig.wav\n');

% =========================================================================
% STEP 1 – Load the provided noisy audio file
% =========================================================================
[x, fs] = audioread('task1sig.wav');
disp('Loaded task1sig.wav successfully.');

% =========================================================================
% STEP 2 – Filter parameters
% =========================================================================
% We’re using a Butterworth low-pass filter to reduce noise above 3000 Hz.
% These settings were chosen by trial and error to balance clarity and noise removal.
filterType = 1;       % 1 = Low-pass
filterDesign = 1;     % 1 = Butterworth
cutoff = 3000;        % Cutoff frequency in Hz
order = 4;            % Steepness of the filter

% =========================================================================
% STEP 3 – Filter Design
% =========================================================================
Wn = cutoff / (fs / 2);  % Normalise cutoff

% DSP Concept:
% Butterworth filters have a smooth roll-off and no ripple in the passband,
% making them a good choice for audio where we want clarity in what's left.
[b, a] = butter(order, Wn, 'low');

% =========================================================================
% STEP 4 – Apply the filter
% =========================================================================
% filtfilt does forward and backward filtering to cancel phase shift.
% If stereo, apply the filter to both channels separately.
if size(x, 2) == 2
    y(:,1) = filtfilt(b, a, x(:,1));
    y(:,2) = filtfilt(b, a, x(:,2));
else
    y = filtfilt(b, a, x);
end

disp('Filtering complete.');

% =========================================================================
% STEP 5 – Save the cleaned audio
% =========================================================================
audiowrite('filteredsig.wav', y, fs);
disp('Filtered audio saved as filteredsig.wav');

% =========================================================================
% STEP 6 – Optional: Listen to the results
% =========================================================================
playChoice = menu('Do you want to listen to the audio?', ...
                  'Play original (noisy)', ...
                  'Play filtered (clean)', ...
                  'Play both', ...
                  'Skip playback');

switch playChoice
    case 1
        disp('Playing original audio...');
        soundsc(x, fs);
    case 2
        disp('Playing filtered audio...');
        soundsc(y, fs);
    case 3
        disp('Playing original audio...');
        soundsc(x, fs);
        pause(length(x)/fs + 1);
        disp('Playing filtered audio...');
        soundsc(y, fs);
    otherwise
        disp('Playback skipped.');
end

% =========================================================================
% STEP 7 – Summary for report/presentation
% =========================================================================
% This task shows how we can use digital filters to clean up real-world
% signals. The Butterworth filter was chosen for its smooth passband.
% Cutoff = 3000 Hz was enough to reduce hiss without cutting into vocals.
% -------------------------------------------------------------------------
% Real-world uses:
% - Music restoration (old recordings)
% - Cleaning field recordings or interviews
% - Removing unwanted noise in streaming and broadcast
% =========================================================================

fprintf('\nFiltering complete. Summary:\n');
fprintf('Input: task1sig.wav\n');
fprintf('Filter: Low-pass Butterworth\n');
fprintf('Cutoff: 3000 Hz\n');
fprintf('Order: 4\n');
fprintf('Output: filteredsig.wav\n');
fprintf('Result: High-frequency noise reduced, musical content kept.\n');