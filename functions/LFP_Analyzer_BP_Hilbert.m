function LFP_Analyzer_BP_Hilbert (header,electrodeTypeInd,channels,timefArgs, cutoffTimes,freq_ranges, equalizeIndices, ...
     isSaveEpochsData, invalidTimes)
%equalizeIndices - 
%[Index.UNEQUALIZED] - run the analysis on *unequalized* num of trials (between time groups)
%[Index.EQUALIZED] - run the analysis on *equalized* num of trials (between time groups)
%[Index.EQUALIZED Index.UNEQUALIZED] - run the analysis on both *equalized*and *unequalized*


MS_IN_SEC = 1000;
REMOVE_NOISY_EPOCHS = true;
DONT_REMOVE_NOISY_EPOCHS = false;

if (~exist('invalidTimes','var'))
    invalidTimes = [];
end


if(~exist('isSaveEpochsData','var'))
    isSaveEpochsData = true;
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

signal_type={'Macro', 'Micro'};
montageMap = readMontage(header);
noisyDataPointsPerChannel = getNoisyDataPointsPerChannel(header,electrodeTypeInd);

stimMap = getStimuliMap (header, true, true);

sr = Consts.DOWNSAMPLED_FREQUENCY;

timefDataFolderPath=[ header.processedDataPath '\BP_filter\' signal_type{electrodeTypeInd}...
    num2str(freq_ranges(1)) '_' num2str(freq_ranges(2)) 'Hz\'];

if ~exist(timefDataFolderPath); mkdir(timefDataFolderPath);
end

for channel = channels
    
        electrodeFullStr = getElectrodeFullStr(montageMap,electrodeTypeInd,channel);

    data = getDenoisedData (header,electrodeTypeInd,channel);    
    [dataEpochsPerStim,stimStartTimesPerStimType, badEpochsLog, badStimIndicesPerStimType,...
        badStimStartTimesPerStimType] = getDataEpochsPerStimWithoutNoisyEpochs_H (...
        data, header,electrodeTypeInd, timefArgs.preStartTimeInSec, timefArgs.postStartTimeInSec,true, invalidTimes);
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
        
    gammaEnvelope = getEnvelopeOfFrequencyBandWithHilbert(data, sr, ...
        freq_ranges(1), freq_ranges(2));
  
    [gammaActivityPerStimA,~, ~, ~, ~] = getDataEpochsPerStimWithoutNoisyEpochs_H (...
        gammaEnvelope, header,electrodeTypeInd, timefArgs.preStartTimeInSec, timefArgs.postStartTimeInSec,DONT_REMOVE_NOISY_EPOCHS);
    %remove epochs by indices found for the raw data
    if(~isempty(badStimIndicesPerStimType))
        gammaActivityPerStimA = cellfun(@removeBadIndices, gammaActivityPerStimA,...
            badStimIndicesPerStimType,'UniformOutput',false);
    end
    gammaActivityPerStim=gammaActivityPerStimA;
    clear gammaActivityPerStimA
    end
    
    [indicesPerGroup] = cellfun(@(x) getIndicesPerTimeGroup_H(cutoffTimes,x,false),...
        stimStartTimesPerStimType,'UniformOutput',false);
    %get indices for each time group !!HANNA!!
    [indicesPerGroupPerStimType] = cellfun(@(x) getIndicesPerTimeGroup_H(cutoffTimes,x,false),...
        stimStartTimesPerStimType,'UniformOutput',false);
% %     get a random sample of indices for each time group to equalize to num
% %     of epochs in each group
    [indicesPerGroupPerStimTypeEqualizedNumOfEpochs] = cellfun(@(x) getIndicesPerTimeGroup_H(cutoffTimes,x,true),...
        stimStartTimesPerStimType,'UniformOutput',false); % Hanna
% % % % % % % % % % % % % % % %     
    nStimTypes = length(dataEpochsPerStim);
    
    for stimTypeInd=1:nStimTypes-1  
        
        stimStr = stimMap(stimTypeInd);
        
        indicesPerGroupForThisStim = indicesPerGroupPerStimType{stimTypeInd};
        indicesPerGroupForThisStimEqualizedNumOfEpochs = ...
            indicesPerGroupPerStimTypeEqualizedNumOfEpochs{stimTypeInd};

        dataEpochsForThisStim = dataEpochsPerStim{stimTypeInd};

        
        for groupInd = 1:numOfTimeGroups %numOfTimeGroups:-1:1 %
            
            indicesForGroupAndStim = indicesPerGroupForThisStim{groupInd};
            indicesForGroupAndStimEqualizedNumOfEpochs = indicesPerGroupForThisStimEqualizedNumOfEpochs{groupInd};
            
            if isempty(indicesForGroupAndStimEqualizedNumOfEpochs)
                disp('epochsTrain of stim was empty. check if because noisy data');
                continue;
            end
                    
                for q=1:size(freq_ranges,1)

                gammaActivityForThisStim = gammaActivityPerStim{stimTypeInd};

            epochsIndicesPerEqualizeState{Index.UNEQUALIZED} = indicesForGroupAndStim;
% %             epochsIndicesPerEqualizeState{Index.EQUALIZED} = indicesForGroupAndStimEqualizedNumOfEpochs;
            
            dataEpochsPerEqualizedState{Index.UNEQUALIZED} = dataEpochsForThisStim(...
                epochsIndicesPerEqualizeState{Index.UNEQUALIZED},:);

            filtered_dataPerEqualizedState{Index.UNEQUALIZED} = gammaActivityForThisStim(...
                epochsIndicesPerEqualizeState{Index.UNEQUALIZED},:);

           electrodeFullStr = getElectrodeFullStr(montageMap,electrodeTypeInd,channel);
             fileName=[char(header.id) char(electrodeFullStr) '_' stimStr '_' header.groupsNames{groupInd}];         
% % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % 
            if (isempty(badEpochsLog))
                badEpochsLogForStim = [];
                badStimIndicesForStim = [];
                badStimStartTimesForStim = [];
            else
                badEpochsLogForStim = badEpochsLog.perStimType(stimTypeInd);
                badStimIndicesForStim = badStimIndicesPerStimType{stimTypeInd};
                badStimStartTimesForStim = badStimStartTimesPerStimType{stimTypeInd};
            end
            
            equalizeInd=1;
                chosenEpochsIndices = epochsIndicesPerEqualizeState{equalizeInd};
                filtered_data(:,:) = filtered_dataPerEqualizedState{equalizeInd};
                filtered_data_norm(:,:) = filtered_data(:,:)./mean(filtered_data(:,50:(timefArgs.preStartTimeInSec-0.05)*1000),2);
                meanfiltered_data(:,:) = mean(filtered_dataPerEqualizedState{equalizeInd});
                meanfiltered_data_norm(:,:) = mean( filtered_data_norm(:,:,q));
                dataEpochs = dataEpochsPerEqualizedState{equalizeInd};
                erp = mean(dataEpochs);
            
                end
                
            
                
             epochsDataFullPath = [timefDataFolderPath fileName];

         epochsDataFullPath = [timefDataFolderPath fileName];
       
                

 save(epochsDataFullPath,'header','channel','stimTypeInd','stimStr',...
   'electrodeTypeInd','timefArgs', 'cutoffTimes','chosenEpochsIndices',...
  'erp', 'filtered_data','dataEpochs',...
   'filtered_data_norm', 'freq_ranges' , 'indicesPerGroupPerStimType' );
         
clear chosenEpochsIndices dataEpochs erp filtered_data filtered_data_norm  meanfiltered_data ...
   meanfiltered_data_norm filtered_data_norm_band filtered_data_band
            end
            
            
    end
     
%  save( [timefDataFolderPath 'Ch' num2str(channel) '_indicesandtimePerGroupPerStimType'], 'timePerGroup','indicesPerGroup');
    end
    





