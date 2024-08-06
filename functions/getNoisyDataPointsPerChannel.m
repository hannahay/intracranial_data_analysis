function noisyDataPointsPerChannel = getNoisyDataPointsPerChannel(header,electrodeTypeInd)

if (electrodeTypeInd~=Index.MACRO && electrodeTypeInd~=Index.MICRO)
    noisyDataPointsPerChannel = {};
    return;
end

if(electrodeTypeInd==Index.MACRO)
    noisyDataPointsFileName = ConstStrings.NOISY_DATA_POINTS_FILE_NAME_MACRO;
elseif (electrodeTypeInd==Index.MICRO)
    noisyDataPointsFileName = ConstStrings.NOISY_DATA_POINTS_FILE_NAME_MICRO;
end
noisyDataPoints = load(sprintf('%s%s',header.processedDataPath,noisyDataPointsFileName));

noisyDataPointsPerChannel = noisyDataPoints.noisyDataPointsPerChannel;

end
