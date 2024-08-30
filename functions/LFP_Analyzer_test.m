function LFP_Analyzer_chatGPT (header,electrodeTypeInd,channels,timefArgs, cutoffTimes, equalizeIndices, ...
    isTimef, isSaveEpochsData, invalidTimes)

%Initialization and Default Values
MS_IN_SEC = 1000;
REMOVE_NOISY_EPOCHS = true;
DONT_REMOVE_NOISY_EPOCHS = false;
sr = Consts.DOWNSAMPLED_FREQUENCY;


if (~exist('invalidTimes','var'))
    invalidTimes = [];
end

if(~exist('isSaveEpochsData','var'))
    isSaveEpochsData = true;
end

if(~exist('isTimef','var'))
    isTimef = true;
end

if(~exist('equalizeIndices','var'))
    equalizeIndices = [Index.UNEQUALIZED, Index.EQUALIZED];
end

if (~exist('cutoffTimes','var'))
  cutoffTimes = [-Inf Inf];
    numOfTimeGroups = size(cutoffTimes,1);
else
    numOfTimeGroups = size(cutoffTimes,2);
end

% Reading Header and Montage Information
% groupsStr = getEqualizedGroupsStr_H(cutoffTimes);

preStartTimeInSec = timefArgs.preStartTimeInSec;
postStartTimeInSec = timefArgs.postStartTimeInSec;
maxFreq = timefArgs.maxFreq;
cycles = timefArgs.cycles;
myWinSize = timefArgs.myWinSize;
alpha = timefArgs.alpha;
timesout = timefArgs.timesout;

montageMap = readMontage(header);
stimMap = getStimuliMap(header, true, true);

[timefDataFolderPath,timefFiguresFolderPath,epochsDataFolderPath] = ...
    getLfpAnalysisFolderPaths_H(header,electrodeTypeInd,timefArgs,cutoffTimes, true);

% loop through channels

for channel = [channels]
    electrodeFullStr = getElectrodeFullStr(montageMap, electrodeTypeInd, channel);
    data = getDenoisedData(header, electrodeTypeInd, channel);
    [dataEpochsPerStim, stimStartTimesPerStimType, badEpochsLog, badStimIndicesPerStimType, badStimStartTimesPerStimType] = getDataEpochsPerStimWithoutNoisyEpochs_H(data, header, electrodeTypeInd, timefArgs.preStartTimeInSec, timefArgs.postStartTimeInSec, true, invalidTimes);
    [indicesPerGroupPerStimType ]= cellfun(@(x) getIndicesPerTimeGroup_H(cutoffTimes, x, false), stimStartTimesPerStimType, 'UniformOutput', false);
    [indicesPerGroupPerStimTypeEqualizedNumOfEpochs] = cellfun(@(x) getIndicesPerTimeGroup_H(cutoffTimes, x, true), stimStartTimesPerStimType, 'UniformOutput', false);

    nStimTypes = length(dataEpochsPerStim);
  

for stimTypeInd = 1:nStimTypes
    stimStr = stimMap(stimTypeInd);
    indicesPerGroupForThisStim = indicesPerGroupPerStimType{stimTypeInd};
    indicesPerGroupForThisStimEqualizedNumOfEpochs = indicesPerGroupPerStimTypeEqualizedNumOfEpochs{stimTypeInd};
    dataEpochsForThisStim = dataEpochsPerStim{stimTypeInd};

    for groupInd = 1:numOfTimeGroups
        indicesForGroupAndStim = indicesPerGroupForThisStim{groupInd};
        indicesForGroupAndStimEqualizedNumOfEpochs = indicesPerGroupForThisStimEqualizedNumOfEpochs{groupInd};

        if isempty(indicesForGroupAndStimEqualizedNumOfEpochs)
            disp('epochsTrain of stim was empty. check if because noisy data');
            continue;
        end

        epochsIndicesPerEqualizeState{Index.UNEQUALIZED} = indicesForGroupAndStim;
        epochsIndicesPerEqualizeState{Index.EQUALIZED} = indicesForGroupAndStimEqualizedNumOfEpochs;

        dataEpochsPerEqualizedState{Index.UNEQUALIZED} = dataEpochsForThisStim(epochsIndicesPerEqualizeState{Index.UNEQUALIZED}, :);
        dataEpochsPerEqualizedState{Index.EQUALIZED} = dataEpochsForThisStim(epochsIndicesPerEqualizeState{Index.EQUALIZED}, :);

