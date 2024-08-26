% identify significant increase or decrease of the signal during
% stimul compared to baseline (in wake and sleep separately) for different
% freq bands

% define parameters
PATIENT_id='d009';
exp_num=[1]; % type of experiment
params.groups={'wake', 'NREM'};
params.freq_bands=[10,30]; % fequency band
params.electrodeTypeInd=Index.MACRO; % type of electrode 
params.gap=[4, 10]; % parameters for detection of significant responses to stimuli 
params.min_num_of_trials=6; % if number of trials for a specific stim in a specific state (e.g. wake) < 6, discard it
params.sigma=8; params.hsize=3; % parameters for smoothing function
params.std=5; % threshold for rejecting noisy trials (> mean + (params.std)*std)

% load patient information
header = getExperimentHeader(PATIENT_id,exp_num);
montageStruct = readMontage(header); % read the electrodes montage
channels=header.channelsVec{params.electrodeTypeInd}; % run on all the channels; or replace by specific channel

% run the function
PlotTrials_and_Stats_afterHilbert_Transform (header, channels,params)


