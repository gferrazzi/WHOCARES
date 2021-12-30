function data_smooth = smooth_data_window(input_data,sigma)

% Giulio Ferrazzi, December 2021
% WHOCARES: Data-driven WHOle-brain CArdiac signal REgression from highly Sampled fMRI acquisitions by Nigel Colenbier, Marco Marino, Giorgio Arcara, Blaise Frederick, Giovanni Pellegrino, Daniele Marinazzo, Giulio Ferrazzi - submitted manuscript

% 2D spatial smoothing

%% INPUT
% input_data = 4D fMRI data
% sigma      = standard deviation (in px) of smoothing kernel
%% OUTPUT
% data_smooth = smoothed data

[X,Y,Z,T] = size(input_data);
data_smooth = zeros(size(input_data));
for islice = 1:Z
    for itime = 1:T
        data_smooth(:,:,islice,itime) = imgaussfilt(input_data(:,:,islice,itime),sigma);
    end
end
