function [epochsTrain, extendedEpochsTrain, nevSr] = getAndSaveEpochsTrain_H_onepart(header)

MAX_LEAD_IN_MS = 50;
MAX_DELAY_IN_MS = 100;

% NEV = openNEV(sprintf('%s%s',header.nevFilePath,'.nev'),'read','overwrite');
NEV = openNEV(sprintf('%s%s',header.nevFilePath,'.nev'),'read','overwrite');

[epochsTrain, nevSr] = generateTrain40HzFromNev_forAll(NEV);

epochsTrain(header.nullTrials) = [];
if(isfield(header,'stimsHardCoded'))
    epochsTrain = fixEpochsTrainWithHardCodedStims(epochsTrain,header.stimsHardCoded.file);
    disp('Stimuli codons were retrieved');
end
if (isfield(header,'isStimuliCodonsNeedRemapping') && ...
        (header.isStimuliCodonsNeedRemapping))
    stimCodonsRemap = getStimuliCodonsReMap(header);
    for epochInd = 1:length(epochsTrain)
        epochsTrain(epochInd).vol = stimCodonsRemap(epochsTrain(epochInd).vol);
    end
    disp('Stimuli codons were remapped');
end

stimNamesToCodonsMap = getStimuliMap(header,false,false);



% if (header.ttlChannel>0)
if(length(header.channelsVec)>=Index.AUDIO_TTL && ...
        ~isempty(header.channelsVec{Index.AUDIO_TTL}))
    if (length(header.channelsVec{Index.AUDIO_TTL})>1)
        error('more than 1 ttl channel');
    end
    ttlChannel = header.channelsVec{Index.AUDIO_TTL};
    NSx = openNSx(sprintf('%s%s%s',header.nsFilePath{Index.AUDIO_TTL},'.', ...
        header.nsFormat{Index.AUDIO_TTL}),'read','precision',...
        'double', sprintf('c:%d:%d',ttlChannel,ttlChannel));
    
    if (header.dataIndexInNsFile{Index.AUDIO_TTL}>0)
        ttlChannelData=NSx.Data{header.dataIndexInNsFile{Index.AUDIO_TTL}};
    else
        ttlChannelData=NSx.Data;
    end
     save([ header.processedDataPath 'ttlChannelData'],'ttlChannelData', '-v7.3');

%     if (header.dataIndexInNsFile{Index.AUDIO_TTL}>0)
%         ttlChannelData=eval(sprintf('%s.Data{%d}',...
%             upper(header.nsFormatTtl),...
%             header.dataIndexInNsFileTtl));
%     else
%         ttlChannelData=eval(sprintf('%s.Data',upper(header.nsFormatTtl)));
%     end
    if (header.isAutoThreshold)
        ttlThreshold = getAutoTtlThresholdFast(ttlChannelData);
    else
        ttlThreshold = header.ttlThreshold;
    end
    logicalTtlChannelData = (ttlChannelData>ttlThreshold);
    logicalTtlChannelDataShiftedForward = [logicalTtlChannelData(1,1), logicalTtlChannelData(1,1:(end-1))];
    logicalTtlChannelDataShiftedBackward = [logicalTtlChannelData(1,2:(end)),logicalTtlChannelData(1,end)];
    epoctStartIndices = (logical(logicalTtlChannelData==1) &...
        logical(logicalTtlChannelDataShiftedForward==0));
    epoctEndIndices = (logical(logicalTtlChannelData==1) &...
        logical(logicalTtlChannelDataShiftedBackward==0));
    
    epochStartTime = find(epoctStartIndices);
    epochEndTime = find(epoctEndIndices);
    
    
    
    startTimeInd = 1;
    delays = [];
    numOfEpochsWithNoTtlThatFits = 0;
    epochsWithNoTtlThatFits = [];
    
    
    %edit epochsTrain start and end Codons
    for epochInd = 1:numel(epochsTrain)
        while(double(epochsTrain(epochInd).startCodonTime)-epochStartTime(startTimeInd)>MAX_LEAD_IN_MS/1000*nevSr)
            startTimeInd = startTimeInd + 1;
            if (startTimeInd>numel(epochStartTime))
                break;
            end
        end
        currentDelay = epochStartTime(startTimeInd) - double(epochsTrain(epochInd).startCodonTime);
        if (currentDelay<=MAX_DELAY_IN_MS/1000*nevSr)
            delays = [delays, currentDelay];
            epochsTrain(epochInd).startCodonTime = epochStartTime(startTimeInd);
            epochsTrain(epochInd).endCodonTime = epochsTrain(epochInd).endCodonTime + currentDelay;
            startTimeInd = startTimeInd + 1;
        else
            if ((isfield(header, 'shamStimIndex') && ...
                    epochsTrain(epochInd).vol == header.shamStimIndex) ||...
                    (isKey(stimNamesToCodonsMap,'sham') &&...
                        epochsTrain(epochInd).vol == stimNamesToCodonsMap('sham')))
                continue;
            end
            numOfEpochsWithNoTtlThatFits = numOfEpochsWithNoTtlThatFits + 1;
            epochsWithNoTtlThatFits = [epochsWithNoTtlThatFits, epochInd];
            continue;
        end
        
        %         epochsTrain(epochInd).startCodonTime = epochsTrain(epochInd).startCodonTime - PRE_STIM_TIME_SEC*nevSr;
        %         epochsTrain(epochInd).endCodonTime = epochsTrain(epochInd).endCodonTime + POST_STIM_TIME_SEC*nevSr;
    end
    
    %     if (double(epochsTrain(1).startCodonTime)-...
    %             (PRE_STIM_TIME_SEC+STIM_LENGTH_IN_SEC+POST_STIM_TIME_SEC)*sr<=0)
    if length(header.stimLengthInSec)>1
    if (double(epochsTrain(1).startCodonTime)-header.stimLengthInSec(epochsTrain(1).vol)*nevSr<=0) %
        epochsTrain(1) = [];
    end
    else
         if (double(epochsTrain(1).startCodonTime)-header.stimLengthInSec*nevSr<=0) %
        epochsTrain(1) = [];
    end
    end
    
    if(epochsTrain(numel(epochsTrain)).endCodonTime>NEV.MetaTags.DataDuration) 
        epochsTrain(numel(epochsTrain)) = [];
    end
    fprintf('%d%% of epochs were matched by TTL\n',...
        (numel(epochsTrain)-numOfEpochsWithNoTtlThatFits)/numel(epochsTrain)*100);
