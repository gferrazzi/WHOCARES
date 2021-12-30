function regressor_out = WHOCARES_pipeline( stringData, stringMask, TR, MB, FW, NW, T, bpm_iter)

% Giulio Ferrazzi, December 2021
% WHOCARES: Data-driven WHOle-brain CArdiac signal REgression from highly Sampled fMRI acquisitions by Nigel Colenbier, Marco Marino, Giorgio Arcara, Blaise Frederick, Giovanni Pellegrino, Daniele Marinazzo, Giulio Ferrazzi - submitted manuscript

% Entry point for WHOCARES, builds the cardiac regressor

%% INPUT
% stringData = input fMRI path
% stringMask = input mask path
% TR         = repetition time
% MB         = multiband factor
% FW         = width of temporal filter  (in Hz)
% NW         = segment length
% bpm_iter   = average heart-rate per segment
%% OUTPUT
% regressor_out = cardiac regressor

%% LOAD DATA
data_container = load_untouch_nii(stringData); data = double(data_container.img);
mask = load_untouch_nii(stringMask); mask = double(mask.img);
data = bsxfun(@times, data, mask);

%% DETRENDING fMRI DATA with 3rd ORDER POLYNOMIA
[X, Y, totZ, NV] = size(data);        
opol = 3;
for x = 1 : X 
for y = 1 : Y
    for z = 1 : totZ
        voxel = squeeze(data(x,y,z,:));
        [p,s,mu] = polyfit((1:NV)',voxel,opol);
        f_y = polyval(p,(1:NV)',[],mu);
        voxel = voxel-f_y+mean(voxel);
        data(x,y,z,:) = reshape(voxel,[1 1 1 NV]);
    end
end
end

%% SAVE DETRENDED DATA
data_container.img = data;
data_container.hdr.dime.dim(5) = NV;
save_untouch_nii(data_container,'data_detrend.nii')

%% EXTRACTING CARDIAC SIGNAL
numWindows = floor((size(data,4)-NW)/(NW-T)+1);
regressor_out = [];
for mbpack = 1 : totZ/MB      % for each block B

data_toProcess = data(:,:,MB*(mbpack-1)+1:MB*(mbpack),:);    % select block
[~, ~, smallZ, ~] = size(data_toProcess);

cardiac_regressor = zeros(X,Y,smallZ,NV,4);
regressor = zeros(X,Y,smallZ,NV);   

for iter = 1:numWindows      % for each segment W

    cardiac_freq = bpm_iter(iter)/60;     % average HR from happy

    bandpassNS = [cardiac_freq-FW 2/TR-cardiac_freq-FW 2/TR+cardiac_freq-FW 4/TR-cardiac_freq-FW;        % cut-off frequencies of the filter
       cardiac_freq+FW 2/TR-cardiac_freq+FW 2/TR+cardiac_freq+FW 4/TR-cardiac_freq+FW];

    start = ((iter-1)*(NW-T)+1); stop = ((iter-1)*(NW-T)+NW);      % select segment within block
    data_window  = data_toProcess(:,:,:,start:stop);
    data_smooth  = smooth_data_window(data_window,1);              % spatial smoothing
    data_smooth(isnan(data_smooth)) = 0;
   
    regressor_chunk = cardiac_extraction(data_smooth,TR,1,bandpassNS,mask(:,:,MB*(mbpack-1)+1:MB*(mbpack)));    % extract cardiac_frequencies

    cardiac_regressor(:,:,:,start:start+(NW-T-1),:) = regressor_chunk(:,:,:,1:(NW-T),:);    % compound data

end

%% ADD ANATOMY
cardiac_regressor = bsxfun(@times, cardiac_regressor, mean(data_toProcess,4));        
clear regressor_chunk; clear data_window; 
[~,~,~,~,F] = size(cardiac_regressor);

%% LINEAR FITTING
BETA = zeros(X*Y*smallZ,F+1);
firstSignal  = reshape(cardiac_regressor,[X*Y*smallZ NV F]);
clear cardiac_regressor;
firstSignal  = permute(firstSignal,[2 3 1]);
firstSignal  = bsxfun(@minus,firstSignal,mean(firstSignal,1));
firstSignal  = cat(2, firstSignal,ones(NV,1,X*Y*smallZ));
secondSignal = reshape(data_toProcess,[X*Y*smallZ NV]);
secondSignal = permute(secondSignal,[2 3 1]);

for index = 1 : X*Y*smallZ
    beta = firstSignal(:,:,index)\secondSignal(:,:,index);  
    for f = 1 : F+1
        BETA(index,f)  = beta(f);
    end
end
BETA = reshape(BETA,[X Y smallZ 1 (F+1)]);
BETA(isnan(BETA)) = 0;
BETA(isinf(BETA)) = 0;

%% CONSTRUCTING REGRESSOR, i.e. SUMMING BETAS 
firstSignal  = permute(firstSignal,[3 1 2]);
firstSignal  = reshape(firstSignal,[X Y smallZ NV F+1]);

for f = 1 : F+1
    regressor = regressor + bsxfun(@times,BETA(:,:,:,1,f), firstSignal(:,:,:,:,f));
end

% compounding blocks
regressor_out = cat(3,regressor_out,regressor);  

end

%% SAVING REGRESSOR
regressor_out(isnan(regressor_out)) = 0;
regressor_out(isinf(regressor_out)) = 0;
data_container.img = regressor_out;
data_container.hdr.dime.dim(5) = NV;
save_untouch_nii(data_container,'regressor.nii')

end
