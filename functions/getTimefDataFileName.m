function fileName = getTimefDataFileName(header,electrodeTypeInd,channel,...
    stimStr,numOfTimeGroups,groupInd,montageMap)

if(~exist('montageMap','var'))
    montageMap = readMontage(header);
end
electrodeFullStr = getElectrodeFullStr(montageMap,electrodeTypeInd,channel);
if (numOfTimeGroups==1)
    fileName = sprintf('%s-%d_%s_%s',header.id, ...
        header.experimentNum, electrodeFullStr,stimStr);
else
    fileName = sprintf('%s-%d_%s_%s_Group%d',header.id, ...
        header.experimentNum, electrodeFullStr,stimStr,groupInd);
end

end