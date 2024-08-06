function [data, sr] = getDenoisedData(header, electrodeTypeInd, channel)
    % This function loads and returns denoised data for a specified electrode channel.
    % It also returns the sampling rate (sr) of the data.
    %
    % Parameters:
    %   header: A structure containing metadata, including the path to processed data.
    %   electrodeTypeInd: Index indicating the type of electrode (macro or micro).
    %   channel: The channel number of the electrode.
    %
    % Returns:
    %   data: The denoised data for the specified channel.
    %   sr: The sampling rate of the denoised data.

    % Construct the folder path to the denoised data files
    denoisedDataFolderPath = sprintf('%s%s%s', header.processedDataPath, ...
        ConstStrings.DENOISED_FOLDER, getElectrodeTypeFolderName(electrodeTypeInd));
    % Construct the full file name for the denoised data file for the specified channel
    denoisedDataFileName = sprintf('%s%s%d', denoisedDataFolderPath, ...
        ConstStrings.DENOISED_FILE_PREFIX, channel);

    % Load the denoised data file
    ch = load(denoisedDataFileName);
    % Extract the denoised data from the loaded file
    data = ch.denoised_data;
    % Check if the sampling rate is specified in the loaded file
    if (isfield(ch, 'downsampledFreqHzForThisElectrode'))
        % If so, use the specified sampling rate
        sr = ch.downsampledFreqHzForThisElectrode;
    else
        % Otherwise, use a default downsampled frequency from constants
        sr = Consts.DOWNSAMPLED_FREQUENCY;
    end
    % Clear the loaded variable to free up memory
    clear ch;

    % Ensure the data is a row vector
    if (~isrow(data))
        data = data';
    end
end
