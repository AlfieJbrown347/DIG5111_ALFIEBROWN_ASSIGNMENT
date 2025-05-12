%% MATLAB Starter Code for Image Source Method (ISM)
% This script generates a room impulse response using the Image Source Method.
% It is intended as a starting point for your DSP Assessment.
%
% Key Features:
%   1. Define a custom cuboid room (length, width, height).
%   2. Specify positions for the sound source and receiver.
%   3. Compute reflections up to a user-defined reflection order.
%   4. Include placeholders to incorporate absorption coefficients for each room surface.
%   5. Plot the resulting impulse response.
%   6. Provide a basic framework for later convolution with an audio signal.
%
% You are encouraged to expand%% the code (e.g., to include higher-order reflections
% or frequency-dependent absorption coefficients) by modifying the indicated sections.

%% 1. Parameter Definition
% Room dimensions (meters)
room_length = 17;    % Length in x-direction
room_width  = 11;     % Width in y-direction
room_height = 4;     % Height in z-direction

% Sound source and receiver (listener) positions [x, y, z] in meters
src_pos = [3, 4, 1.5];   % Source position
rec_pos = [7, 2, 1.5];   % Receiver position

% Sampling parameters and speed of sound
fs = 44100;          % Sampling frequency in Hz
c  = 343;            % Speed of sound in m/s

% Maximum reflection order (i.e. include reflections from -max_order to max_order in each dimension)
max_order = 5; %just changed this from 50 to 5 to see if it helps

% Absorption coefficients for surfaces (values between 0 and 1)
% These represent the fraction of energy absorbed at each surface.
% For now, we use a uniform absorption coefficient.
% --- Students: Replace the following with surface-specific coefficients as desired.
absorption_left_wall   = 0.1; % wood wall
absorption_right_wall  = 0.6; % acoustic tiles
absorption_front_wall  = 0.4; % acoustic pannels 
absorption_back_wall   = 0.4; % acoustic pannels 
absorption_floor       = 0.1; % wood floor  
absorption_ceiling= 0.2;      % acoustic tiles 

% Convert to reflection coefficients (based on energy conservation)
reflection_left_wall   = sqrt(1 - absorption_left_wall);
reflection_right_wall  = sqrt(1 - absorption_right_wall);
reflection_front_wall  = sqrt(1 - absorption_front_wall);
reflection_back_wall   = sqrt(1 - absorption_back_wall);
reflection_floor       = sqrt(1 - absorption_floor);
reflection_ceiling     = sqrt(1 - absorption_ceiling);


% Impulse response duration (seconds)
ir_duration = 3.0;  
N = round(fs * ir_duration);    % Number of samples in the IR
h = zeros(N, 1);                % Preallocate the impulse response vector

%% 2. Image Source Computation and IR Construction
% Loop over reflection orders in each spatial dimension.
% The image source method creates virtual sources by “mirroring” the actual source.
% For each axis, the image source coordinate is computed as follows:
%   - If the reflection order (n) is even:  img_coord = n*room_dim + src_coord
%   - If odd:                         img_coord = n*room_dim + (room_dim - src_coord)
%
% The total number of reflections for a given image is the sum of the absolute
% values of the reflection orders in x, y, and z. This count is used to scale
% the amplitude (via the reflection coefficients) and to mimic energy loss.

for nx = -max_order:max_order
    % Compute image source x-coordinate
    if mod(nx,2) == 0
        img_x = src_pos(1) + nx * room_length;
    else
        img_x = (room_length - src_pos(1)) + nx * room_length;
    end
    
    for ny = -max_order:max_order
        % Compute image source y-coordinate
        if mod(ny,2) == 0
            img_y = src_pos(2) + ny * room_width;
        else
            img_y = (room_width - src_pos(2)) + ny * room_width;
        end
        
        for nz = -max_order:max_order
            % Compute image source z-coordinate
            if mod(nz,2) == 0
                img_z = src_pos(3) + nz * room_height;
            else
                img_z = (room_height - src_pos(3)) + nz * room_height;
            end
            
            % Compute the Euclidean distance from the image source to the receiver
            distance = sqrt((img_x - rec_pos(1))^2 + (img_y - rec_pos(2))^2 + (img_z - rec_pos(3))^2);
            
            % Compute the propagation delay in seconds and convert to a sample index
            time_delay = distance / c;
            sample_delay = round(time_delay * fs) + 1;  % +1 for MATLAB 1-indexing
            
            % Count the total number of reflections from all three dimensions
            num_reflections = abs(nx) + abs(ny) + abs(nz);
            
            % Compute the overall reflection coefficient for this image source.
            % --- Students: Modify this section to apply surface-specific absorption.
            % For example, you could assign different reflection coefficients depending on
            % which wall (left/right, front/back, floor/ceiling) was involved in the reflection.
            % Start with full energy (reflection coefficient = 1)
            % ONE ALFIE INPUTED
