function [dataEpochsPerStim,stimStartTimesPerStimType, badEpochsLog, ...
    badEpochsIndicesPerStimType, badEpochsTimesPerStimType] = removeNoisyEpochs (...
    data, dataEpochsPerStim ,stimStartTimesPerStimType)


estimatedNoiseStd = median(abs(data))/0.6745; %this is a magic formula by Rodrigo Quian Quiroga

positiveBound = estimatedNoiseStd*Consts.MAX_STDS_FOR_EXTREME_VALUES_DETECTION;
negativeBound = -positiveBound;

nStimTypes = length(dataEpochsPerStim);

nEpochsInAllStims = 0;
nBadEpochsInAllStims = 0;

for stimTypeInd = 1:nStimTypes
    %dataEpochs dimensions suppose to be trials*dataPoints
     dataEpochs = dataEpochsPerStim{stimTypeInd};
     
    %remove bad epochs by extreme values
    badPointsMatrix = dataEpochs>positiveBound | ...
         dataEpochs<negativeBound;
    badEpochsByExtremeValuesVec = sum(badPointsMatrix,2)>0;
    
    %remove bad epochs by extreme std of epochs
    allEpochsStd = std(dataEpochs,0,2);
    medianStdOfAllEpochs = median(allEpochsStd);
    badEpochsByExtremeStdsVec = allEpochsStd>(...
        medianStdOfAllEpochs*Consts.MAX_RATIO_OF_MEDIAN_STD_FOR_EXTREME_STD_EPOCHS_DETECTION) |...
        allEpochsStd<(medianStdOfAllEpochs*Consts.MIN_RATIO_OF_MEDIAN_STD_FOR_EXTREME_STD_EPOCHS_DETECTION) | ...
        allEpochsStd<Consts.MIN_STD_MICROVOLT;
    
    
    allBadEpochs = badEpochsByExtremeValuesVec | badEpochsByExtremeStdsVec;
    badEpochsIndicesPerStimType{stimTypeInd} = find(allBadEpochs);
    badEpochsTimesPerStimType{stimTypeInd} = stimStartTimesPerStimType{stimTypeInd}(allBadEpochs);
    dataEpochsPerStim{stimTypeInd}(allBadEpochs,:) = [];
    stimStartTimesPerStimType{stimTypeInd}(allBadEpochs) = [];
    
    
    nAllEpochs = size(dataEpochs,1);
    nBadEpochsInAllStims = nBadEpochsInAllStims + sum(allBadEpochs);
    nEpochsInAllStims = nEpochsInAllStims + nAllEpochs;
    badEpochsLog.perStimType(stimTypeInd).percentBadEpochsByExtremeStds = sum(badEpochsByExtremeStdsVec)/nAllEpochs*100;
    badEpochsLog.perStimType(stimTypeInd).percentBadEpochsByExtremeValues = sum(badEpochsByExtremeValuesVec)/nAllEpochs*100;
    badEpochsLog.perStimType(stimTypeInd).allBadEpochs = sum(allBadEpochs)/nAllEpochs*100;
end

badEpochsLog.nBadEpochsInAllStims = nBadEpochsInAllStims;
badEpochsLog.nEpochsInAllStims = nEpochsInAllStims;
badEpochsLog.percentRejectedTotal = nBadEpochsInAllStims/nEpochsInAllStims*100;

end