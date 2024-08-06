function samplingRatePerElectrodeType = SR_per_system_recording (system_recording, raw_data)

if raw_data==0 % no access to raw data

switch system_recording
    case 'Blackrock'
        samplingRatePerElectrodeType{1, Index.MACRO} = 2000;
    case 'Neuralynx'
        samplingRatePerElectrodeType{1, Index.MACRO} = 40000;
    otherwise
        error('Unknown system recording: %s', system_recording);
end


elseif raw_data==1
    samplingRatePerElectrodeType = getSamplingRatePerElectrodeType_H(header);

end

end