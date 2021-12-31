function bpm = get_bpm(input_data)

% Giulio Ferrazzi, December 2021
% WHOCARES: Data-driven WHOle-brain CArdiac signal REgression from highly accelerated simultaneous multi-Slice fMRI acquisitions by Nigel Colenbier, Marco Marino, Giorgio Arcara, Blaise Frederick, Giovanni Pellegrino, Daniele Marinazzo, Giulio Ferrazzi - submitted manuscript

% average bpm from happy cardiac segment

%% INPUT
% input_data = happy cardiac segment at 25Hz
%% OUTPUT
% bpm = average bpm within segment

dt = 1/25;
input_data = input_data/max(input_data(:));
input_data = 2*(input_data-0.5);

time = linspace(0,length(input_data)*dt,length(input_data));
[~,peaks,~] = findpeaks(input_data,time,'MinPeakHeight',0.2,'MinPeakDistance',0.3);

bpm = peaks';
bpm = diff(bpm);
bpm = bpm(2:end-1);
bpm = (1./bpm)*60; 
bpm_plus = prctile(bpm,80);
bpm_minus = prctile(bpm,20);
bpm = bpm(bpm<=bpm_plus);
bpm = bpm(bpm>=bpm_minus);
bpm = median(bpm);

end