% Start with full energy before any reflections
% (i.e., reflection coefficient = 1 means no energy lost yet)
total_reflection_coeff = 1;

% --- Handle reflections in the x-direction (left/right walls) ---
% Each reflection in the x-axis alternates between left and right walls.
% We loop from 1 to the number of reflections in x (absolute value of nx).
% For each reflection in x (left/right walls)
for i = 1:abs(nx)
    if mod(i, 2) == 1  % odd reflection
        total_reflection_coeff = total_reflection_coeff * reflection_left_wall;
    else
        total_reflection_coeff = total_reflection_coeff * reflection_right_wall;
    end
end
%--- Handle reflections in the y-direction (front/back walls) ---
% Similar to x, we alternate between front and back wall reflections.
% For each reflection in y (front/back walls)
for i = 1:abs(ny)
    if mod(i, 2) == 1
        total_reflection_coeff = total_reflection_coeff * reflection_front_wall;
    else
        total_reflection_coeff = total_reflection_coeff * reflection_back_wall;
    end
end
% --- Handle reflections in the z-direction (floor/ceiling) ---
% Again, alternate between floor and ceiling based on odd/even reflections.
% For each reflection in z (floor/ceiling)
for i = 1:abs(nz)
    if mod(i, 2) == 1
        total_reflection_coeff = total_reflection_coeff * reflection_floor;
    else
        total_reflection_coeff = total_reflection_coeff * reflection_ceiling;
    end
end

            
            % Attenuation due to spherical spreading (inverse of distance)
            attenuation = 1 / distance;
            
            % Add the contribution from this image source to the impulse response,
            % if the computed sample delay is within the impulse response length.
            if sample_delay <= N
                h(sample_delay) = h(sample_delay) + total_reflection_coeff * attenuation;
            end
        end
    end
end

% === Normalize the impulse response ===
h = h / max(abs(h));  % Normalize IR


%% 3. Plot the Impulse Response
time_axis = (0:N-1) / fs;  % Time vector in seconds
figure;
stem(time_axis, h, 'Marker', 'none');
xlabel('Time (s)');
ylabel('Amplitude');
title('Room Impulse Response using Image Source Method');
grid on;

%% 4. Using the Impulse Response for Convolution Reverb
% The generated impulse response (vector h) can now be used to apply convolution
% reverb to an audio signal.
% Example (uncomment and modify as needed):

 %% 4. Using the Impulse Response for Convolution Reverb

% === Load a dry audio file (mono recommended for simplicity) ===
% Replace 'your_audio_file.wav' with the name of your own file.
% Make sure it's in the same folder as your script or give the full path.
[audio_in, fs_audio] = audioread('JazzSax.wav');

% === If the audio sample rate is different from our IR sample rate, match it ===
% This ensures the impulse response and audio are at the same sampling frequency,
% otherwise MATLAB will throw an error or it won't sound correct.
if fs_audio ~= fs
    audio_in = resample(audio_in, fs, fs_audio);  % Resample audio to match IR sample rate
end

% === Convolve the audio with the impulse response ===
% This is the key step: applying reverb by simulating how the room modifies the sound.
% Convolution mathematically "blends" the audio with the impulse response.
% If stereo, convert to mono by averaging channels
if size(audio_in, 2) > 1
    audio_in = mean(audio_in, 2);
end

audio_out = conv(audio_in, h);

% === Normalize the output to prevent clipping ===
% After convolution, the amplitude might go above 1 or below -1, which can cause distortion.
% We normalize it so the loudest part is at full scale, but it doesn't clip.
audio_out = audio_out / max(abs(audio_out));  % Keep the output within [-1, 1]

% === Playback the reverberated sound ===
% soundsc scales the signal automatically and plays it back.
% You should hear your original audio as if it's being played in your simulated room.
soundsc(audio_out, fs);  % fs is the sample rate we defined earlier (44100 Hz)

% === Optionally save the result to a new WAV file ===
% This lets you export the reverberated audio so you can use it outside of MATLAB.
% Great if you want to include it in a report or submit it as part of your project.
audiowrite('output_reverb.wav', audio_out, fs);

