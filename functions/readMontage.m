function montageStruct = readMontage(header)
if (header.isAutoMontage)
    error('Automatic montage not implemented yet');
end
fid = fopen(header.montagePath); 
data = fread(fid, '*char')';
fclose(fid);

newlineChar = char(13);
lines = strsplit(data,newlineChar);
montageWithHeadlines = regexp(lines, ',', 'split');

headlines = montageWithHeadlines{1};
montage = montageWithHeadlines(2:end);
%if final line is empty
if (numel(montage{numel(montage)})<4)
   montage = montage(1:end-1);
end

if (~strcmp(headlines{Index.MONTAGE_CSV_CHANNEL},ConstStrings.MONTAGE_CSV_CHANNEL) ||...
        ~strcmp(headlines{Index.MONTAGE_CSV_IS_MACRO},ConstStrings.MONTAGE_CSV_IS_MACRO) ||...
        ~strcmp(headlines{Index.MONTAGE_CSV_LOCATION},ConstStrings.MONTAGE_CSV_LOCATION) ||...
        ~strcmp(headlines{Index.MONTAGE_CSV_DEPTH},ConstStrings.MONTAGE_CSV_DEPTH))
    error('montage csv file not in format');
end
        
for lineInd = 1:numel(montage)
    line = montage{lineInd};
    channel = str2num(line{Index.MONTAGE_CSV_CHANNEL});
    isMacro = logical(str2num(line{Index.MONTAGE_CSV_IS_MACRO}));
    location = line{Index.MONTAGE_CSV_LOCATION};
    depth = str2num(line{Index.MONTAGE_CSV_DEPTH});
    if(isMacro)
        montageStruct{Index.MACRO,channel}.location = location;
        montageStruct{Index.MACRO,channel}.depth = depth;
    else
        montageStruct{Index.MICRO,channel}.location = location;
        montageStruct{Index.MICRO,channel}.depth = depth;
    end
% % % 
% % %     line = montage{lineInd};
% % %     channelStr(lineInd) = str2num(line{Index.MONTAGE_CSV_CHANNEL});
% % %     isMacroStr(lineInd) = logical(str2num(line{Index.MONTAGE_CSV_IS_MACRO}));
% % %     locationStr{lineInd} = line{Index.MONTAGE_CSV_LOCATION};
% % %     depthStr(lineInd) = line{Index.MONTAGE_CSV_DEPTH};
end

end