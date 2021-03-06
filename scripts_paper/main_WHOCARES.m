% Giulio Ferrazzi, December 2021
% WHOCARES: Data-driven WHOle-brain CArdiac signal REgression from highly accelerated simultaneous multi-Slice fMRI acquisitions by Nigel Colenbier, Marco Marino, Giorgio Arcara, Blaise Frederick, Giovanni Pellegrino, Daniele Marinazzo, Giulio Ferrazzi - submitted manuscript

% Main WHOCARES, computes cardiac regressor and mutual information map, loops over subjects

warning off
clear all; close all; clc

%% ADD PATHS and SUBJECT LIST
% insert here your WHOCARES folder
folder = '/home/giulio.ferrazzi@rc.fhsc.net/Desktop/gitHub/WHOCARES/';
cd(folder)

addpath(genpath([folder '/packages']))
addpath(genpath([folder '/scripts_paper']))
load([folder 'subject_list.txt'])
[SUB,~]=size(subject_list);

%% PARAMETERS
TR=0.72;              % repetition time
Z=72;                   % number of slices
MB=8;                  % multiband factor
sizeData=1200;   % number of volumes
FW=0.2;               % width of the temporal filter (Hz)
NW=20;                % number of frames per segment (in TRs). Note that the W parameter in the paper is NW*(Z/MB) = 180
T=0;                      % overlapping number of frames in successive segments, not tested, i.e. T=0 with no overlap
nregre = 8;           % number of regressors
smoothing = 1.5; % spatial smoothing (in pixels)

%% LOOP OVER SUBJECTS
for sub = 1 : SUB
    
    %% cd into STRUCTURE
    disp(['Processing Subject ' num2str(subject_list(sub,1)) ', ' num2str(round(sub/SUB*100)) ' %']);
    cd([folder '/processing/' num2str(subject_list(sub,1))]);
    cd('PROCESSED/');
    cd('WHOCARES/');

    %% DATA LOCATION
    stringData = ['../../DATA/rfMRI_REST1_LR/' num2str(subject_list(sub,1)) '_3T_rfMRI_REST1_LR.nii'];
    system(['gunzip -f ' stringData '.gz']);    
    system(['fslmaths ' stringData ' -Tmean brain_av.nii']); 
    system('bet brain_av.nii.gz brain.nii.gz -m -R');
    system('rm brain.nii.gz');
    system('rm brain_av.nii.gz');
    system('gunzip -f *.nii.gz');     
    stringMask = 'brain_mask.nii';
    stringDataHappy = 'happy/fmri_normcardfromfmri_dlfiltered_25.0Hz.txt';
    
    data_container = load_untouch_nii(stringMask); mask = data_container.img;
    [X, Y, Z] = size(mask);
    
    %% ESTIMATING AVERAGE HR PER SEGMENTS
    cardiac_signal = importdata(stringDataHappy);
    cardiac_signal = rest_IdealFilter(cardiac_signal, 1/25, [25/60; 150/60]); 
    
    numWindows = floor((sizeData-NW)/(NW-T)+1);
    ScaleFact = size(cardiac_signal,1)/sizeData;
    NW_bpm = floor(NW*ScaleFact);
    T_bpm = floor(T*ScaleFact);
    for iter = 1:numWindows
        log_window = cardiac_signal(((iter-1)*(NW_bpm-T_bpm)+1):((iter-1)*(NW_bpm-T_bpm)+NW_bpm));
        BPM=get_bpm(log_window);
        bpm_iter(iter)=BPM;
    end
    opol = 5;
    bpm_iter = [bpm_iter(end:-1:1) bpm_iter bpm_iter(end:-1:1)];
    [p,s,mu] = polyfit((1:length(bpm_iter)),bpm_iter,opol);
    f_y = polyval(p,(1:length(bpm_iter)),[],mu);
    bpm_iter = f_y(numWindows+1:2*numWindows);
    
    %% WHOCARES PIPELINE
    [data_detrend, regressor] = WHOCARES_pipeline(stringData, stringMask, TR, MB, FW, NW, T, bpm_iter, nregre, smoothing);

    data_detrend(isnan(data_detrend)) = 0;
    data_detrend(isinf(data_detrend)) = 0;
    data_container.img = data_detrend;
    data_container.hdr.dime.dim(1) = 4;
    data_container.hdr.dime.dim(5) = sizeData;
    save_untouch_nii(data_container,'data_detrend.nii')
    
    regressor(isnan(regressor)) = 0;
    regressor(isinf(regressor)) = 0;
    data_container.img = regressor;
    data_container.hdr.dime.dim(5) = sizeData;
    save_untouch_nii(data_container,'regressor.nii')
     
    meanData = mean(data_detrend, 4);
    fMRI_corrected = data_detrend-regressor;     
    fMRI_corrected = bsxfun(@plus,fMRI_corrected, meanData);
    data_container.img = fMRI_corrected;
    data_container.hdr.dime.dim(5) = sizeData;
    save_untouch_nii(data_container,'fMRI_corrected.nii')
    
    %% CALCULATE MUTUAL INFORMATION 
    ind=find(abs(mask));
    regressor = reshape(regressor,[],sizeData)';
    regressor=regressor(:,ind);
    data_detrend = reshape(data_detrend,[],sizeData)';
    data_detrend=data_detrend(:,ind);
    
    nvoxels=length(ind);
    parfor ivoxel=1:nvoxels
        D=[data_detrend(:,ivoxel),regressor(:,ivoxel)];
        D=copnorm(D);
        MI(ivoxel) = gcmi_cc(D(:,1),D(:,2));
    end
    
    MI_im = zeros(1,X*Y*Z);
    MI_im(ind) = MI;
    MI_im = reshape(MI_im, [X Y Z]);
    
    data_container.hdr.dime.dim(5) = 1;
    data_container.img = MI_im*10000;  % MI multiplied by 10000 to improve nifti dynamic range
    save_untouch_nii(data_container,'MI.nii')
    
    %% ZIPPING BIG FILES TO SAVE SPACE
    system('gzip data_detrend.nii')
    system('gzip fMRI_corrected.nii')
    system('gzip regressor.nii')
    system(['gzip ' stringData])

    clearvars -except sub SUB subject_list folder TR Z MB sizeData FW NW T nregre smoothing

end
