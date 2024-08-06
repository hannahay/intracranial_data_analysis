function groupsStr = getEqualizedGroupsStr_H (header,cutoffTimes)
%the new group str (for equalized and unequalized time groups)
% numOfGroups = size(cutoffTimes,1);
numOfGroups = size(cutoffTimes,2);

if numOfGroups<1
    
    error('bad cutoff values')
end


if (numOfGroups==1 && cutoffTimes{1,1}(1) == -Inf && ...
        cutoffTimes{1,1}(2) == Inf)
    groupsStr = ConstStrings.MEAN_INDUCED_RESPONSES_ALL_GROUPS_STR;
else
    groupsStr = [ConstStrings.MEAN_INDUCED_RESPONSES_GROUPS_STR];
    for cutoffTimeInd=1:numOfGroups
%         groupsStr = [groupsStr ConstStrings.MEAN_INDUCED_RESPONSES_EQUALIZED_GROUPS_SEPERATOR ...
%             sprintf('%.0f-%.0f',cutoffTimes(cutoffTimeInd,1),cutoffTimes(cutoffTimeInd,2))];
        groupsStr = [groupsStr ConstStrings.MEAN_INDUCED_RESPONSES_EQUALIZED_GROUPS_SEPERATOR ...
            sprintf('%s',header.groupsNames{cutoffTimeInd})];

    end
end

end