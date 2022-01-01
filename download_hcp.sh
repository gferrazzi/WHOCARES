#!/bin/bash

#this bash script downloads the data of one subject from the HCP project using AWS services (https://www.humanconnectome.org/study/hcp-young-adult/article/hcp-s1200-release-now-available-amazon-web-services). To download more subjects, append entries to file subject_list.txt

#ps: subject chosen corresponds to Figure 2 (top left) in the paper

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
