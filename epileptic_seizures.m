%% LAB 4 - Epileptic seizures

clear; close all; clc;
load('data_4.mat')

signal = double(signal);
Fs = double(Fs);

%% TASK 1 — RAW EEG + Spectrogram + Entropy
% Plot RAW EEG
figure
subplot(3,1,1)
plot(t, signal)
ylim([-1000 1000])
title('Raw EEG Signal')
xlabel('Time (min)')
ylabel('Amplitude')

% Spectrogram
% Parameters
win = 30 * Fs;
noverlap = 29 * Fs;
freqVec = 0.1:0.1:32;

[S,F,T,P] = spectrogram(signal, win, noverlap, freqVec, Fs);

subplot(3,1,2)
imagesc(T/60, F, log10(P)) %10*log10(P)
axis xy
% ylim([0 32]) 
clim([-4 6])
title('Spectrogram')
xlabel('Time (min)')
ylabel('Frequency (Hz)')

% Spectral Entropy
% Normalize power
P_norm = P ./ sum(P,1);

% Entropy
entropy = -sum(P_norm .* log(P_norm + eps),1);

subplot(3,1,3)
plot(T/60, entropy)
title('Spectral Entropy')
xlabel('Time (min)')
ylabel('Entropy')


%% TASK 2 — Ictal vs Interictal
%idx1 = round(5.5 * 60 * Fs); % ictal
%idx2 = round(2 * 60 * Fs); % interictal
%signal1 = signal(idx1 : idx1 + 10*Fs);
%signal2 = signal(idx2 : idx2 + 10*Fs);

signal1 = signal(:,320*Fs:330*Fs);
signal2 = signal(:,400*Fs:410*Fs);

figure

subplot(2,1,1)
plot(t1, signal1)
ylim([-1000 1000])
title('Ictal EEG Segment')

subplot(2,1,2)
plot(t1, signal2)
ylim([-1000 1000])
title('Interictal EEG Segment')


%% TASK 3 — Nonlinear (2D Embedding)
start = 208 * Fs;
stop  = 440 * Fs;

segment = signal(start:stop);

figure
subplot(2,1,1)
plot(t2, segment)
ylim([-1000 1000])
title('EEG Segment (Pre + Ictal + Post)')
xlabel('Time (s)')
ylabel('Amplitude')

delta = 67;
X = segment(1:end-delta);
Y = segment(1+delta:end);
N = length(X);

% Define approximate regions
ictal_start = round(0.4 * N);
ictal_end   = round(0.55 * N);

pre_idx   = 1:ictal_start;
ictal_idx = ictal_start:ictal_end;
post_idx  = ictal_end:N;

subplot(2,1,2)
plot([-1500 1500],[-1500 1500], '.')
hold on

plot(X(pre_idx),   Y(pre_idx),   'b.') % blue
plot(X(ictal_idx),Y(ictal_idx),'c.') % cyan
plot(X(post_idx), Y(post_idx),  'r.') % red

xlim([-1500 1500])
ylim([-1500 1500])
title('2D Embedding')
xlabel('X(i)')
ylabel('X(i+\Delta)')