% Students can expand this section to include additional processing, such as
% normalizing the impulse response, using frequency-dependent absorption, or
% implementing higher-order reflections.


 %% 4.5 SEE SIGNAL WET AND DRY ALONGSIDE EACHOTHER
 
 t_audio = (0:length(audio_in)-1)/fs;
t_reverb = (0:length(audio_out)-1)/fs;

figure;
subplot(2,1,1);
plot(t_audio, audio_in);
title('Original (Dry) Audio');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(2,1,2);
plot(t_reverb, audio_out);
title('Reverberated (Wet) Audio');
xlabel('Time (s)'); ylabel('Amplitude');

%% 5. Simple Spectral Analysis

% Load the reverberated audio
[y, fs] = audioread('output_reverb.wav');

% If stereo, convert to mono
if size(y, 2) > 1
    y = mean(y, 2);
end

% Compute the FFT
Y = fft(y);
N = length(Y);
f = fs * (0:(N/2)) / N;

% Get magnitude
mag = abs(Y(1:N/2+1));

% Plot the magnitude spectrum
figure;
plot(f, mag);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Spectral Analysis of Output Reverb');
grid on;

%% Auralisation
%% 6. Simple 3D Auralisation (with Floor Reflection)

% Create a 3D figure
figure;
hold on;             % Keep all plotted items in the same figure
grid on;             % Add gridlines for clarity
axis equal;          % Make axes proportional
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('3D Room Auralisation');

% ==== Draw Room Edges ====
% Plot the floor outline (just a square on the bottom)
plot3([0 room_length room_length 0 0], ...
      [0 0 room_width room_width 0], ...
      [0 0 0 0 0], 'k');  % Black line for floor

% Plot the ceiling outline (same shape, higher up)
plot3([0 room_length room_length 0 0], ...
      [0 0 room_width room_width 0], ...
      [room_height room_height room_height room_height room_height], 'k');  % Ceiling

% ==== Plot Real Source and Receiver ====
% Source (red circle)
plot3(src_pos(1), src_pos(2), src_pos(3), 'ro', 'MarkerSize', 10);

% Receiver (green circle)
plot3(rec_pos(1), rec_pos(2), rec_pos(3), 'go', 'MarkerSize', 10);

% ==== Define 5 Reflected Image Sources ====
% These represent mirrored versions of the sound source due to reflections
img1 = [src_pos(1) + room_length, src_pos(2), src_pos(3)];     % Right wall
img2 = [src_pos(1) - room_length, src_pos(2), src_pos(3)];     % Left wall
img3 = [src_pos(1), src_pos(2) + room_width, src_pos(3)];      % Back wall
img4 = [src_pos(1), src_pos(2), src_pos(3) + room_height];     % Ceiling
img5 = [src_pos(1), src_pos(2), src_pos(3) - room_height];     % Floor

% ==== Plot the Image Sources ====
% Blue 'x' markers for each image source
plot3(img1(1), img1(2), img1(3), 'bx');
plot3(img2(1), img2(2), img2(3), 'bx');
plot3(img3(1), img3(2), img3(3), 'bx');
plot3(img4(1), img4(2), img4(3), 'bx');
plot3(img5(1), img5(2), img5(3), 'bx');

% ==== Draw Reflection Paths to Receiver ====
% Dashed blue lines show sound traveling from each image source to the receiver
line([img1(1) rec_pos(1)], [img1(2) rec_pos(2)], [img1(3) rec_pos(3)], 'Color', 'b', 'LineStyle', '--');
line([img2(1) rec_pos(1)], [img2(2) rec_pos(2)], [img2(3) rec_pos(3)], 'Color', 'b', 'LineStyle', '--');
line([img3(1) rec_pos(1)], [img3(2) rec_pos(2)], [img3(3) rec_pos(3)], 'Color', 'b', 'LineStyle', '--');
line([img4(1) rec_pos(1)], [img4(2) rec_pos(2)], [img4(3) rec_pos(3)], 'Color', 'b', 'LineStyle', '--');
line([img5(1) rec_pos(1)], [img5(2) rec_pos(2)], [img5(3) rec_pos(3)], 'Color', 'b', 'LineStyle', '--');

% ==== Add Legend and Set 3D View ====
legend('Room', 'Source', 'Receiver', 'Image Sources');
view(3);  % Set view to 3D



%% End of Script
