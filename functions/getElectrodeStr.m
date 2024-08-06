function electrodeStr = getElectrodeStr (electrodeTypeInd, locationStr, depthInd, isForFileName, channel)

electrodeTypeStr{Index.MACRO} = ConstStringsForPlots.ELECTRODE_MACRO;
electrodeTypeStr{Index.MICRO} = ConstStringsForPlots.ELECTRODE_MICRO;
electrodeTypeStr{Index.AUDIO_OUTPUT} = ConstStringsForPlots.AUDIO_WAV;
electrodeTypeStr{Index.AUDIO_TTL} = ConstStringsForPlots.AUDIO_TTL;
% electrodeTypeStr{Index.RESPONSE_BUTTON} = ConstStringsForPlots.RESPONSE_BUTTON;

if (electrodeTypeInd==Index.MACRO || electrodeTypeInd==Index.MICRO)

    if(isForFileName)
        electrodeStr = sprintf('%s_%s%d', electrodeTypeStr{electrodeTypeInd},...
            locationStr,depthInd);
    else
        electrodeStr = sprintf('%s %s%d (ch. %d)', electrodeTypeStr{electrodeTypeInd},...
            locationStr,depthInd,channel);
    end
else
    electrodeStr = electrodeTypeStr{electrodeTypeInd};
end