% Biosignal Processing II - Lab 1
% Artifact removal from EEG

clear;
clc;
close all;

%% TASK 1 - Data Loading
% Load data
load('EEGdata.mat');

% 1) Plot raw EEG data
figure('Name','Raw EEG');
plot(t, signal + spread, 'LineWidth', 0.8);
xlabel('Time (s)');
ylabel('Amplitude + spread');
title('Raw EEG Signals');
grid on;


%% TASK 2 - Basic Filtering

% Create filters from exported design functions
lpFilt = design_lp_filter;
hpFilt = design_hp_filter;
notchFilt = design_notch_filter;

% Apply filters in order:
% 1) high-pass -> remove trend
% 2) notch -> remove 50 Hz power-line interference
% 3) low-pass -> remove high-frequency noise/spikes

hp1_signal = filter(hpFilt, signal);
notch_signal = filter(notchFilt, hp1_signal);
hp_signal = filter(lpFilt, notch_signal);

% Plot filtered EEG
figure
plot(t, hp_signal + spread)
title('HP + Notch + LP Filtered EEG')
xlabel('Time (s)')
ylabel('Amplitude + spread')
grid on

%% TASK 3 - Adaptive filtering (LMS)

% First LMS stage: use EOG1 (channel 14) as reference
% Initialize variable
eog1_filtered = zeros(size(hp_signal));

% Iterate over channels
for ch = 1:size(hp_signal, 2)
    % New LMS filter for each channel
    LMS_filter = dsp.LMSFilter('Length', 11, ...
                               'Method', 'LMS', ...
                               'StepSize', 0.6, ...
                               'WeightsOutputPort', false);

    x_ref = hp_signal(:,14);   % EOG1 reference
    d_sig = hp_signal(:,ch);   % channel to be cleaned

    % Run 10 iterations, keep the 10th output
    for k = 1:10
        [~, e] = step(LMS_filter, x_ref, d_sig);
        d_sig = e;
    end

    eog1_filtered(:,ch) = d_sig;
end

% Second LMS stage: use EOG2 after first LMS stage
% Initialize variable
eog12_filtered = zeros(size(eog1_filtered));

% Iterate over channels
for ch = 1:size(eog1_filtered, 2)
    % LMS filter for each channel
    LMS_filter = dsp.LMSFilter('Length', 11, ...
                               'Method', 'LMS', ...
                               'StepSize', 0.6, ...
                               'WeightsOutputPort', false);

    x_ref = eog1_filtered(:,15);
    d_sig = eog1_filtered(:,ch);

    % Run 10 iterations, keep the 10th output
    for k = 1:10
        [~, e] = step(LMS_filter, x_ref, d_sig);
        d_sig = e;
    end

    eog12_filtered(:,ch) = d_sig;
end

% Plot LMS stage 1
figure
plot(t, eog1_filtered + spread)
title('EEG after LMS filtering using EOG1')
xlabel('Time (s)')
ylabel('Amplitude + spread')
grid on

% Plot LMS stage 2
figure
plot(t, eog12_filtered + spread)
title('EEG after LMS filtering using EOG1 and EOG2')
xlabel('Time (s)')
ylabel('Amplitude + spread')
grid on

%% TASK 4 - ICA artifact removal

addpath('FastICA_25')
rng(666)

% Run ICA using the filtered EEG
[icasig, A, W] = fastica(hp_signal');

% Convert ICs to time x components
IC = icasig';
IC_scaled = IC/100;

[nSamples, nIC] = size(IC_scaled);
spread_ica = repmat(linspace(0, -1.4, nIC), nSamples, 1);

% Plot independent components
figure
plot(t, IC_scaled + spread_ica)
title('Independent Components (ICA)')
xlabel('Time (s)')
ylabel('Amplitude + spread')
grid on

% Select artifact components after visual inspection
artifact_idx = [1 2 3 4 5 6];

% Remove artifacts
IC_clean = IC';
IC_clean(artifact_idx, :) = 0;

% Reconstruct EEG
clean_eeg = (A * IC_clean)';

figure
plot(t, clean_eeg + spread)
title('ICA Cleaned EEG')
xlabel('Time (s)')
ylabel('Amplitude + spread')
grid on
