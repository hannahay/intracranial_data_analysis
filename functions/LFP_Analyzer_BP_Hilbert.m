function LFP_Analyzer_BP_Hilbert(header, electrodeTypeInd, channels, timefArgs, cutoffTimes, freq_ranges, equalizeIndices, ...
    isSaveEpochsData, invalidTimes)
% LFP_Analyzer_BP_Hilbert analyzes LFP data by applying bandpass filters and the Hilbert transform.
% It saves the analysis results for each channel and stimulus condition, including raw and processed LFP data.
%
% Inputs:
%   header - Data structure containing session metadata and paths.
%   electrodeTypeInd - Index indicating the type of electrode (e.g., Macro or Micro).
%   channels - Array of channels to be analyzed.
%   timefArgs - Structure with timing arguments for analysis (e.g., pre and post start times).
%   cutoffTimes - Time intervals for different analysis conditions.
%   freq_ranges - Frequency range for bandpass filtering.
%   equalizeIndices - Specifies whether to use equalized or unequalized number of trials.
%   isSaveEpochsData - Boolean flag to control data saving.
%   invalidTimes - Time intervals that should be excluded from the analysis.

% Constants
MS_IN_SEC = 1000;  % Milliseconds per second, used for time conversion.
REMOVE_NOISY_EPOCHS = true;  % Flag to indicate removal of noisy epochs.
DONT_REMOVE_NOISY_EPOCHS = false;  % Flag to keep noisy epochs.

% Default parameter checks
if ~exist('invalidTimes', 'var')
    invalidTimes = [];
end

if ~exist('isSaveEpochsData', 'var')
    isSaveEpochsData = true;
end

if ~exist('equalizeIndices', 'var')
    equalizeIndices = [Index.EQUALIZED, Index.UNEQUALIZED];  % Default to both equalized and unequalized analysis.
end

if ~exist('cutoffTimes', 'var')
    cutoffTimes = [-Inf, Inf];  % Default cutoff to include all data if not specified.
end
numOfTimeGroups = size(cutoffTimes, 1);  % Determine the number of time groups based on cutoffTimes.

% Load and set configurations
signal_type = {'Macro', 'Micro'};
montageMap = readMontage(header);  % Load channel montage mapping from the header.
noisyDataPointsPerChannel = getNoisyDataPointsPerChannel(header, electrodeTypeInd);  % Load noise data.
stimMap = getStimuliMap(header, true, true);  % Load stimulus mapping, parameters true for options.
sr = Consts.DOWNSAMPLED_FREQUENCY;  % Sampling frequency from constants.

% Define the path for saving filtered data
timefDataFolderPath = fullfile(header.processedDataPath, 'BP_filter', signal_type{electrodeTypeInd}, ...
    sprintf('%d_%dHz', freq_ranges(1), freq_ranges(2)));

if ~exist(timefDataFolderPath, 'dir')
    mkdir(timefDataFolderPath);  % Create the directory if it does not exist.
end

