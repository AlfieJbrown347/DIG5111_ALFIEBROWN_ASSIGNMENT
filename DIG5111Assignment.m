% =========================================================================
% DIG5111 - Task 1: Frequency-Domain Comparison of Two Audio Signals
% =========================================================================
% In this task, I'm comparing the frequency content of two audio files provided for me from moodle.
% The idea is to see where energy is concentrated in the spectrum (like bass or treble),
% and to compare the structure of two signals using both magnitude and
% phase, which i will later use in order to create the filter 
% =========================================================================

clear;
clc;

fprintf('\nDIG5111 - Task 1: Compare Two Audio Files in the Frequency Domain\n');

% =========================================================================
% SECTION 1 – Load and prepare audio signals
% =========================================================================
% User selects two .wav files. These could be recordings with different filters,
% different instruments, or different levels of noise.

% -- First audio file
[file1, path1] = uigetfile('*.wav', 'Select the FIRST audio file');
if isequal(file1, 0)
    error('File selection cancelled.');
end
[x1, fs1] = audioread(fullfile(path1, file1));
%This line loads the audio file and gives us both the sound data and its sample rate."

% -- Second audio file
[file2, path2] = uigetfile('*.wav', 'Select the SECOND audio file');
if isequal(file2, 0)
    error('File selection cancelled.');
end
[x2, fs2] = audioread(fullfile(path2, file2));
% same as line 27 but for the second audio file 

% -- Check sample rate (fs) is the same
% DSP Theory: The frequency axis depends directly on fs (sample rate), so we can't compare
% signals fairly unless both have the same sample rate.
if fs1 ~= fs2 
   % This checks if the sample rates are not the same.
    error('Sample rates do not match – cannot compare spectra directly.');
end

% -- Convert stereo to mono
% Practical: Averaging the two channels simplifies the FFT and avoids stereo imbalance.
% If the audio is stereo, this converts it to mono by averaging the two channels.
if size(x1, 2) == 2
    x1 = mean(x1, 2);
end
if size(x2, 2) == 2
    x2 = mean(x2, 2);
end

fprintf('Audio files loaded and converted to mono (if needed).\n');

% =========================================================================
% SECTION 2 – FFT: Convert both signals to frequency domain
% =========================================================================
% DSP Theory: The FFT is an efficient implementation of the Discrete Fourier Transform.
% It reveals which frequencies are present in a signal and how strong they are.

N = 2^nextpow2(max(length(x1), length(x2)));  % Next power of 2 for speed and detail

%This sets the FFT length to the next power of 2 for faster performance and better frequency detail.

X1 = fft(x1, N);  % Frequency content of signal 1
X2 = fft(x2, N);  % Frequency content of signal 2

f = fs1 * (0:(N/2 - 1)) / N;  % Frequency axis up to Nyquist
%This sets up the frequency axis in Hz so we can plot the FFT on a proper scale

% -- Convert amplitude to decibels (dB)
% DSP Theory: dB scaling helps us visualise small and large magnitudes together.
% It's also closer to how humans perceive loudness.
magX1 = 20 * log10(abs(X1(1:N/2)));
magX2 = 20 * log10(abs(X2(1:N/2)));

% =========================================================================
% SECTION 3 – Frequency range selection
% =========================================================================
% User can zoom into part of the spectrum to make comparisons clearer.
% This helps focus on things like bass (0–1kHz), mids (1–5kHz), or treble.

fNyq = fs1 / 2;  % Nyquist frequency (fs/2)

choice = menu('Select frequency range to analyse:', ...
              '0–1000 Hz (bass)', ...
              '1000–5000 Hz (mids)', ...
              '5000–Nyquist (treble)', ...
              'Custom range', ...
              'Full spectrum');

switch choice
    case 1
        f_min = 0;     f_max = 1000;
    case 2
        f_min = 1000;  f_max = 5000;
    case 3
        f_min = 5000;  f_max = fNyq;
    case 4
        % Ask user to enter their own limits
        prompt = {'Minimum frequency (Hz):', 'Maximum frequency (Hz):'};
        def = {'0', num2str(fNyq)};
        inputRange = inputdlg(prompt, 'Custom Range', [1 35], def);
        if isempty(inputRange)
            f_min = 0; f_max = fNyq;
        else
            f_min = str2double(inputRange{1});
            f_max = str2double(inputRange{2});
        end
        % Simple validation
        if isnan(f_min) || isnan(f_max) || f_min < 0 || f_max > fNyq || f_min >= f_max
            warning('Invalid range. Using full spectrum.');
            f_min = 0; f_max = fNyq;
        end
    otherwise
        f_min = 0; f_max = fNyq;
end

% Filter frequency range to plot
idx = (f >= f_min) & (f <= f_max);
f_range = f(idx);
magX1_range = magX1(idx);
magX2_range = magX2(idx);

% =========================================================================
% SECTION 4 – Plot magnitude spectra
% =========================================================================
% Real World: This is how audio engineers check mixes for missing energy,
% forensics people compare voice recordings, and audio tools visualise EQ curves.

figure;
subplot(2,1,1);
plot(f_range, magX1_range);
title(sprintf('Magnitude Spectrum: File 1 (%.0f–%.0f Hz)', f_min, f_max));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;

subplot(2,1,2);
plot(f_range, magX2_range);
title(sprintf('Magnitude Spectrum: File 2 (%.0f–%.0f Hz)', f_min, f_max));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;

% =========================================================================
% SECTION 5 – Plot phase spectra (optional)
% =========================================================================
% DSP Theory: The phase spectrum shows how frequencies are aligned in time.
% A flat or linear phase means the timing is consistent.
% This isn’t always needed for music, but it's useful in speech or systems analysis.

phaseX1 = angle(X1(1:N/2));
phaseX2 = angle(X2(1:N/2));

figure;
subplot(2,1,1);
plot(f, phaseX1);
title('Phase Spectrum: File 1');
xlabel('Frequency (Hz)');
ylabel('Phase (radians)');
grid on;

subplot(2,1,2);
plot(f, phaseX2);
title('Phase Spectrum: File 2');
xlabel('Frequency (Hz)');
ylabel('Phase (radians)');
grid on;

fprintf('Phase shows the structure/timing of components in the signal.\n');

% =========================================================================
% SECTION 6 – Playback
% =========================================================================
% This makes it easier to link what you see in the plots with what you hear.
% You can directly hear if there's more bass, or if one signal is cleaner.

playChoice = menu('Which file do you want to hear?', ...
                  'Play File 1', ...
                  'Play File 2', ...
                  'Play Both', ...
                  'Skip');

switch playChoice
    case 1
        soundsc(x1, fs1);
    case 2
        soundsc(x2, fs2);
    case 3
        soundsc(x1, fs1);
        pause(length(x1)/fs1 + 1);
        soundsc(x2, fs2);
    otherwise
        disp('Playback skipped.');
end

% =========================================================================
% Final comment – summary
% =========================================================================
% This task demonstrates how the FFT lets us see inside audio signals.
% It connects directly to lecture theory on the DFT and spectrum analysis.
% In real applications, this process is used in mixing, mastering, forensics,
% voice matching, and even wildlife monitoring and sound detection.

fprintf('\nTask 1 finished – frequency comparison complete ✅\n');
