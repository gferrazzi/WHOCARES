function filter_nstandard = cardiac_extraction(data,TR,MB,bandpassNS,mask_brain)

% Giulio Ferrazzi, December 2021
% WHOCARES: Data-driven WHOle-brain CArdiac signal REgression from highly accelerated simultaneous multi-Slice fMRI acquisitions by Nigel Colenbier, Marco Marino, Giorgio Arcara, Blaise Frederick, Giovanni Pellegrino, Daniele Marinazzo, Giulio Ferrazzi - submitted manuscript

% Cardiac signal extraction

%% INPUT
% data = input data
% TR         = repetition time
% MB         = multiband factor
% bandpassNS = cut off frequencies for filters
% mask_brain = brain mask
%% OUTPUT
% filter_nstandard = filtered cardiac components

data = double(data);

%% PARAMETERS
[X,Y,Z,T]  = size(data);
TS         = (TR/Z)*MB;            % time between two consecutive slices
newT       = (Z/MB)*T;             % new reformatted time dimension
newZ       = MB;                   % new reformatted slice dimension
sliceOrder = [1:2:Z/MB 2:2:Z/MB];  % slice order within block B

%% SETTING UP MASK
if isempty(mask_brain)
option = 1;
mask_brain = ones(X,Y,Z,T); 
else
option = 2;
mask_brain = repmat(mask_brain,[1 1 1 T]);
end

%% REMOVE ANATOMY
meanData = mean(data,4);  
data_noAnant = bsxfun(@rdivide, data, meanData);
data_noAnant(isnan(data_noAnant)) = 1;
data_noAnant(isinf(data_noAnant)) = 1;
data_noAnant = data_noAnant-1;

%% MEDIAN NORMALIZATION
for x = 1 : X 
for y = 1 : Y
    for z = 1 : Z
        voxel  = squeeze(data_noAnant(x,y,z,:));
        factor = median(abs(voxel-median(voxel)));
        voxel  = voxel/factor;
        data_noAnant(x,y,z,:) = reshape(voxel,[1 1 1 T]);           
    end
end
end
data_noAnant = data_noAnant+1;

%% REFORMATTED DATASET
toFilter = zeros(X,Y,newZ,newT);
toFilterM = zeros(X,Y,newZ,newT);
for newz = 1 : newZ
for t = 1 : T        
    order_slice = (Z/MB)*(newz-1)+1:(Z/MB)*newz;
    order_slice = order_slice(sliceOrder);
    order_time  = (Z/MB)*(t-1)+1:(Z/MB)*t;
    toFilter(:,:,newz,order_time) = permute(data_noAnant(:,:,order_slice,t),[1 2 4 3]);
    toFilterM(:,:,newz,order_time) = permute(mask_brain(:,:,order_slice,t),[1 2 4 3]);
end
end

if option == 1
toFilter(toFilter == 0) = 1;
else
toFilter(toFilterM == 0) = 1;
end
                  
%% FILTERING
[~, F] = size(bandpassNS);
TF = reshape(toFilter,[X*Y*newZ,newT])';
filtered=zeros(X,Y,newZ,newT,F);
for f = 1 : F

TF_F=rest_IdealFilter(TF, TS, [bandpassNS(1,f); bandpassNS(2,f)]);
TF_F=TF_F';
filtered(:,:,:,:,f) = reshape(TF_F,[X Y newZ newT]);

end 

%% REFORMAT OUTPUT
toSave = zeros(X,Y,Z,T,F);
for f = 1 : F
for newz = 1 : newZ
    for t = 1 : T        
        order_slice = (Z/MB)*(newz-1)+1:(Z/MB)*newz;
        order_slice = order_slice(sliceOrder);
        order_time  = (Z/MB)*(t-1)+1:(Z/MB)*t;
        toSave(:,:,order_slice,t,f) = permute(filtered(:,:,newz,order_time,f),[1 2 4 3 5]);    
    end
end 
end

filter_nstandard = bsxfun(@minus, toSave, mean(toSave,4)); 
filter_nstandard = filter_nstandard+1;

end
