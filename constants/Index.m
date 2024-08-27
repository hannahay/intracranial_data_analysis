classdef Index
   properties (Constant)
      MACRO = 1;
      MICRO = 2; 
      AUDIO_OUTPUT = 3;
      AUDIO_TTL = 4;
%       RESPONSE_BUTTON = 10;
      EEG=5;
      EKG=6;
      EOG=7;
      EMG=8;
      Mastoid=9;
      
      UNEQUALIZED = 1;
      EQUALIZED = 2;
      
      MONTAGE_CSV_CHANNEL = 1;
      MONTAGE_CSV_IS_MACRO = 2;
      MONTAGE_CSV_LOCATION = 3;
      MONTAGE_CSV_DEPTH = 4;
      
      %event types to lock raster and psth
      AUDITORY_STIMULUS_EVENT = 1; %lock raster and psth to auditory stimulus (this is the classic raster)
      BUTTON_PUSH_EVENT = 2;
      CORRECT_BUTTON_PUSH_EVENT = 3; %correct button push (after the appropriate 
                % auditory stimulus of the task(LEMAALA))
      WRONG_BUTTON_PUSH_EVENT = 4;
      TARGET_STIM_HITS = 5;
      TARGET_STIM_MISSES = 6;
      
      EARLY_RESPONSE = 1;
      LATE_RESPONSE = 2;
      
      BEFORE_SD = 1;
      AFTER_SD = 2;
      
   end
end