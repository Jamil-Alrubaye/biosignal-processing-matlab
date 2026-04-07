%% LAB 3 - Topographic analysis of EEG

clear; close all; clc;
load('data_3.mat')

Fs = double(Fs);
signal = double(signal);
locFile = 'channelLocations.locs';


%% TASK 1 
figure
topoplot((1:size(signal,1))', locFile, 'style', 'blank', 'electrodes', 'labelpoint');
title('Electrode locations')


%% TASK 2 - Spectrogram and total power

% Spectrogram parameters
win = 30 * Fs;
noverlap = 29 * Fs;
freqVec = 0.1:0.1:32;

% Compute spectrogram for each channel
for ch = 1:size(signal,1)
    [~, F, T, P{ch}] = spectrogram(signal(ch,:), win, noverlap, freqVec, Fs);
end

% Total power across all frequencies
totalPower = zeros(size(signal,1), length(T));
for ch = 1:size(signal,1)
    totalPower(ch,:) = sum(P{ch}, 1);
end

% Time in minutes
timeMin = T / 60;

% Indices for selected time points
idx1 = 1; 
[~, idx2] = min(abs(T - 120));
[~, idx5] = min(abs(T - 300));
[~, idx7] = min(abs(T - 420));

idx = [idx1 idx2 idx5 idx7];
names = {'Start','2 min','5 min','7 min'};

% Topoplots of log10(total power)
figure
for k = 1:4
    subplot(2,2,k)
    topoplot(log10(totalPower(:,idx(k))), locFile, ...
        'maplimits', 'maxmin', 'electrodes', 'labelpoint');
    colorbar
    title(['Log_{10}(Total Power) - ' names{k}])
end


%% TASK 2b - Frontal vs rear power

% Channel indices (from electrode layout)
frontalIdx = [3 4 2 1];
rearIdx = [8 12 7 13];

% Sum power for regions
frontalSum = sum(totalPower(frontalIdx,:), 1);
rearSum = sum(totalPower(rearIdx,:), 1);

% Plot comparison
figure
plot(timeMin, log10(frontalSum), 'LineWidth', 1.5)
hold on
plot(timeMin, log10(rearSum), 'LineWidth', 1.5)
grid on
xlabel('Time (min)')
ylabel('log_{10}(Power)')
legend('Frontal','Rear','Location','best')
title('Frontal vs Rear total power')


%% TASK 3 - Relative alpha and delta power

% Frequency bands
alphaMask = (F >= 8 & F < 12);
deltaMask = (F >= 1 & F < 4);
totalMask = (F >= 0.1 & F <= 32);

% Preallocate
relAlpha = zeros(size(signal,1), length(T));
relDelta = zeros(size(signal,1), length(T));

% Compute relative powers
for ch = 1:size(signal,1)
    totalBand = sum(P{ch}(totalMask,:), 1);
    alphaPower = sum(P{ch}(alphaMask,:), 1);
    deltaPower = sum(P{ch}(deltaMask,:), 1);

    relAlpha(ch,:) = alphaPower ./ totalBand;
    relDelta(ch,:) = deltaPower ./ totalBand;
end

% Plot topoplots
figure
for k = 1:4

    % Alpha
    subplot(4,2,2*k-1)
    topoplot(relAlpha(:,idx(k)), 'channelLocations.locs', ...
        'maplimits', [0 1], 'electrodes', 'labelpoint');
    colorbar
    title(['Relative Alpha - ' names{k}])

    % Delta
    subplot(4,2,2*k)
    topoplot(relDelta(:,idx(k)), 'channelLocations.locs', ...
        'maplimits', [0 1], 'electrodes', 'labelpoint');
    colorbar
    title(['Relative Delta - ' names{k}])
end

