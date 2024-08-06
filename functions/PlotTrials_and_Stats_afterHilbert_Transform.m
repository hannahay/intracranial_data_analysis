function PlotTrials_and_Stats_afterHilbert_Transform (header, channels,params)
    % Load necessary data

    groups=params.groups;
    freq_bands=params.freq_bands;
    electrodeTypeInd=params.electrodeTypeInd;
    gap=params.gap;
    min_num_of_trials=params.min_num_of_trials;
    sigma=params.sigma;
    hsize=params.hsize;
    std_thres=params.std;
    electrode_name={'Macro', 'Micro'};

    load(fullfile(header.processedDataPath, ['groupsTimes']));
    timefDataFolderPath = fullfile(header.processedDataPath, 'BP_filter', [electrode_name{electrodeTypeInd}...
        num2str(freq_bands(1)) '_' num2str(freq_bands(2)) 'Hz']);
    numOfTimeGroups = size(groupsTimes, 2);
    stimMap = getStimuliMap(header, true, true);
    montageStruct = readMontage(header);
    plotColors = {'b', 'r', 'g'}; % Colors for plotting

    % Loop over channels
    for channel = channels

        electrodeFullStr = getElectrodeFullStr(montageStruct, electrodeTypeInd, channel);

        % Loop over stimuli
        stim = 1;
        for stimInd = header.stimuliCodons(2:end) % not running on "empty stim"

            stimStr = stimMap(stimInd);

            % Loop over groups
            for groupInd = 1: numOfTimeGroups
                fileName = [header.id electrodeFullStr '_' stimStr '_' header.groupsNames{groupInd}];
                if iscell(fileName)
                    fileName = cell2mat(fileName);
                end
                epochsDataFullPath = fullfile(timefDataFolderPath, fileName);
                load(epochsDataFullPath)

                baselineLength = timefArgs.preStartTimeInSec * 1000; % Baseline length in ms
                responseLength = round((header.stimLengthInSec(stimInd + 1) + 0.100) * 1000); % Response length in ms
                
                [filteredDataNormSmooth, sigma] = smooth_f(filtered_data_norm, sigma, hsize ,1);

                indexStimPerState{groupInd} = [];
                filter_smooth_dataperGroup{groupInd} = filteredDataNormSmooth;
                threshold = mean(mean(filter_smooth_dataperGroup{groupInd})) + std_thres* mean(std(filter_smooth_dataperGroup{groupInd}));

                % Remove noisy epochs (above threshold)
                epochIndex = 1;
                validEpochIndex = 1;
                totalEpochs = size(filter_smooth_dataperGroup{groupInd}, 1);
                IndicesPerGroupStimState{1, groupInd} = indicesPerGroupPerStimType;
                
