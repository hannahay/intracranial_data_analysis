PATIENT_id='489';
num_of_exp=12;

header = getExperimentHeader(PATIENT_id,num_of_exp) 
 
DOWNSAMPLED_FREQ_HZ = 1000;
groupsTimes= importscoring_H(header);

samplingRatePerElectrodeType = SR_per_system_recording (header.system_recording, raw_data=0)

downsampleDenoiseChangeToMicroVoltAndSave(header,samplingRatePerElectrodeType,DOWNSAMPLED_FREQ_HZ);

noisyDataPointsPerChannelForMicroAndMicro = getAndSaveNoisyDataPointsForMicroAndMacro(header);

[epochsTrain, extendedEpochsTrain, nevSr] = getAndSaveEpochsTrain_H_onepart(header);

