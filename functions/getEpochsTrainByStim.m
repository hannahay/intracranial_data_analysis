function epochsTrainByStim = getEpochsTrainByStim(header, epochsTrain)
    % This function organizes training epochs by their stimulus types.
    % It groups the epochs based on stimulus types and returns a cell array where
    % each cell contains epochs corresponding to a specific stimulus type.
    %
    % Parameters:
    %   header: A structure containing information about stimuli and their codons.
    %   epochsTrain: A structure array where each element represents an epoch and 
    %                 contains information about stimulus type (vol field).
    %
    % Returns:
    %   epochsTrainByStim: A cell array where each cell contains epochs corresponding 
    %                       to a specific stimulus type.

    % Check if 'epochsTrain' is empty
    if (isempty(epochsTrain))
        % Return an empty cell array if there are no epochs
        epochsTrainByStim = {};
        return;
    end

    % If 'stimsHardCoded' field is present in the header, use it to update stimuli information
    if (isfield(header, 'stimsHardCoded'))
        header.stimuliCodons = header.stimsHardCoded.stimuliCodons;
        header.stimuli = header.stimsHardCoded.stimuli;
    end

    % Determine the maximum value of stimulus types
    if (find(header.stimuliCodons == 0, 1, 'first'))
        % If there is a zero in 'stimuliCodons', use the alternative value
        zeroAlternativeValue = getZeroAlternativeValue(header.stimuliCodons);
        maxValueOfStimTypes = zeroAlternativeValue;
    else
        % Otherwise, use the maximum value from 'stimuliCodons'
        maxValueOfStimTypes = max(header.stimuliCodons);
    end

    % Initialize a logical matrix to mark stimulus types for each epoch
    stimTypesBool = zeros(numel(epochsTrain), maxValueOfStimTypes);

    % Populate the logical matrix based on stimulus type for each epoch
    for epochInd = 1:numel(epochsTrain)
        stimType = epochsTrain(epochInd).vol;
        if (stimType == 0)
            % If stimulus type is 0 and no alternative value is defined,
            % it indicates an issue with 'stimuliCodons' definition
            stimTypesBool(epochInd, zeroAlternativeValue) = 1;
        else
            % Mark the appropriate column for the given stimulus type
            stimTypesBool(epochInd, stimType) = 1;
        end
    end

    % Initialize cell array to hold epochs for each stimulus type
    epochsTrainByStim = cell(1, maxValueOfStimTypes);

    % Group epochs by stimulus type
    for stimType = 1:maxValueOfStimTypes
        % Select epochs where the stimulus type matches the current type
        epochsTrainByStim{stimType} = epochsTrain(logical(stimTypesBool(:, stimType)));
    end
end
