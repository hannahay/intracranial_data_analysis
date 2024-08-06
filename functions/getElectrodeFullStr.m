function electrodeFullStr = getElectrodeFullStr(montageMap,electrodeTypeInd,channel)

if (electrodeTypeInd==Index.MACRO || electrodeTypeInd==Index.MICRO)
    montageForElectrodeType = montageMap(electrodeTypeInd,:);
    locationStr = montageForElectrodeType{1,channel}.location;
    depthInd = montageForElectrodeType{1,channel}.depth;
else
    locationStr = [];
    depthInd = [];
end
electrodeName = getElectrodeStr (electrodeTypeInd, locationStr, depthInd, true, channel);
electrodeFullStr = sprintf('%s-Ch%d', electrodeName,channel);

end