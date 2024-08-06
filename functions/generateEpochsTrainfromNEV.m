function [train40Hz,sampleRes] = generateEpochsTrainfromNEV (NEV)

unparsedData = NEV.Data.SerialDigitalIO.UnparsedData;
% insertionReason = NEV.Data.SerialDigitalIO.InsertionReason;
timeStamp = NEV.Data.SerialDigitalIO.TimeStamp;
sampleRes = NEV.MetaTags.SampleRes;

IND_START = 100;  %need to check exactly 
IND_END = 200;
isStartCodonHappened = false;
recentStartCodon = 0;
startCodonIndex = 0;
recentEndCodonTime = -Inf;

structIndex = 1;
howMuchTimeBad = 0;

%while unparsedData begin with closing codon (200-204) delete it.
while (unparsedData(1)>200) || (unparsedData(1)<100)
    unparsedData(1) = [];
%     insertionReason(:,[1,2]) = [];
    timeStamp(1) = [];%   
% unparsedData([1],:) = [];
%     insertionReason(:,[1]) = [];
%     timeStamp(:,[1]) = [];
end
a=find(unparsedData==0);
unparsedData(a)=[]; timeStamp(a)=[]; %insertionReason(find(unparsedData==0))=[];

b=find(unparsedData>255);
unparsedData(b)=[]; timeStamp(b)=[];

count=1; count_m=1;
for i=1:numel(unparsedData)
    codon = unparsedData(i);
    if (floor(codon/100)==1)
        if (isStartCodonHappened)
            'Error: 2 straight start codons'
%             break;
        end
        recentStartCodon = codon;
        isStartCodonHappened = true;
        startCodonIndex=i;
    end
    
    if ((floor(codon/100)==2) && (mod(codon,100)<=60 && mod(codon,100)>=0))
       if (~isStartCodonHappened)
           'Error: end codon without preceding start codon'
           index_errorEndCodon(count)=i;
           count=count+1;
%             break; %amit
       end
       if (codon-100~=recentStartCodon)
           'Error: Mismatched start-end codons'
            index_errorMismatch(count_m)=i;
           count_m=count_m+1;
%            break; %Amit
       end

             train40Hz(structIndex).vol = mod(codon,100);
           train40Hz(structIndex).startCodonTime = timeStamp(startCodonIndex);
           train40Hz(structIndex).endCodonTime = timeStamp(i);
           structIndex = structIndex + 1;
 
       recentEndCodonTime = timeStamp(i);
       isStartCodonHappened = false; %temp
    end
end

end