%% Load patient info
PATIENT_id = 'd009';
exp_num = 1;
electrodeTypeInd = Index.MACRO;

header = getExperimentHeader(PATIENT_id, exp_num);
load([header.processedDataPath 'groupsTimes']);
cutoffTimes = groupsTimes;
channels = cell2mat(header.channelsVec(electrodeTypeInd));

%% Load parameters
isSaveEpochsData = true;

% Time parameters
timefArgs.preStartTimeInSec = 0.6; 
timefArgs.postStimInSec = 1;
timefArgs.postStartTimeInSec = header.stimLengthInSec(2:end) + timefArgs.postStimInSec;
timefArgs.postStartTimeInSec(end + 1) = header.stimLengthInSec(1) + timefArgs.postStimInSec;
timefArgs.timesout = round((timefArgs.preStartTimeInSec + timefArgs.postStartTimeInSec) * 200);

%% Run envelop of Hilbert transform in different frequency bands
freq_ranges = [10, 30; 40, 80; 80, 200];

for freqs = 1:size(freq_ranges, 1)
    LFP_Analyzer_BP_Hilbert(header, electrodeTypeInd, channels, timefArgs, cutoffTimes,...
        freq_ranges(freqs, :), Index.UNEQUALIZED, isSaveEpochsData);
end


%% Parameters for plotting scalogram (spectrogram for wavelet transform) and ITPC (inter-trial phase coherence)
% isTimef = true;
% timefArgs.maxFreq = 180; 
% timefArgs.cycles = [3];
% timefArgs.myWinSize = 1000; % Default: 1000
% timefArgs.alpha=[]
% % Run the analyzer for scalogram and ITPC
% LFP_Analyzer_chatGPT(header, electrodeTypeInd, channels, timefArgs, cutoffTimes, Index.UNEQUALIZED, isTimef, isSaveEpochsData);        
