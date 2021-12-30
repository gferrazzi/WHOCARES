clear all; close all; clc
warning off

%% ADD PATHS and SUBJECT LIST
addpath(genpath('/mnt/raid/Giulio_Nigel_Marco_Daniele_fmri/packages/'))
addpath(genpath('/mnt/raid/Giulio_Nigel_Marco_Daniele_fmri/scripts_paper/'))
%load('/mnt/raid/Giulio_Nigel_Marco_Daniele_fmri/subject_list_badQC_yes_correlation.txt')
%subject_list = subject_list_badQC_yes_correlation;
load('/mnt/raid/Giulio_Nigel_Marco_Daniele_fmri/subject_list_alltodo.txt')
subject_list = subject_list_alltodo;
[SUB,~]=size(subject_list);

%% LOOP OVER SUBJECTS
for sub = 577 : SUB
    
    disp(['Calculating subject ' num2str(subject_list(sub,1)) ' ' num2str(floor(sub/SUB*100)) '% '])
    
    cd(['/mnt/raid/Giulio_Nigel_Marco_Daniele_fmri/processing/' num2str(subject_list(sub,1))])
    mkdir('PROCESSED')
    cd('PROCESSED/')
    system('rm -rf OTHERSTUFF4')
    cd('GLOBAL4')
    
    system('gunzip data_detrend.nii.gz')
    system('gunzip regressor.nii.gz')
    
    %% DATA LOCATION
    mask = load_untouch_nii('brain_mask.nii');
    mask = mask.img;
    
    data_container = load_untouch_nii('data_detrend.nii');
    data = data_container.img;
    [X, Y , Z, T] = size(data);
    
    regressor_proposed = load_untouch_nii('regressor.nii');
    regressor_proposed = regressor_proposed.img;
    
    system('gzip regressor.nii')
    system('gzip data_detrend.nii')
    
    cd('../RETROICOR')
    system('gunzip regressor.nii.gz')
    
    regressor_retroicor = load_untouch_nii('regressor.nii');
    regressor_retroicor = regressor_retroicor.img;
   
    system('gzip regressor.nii')
    
    npoints=size(data,4);
    rp = reshape(regressor_proposed,[],npoints)';
    ind=find(abs(mask));
    rp=rp(:,ind);
    rr = reshape(regressor_retroicor,[],npoints)';
    rr=rr(:,ind);
    data = reshape(data,[],npoints)';
    data=data(:,ind);
    
    nvoxels=length(ind);
    JMI=zeros(nvoxels,1);MI1=JMI;MI2=JMI;
    parfor ivoxel=1:nvoxels
        D=[data(:,ivoxel),rp(:,ivoxel),rr(:,ivoxel)];
        D=copnorm(D);
        [JMI(ivoxel), MI1(ivoxel), MI2(ivoxel)]=compute_info3(D(:,1),D(:,2),D(:,3));
    end
    RED=min(MI1,MI2);
    U1=MI1-RED;
    U2=MI2-RED;
    SYN=JMI-RED-U1-U2;
    II=JMI-MI1-MI2;
    
    MI1_im = zeros(1,X*Y*Z);
    MI1_im(ind) = MI1; %you load MI1 and Ind from Daniele's solution
    MI1_im = reshape(MI1_im, [X Y Z]);
    
    MI2_im = zeros(1,X*Y*Z);
    MI2_im(ind) = MI2; %you load MI1 and Ind from Daniele's solution
    MI2_im = reshape(MI2_im, [X Y Z]);
    
    JMI_im = zeros(1,X*Y*Z);
    JMI_im(ind) = JMI; %you load MI1 and Ind from Daniele's solution
    JMI_im = reshape(JMI_im, [X Y Z]);
    
    RED_im = zeros(1,X*Y*Z);
    RED_im(ind) = RED; %you load MI1 and Ind from Daniele's solution
    RED_im = reshape(RED_im, [X Y Z]);
    
    U1_im = zeros(1,X*Y*Z);
    U1_im(ind) = U1; %you load MI1 and Ind from Daniele's solution
    U1_im = reshape(U1_im, [X Y Z]);
    
    U2_im = zeros(1,X*Y*Z);
    U2_im(ind) = U2; %you load MI1 and Ind from Daniele's solution
    U2_im = reshape(U2_im, [X Y Z]);
    
    SYN_im = zeros(1,X*Y*Z);
    SYN_im(ind) = SYN; %you load MI1 and Ind from Daniele's solution
    SYN_im = reshape(SYN_im, [X Y Z]);
    
    II_im = zeros(1,X*Y*Z);
    II_im(ind) = II; %you load MI1 and Ind from Daniele's solution
    II_im = reshape(II_im, [X Y Z]);
  
    cd('../')
    
    data_container.hdr.dime.dim(5) = 1;
    data_container.img = MI1_im*100000;
    save_untouch_nii(data_container,'GLOBAL4/MI.nii')
    
    data_container.img = MI2_im*100000;
    save_untouch_nii(data_container,'RETROICOR/MI.nii')
    
    mkdir('OTHERSTUFF4')
    
    data_container.img = JMI_im*100000;
    save_untouch_nii(data_container,'OTHERSTUFF4/JMI.nii')
    data_container.img = RED_im*100000;
    save_untouch_nii(data_container,'OTHERSTUFF4/RED.nii')
    data_container.img = U1_im*100000;
    save_untouch_nii(data_container,'OTHERSTUFF4/U1.nii')
    data_container.img = U2_im*100000;
    save_untouch_nii(data_container,'OTHERSTUFF4/U2.nii')
    data_container.img = SYN_im*100000;
    save_untouch_nii(data_container,'OTHERSTUFF4/SYN.nii')
    system('cp OTHERSTUFF4/SYN.nii OTHERSTUFF4/II.nii')
    system('/mnt/raid/Giulio/software/irtk/convert OTHERSTUFF4/II.nii OTHERSTUFF4/II.nii -short')
    data_container = load_untouch_nii('OTHERSTUFF4/II.nii');
    data_container.img = II_im*100000;
    save_untouch_nii(data_container,'OTHERSTUFF4/II.nii')
    
end
