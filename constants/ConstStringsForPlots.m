classdef ConstStringsForPlots
   properties (Constant)

      SUBPLOTS_INDEX = 2;
      NO_SUBPLOTS_INDEX = 1;
       
      X_LABEL_FONT_SIZE = [18 13];
      Y_LABEL_FONT_SIZE = [18 13];
      TITLE_FONT_SIZE = [18 13];
      LEGEND_FONT_SIZE = [16 12];
      AXIS_FONT_SIZE = [14 12];

      
      
%             X_LABEL_FONT_SIZE = 18;
%       Y_LABEL_FONT_SIZE = 18;
%       TITLE_FONT_SIZE = 18;
%       LEGEND_FONT_SIZE = 18;
      
       
      X_LABEL = 'Frequency(Hz)'; 
      Y_LABEL = 'Power(Db)';
      STIM_LEGEND = 'stimulus';
      CONTROL_LEGEND = 'control';
      TITLE_PLOT_TYPE = 'mean spectrum for stimulus vs. control';
      
      STATE_AWAKE = 'Ward';
      STATE_OR = 'OR';
      
      ELECTRODE_MACRO = 'Macro';
      ELECTRODE_MICRO = 'Micro';
      AUDIO_WAV = 'Audio Wav';
      AUDIO_TTL = 'Audio TTL';
      RESPONSE_BUTTON = 'Response Button';
      
   end
end