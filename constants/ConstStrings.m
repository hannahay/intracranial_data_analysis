classdef ConstStrings
   properties (Constant)
      DENOISED_FILE_NAME_PREFIX = 'denoised_';
      
      DENOISED_AUDIO_FILE_NAME = 'denoisedAudio';
      EVOKED_AUDIO_OUTPUT_FILE_NAME = 'evoked_audio_output';
      
      NOISY_DATA_POINTS_FILE_NAME_PREFIX = 'noisy_data_points_per_channel_';
      NOISY_DATA_POINTS_FILE_NAME_MICRO = [ConstStrings.NOISY_DATA_POINTS_FILE_NAME_PREFIX 'micro'];
      NOISY_DATA_POINTS_FILE_NAME_MACRO = [ConstStrings.NOISY_DATA_POINTS_FILE_NAME_PREFIX 'macro'];
      
      EVOKED_RESPONSES_MACRO_AND_MICRO_FILE_NAME = 'evoked_responses_macro_and_micro';
      EVOKED_RESPONSES_MACRO_AND_MICRO_EXTENDED_FILE_NAME = 'evoked_responses_macro_and_micro_extended';
      INDUCED_RESPONSES_MACRO_AND_MICRO_FILE_NAME = 'induced_responses_macro_and_micro';
      MEAN_INDUCED_RESPONSES_MACRO_AND_MICRO_FILE_NAME = ...
          [ConstStrings.INDUCED_RESPONSES_MACRO_AND_MICRO_FILE_NAME '_mean_and_sem'];
      MEAN_INDUCED_RESPONSES_ALL_GROUPS_STR = '_allGroups';
      MEAN_INDUCED_RESPONSES_GROUPS_STR = '_groups';
      MEAN_INDUCED_RESPONSES_GROUPS_SEPERATOR = '-';
      MEAN_INDUCED_RESPONSES_EQUALIZED_GROUPS_SEPERATOR = '_';
      
      DENOISED_FOLDER = 'Denoised_Downsampled_InMicroVolt\';
      DENOISED_FILE_PREFIX = 'denoised_';
      
      SPATIAL_EFFECTS_FOLDER = 'spatial effects\';
      MEAN_SPECTRUM_FIGURES_FOLDER = 'mean spectrum\';
      STIM_VS_CONTROL_FIGURES_FOLDER = 'stim vs control\';
      SPIKES_FOLDER = 'spikes\';
      TIMEF_FOLDER = 'timef\';
      MOMENTARY_ANALYSIS_FOLDER = 'momentary\';
      STATE_ANALYSIS_FOLDER = 'state analysis\';
      ACTIVITY_IN_FREQUENCIES_FOLDER = 'oscillatory activity\';
      SPONTANEOUS_SPECTROGRAM_FOLDER = 'Spontaneous Spectrogram\';
      BEHAVIOR_ANALYSIS_FOLDER = 'behavior\';
      NO_BEHAVIOR_ANALYSIS_FOLDER = 'without behavior\';
      
      GAMMA_FOLDER = 'gammaAmpLFP\';
      GAMMA_BASELINED_FOLDER = 'Baselined\';
      GAMMA_NOT_BASELINED_FOLDER = 'Not Baselined\';
      
      EPOCHS_DATA_FOLDER = 'epochs data\';
      BUTTON_RESPONSES_FOLDER = 'button responses\'
%       EQUALIZED_EPOCHS_FOLDER = 'Equalized Num Of Epochs\';
      EQUALIZED_EPOCHS_FOLDER = 'Equal Epochs\';

      UNEQUALIZED_EPOCHS_FOLDER = 'All Epochs\'
      
      AUDIO_FOLDER = 'Audio';
      AUDIO_FILE = 'Audio';
      ITC_SINGLE_TRIALS_FOLDER = 'itc single trials\';
      BANDPASS_FOLDER = 'bandpass%d_%d\';
      
      MONTAGE_CSV_CHANNEL = 'CHANNEL';
      MONTAGE_CSV_IS_MACRO = 'IS_MACRO';
      MONTAGE_CSV_LOCATION = 'LOCATION';
      MONTAGE_CSV_DEPTH = 'DEPTH';
      
      
      EPOCHS_TRAIN_FILE_NAME = 'epochsTrain';
      
      SPIKE_TIMES_FILE_NAME = 'times_CSC';
      
      WARD_STR = 'Ward';
      OR_STR = 'OR';
      OVERNIGHT='Sleep';
      
      RESPONSE_BUTTON_PUSH = 'Button Push';
      CORRECT_RESPONSE_BUTTON_PUSH = 'Button Push Hit'
      WRONG_RESPONSE_BUTTON_PUSH = 'Button Push False Positive'
      TARGET_STIM_HITS = 'Target Hits';
      TARGET_STIM_MISSES = 'Target Misses';
      
      HAMMING_WINDOW = 'hamming';
      HANN_WINDOW = 'hann';
      SQUARE_WINDOW = 'square';
   end
end