end

% epochsTrain(epochsWithNoTtlThatFits)=[];


extendedEpochsTrain = epochsTrain;
for epochInd = 1:numel(extendedEpochsTrain)
    extendedEpochsTrain(epochInd).startCodonTime = extendedEpochsTrain(epochInd).startCodonTime - ...
        Consts.PRE_STIM_TIME_SEC_FOR_EXTENDED_EPOCHS*nevSr;
    extendedEpochsTrain(epochInd).endCodonTime = extendedEpochsTrain(epochInd).endCodonTime + ...
        Consts.POST_STIM_TIME_SEC_FOR_EXTENDED_EPOCHS*nevSr;
end

if length(header.stimLengthInSec)>1
if (double(extendedEpochsTrain(1).startCodonTime)-...
        (Consts.PRE_STIM_TIME_SEC_FOR_EXTENDED_EPOCHS + ...
       header.stimLengthInSec(epochsTrain(1).vol) + Consts.POST_STIM_TIME_SEC_FOR_EXTENDED_EPOCHS)*nevSr<=0)
end
else
 if (double(extendedEpochsTrain(1).startCodonTime)-...
        (Consts.PRE_STIM_TIME_SEC_FOR_EXTENDED_EPOCHS + ...
       header.stimLengthInSec + Consts.POST_STIM_TIME_SEC_FOR_EXTENDED_EPOCHS)*nevSr<=0)
end   
end



if(extendedEpochsTrain(numel(extendedEpochsTrain)).endCodonTime>NEV.MetaTags.DataDuration)
    extendedEpochsTrain(numel(extendedEpochsTrain)) = [];
end

if (~exist(header.processedDataPath,'dir'))
    mkdir(header.processedDataPath)
end

save(sprintf('%s%s',header.processedDataPath,...
    ConstStrings.EPOCHS_TRAIN_FILE_NAME),'epochsTrain', 'extendedEpochsTrain','nevSr');

end



%{
% syncDataForStim
openNSx(sprintf('%s%s%s',filePath,'.',nsFormat),'read','precision',...
        'double', sprintf('c:%d:%d',ttlChannel,ttlChannel));
ttlChannelData = NS6.Data;
logicalTtlChannelData = (ttlChannelData>161);

logicalTtlChannelDataShiftedForward = [logicalTtlChannelData(1,1), logicalTtlChannelData(1,1:(end-1))];
logicalTtlChannelDataShiftedBackward = [logicalTtlChannelData(1,2:(end)),logicalTtlChannelData(1,end)];
epoctStartIndices = (logical(logicalTtlChannelData==1) &...
    logical(logicalTtlChannelDataShiftedForward==0));
epoctEndIndices = (logical(logicalTtlChannelData==1) &...
    logical(logicalTtlChannelDataShiftedBackward==0));

epochStartTime = find(epoctStartIndices);
epochEndTime = find(epoctEndIndices);


%edit train40Hz start and end Codons
for epochInd = 1:numel(train40Hz)
    while(double(train40Hz(epochInd).startCodonTime)-epochStartTime(startTimeInd)>MAX_LEAD_IN_MS/1000*nevSr)
        startTimeInd = startTimeInd + 1;
        if (startTimeInd>numel(epochStartTime))
            break;
        end
    end
    currentDelay = epochStartTime(startTimeInd) - double(train40Hz(epochInd).startCodonTime);
    if (currentDelay<=MAX_DELAY_IN_MS/1000*nevSr)
        delays = [delays, currentDelay];
        train40Hz(epochInd).startCodonTime = epochStartTime(startTimeInd);
        train40Hz(epochInd).endCodonTime = train40Hz(epochInd).endCodonTime + currentDelay;
        startTimeInd = startTimeInd + 1;
    else
        if (train40Hz(epochInd).vol == SHAM_STIM_INDEX)
            continue;
        end
        numOfEpochsWithNoTtlThatFits = numOfEpochsWithNoTtlThatFits + 1;
        epochsWithNoTtlThatFits = [epochsWithNoTtlThatFits, epochInd];
        continue;
    end
    
    train40Hz(epochInd).startCodonTime = train40Hz(epochInd).startCodonTime - PRE_STIM_TIME_SEC*nevSr;
    train40Hz(epochInd).endCodonTime = train40Hz(epochInd).endCodonTime + POST_STIM_TIME_SEC*nevSr;
end

if (double(train40Hz(1).startCodonTime)-...
        (PRE_STIM_TIME_SEC+STIM_LENGTH_IN_SEC+POST_STIM_TIME_SEC)*sr<=0)
    train40Hz(1) = [];
end
if(train40Hz(numel(train40Hz)).endCodonTime>NEV.MetaTags.DataDuration)
    train40Hz(numel(train40Hz)) = [];
end
%}