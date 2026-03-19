%% Lab 2 Biosignal Processing
clear
close all
clc

% Load dataset
load('data_2.mat')


%% Task 1 - Bandpass filtering and RMS envelopes
% Delta filter (1–4 Hz)
%Fs = 200; % Sampling Frequency
N  = 800; % Order
Fc1 = 1;  % First Cutoff Frequency
Fc2 = 4;  % Second Cutoff Frequency
flag = 'scale';

% Create window
win = hamming(N+1);

% FIR filter coefficients
b = fir1(N,[Fc1 Fc2]/(Fs/2),'bandpass',win,flag);

Hd = dfilt.dffir(b);

% Apply delta filter
delta = filter(Hd, signal);

% Theta filter (4–8 Hz)-------------------------------------
N  = 800;
Fc1 = 4;
Fc2 = 8;
flag = 'scale';

win = hamming(N+1);
b = fir1(N,[Fc1 Fc2]/(Fs/2),'bandpass',win,flag);
Hd = dfilt.dffir(b);

theta = filter(Hd, signal);

% Alpha filter (8–12 Hz)-------------------------------------
N  = 800;
Fc1 = 8;
Fc2 = 12;
flag = 'scale';

win = hamming(N+1);
b = fir1(N,[Fc1 Fc2]/(Fs/2),'bandpass',win,flag);
Hd = dfilt.dffir(b);

alpha = filter(Hd, signal);

% Beta filter (12–25 Hz)-------------------------------------
N  = 800;
Fc1 = 12;
Fc2 = 25;
flag = 'scale';

win = hamming(N+1);
b = fir1(N,[Fc1 Fc2]/(Fs/2),'bandpass',win,flag);
Hd = dfilt.dffir(b);

beta = filter(Hd, signal);

% RMS envelopes
windowSize = 30 * Fs;

[up_raw, low_raw] = envelope(signal, windowSize, 'rms');
[up_delta, low_delta] = envelope(delta, windowSize, 'rms');
[up_theta, low_theta] = envelope(theta, windowSize, 'rms');
[up_alpha, low_alpha] = envelope(alpha, windowSize, 'rms');
[up_beta,  low_beta]  = envelope(beta,  windowSize, 'rms');

% Plot raw EEG and filtered bands with RMS envelopes
figure

subplot(5,1,1)
plot(t, signal)
hold on
plot(t, up_raw, 'r')
plot(t, low_raw, 'r')
title('Raw EEG')
xlabel('Time (min)')
ylabel('Amplitude')
set(gca,'ylim',[-0.03 0.03])

subplot(5,1,2)
plot(t, delta)
hold on
plot(t, up_delta, 'r')
plot(t, low_delta, 'r')
title('Delta band (1–4 Hz)')
xlabel('Time (min)')
ylabel('Amplitude')
set(gca,'ylim',[-0.03 0.03])

subplot(5,1,3)
plot(t, theta)
hold on
plot(t, up_theta, 'r')
plot(t, low_theta, 'r')
title('Theta band (4–8 Hz)')
xlabel('Time (min)')
ylabel('Amplitude')
set(gca,'ylim',[-0.03 0.03])

subplot(5,1,4)
plot(t, alpha)
hold on
plot(t, up_alpha, 'r')
plot(t, low_alpha, 'r')
title('Alpha band (8–12 Hz)')
xlabel('Time (min)')
ylabel('Amplitude')
set(gca,'ylim',[-0.03 0.03])

subplot(5,1,5)
plot(t, beta)
hold on
plot(t, up_beta, 'r')
plot(t, low_beta, 'r')
title('Beta band (12–25 Hz)')
xlabel('Time (min)')
ylabel('Amplitude')
set(gca,'ylim',[-0.03 0.03])


%% Task 2 - Spectrogram and relative band powers

% Spectrogram parameters
window = 30 * Fs;
noverlap = 29 * Fs;
freq_vector = 0.1:0.1:32;

% Compute spectrogram
[S,F,T,P] = spectrogram(signal, window, noverlap, freq_vector, Fs);

% Total power in 0.1-32 Hz
total_power = sum(P, 1);

% Frequency indices for each band
idx_delta = (F >= 1 & F < 4);
idx_theta = (F >= 4 & F < 8);
idx_alpha = (F >= 8 & F < 12);
idx_beta  = (F >= 12 & F <= 25);

% Relative band powers
rel_delta = sum(P(idx_delta, :), 1) ./ total_power;
rel_theta = sum(P(idx_theta, :), 1) ./ total_power;
rel_alpha = sum(P(idx_alpha, :), 1) ./ total_power;
rel_beta  = sum(P(idx_beta, :), 1) ./ total_power;

% Plot the results
figure

subplot(3,1,1)
imagesc(T/60, F, log10(P), [-7 -3])
axis xy
colormap(jet)
colorbar
axis xy
xlabel('Time (min)')
ylabel('Frequency (Hz)')
title('Spectrogram')

subplot(3,1,2)
plot(T/60, rel_delta, 'b', 'LineWidth',1.5)
hold on
plot(T/60, rel_theta, 'r', 'LineWidth',1.5)
plot(T/60, rel_alpha, 'g', 'LineWidth',1.5)
plot(T/60, rel_beta,  'm', 'LineWidth',1.5)
xlabel('Time (min)')
ylabel('Relative power')
title('Relative band powers')
legend('Delta','Theta','Alpha','Beta')
ylim([0 1])
grid on


%% Task 3 - Spectral entropy

SE = zeros(1, length(T));

for i = 1:length(T)

    % Normalize power spectrum
    p = P(:,i) / sum(P(:,i));

    % Avoid log(0)
    p(p == 0) = eps;

    % Spectral entropy
    SE(i) = -sum(p .* log2(p));

end

% Plot the results
subplot(3,1,3)
plot(T/60, SE, 'c', 'LineWidth',2)
xlabel('Time (min)')
ylabel('Spectral entropy')
title('Spectral entropy of EEG')
grid on