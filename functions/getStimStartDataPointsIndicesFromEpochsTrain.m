function [stimStartDataPointsIndices, stimStartTimes] = getStimStartDataPointsIndicesFromEpochsTrain(...
    header, epochsTrain, nevSr, sr)
    % This function calculates the indices and times of stimulus start points 
    % based on epochs training data and sampling rates.
    %
    % Parameters:
    %   header: A structure containing metadata, including delay information.
    %   epochsTrain: A structure or cell array containing stimulus start times.
    %   nevSr: The sampling rate of the NEV data.
    %   sr: The sampling rate of the processed data (optional).
    %
    % Returns:
    %   stimStartDataPointsIndices: Indices of stimulus start points in the data.
    %   stimStartTimes: Times of stimulus start points in seconds.

    % Check if the sampling rate (sr) is provided; if not, use a default value
    if (~exist('sr', 'var'))
        sr = Consts.DOWNSAMPLED_FREQUENCY;
    end

    % Extract stimulus start times from the epochsTrain structure or cell array
    startTimesCell = [epochsTrain.startCodonTime];
    nStims = length(startTimesCell); % Number of stimuli
    % Preallocate arrays for stimulus start data points indices and times
    stimStartDataPointsIndices = zeros(nStims, 1);
    stimStartTimes = zeros(nStims, 1);

    % Check if a delay is specified in the header
    if (isfield(header, 'delayInSec'))
        % If so, get the delay for the specific electrode type
        delayToNevInSec = header.delayInSec{electrodeTypeInd};
    else
        % Otherwise, use a default delay of 0 seconds
        delayToNevInSec = 0;
    end

    % Convert delay from seconds to data samples
    delayInDataSamples = sr * delayToNevInSec;

    % Determine if startTimesCell is a cell array or a numeric array
    if iscell(startTimesCell)
        % If it's a cell array, process each cell element
        for i = 1:nStims
            % Calculate the index of the stimulus start point in the data
            stimStartDataPointsIndices(i) = round(startTimesCell{i} / double(nevSr / sr) + delayInDataSamples);
            % Convert stimulus start time to seconds
            stimStartTimes(i) = startTimesCell{i} / double(nevSr);
        end
    else
        % If it's a numeric array, process each element directly
        for i = 1:nStims
            % Calculate the index of the stimulus start point in the data
            stimStartDataPointsIndices(i) = round(startTimesCell(i) / double(nevSr / sr) + delayInDataSamples);
            % Convert stimulus start time to seconds
            stimStartTimes(i) = double(startTimesCell(i)) / double(nevSr);
        end
    end
end
