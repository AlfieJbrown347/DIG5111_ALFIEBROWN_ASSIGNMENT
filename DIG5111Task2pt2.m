% =========================================================================
% DIG5111 - Task 2: Interactive Audio Filtering Tool
% =========================================================================
% This script lets the user load an audio file and apply a filter to it.
% You can choose whether you want a low-pass or high-pass filter, pick the
% cutoff frequency, the filter steepness, and even the filter design.
% =========================================================================

clear;
clc;

fprintf('\nDIG5111 - Task 2: Filter Design and Application\n');

% =========================================================================
% STEP 1 – Load the input audio file
% =========================================================================
% This opens a file picker so the user can select any .wav file.
[file, path] = uigetfile('*.wav', 'Select an audio file to filter');
if isequal(file, 0)
    error('No file selected.');
end
[x, fs] = audioread(fullfile(path, file));

% If the audio is stereo, we'll just average the two channels into mono.
% It keeps things simpler and works fine for most cases.
if size(x, 2) == 2
    x = mean(x, 2);
    disp('Stereo detected – converted to mono.');
end

fprintf('Loaded file: %s\n', file);

% =========================================================================
% STEP 2 – Ask what type of filter the user wants
% =========================================================================
% Low-pass keeps the low frequencies and cuts the high ones (like hiss)
% High-pass does the opposite – removes low frequencies (like rumble)
filterType = menu('Select filter shape:', ...
                  'Low-pass (remove high frequencies)', ...
                  'High-pass (remove low frequencies)');
if filterType == 0
    error('No filter shape selected.');
end

% =========================================================================
% STEP 3 – Ask what the user wants to achieve (purpose of filtering)
% =========================================================================
% These are just friendly presets to make it easier for non-experts
cutoffChoice = menu('What do you want the filter to do?', ...
    'Remove hiss (cut above 3000 Hz)', ...
    'Keep only bass (cut above 500 Hz)', ...
    'Remove rumble (cut below 300 Hz)', ...
    'Custom input');

switch cutoffChoice
    case 1
        cutoff = 3000;
    case 2
        cutoff = 500;
    case 3
        cutoff = 300;
    case 4
        cutoff = input('Enter your custom cutoff frequency in Hz: ');
    otherwise
        error('No cutoff selected.');
end

% =========================================================================
% STEP 4 – Pick how steep the filter should be (filter order)
% =========================================================================
% Higher order = sharper cutoff, but might distort more
orderChoice = menu('Filter steepness (order):', ...
    'Low (Order 2)', 'Medium (Order 4)', 'High (Order 8)', 'Custom');

switch orderChoice
    case 1
        order = 2;
    case 2
        order = 4;
    case 3
        order = 8;
    case 4
        order = input('Enter custom filter order: ');
    otherwise
        error('No filter order selected.');
end

% =========================================================================
% STEP 5 – Choose the filter design type
% =========================================================================
% Butterworth = smoother and no ripple
% Chebyshev = sharper cutoff but can have slight ripple in the passband
% -------------------------------------------------------------------------
% A little theory:
% - Butterworth filters are known for having a flat response in the passband.
%   That means no ripples or distortion in the frequencies we keep.
%   They roll off gradually, which is smooth but not the sharpest.
%
% - Chebyshev Type I filters allow a small ripple in the passband,
%   but the advantage is they roll off faster after the cutoff point.
%   So they're good if we want a more aggressive filter.
% -------------------------------------------------------------------------
filterDesign = menu('Select filter design:', 'Butterworth', 'Chebyshev Type I');
if filterDesign == 0
    error('No filter design selected.');
end

% =========================================================================
% STEP 6 – Create the filter using user settings
% =========================================================================
% We convert the cutoff into the 0–1 range because MATLAB expects it
Wn = cutoff / (fs/2);

switch filterDesign
    case 1
        if filterType == 1
            [b, a] = butter(order, Wn, 'low');
        else
            [b, a] = butter(order, Wn, 'high');
        end
        disp('Butterworth filter created.');
    case 2
        ripple = 1;  % Small ripple allowed
        if filterType == 1
            [b, a] = cheby1(order, ripple, Wn, 'low');
        else
            [b, a] = cheby1(order, ripple, Wn, 'high');
        end
        disp('Chebyshev Type I filter created.');
end

% =========================================================================
% STEP 7 – Apply the filter to the audio
% =========================================================================
% We use filtfilt to apply the filter forward and backward
% This avoids any phase shift and gives a cleaner result
y = filtfilt(b, a, x);

fprintf('Filter applied successfully.\n');

% =========================================================================
% STEP 8 – Save the new filtered audio
% =========================================================================
audiowrite('filtered_output.wav', y, fs);
fprintf('Filtered file saved as filtered_output.wav\n');

% =========================================================================
% STEP 9 – Plot the waveforms before and after filtering
% =========================================================================
% This lets us see how the overall shape of the audio has changed
t = (0:length(x)-1)/fs;
figure;
subplot(2,1,1);
plot(t, x);
title('Original Signal (Time Domain)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(2,1,2);
plot(t, y);
title('Filtered Signal (Time Domain)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% =========================================================================
% STEP 10 – Plot the frequency content (spectrum) of both
% =========================================================================
% This helps confirm if the unwanted frequencies were removed or reduced
N = 2^nextpow2(length(x));
f = fs*(0:(N/2 - 1))/N;
X = abs(fft(x, N));
Y = abs(fft(y, N));

figure;
subplot(2,1,1);
plot(f, 20*log10(X(1:N/2)));
title('Original Spectrum');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); grid on;

subplot(2,1,2);
plot(f, 20*log10(Y(1:N/2)));
title('Filtered Spectrum');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); grid on;

% =========================================================================
% STEP 11 – Let the user listen to before/after
% =========================================================================
playChoice = menu('Which signal do you want to listen to?', ...
                  'Original', 'Filtered', 'Play Both', 'Skip');

switch playChoice
    case 1
        soundsc(x, fs);
    case 2
        soundsc(y, fs);
    case 3
        soundsc(x, fs);
        pause(length(x)/fs + 1);
        soundsc(y, fs);
    otherwise
        disp('Playback skipped.');
end

% =========================================================================
% Final note: Where this gets used in real life
% =========================================================================
% You’d use this kind of filter to clean up audio recordings,
% remove hiss in old tracks, reduce background noise in voice calls,
% or even in medical signals like heartbeats (ECG).

fprintf('\nTask 2 complete – Filter designed, applied, and saved.\n');