%                 CHECK THIS CODE
%                 while epochIndex <= totalEpochs
%                     if any(filter_smooth_dataperGroup{groupInd}(epochIndex, :) > threshold)
%                         filter_smooth_dataperGroup{groupInd}(epochIndex, :) = [];
%                         IndicesPerGroupStimState{1, groupInd}(epochIndex) = [];
%                         indexStimPerState{groupInd}(validEpochIndex) = epochIndex;
%                         validEpochIndex = validEpochIndex + 1;
%                     else
%                         epochIndex = epochIndex + 1;
%                     end
%                     epochIndex = epochIndex + 1;
%                 end

                % Perform statistical analysis
                [p(groupInd, :), h(groupInd, :)] = fastRasterRankSum_2024(filter_smooth_dataperGroup{groupInd}, baselineLength, round(responseLength), ...
                    'alpha', 0.01, 'fdr', 1, 'responseType', 'inc', 'gap', gap);

                % Check if the response is significant
                if size(filter_smooth_dataperGroup{groupInd}, 1) < min_num_of_trials
                    h(groupInd, :) = zeros(1, size(h, 2));
                end

                if length(find(h(groupInd, :))) < 0.015 * header.stimLengthInSec(stimInd + 1) * 1000
                    h(groupInd, :) = zeros(1, size(h, 2));
                end

                % Plot results
                timeVector = -(baselineLength-1):responseLength+900;

                plot(timeVector, mean(filter_smooth_dataperGroup{groupInd}), 'LineWidth', 2, 'Color', plotColors{groupInd});
                hold on;
                title([ num2str(freq_bands(1)) '-' num2str(freq_bands(2)) 'Hz' '- Hilbert Envelope' stimStr]);
                responseLine = NaN(1, length(filter_smooth_dataperGroup{groupInd}));
                h_onlypos=h(groupInd);
                h_onlypos(h_onlypos==0)=NaN;
                responseLine(baselineLength:baselineLength + responseLength) = h_onlypos * max(mean(filter_smooth_dataperGroup{groupInd}, 1));
                plot(responseLine, '*', 'Color', plotColors{groupInd});
                xlim([timeVector(1) responseLength+500])
                if groupInd == numOfTimeGroups
                    allvalues = vertcat(filter_smooth_dataperGroup{:});
                    allvalues_mean=[mean(allvalues(1:size(filter_smooth_dataperGroup{1,1},1),:),1), ...
                  mean(allvalues(size(filter_smooth_dataperGroup{1,1})+1:size(allvalues,1),:),1)]  ;    
                    ylim([min(allvalues_mean)-0.05, max(allvalues_mean)+0.05]);
                end
                currentAxis = gca;
                ylimCurrent = get(currentAxis, 'YLim');

                % Plot stimulation times
                stimStartTime = 0; % Stim start time
                line([stimStartTime stimStartTime], ylimCurrent, 'Color', 'k', 'LineWidth', 1)
                stimEndTime = header.stimLengthInSec(stimInd + 1) * 1000; % Stim end time
                line([stimEndTime stimEndTime], ylimCurrent, 'Color', 'k', 'LineWidth', 1);
                hold on;
            end

            % Save figures
            figureSavePath = fullfile(header.figuresDataPath, 'envelop_Hilbert',  [electrode_name{electrodeTypeInd}...
           num2str(freq_bands(1)) '_' num2str(freq_bands(2)) 'Hz']);
            if ~exist(figureSavePath, 'dir')
                mkdir(figureSavePath);
            end
            savePath = fullfile(figureSavePath, ['channel_' num2str(channel) electrodeFullStr stimStr]);
            saveas(gcf, savePath, 'fig');
            saveas(gcf, savePath, 'jpeg');
            close all

            % Save processed data
            dataSavePath = fullfile(header.processedDataPath, 'envelop_Hilbert_', [num2str(freq_bands(1)) '-' num2str(freq_bands(2)) 'Hz']);
            if ~exist(dataSavePath, 'dir')
                mkdir(dataSavePath);
            end
            save(fullfile(dataSavePath, ['channel_' num2str(channel) electrodeFullStr stimStr]), 'h', 'p', 'filter_smooth_dataperGroup', 'indexStimPerState', 'IndicesPerGroupStimState');

            % Compute and save response statistics
            if numOfTimeGroups==2
             significantResponse = or(h(1, :), h(2, :));
            elseif numOfTimeGroups==3
             significantResponse = or(h(1, :), h(2, :),h(3, :));

            if any(significantResponse)
                dataIndex = 1;
                for groupInd = 1: numOfTimeGroups
                    Sig_response_timeavg{stim, dataIndex} = mean(filter_smooth_dataperGroup{groupInd}(:, find(significantResponse)), 2);
                    Mean_Resp(stim, dataIndex) = mean(Sig_response_timeavg{stim, dataIndex});
                    dataIndex = dataIndex + 1;
                end

                [p_states(stim), h_states(stim)] = ranksum(Sig_response_timeavg{stim, 1}, Sig_response_timeavg{stim, 2}, 'alpha', 0.01);
                stim_ind(stim) = stimInd;
                stim_name{stim} = stimStr;
                stim = stim + 1;
            end

            clear baseline response response_normalized filter_smooth_dataperGroup h p dataEpochs ...
                filter_smooth_dataperGroup_m h p significantResponse significantResponse h_or h_or_inh
        end

        % Save channel results
        resultsSavePath = fullfile(header.processedDataPath, 'LFP', 'afterStatsAnalysis', electrode_name{electrodeTypeInd}, [num2str(freq_bands(1)) '-' num2str(freq_bands(2)) 'Hz']);
        if ~exist(resultsSavePath, 'dir')
            mkdir(resultsSavePath);
        end

        if exist('h_states', 'var')
            saveFileName = sprintf('Patient%s_channel%d(%s_%d)_%s_p=0_01', char(header.id), channel, montageStruct{2, channel}.location, ...
                montageStruct{2, channel}.depth, freq_bands);
            save(fullfile(resultsSavePath, saveFileName), 'p_states', 'h_states', 'Mean_Resp', 'Sig_response_timeavg', ...
                'electrodeFullStr', 'channel', 'stim_ind', 'stim_name', 'stim', 'electrodeFullStr');
        end

        clear p_states h_states stim_ind stim_name Mean_Resp Sig_response_timeavg
    end
end
