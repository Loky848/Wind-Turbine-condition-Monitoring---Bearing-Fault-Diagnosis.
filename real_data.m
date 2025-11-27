clc; clear; close all;

% ------------------------
% Parameters
% ------------------------
base_freq = 50;                  % Base frequency (Hz)
f_samp = 48000;                  % Sampling frequency (Hz)
duration = 1.6;                  % Duration in seconds
N_arr = floor(f_samp * duration);
t_arr = (0:N_arr-1) / f_samp;    % Time vector


Nb = 8;                          % Number of rolling elements
Bd = 7;                          % Ball diameter (mm)
Pd = 40;                         % Pitch diameter (mm)
phi = deg2rad(0);                % Contact angle in radians

real_data = load('111.mat');     
real_signal = real_data.X111_DE_time;    
rpm = real_data.X111RPM;
f_rot = rpm / 60;                % Rotational frequency (Hz)


% ------------------------
% Fault Frequencies
% ------------------------
BPFI = 0.5 * Nb * f_rot * (1 + (Bd/Pd) * cos(phi));
BPFO = 0.5 * Nb * f_rot * (1 - (Bd/Pd) * cos(phi));
BSF  = (Pd / (2 * Bd)) * f_rot * (1 - ((Bd/Pd)^2) * cos(phi)^2);
FTF  = 0.5 * f_rot * (1 - (Bd/Pd) * cos(phi));

fprintf("Fault Frequencies (Hz):\n");
fprintf("BPFI: %.2f | BPFO: %.2f | BSF: %.2f | FTF: %.2f\n\n", BPFI, BPFO, BSF, FTF);

% ------------------------
% Load Signals
% ------------------------

healthy_data = load('99.mat'); 
healthy_signal = healthy_data.X098_DE_time;   

% ------------------------

% ------------------------
% FFT of Envelope Signals
% ------------------------
Y_real = fft(real_signal);
Y_healthy = fft(healthy_signal);

A_real = abs(Y_real) / N_arr;
A_healthy = abs(Y_healthy) / N_arr;

A_real_dB = 20 * log10(2 * A_real(1:floor(N_arr/2)) + eps);
A_healthy_dB = 20 * log10(2 * A_healthy(1:floor(N_arr/2)) + eps);

freq_arr = (0:floor(N_arr/2)-1) * (f_samp / N_arr);

% ------------------------
% Plot Envelope Spectrum
% ------------------------
figure;
semilogx(freq_arr, A_healthy_dB, 'b', 'LineWidth', 1.2); hold on;
semilogx(freq_arr, A_real_dB, 'r--', 'LineWidth', 1.2);

% Mark key frequencies
xline(BPFI, '--k', 'BPFI', 'LabelVerticalAlignment', 'bottom');
xline(BPFO, '--r', 'BPFO', 'LabelVerticalAlignment', 'bottom');
xline(BSF,  '--g', 'BSF',  'LabelVerticalAlignment', 'bottom');
xline(FTF,  '--m', 'FTF',  'LabelVerticalAlignment', 'bottom');

xlabel('Frequency (Hz)');
ylabel('Envelope Amplitude (dB)');
legend('Healthy Twin', 'Real Signal');
grid on;
xlim([0 500]);
ylim([-100, 10])