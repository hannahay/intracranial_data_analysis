function [dataEpochsPerStim,stimStartTimesPerStimType, badEpochsLog, ...
    badStimIndicesPerStimType, badStimStartTimesPerStimType] = getDataEpochsPerStimWithoutNoisyEpochs_H (...
    data, header,electrodeTypeInd, preStimStartTimeInSec, postStimStartTimeInSec,...
    isRemoveNoisyEpochs,invalidTimes, sr)

if(~exist('invalidTimes','var') || mod(numel(invalidTimes),2)~=0)
    invalidTimes = [];
end
if(~exist('isRemoveNoisyEpochs','var'))
    isRemoveNoisyEpochs = true;
end
if(~exist('sr','var'))
    sr = Consts.DOWNSAMPLED_FREQUENCY;
end

dataLength = length(data);
[stimStartDataPointsIndicesPerStimType,stimStartTimesPerStimType] = getStimStartTimeWithoutTruncatedEpochs_H(...
    header,preStimStartTimeInSec,postStimStartTimeInSec,dataLength,sr);

for stimTypeInd = 1:length(stimStartTimesPerStimType)
    isInvalidTrial = getIsValuesBetweenBorders(stimStartTimesPerStimType{stimTypeInd},invalidTimes);
    stimStartTimesPerStimType{stimTypeInd}(isInvalidTrial) = [];
    stimStartDataPointsIndicesPerStimType{stimTypeInd}(isInvalidTrial) = [];
end
% stimStartTimes = cellfun(@(x) x/sr,stimStartDataPointsIndicesPerStimType,'UniformOutput',false);

nStimTypes = length(stimStartDataPointsIndicesPerStimType);
for stimTypeInd = 1:nStimTypes
    dataEpochsPerStim{stimTypeInd} = [];
    stimStartDataPointsIndicesForThisStimType = stimStartDataPointsIndicesPerStimType{stimTypeInd};
    for i=1:numel(stimStartDataPointsIndicesForThisStimType)
        segmentStartInd = stimStartDataPointsIndicesForThisStimType(i)-preStimStartTimeInSec*sr;     
   segmentEndInd = stimStartDataPointsIndicesForThisStimType(i)+postStimStartTimeInSec(stimTypeInd)*sr-1;

        dataEpochsPerStim{stimTypeInd} = [dataEpochsPerStim{stimTypeInd}; data(segmentStartInd:segmentEndInd)];
    end
end

if (isRemoveNoisyEpochs) && (electrodeTypeInd==Index.MACRO || electrodeTypeInd==Index.MICRO)
    [dataEpochsPerStim,stimStartTimesPerStimType, badEpochsLog, badStimIndicesPerStimType, ...
        badStimStartTimesPerStimType] = removeNoisyEpochs (data, dataEpochsPerStim, stimStartTimesPerStimType);
else
    badEpochsLog = [];
    badStimIndicesPerStimType = {};
    badStimStartTimesPerStimType = {};
end

end
