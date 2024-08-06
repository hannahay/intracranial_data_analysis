function folderName = getElectrodeTypeFolderName(electrodeTypeInd)
    switch (electrodeTypeInd)
        case Index.MACRO
            folderName = 'Macro\';
            return;
        case Index.MICRO
            folderName = 'Micro\';
            return;
        case Index.AUDIO_OUTPUT
            folderName = 'AudioWav\';
            return;
        case Index.AUDIO_TTL
            folderName = 'AudioTTL\';
            return;
%         case Index.RESPONSE_BUTTON
%             folderName = 'ResponseButton\';
%             return;
            case Index.EEG
            folderName = 'EEG\';
            return;
             case Index.EKG
            folderName = 'EKG\';
            return;
            case Index.EOG
            folderName = 'EOG\';
            return;
            case Index.EMG
            folderName = 'EMG\';
            return;
               case Index.Mastoid
            folderName = 'Mastoid\';
            return;
        otherwise
            error('bad electrode type index')
    end
end