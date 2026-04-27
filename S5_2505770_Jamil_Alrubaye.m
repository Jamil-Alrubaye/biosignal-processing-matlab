clear; close all; clc;
load('data_5.mat')

raw = double(data_samples.raw_data);
Fs  = double(data_samples.Fs);
scale = double(data_samples.amplitude_unit);

% Convert to microvolts
signal = raw * scale * 1e6;

[M, N] = size(signal); % M=100 trials, N=489 samples

t = (0:N-1) / Fs * 1000; % time in ms


%% TASK 1 Raw Signals & Ensemble Average
avg_signal = mean(signal, 1);

figure
plot(t, signal', 'Color', [0.7 0.7 0.7]) % all trials (gray)
hold on
plot(t, avg_signal, 'r', 'LineWidth', 2) % average (red)
xlabel('Time (ms)')
ylabel('Amplitude (µV)')
title('SSEP Trials and Ensemble Average')
grid on

%% TASK 2 SNR Calculation

noise_var_n = zeros(1, N);

for n = 1:N
    noise_var_n(n) = mean((signal(:,n) - avg_signal(n)).^2);
end

sigma_v2 = mean(noise_var_n); % Average noise variance

E_s = mean(avg_signal.^2); % Signal energy

SNR = 10 * log10(E_s / sigma_v2); % SNR (dB)

SNR_improvement = 20 * log10(sqrt(M)); % Averaging improvement

SNR_avg = SNR + SNR_improvement; % SNR after averaging

% Print result
fprintf('\n--- TASK 2 FEATURES ---\n');
fprintf('Noise variance: %.4f\n', sigma_v2);
fprintf('Signal energy: %.4f\n', E_s);
fprintf('SNR (dB): %.2f dB\n', SNR);
fprintf('Averaging improvement: %.2f dB\n', SNR_improvement);
fprintf('SNR after averaging: %.2f dB\n', SNR_avg);


%% TASK 3 Chirp Modeling (PSO)
addpath(genpath('SEPchirp_v101'))
addpath(genpath('PSOt'))

features = chirp_features(data_samples);

chirp_fit = features.fitted_chirp; % Extract fitted signal

% Plotting
figure
plot(t, signal', 'Color', [0.8 0.8 0.8])
hold on
plot(t, avg_signal, 'r', 'LineWidth', 2)
plot(t, chirp_fit, 'b', 'LineWidth', 2)

legend('Trials', 'Average', 'Chirp Fit')
xlabel('Time (ms)')
ylabel('Amplitude (µV)')
title('SSEP + Chirp Model')
grid on


%% TASK 4 Extract Features

chirp_delay      = features.fit_delay;
peak1_amp        = features.fit_first_peak_amplitude;
peak2_amp        = features.fit_second_peak_amplitude;
peak1_delay      = features.fit_first_peak_location;
peak2_delay      = features.fit_second_peak_location;

% Convert delays from seconds to milliseconds
%% TASK 4 Extract Features

fprintf('\n--- TASK 4 FEATURES ---\n');
fprintf('Chirp delay: %.2f ms\n', features.fit_delay * 1000);
fprintf('First peak amplitude: %.2f uV\n', features.fit_first_peak_amplitude);
fprintf('Second peak amplitude: %.2f uV\n', features.fit_second_peak_amplitude);
fprintf('First peak delay: %.2f ms\n', features.fit_first_peak_location * 1000);
fprintf('Second peak delay: %.2f ms\n', features.fit_second_peak_location * 1000);

% --- Third peak ---
start_idx = round(features.fit_second_peak_location * Fs); % start search after second peak

[third_amp, idx] = max(chirp_fit(start_idx:end)); % find max value (third peak)
third_idx = idx + start_idx - 1;  % convert to full signal index

third_delay_ms = (third_idx / Fs) * 1000; % convert index to time (ms)


% Plotting

figure
plot(t, signal', 'Color', [0.8 0.8 0.8])
hold on
plot(t, avg_signal, 'r', 'LineWidth', 2)
plot(t, chirp_fit, 'b', 'LineWidth', 2)

% Vertical dashed lines (like example figure)
xline(features.fit_delay * 1000, '--b', 'LineWidth', 1.5)
xline(features.fit_first_peak_location * 1000, '--b', 'LineWidth', 1.5)
xline(features.fit_second_peak_location * 1000, '--b', 'LineWidth', 1.5)
xline(third_delay_ms, '--r', 'LineWidth', 1.5)

% Horizontal dashed lines (correct polarity)
yline(features.fit_first_peak_amplitude, '--b', 'LineWidth', 1.5)
yline(-features.fit_second_peak_amplitude, '--b', 'LineWidth', 1.5)
yline(third_amp, '--r', 'LineWidth', 1.5)

legend('Trials', 'Average', 'Chirp Fit')
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
title('SSEP + Chirp Model + Extracted Features')
grid on


fprintf('Third peak delay: %.2f ms\n', third_delay_ms);


%fprintf('\n--- filesnames ---\n');
%fieldnames(features)