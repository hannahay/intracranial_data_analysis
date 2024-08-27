function PlotTrials_and_Stats_afterHilbert_Transform(header, channels, params)
    % PlotTrials_and_Stats_afterHilbert_Transform processes and plots statistical analysis after applying the Hilbert transform
    %
    % This function loads the Hilbert transform data, performs statistical analysis, and plots results for specified channels and frequency bands.
    %
    % Arguments:
    %   header - Struct containing metadata and data paths.
    %   channels - Array of channel indices to be analyzed.
    %   params - Struct containing parameters such as frequency bands, gaps, thresholds, etc.

    % Unpack parameters for easier access
    group_names = params.groups;
    freq_bands = params.freq_bands;
    electrodeTypeInd = params.electrodeTypeInd;
    gap = params.gap;
    min_num_of_trials = params.min_num_of_trials;
    sigma = params.sigma;
    hsize = params.hsize;
    std_thres = params.std;
    electrode_name = {'Macro', 'Micro'};

    % Load group times and setup paths
    load(fullfile(header.processedDataPath, 'groupsTimes.mat'));
    timefDataFolderPath = fullfile(header.processedDataPath, 'BP_filter', electrode_name{electrodeTypeInd}, ...
        sprintf('%d_%dHz', freq_bands(1), freq_bands(2)));

    numOfTimeGroups = size(groupsTimes, 2);
    stimMap = getStimuliMap(header, true, true);
    montageStruct = readMontage(header);
    plotColors = {'b', 'r', 'g'};  % Colors for plotting

    % Loop over channels
    for channel = channels
        electrodeFullStr = getElectrodeFullStr(montageStruct, electrodeTypeInd, channel);

        % Loop over stimuli, skipping the "empty stim"
        for stimInd = header.stimuliCodons(2:end)  
            stimStr = stimMap(stimInd);
            % Define paths for figures and data storage specific to each channel and stimulus
            figureSavePath = fullfile(header.figuresDataPath, 'envelop_Hilbert', electrode_name{electrodeTypeInd}, ...
               sprintf('%d_%dHz', freq_bands(1), freq_bands(2)), ['channel_' num2str(channel)]);
            if ~exist(figureSavePath, 'dir')
                mkdir(figureSavePath);
            end

            dataSavePath = fullfile(header.processedDataPath, 'envelop_Hilbert', sprintf('%d-%dHz', freq_bands(1), freq_bands(2)), ...
               ['channel_' num2str(channel)]);
            if ~exist(dataSavePath, 'dir')
                mkdir(dataSavePath);
            end

            % Loop over time groups
            for groupInd = 1:numOfTimeGroups
                fileName = sprintf('%s_%s_%s %s.mat', header.id, electrodeFullStr, stimStr, header.groupsNames{groupInd});
                epochsDataFullPath = fullfile(timefDataFolderPath, fileName);
                load(epochsDataFullPath);

                % Analysis parameters
                baselineLength = timefArgs.preStartTimeInSec * 1000;
                responseLength = round((header.stimLengthInSec(stimInd + 1) + 0.100) * 1000);

                % Data smoothing
                [filteredDataNormSmooth, sigma] = smooth_f(filtered_data_norm, sigma, hsize, 1);

                % Define and calculate thresholds
                threshold = mean(mean(filteredDataNormSmooth)) + std_thres * mean(std(filteredDataNormSmooth));

                % Statistical analysis using a custom fast Raster technique
                [p(groupInd, :), h(groupInd, :)] = fastRasterRankSum_2024(filteredDataNormSmooth, baselineLength, round(responseLength), ...
                    'alpha', 0.01, 'fdr', 1, 'responseType', 'inc', 'gap', gap);

                % Handling minimum trial requirements
                if size(filteredDataNormSmooth, 1) < min_num_of_trials
                    h(groupInd, :) = zeros(1, size(h, 2));
                end

                % Validate significant response length
                if length(find(h(groupInd, :))) < 0.015 * header.stimLengthInSec(stimInd + 1) * 1000
                    h(groupInd, :) = zeros(1, size(h, 2));
                end

                % Plotting results
                plot_afterstimend_ms = 900;
                timeVector = -(baselineLength-1) : (responseLength + plot_afterstimend_ms);
                plot(timeVector, mean(filteredDataNormSmooth), 'LineWidth', 2, 'Color', plotColors{groupInd});
                hold on;
                max_sig(groupInd)=max(mean(filteredDataNormSmooth));
                min_sig(groupInd)=min(mean(filteredDataNormSmooth));

                title(sprintf('%d-%dHz - Hilbert Envelope %s', freq_bands(1), freq_bands(2), stimStr));
                responseLine = NaN(1, length(filteredDataNormSmooth));
                h_onlypos = h(groupInd);
                h_onlypos(h_onlypos == 0) = NaN;
                responseLine(baselineLength : (baselineLength + responseLength)) = h_onlypos * max(mean(filteredDataNormSmooth, 1));
                plot(responseLine, '*', 'Color', plotColors{groupInd});
                xlim([timeVector(1), responseLength + 500]);
                
                % Set plot limits for the final group
                if groupInd == numOfTimeGroups
                    ylim([min(min_sig) - 0.1, max(max_sig) + 0.1]);
                end

                % Mark stimulation times
                stimStartTime = 0;
                line([stimStartTime, stimStartTime], get(gca, 'YLim'), 'Color', 'k', 'LineWidth', 1);
                stimEndTime = header.stimLengthInSec(stimInd + 1) * 1000;
                line([stimEndTime, stimEndTime], get(gca, 'YLim'), 'Color', 'k', 'LineWidth', 1);
            end
                legend(group_names{1} ,'', '', '',group_names{2});

            % Save plots and data
            savePlotAndData(header, figureSavePath, dataSavePath, channel, electrode_name,electrodeTypeInd,electrodeFullStr, freq_bands,stimStr, filteredDataNormSmooth, h, p);
        end
    end
end

function savePlotAndData(header, figureSavePath, dataSavePath, channel, electrode_name,electrodeTypeInd,electrodeFullStr,freq_bands, stimStr, filteredDataNormSmooth, h, p)
    % Helper function to save plots and processed data
    figureSavePath = fullfile(header.figuresDataPath, 'envelop_Hilbert', sprintf('%s_%d_%dHz', electrode_name{electrodeTypeInd}, freq_bands(1), freq_bands(2)));
    if ~exist(figureSavePath, 'dir')
        mkdir(figureSavePath);
    end
    savePath = fullfile(figureSavePath, sprintf('channel_%d_%s_%s', channel, electrodeFullStr, stimStr));
    saveas(gcf, savePath, 'fig');
    saveas(gcf, savePath, 'jpeg');

    dataSavePath = fullfile(header.processedDataPath, 'envelop_Hilbert_', sprintf('%d-%dHz', freq_bands(1), freq_bands(2)));
    if ~exist(dataSavePath, 'dir')
        mkdir(dataSavePath);
    end
    save(fullfile(dataSavePath, sprintf('channel_%d_%s_%s', channel, electrodeFullStr, stimStr)), 'h', 'p', 'filteredDataNormSmooth');

    close(gcf);  % Close figure after saving
end
