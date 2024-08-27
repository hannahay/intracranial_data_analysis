classdef Consts
   properties (Constant)

      DOWNSAMPLED_FREQUENCY = 1000;
      LINE_FREQUENCY = 50;  %50Hz
      FILTER_WINDOW_WIDTH = 1; %1 sec - for line noise filtering
      
      PRE_STIM_TIME_SEC_FOR_EXTENDED_EPOCHS = 0.5
      POST_STIM_TIME_SEC_FOR_EXTENDED_EPOCHS = 0.6
      
      INCREASE_IN_LENGTH_OF_STIM_IN_SEC_FOR_INDUCED_RESPONSE = 0.05;
      DELAY_OF_STIM_IN_SEC_FOR_INDUCED_RESPONSE = 0.05;
      FREQUENCY_VEC_FOR_INDUCED_RESPONSE = 1:200;
     
%       INTERESTING_FREQUENCIES_FOR_INDUCED_POWER_TO_CHECK_EFFECTS = 1:200; %this would be 
%       %generally 40 Hz,8Hz and other relevant frequencies

      
      NUM_OF_ESTIMATED_STD_OF_NOISE_FOR_BAD_TRIAL_DETECTION = 10;
      
      MAXIMAL_FRACTION_OF_NOISY_EPOCHS = 0.25; %no more than 25% of epochs can be considered noisy - ...
      %if so, it might imply that the noise criterion is too loose.
      MINIMAL_FRACTION_OF_NOISY_EPOCHS = 0.02; %no less than 2% of epochs should be considered noisy - ...
      %if so, it might imply that the noise criterion is too strict.
      
      MIN_NUM_OF_EPOCHS_FOR_ITC = 6;
      
      MAX_STDS_FOR_EXTREME_VALUES_DETECTION = 15;
      MAX_RATIO_OF_MEDIAN_STD_FOR_EXTREME_STD_EPOCHS_DETECTION = 8;
      MIN_RATIO_OF_MEDIAN_STD_FOR_EXTREME_STD_EPOCHS_DETECTION = 0.05;
      MIN_STD_MICROVOLT = 0.1;
      LOW_GAMMA_FREQ = 40;
      HIGH_GAMMA_FREQ = 100;
      
      MINIMAL_LAST_NSX_DATA_SEGMENT_RATIO_OF_ALL_SEGMENTS = 0.95;
      
   end
end