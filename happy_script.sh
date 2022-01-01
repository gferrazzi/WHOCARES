#!/bin/bash

#This bash script runs the happy pipeline to extract PPG/EEG-like signals from the fMRI data. For more information please refer to:

#Aslan, S., Hocke, L., Schwarz, N., Frederick, B., 2019. Extraction of the cardiac waveform from simultaneous multislice fMRI data using slice sorted averaging and a deep learning reconstruction filter. Neuroimage 198, 303-316

#Happy OUTPUT in @WHOCARES/processing/$SUBJECT/PROCESSED/WHOCARES/happy/

subjectlist=subject_list.txt

for subject in $(cat $subjectlist);
 do

    source_dir=${PWD}/processing/$subject/DATA/rfMRI_REST1_LR
    results_dir=${PWD}/processing/$subject/PROCESSED/WHOCARES/happy	

    mkdir -p ${PWD}/processing/$subject/PROCESSED/
    mkdir -p ${PWD}/processing/$subject/PROCESSED/WHOCARES/ 
    mkdir -p ${PWD}/processing/$subject/PROCESSED/WHOCARES/happy

    sudo chmod -R 777 ${PWD}/processing/

    #Use this to update rapidtide
    #sudo docker pull fredericklab/rapidtide
    #sudo docker pull fredericklab/rapidtide:latest

    #Run happy using docker image
    sudo docker run \
        -v=$source_dir:/input -v=${PWD}:/slicetiming -v=$results_dir:/output \
        fredericklab/rapidtide:latest happy \
        /input/${subject}_3T_rfMRI_REST1_LR.nii.gz \
        /slicetiming/slice_timing.txt \
        /output/fmri \
        --debug \
        --legacyoutput \
        --cardcalconly

done < $subjectlist
