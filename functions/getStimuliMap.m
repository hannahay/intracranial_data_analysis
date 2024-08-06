function stimMap = getStimuliMap (header, isCodonsToNames, isChangeZero)
    if(isfield(header,'stimsHardCoded'))
        header.stimuliCodons = header.stimsHardCoded.stimuliCodons;
        header.stimuli = header.stimsHardCoded.stimuli;
    end

    stimuliCodons = header.stimuliCodons;
    if (isChangeZero && ismember(0,stimuliCodons))
        stimuliCodons(stimuliCodons==0) = getZeroAlternativeValue(stimuliCodons);
    end
    
    if (numel(stimuliCodons)==1)
        stimNames = header.stimuli{1}; % in this case Containers.Map expect string and not cell array
    else
        stimNames = header.stimuli; % in this case Containers.Map expect cell array
    end
    
    if (isCodonsToNames)
        stimMap = containers.Map(stimuliCodons,stimNames);
    else
        stimMap = containers.Map(stimNames,stimuliCodons);
    end
end