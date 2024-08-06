function header = getExperimentHeader(patientId, experimentNum)

folder_results='C:\Users\hcatt\OneDrive\Documents\results\';
folder_data='C:\Users\hcatt\OneDrive\Documents\data intracranial\';
header.id = patientId;
%if no experiment num than this is the default is the first experiment
if nargin==1
    experimentNum = 1;
end

header.experimentNum = experimentNum;

if (strcmp(lower(patientId),'d009'))
    
        if (experimentNum==1)
            header.folder_data_patient=[folder_data patientId '\exp_' num2str(experimentNum) '\'];
            if ~exist (header.folder_data_patient)
                mkdir(header.folder_data_patient)
            end
            header.system_recording='Blackrock';
            header.nsFilePath{Index.MACRO} = []; % folder where is the raw data recorded from MACRO electrodes (generally iEEG/EcoG) 
            header.nsFormat{Index.MACRO} = 'ns3'; % in Blackrock system, the data is saved in '.ns3' file
            header.channelsVec{Index.MACRO} = 1:9; %number of MACRO channels (sometimes there are channels that don't record anything)
            header.denoisedChannelsPath{Index.MACRO} = [folder_results patientId 'processed\Denoised_']; % folder where to save the denoised/downsampled data
            header.dataIndexInNsFile{Index.MACRO} = 2;
            
            header.nsFilePath{Index.MICRO} =  []; % folder where is the raw data recorded from MICRO electrodes (generally LFP, 30kHz-40kHz)
            header.nsFormat{Index.MICRO} = 'ns5'; % in Blackrock system, the data is saved in '.ns5' file
            header.channelsVec{Index.MICRO} =25:27; %number of MICRO channels (sometimes there are channels that don't record anything)
            header.denoisedChannelsPath{Index.MICRO} =  [folder_results patientId 'processed\Denoised_'];
            header.dataIndexInNsFile{Index.MICRO} = 2;
            
            header.nevFilePath = []; % folder where the stimulus are recorded (in Blackrok system, the stimulus are recorded in a '.nev' file)
            header.shamStimIndex = 0;
            header.isStimuliCodonsNeedRemapping = true;
            header.stimuli = {'sham','40Hz loud','40Hz medium','LEMAALA(push)',...
                'LEMATA(no push)', 'Anima','Brad Pitt','Harry Potter','Joey',...
                'Kelev','Superman','Titanic','Tom Cruise','Tzipor'};
            header.stimuliCodons = [0,1,2,3,4,5,6,7,8,9,10,11,12,13];
           header.stimuliCodons_music=[];
            header.nStimTypes_words=[3:13];  
            header.nStimTypes_click=[1,2];
          header.nStimTypes_sentence=[];
          
            header.stimLengthInSec =zeros(1,14) ;  header.stimLengthInSec(1:14) =0.5;
            header.processedDataPath = [header.folder_data_patient 'processed\']; % where to save the processed data for this patient
            header.figuresDataPath = [header.folder_data_patient 'figures\']; % where to save the figure for this patient
            header.spikesDataPath = [header.folder_data_patient 'spikes\']; % where to save the data after spike sorting for this patient
            header.isAutoMontage = false; % the montage has to been uploaded separately
            header.montagePath = [header.folder_data_patient 'montage.csv'] ; % where the montage file is saved (generally a '.csv' file)
            
            % EEG channels used for sleep scoring
%             header.nsFilePath{Index.EEG}=[]; % folder where the EEG channels are saved (in Blackrock, it is generally the same folder&file as the MACRO channels)
%             header.nsFormat{Index.EEG} = 'ns3';
%             header.dataIndexInNsFile{Index.EEG} = [];
%             header.channelsVec{Index.EEG} = 1:3; % for ex F3,F4,Pz
%             header.denoisedChannelsPath{Index.EEG} = []; % where to save the EEG channels after denoisang/downsampling
% 
%             
%             header.nsFilePath{Index.EKG}='C:\Human recording\raw data\D009\sleep wake\nsp1\20150812-152957\20150812-152957-001';
%             header.nsFormat{Index.EKG} = 'ns6';
%             header.dataIndexInNsFile{Index.EKG} = 2;
%             header.channelsVec{Index.EKG} = 4:5;
%             header.denoisedChannelsPath{Index.EKG} =  'C:\Human recording\results\D009\sleep wake\processed\Denoised_';
%             
            header.dataforALICE=[];
            header.scoring=[header.folder_data_patient 'scoring_1Hz.mat']; % where the sleep scoring is saved (matlab file, in second)
            header.scoringlabel=[200,-200,-300,100]; %wake, NREM2,NREM3, REM
            header.groupsNames = {'Awake','NREM','REM'};

            header.isValid = true; 
        else
            header.isValid = false;
        end   

elseif (strcmp(lower(patientId),'D00'))
%     
%         if (experimentNum==2)
%             header.nsFilePath{Index.MACRO} = []; % folder where is the raw data recorded from MACRO electrodes (generally iEEG/EcoG) 
%             header.nsFormat{Index.MACRO} = 'ns3'; % in Blackrock system, the data is saved in '.ns3' file
%             header.channelsVec{Index.MACRO} = []; %number of MACRO channels (sometimes there are channels that don't record anything)
%             header.denoisedChannelsPath{Index.MACRO} = []; % folder where to save the denoised/downsampled data
%             header.dataIndexInNsFile{Index.MACRO} = 2;
%             
%             header.nsFilePath{Index.MICRO} =  []; % folder where is the raw data recorded from MICRO electrodes (generally LFP, 30kHz-40kHz)
%             header.nsFormat{Index.MICRO} = 'ns5'; % in Blackrock system, the data is saved in '.ns5' file
%             header.channelsVec{Index.MICRO} =[]; %number of MICRO channels (sometimes there are channels that don't record anything)
%             header.denoisedChannelsPath{Index.MICRO} =  [folder_results patientId 'processed\Denoised_'];
%             header.dataIndexInNsFile{Index.MICRO} = 2;
%             
%             header.nevFilePath = []; % folder where the stimulus are recorded (in Blackrok system, the stimulus are recorded in a '.nev' file)
%             header.shamStimIndex = 0;
%             header.isStimuliCodonsNeedRemapping = true;
%             header.stimuli = {}; % name of the auditory stimulus played (for example: {'car', 'neighbour', 'guitar"}
%             header.stimuliCodons = []; % number identigying each stimuli 
%             % in our experiment, we played stimulus of different types 
%             header.stimuliCodons_music=[];header.nStimTypes_words=[];  
%             header.nStimTypes_click=[]; header.nStimTypes_sentence=[];
% 
%             header.stimLengthInSec =[]
%             header.processedDataPath = []; % where to save the processed data for this patient
%             header.figuresDataPath = []; % where to save the figure for this patient
%             header.spikesDataPath = []; % where to save the data after spike sorting for this patient
%             header.isAutoMontage = false; % the montage has to been uploaded separately
%             header.montagePath = [] ; % where the montage file is saved (generally a '.csv' file)
%             
%             % EEG channels used for sleep scoring
%             header.nsFilePath{Index.EEG}=[]; % folder where the EEG channels are saved (in Blackrock, it is generally the same folder&file as the MACRO channels)
%             header.nsFormat{Index.EEG} = 'ns3';
%             header.dataIndexInNsFile{Index.EEG} = [];
%             header.channelsVec{Index.EEG} = 1:3; % for ex F3,F4,Pz
%             header.denoisedChannelsPath{Index.EEG} = []; % where to save the EEG channels after denoisang/downsampling
% 
%             
%             header.nsFilePath{Index.EKG}='C:\Human recording\raw data\D009\sleep wake\nsp1\20150812-152957\20150812-152957-001';
%             header.nsFormat{Index.EKG} = 'ns6';
%             header.dataIndexInNsFile{Index.EKG} = 2;
%             header.channelsVec{Index.EKG} = 4:5;
%             header.denoisedChannelsPath{Index.EKG} =  'C:\Human recording\results\D009\sleep wake\processed\Denoised_';
%             
%             header.dataforALICE=[];
%             header.scoring=[]; % where the sleep scoring is saved (matlab file, in second)
%             header.scoringlabel=[200,-200,-300,100]; %wake, NREM2,NREM3, REM
%             header.groupsNames = {'Awake','NREM','REM'};
% 
%             header.isValid = true; 
%         else
%             header.isValid = false;
%         end         
end
end