%         gammaPowerPerEqualizedState{Index.UNEQUALIZED} = gammaActivityForThisStim(epochsIndicesPerEqualizeState{Index.UNEQUALIZED}, :);
%         gammaPowerPerEqualizedState{Index.EQUALIZED} = gammaActivityForThisStim(epochsIndicesPerEqualizeState{Index.EQUALIZED}, :);

        fileName = getTimefDataFileName(header, electrodeTypeInd, channel, stimStr, numOfTimeGroups, groupInd, montageMap);

        if isempty(badEpochsLog)
            badEpochsLogForStim = [];
            badStimIndicesForStim = [];
            badStimStartTimesForStim = [];
        else
            badEpochsLogForStim = badEpochsLog.perStimType(stimTypeInd);
            badStimIndicesForStim = badStimIndicesPerStimType{stimTypeInd};
            badStimStartTimesForStim = badStimStartTimesPerStimType{stimTypeInd};
        end

        for equalizeInd = equalizeIndices
            chosenEpochsIndices = epochsIndicesPerEqualizeState{equalizeInd};
%             gammaPower = gammaPowerPerEqualizedState{equalizeInd};
%             meanGammaPower = mean(gammaPowerPerEqualizedState{equalizeInd});
            dataEpochs = dataEpochsPerEqualizedState{equalizeInd};
            erp = mean(dataEpochs);

            epochsDataFullPath = [epochsDataFolderPath{equalizeInd} fileName];
            if isSaveEpochsData
                save(epochsDataFullPath, 'header', 'channel', 'stimTypeInd', 'stimStr', 'electrodeTypeInd', 'timefArgs', 'cutoffTimes', 'chosenEpochsIndices', 'dataEpochs', 'erp');
            end

            if ~isTimef
                continue;
            end

            timefFiguresFullPath = [timefFiguresFolderPath{equalizeInd} fileName];
            timefDataFullPath = [timefDataFolderPath{equalizeInd} fileName];
            dataVecForTimef = reshape(dataEpochs', 1, numel(dataEpochs));

            figHandle = figure('units', 'normalized', 'outerposition', [1 1 1 1]);

            if max(abs(dataVecForTimef)) < 1e-20
                errorMsg = sprintf('%s - zero data vector', electrodeFullStr);
                disp(errorMsg);
                title(errorMsg);
            else
                frameLength = round((timefArgs.preStartTimeInSec + timefArgs.postStartTimeInSec(stimTypeInd)) * sr);
                assert(mod(length(dataVecForTimef), frameLength) == 0);
                [ersp, itc, powbase, times, freqs, erspboot, itcboot, ~] = newtimef(dataVecForTimef, frameLength, [-timefArgs.preStartTimeInSec * MS_IN_SEC timefArgs.postStartTimeInSec(stimTypeInd) * MS_IN_SEC], sr, timefArgs.cycles, 'winsize', timefArgs.myWinSize, 'maxfreq', timefArgs.maxFreq, 'plotersp', 'on', 'plotitc', 'on', 'timesout', timefArgs.timesout(stimTypeInd), 'trialbase', 'full');
                save(timefDataFullPath, 'ersp', 'itc', 'powbase', 'times', 'freqs', 'erspboot', 'itcboot', 'header', 'channel', 'stimTypeInd', 'stimStr', 'electrodeTypeInd', 'timefArgs', 'cutoffTimes', 'dataEpochs', 'erp', 'chosenEpochsIndices', 'badEpochsLogForStim', 'badStimIndicesForStim', 'badStimStartTimesForStim', '-v7.3');
            end
            hgexport(figHandle, timefFiguresFullPath, hgexport('factorystyle'), 'Format', 'png');
            set(figHandle, 'Visible', 'on');
            savefig(figHandle, [timefFiguresFullPath '.fig']);
            delete(figHandle);
        end
    end
end

end
