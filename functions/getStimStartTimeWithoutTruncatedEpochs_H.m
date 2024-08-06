function [stimStartDataPointsIndicesPerStimType,stimStartTimesPerStimType] = getStimStartTimeWithoutTruncatedEpochs_H(...
    header,preStimStartTimeInSec,postStimStartTimeInSec,dataLength,sr)


loadedEpochsAndNevData = load(sprintf('%s%s',header.processedDataPath, ...
    ConstStrings.EPOCHS_TRAIN_FILE_NAME));
epochsTrain = loadedEpochsAndNevData.epochsTrain;
nevSr = loadedEpochsAndNevData.nevSr;
epochsTrainPerStim = getEpochsTrainByStim (header,epochsTrain);

if(~exist('sr','var'))
    sr = Consts.DOWNSAMPLED_FREQUENCY;
end

nStimTypes = length(epochsTrainPerStim);

for stimTypeInd = 1:nStimTypes
    [stimStartDataPointsIndices,stimStartTimes] = getStimStartDataPointsIndicesFromEpochsTrain (...
        header,epochsTrainPerStim{stimTypeInd},nevSr,sr);
    %remove truncated epochs (epochs that start before the first data
    %sample or end after the last data sample)
    %%Hanna put in green
% % % % % % %     truncatedEpochsIndices = (stimStartDataPointsIndices-preStimStartTimeInSec*sr)<1 |...
% % % % % % %        (stimStartDataPointsIndices+postStimStartTimeInSec(stimTypeInd)*sr)>dataLength; 
    
    
% % % % %     stimStartDataPointsIndices(truncatedEpochsIndices)=[];
% % % % %     stimStartTimes(truncatedEpochsIndices) = [];
    stimStartDataPointsIndicesPerStimType{stimTypeInd}  = stimStartDataPointsIndices;
    stimStartTimesPerStimType{stimTypeInd}  = stimStartTimes;
end

end