% Process each channel
for channel = channels
    for equalizeInd = equalizeIndices  % Handle both equalized and unequalized cases.
        electrodeFullStr = getElectrodeFullStr(montageMap, electrodeTypeInd, channel);  % Get full electrode name.
        data = getDenoisedData(header, electrodeTypeInd, channel);  % Load denoised data for the channel.

        % Extract epochs for each stimulus without noisy epochs based on header settings
        [dataEpochsPerStim, stimStartTimesPerStimType, badEpochsLog, badStimIndicesPerStimType, badStimStartTimesPerStimType] = ...
            getDataEpochsPerStimWithoutNoisyEpochs_H(data, header, electrodeTypeInd, timefArgs.preStartTimeInSec, timefArgs.postStartTimeInSec, true, invalidTimes);

        % Perform Hilbert transform to obtain the envelope of the LFP signal in the specified frequency band
        LFP_envelope = getEnvelopeOfFrequencyBandWithHilbert(data, sr, freq_ranges(1), freq_ranges(2));
        [LFP_envelope_perstim, ~, ~, ~, ~] = getDataEpochsPerStimWithoutNoisyEpochs_H(LFP_envelope, header, electrodeTypeInd, ...
            timefArgs.preStartTimeInSec, timefArgs.postStartTimeInSec, DONT_REMOVE_NOISY_EPOCHS);

        % Optional: Remove epochs flagged as noisy
        if(~isempty(badStimIndicesPerStimType))
        LFP_envelope_perstim = cellfun(@removeBadIndices, LFP_envelope_perstim,...
            badStimIndicesPerStimType,'UniformOutput',false);
        end

        % Compute indices for grouping stimuli by time, applying both equalization options
        indicesPerGroupPerStimType = cellfun(@(x) getIndicesPerTimeGroup_H(cutoffTimes, x, false), stimStartTimesPerStimType, 'UniformOutput', false);
        indicesPerGroupPerStimTypeEqualizedNumOfEpochs = cellfun(@(x) getIndicesPerTimeGroup_H(cutoffTimes, x, true), stimStartTimesPerStimType, 'UniformOutput', false);
        nStimTypes = length(dataEpochsPerStim);

        % Iterate over all stimuli types, except the last which is assumed to be an empty placeholder
        for stimTypeInd = 1:nStimTypes - 1
            stimStr = stimMap(stimTypeInd);
            processStimuli(header, stimTypeInd, stimStr, dataEpochsPerStim, LFP_envelope_perstim, indicesPerGroupPerStimType, ...
                indicesPerGroupPerStimTypeEqualizedNumOfEpochs, timefDataFolderPath, electrodeFullStr, channel, equalizeInd, timefArgs, freq_ranges);
        end
    end
    fprintf('Analysis completed for channel %d at frequency range %d-%d Hz.\n', channel, freq_ranges(1), freq_ranges(2));

end

end

function processStimuli(header, stimTypeInd, stimStr, dataEpochsPerStim, LFP_envelope_perstim, indicesPerGroupPerStimType, ...
    indicesPerGroupPerStimTypeEqualizedNumOfEpochs, timefDataFolderPath, electrodeFullStr, channel, equalizeInd, timefArgs, freq_ranges)
% Process and save data for each stimulus and time group

% Constants for baseline calculations (e.g., baseline end time index)
BASELINE_END_TIME_INDEX = timefArgs.preStartTimeInSec * 1000;

% Processing for each time group
numOfTimeGroups = length(indicesPerGroupPerStimType{stimTypeInd});
for groupInd = 1:numOfTimeGroups
    % Get indices for the current group
    indicesForGroupAndStim = indicesPerGroupPerStimType{stimTypeInd}{groupInd};
    indicesForGroupAndStimEqualizedNumOfEpochs = indicesPerGroupPerStimTypeEqualizedNumOfEpochs{stimTypeInd}{groupInd};

    % Continue only if there are epochs to process
    if isempty(indicesForGroupAndStimEqualizedNumOfEpochs)
        fprintf('Warning: No epochs to process for stim %d, group %d.\n', stimTypeInd, groupInd);
        continue;
    end

    % Filtered data for the current group
    LFPActivityForThisStim = LFP_envelope_perstim{stimTypeInd};

    % Select epochs based on indices
    filtered_data = LFPActivityForThisStim(indicesForGroupAndStim, :);
    raw_data_epochs = dataEpochsPerStim{stimTypeInd}(indicesForGroupAndStim, :);

    % Normalize filtered data by baseline
    baseline = mean(filtered_data(:, 1:BASELINE_END_TIME_INDEX), 2);  % Calculate baseline as mean of each epoch up to baseline end time
    filtered_data_norm = filtered_data ./ baseline;

    % Calculate averages
    mean_filtered_data = mean(filtered_data, 1);
    mean_filtered_data_norm = mean(filtered_data_norm, 1);
    erp = mean(raw_data_epochs, 1);  % Event-related potential for the group

    % Prepare file path and save data
    fileName = sprintf('%s_%s_%s %s', char(header.id), char(electrodeFullStr), stimStr, header.groupsNames{groupInd});
    epochsDataFullPath = fullfile(timefDataFolderPath, fileName);

    % Save all relevant data
    save(epochsDataFullPath, 'header', 'channel', 'stimTypeInd', 'stimStr', 'electrodeFullStr', 'timefArgs', ...
         'indicesForGroupAndStim', 'erp', 'filtered_data', 'raw_data_epochs', 'filtered_data_norm', ...
         'mean_filtered_data', 'mean_filtered_data_norm', 'freq_ranges', '-v7.3');
    
%     fprintf('Data saved for channel %d, stim %s, group %d.\n', channel, stimStr, groupInd);
end
end
