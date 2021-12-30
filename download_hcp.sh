#!/bin/bash
subjectlist=subject_list.txt

for subject in $(cat $subjectlist);
 do

    mkdir -p processing/$subject
    mkdir -p processing/$subject/DATA

    #download rfMRI
    sudo aws s3 sync \
       s3://hcp-openaccess/HCP_1200/$subject/unprocessed/3T/rfMRI_REST1_LR/  \
       processing/$subject/DATA/rfMRI_REST1_LR/ \
       --region eu-central-1

done < $subjectlist

sudo chmod -R 777 processing/
