Code to perform data-driven cardiac signal regression from fMRI time-series as described in:

WHOCARES: Data-driven WHOle-brain CArdiac signal REgression from highly accelerated simultaneous multi-Slice fMRI acquisitions by Nigel Colenbier, Marco Marino, Giorgio Arcara, Blaise Frederick, Giovanni Pellegrino, Daniele Marinazzo, Giulio Ferrazzi - submitted manuscript

Pre-print available at https://arxiv.org/abs/2201.00744

Published paper available at https://iopscience.iop.org/article/10.1088/1741-2552/ac8bff

The package contains various (open source) toolboxes and Matlab functions. It requires FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki) and the happy toolbox (through docker). The documentation of the happy toolbox can be found at https://rapidtide.readthedocs.io/en/latest/index.html. The source code at https://github.com/bbfrederick/rapidtide.

It also requires the gcmi package, which can be cloned from here (https://github.com/robince/gcmi) and should be saved into the /packages folder or included into your Matlab path

Clone the repo onto Linux and run (in order) the following:

1. from terminal: source download_hcp.sh

this bash script downloads the data of one subject from the HCP project using AWS services (https://www.humanconnectome.org/study/hcp-young-adult/article/hcp-s1200-release-now-available-amazon-web-services). To download more subjects, append entries to file subject_list.txt

ps: subject chosen corresponds to Figure 2 (top left) in the paper

2. from terminal: source happy_script.sh

this bash script runs the happy pipeline to extract PPG/EEG-like signals from the fMRI data. For more information please refer to:

Aslan, S., Hocke, L., Schwarz, N., Frederick, B., 2019. Extraction of the cardiac waveform from simultaneous multislice fMRI data using
slice sorted averaging and a deep learning reconstruction filter. Neuroimage 198, 303-316

Happy OUTPUT in @WHOCARES/processing/$subject/PROCESSED/WHOCARES/happy/

3. from Matlab, scripts_paper/run main_WHOCARES.m

OUTPUT: 

	a) fMRI pre-processed data in @WHOCARES/processing/$subject/PROCESSED/WHOCARES/data_detrend.nii.gz

	b) cardiac regressor in @WHOCARES/processing/$subject/PROCESSED/WHOCARES/regressor.nii.gz 

	c) fMRI corrected time-series in @WHOCARES/processing/$subject/PROCESSED/WHOCARES/fMRI_corrected.nii.gz 

	d) mutual information map in @WHOCARES/processing/$subject/PROCESSED/WHOCARES/MI.nii

4. if you want to clear everything and start from scratch, run clear_all.sh

Please do not hesitate to contact us for suggestions and remarks (giulio.ferrazzi@hsancamillo.it or nigel.colenbier@kuleuven.be)

DISCLAIMER OF WARRANTIES AND LIMITATION OF LIABILITY The code is supplied as is and all use is at your own risk. The authors disclaim all warranties of any kind, either express or implied, as to the softwares, including, but not limited to, implied warranties of fitness for a particular purpose, merchantability or non - infringement of proprietary rights. Neither this agreement nor any documentation furnished under it is intended to express or imply any warranty that the operation of the software will be error - free. Under no circumstances shall the authors of the softwares provided here be liable to any user for direct, indirect, incidental, consequential, special, or exemplary damages, arising from the software, or user' s use or misuse of the softwares. Such limitation of liability shall apply whether the damages arise from the use or misuse of the data provided or errors of the software
