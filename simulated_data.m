clc; clear; close all;

% Simulation Parameters
base_freq = 50;                % Base frequency (Hz)
T_cycle = 1 / base_freq;       % Duration of one cycle
N_cycles = 20;                 % Number of cycles
f_samp = 10000;                % Sampling frequency (Hz)

RPM = 1800;                    % Rotational speed
f_rot = RPM / 60;              % Rotational frequency

Nb = 8;                        % Number of balls
Bd = 8;                        % Ball diameter (mm)
Pd = 40;                       % Pitch diameter (mm)
phi = deg2rad(0);              % Contact angle in radians

% Time vector
t_arr = 0:(1/f_samp):(N_cycles*T_cycle);
N_arr = length(t_arr);

% Fault Frequencies
BPFI = 0.5 * Nb * f_rot * (1 + (Bd/Pd)*cos(phi));
BPFO = 0.5 * Nb * f_rot * (1 - (Bd/Pd)*cos(phi));
BSF  = (Pd / (2 * Bd)) * f_rot * (1 - ((Bd/Pd)^2)*(cos(phi)^2));
FTF  = 0.5 * f_rot * (1 - (Bd/Pd)*cos(phi));

fprintf("Fault Frequencies (Hz):\nBPFI: %.2f | BPFO: %.2f | BSF: %.2f | FTF: %.2f\n\n", BPFI, BPFO, BSF, FTF);


% Healthy Signal
healthy_signal = 1.0 * sin(2*pi*f_rot*t_arr);
% Faulty Signal = Healthy + Fault Frequencies
fault_signal = healthy_signal + ...
               0.3 * sin(2*pi*BPFO*t_arr) + ...
               0.3 * sin(2*pi*BPFI*t_arr) + ...
               0.2 * sin(2*pi*BSF*t_arr)  + ...
               0.2 * sin(2*pi*FTF*t_arr);

% FFT Calculation (for both)
% Healthy
Y_h = fft(healthy_signal);
A_h = abs(Y_h) / N_arr;
A_h_dB = 20*log10(2 * A_h(1:floor(N_arr/2)) + eps);

% Faulty
Y_f = fft(fault_signal);
A_f = abs(Y_f) / N_arr;
A_f_dB = 20*log10(2 * A_f(1:floor(N_arr/2)) + eps);

% Frequency axis
freq_arr = (0:floor(N_arr/2)-1) * (f_samp / N_arr);

% Plot FFT in dB (Healthy vs Faulty)
figure;
semilogx(freq_arr, A_h_dB, 'b', 'LineWidth', 1.2); hold on;
semilogx(freq_arr, A_f_dB , 'r--', 'LineWidth', 1.2);

% Mark fault frequencies
xline(BPFI, '--k', 'BPFI', 'LabelVerticalAlignment', 'bottom');
xline(BPFO, '--r', 'BPFO', 'LabelVerticalAlignment', 'bottom');
xline(BSF,  '--g', 'BSF',  'LabelVerticalAlignment', 'bottom');
xline(FTF,  '--m', 'FTF',  'LabelVerticalAlignment', 'bottom');

xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('FFT Comparison: Healthy vs Faulty Signal');
legend('Healthy', 'Faulty', 'Location', 'northeast');
grid on;
xlim([freq_arr(2), f_samp/2]);  % Avoid log(0)
ylim([-100, 10]);