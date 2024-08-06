function isValuesBetweenBorders = getIsValuesBetweenBorders(values, valuesBorders)
    % This function checks whether each value in the 'values' array falls within
    % any of the specified ranges defined in 'valuesBorders'.
    %
    % Parameters:
    %   values: A column vector of values to check.
    %   valuesBorders: An n-by-2 matrix where each row defines a range [bottom, top]
    %                  for a group of values. Column 1 is the bottom value, and column 2
    %                  is the top value of each range.
    %
    % Returns:
    %   isValuesBetweenBorders: A logical column vector where each element is true if the
    %                            corresponding value in 'values' is within any of the defined
    %                            ranges in 'valuesBorders', and false otherwise.

    % Ensure 'values' is a column vector
    if (isrow(values))
        values = values'; % Transpose if 'values' is a row vector
    end

    % Initialize the output logical vector to false
    isValuesBetweenBorders = false(length(values), 1);

    % Get the number of value border groups (ranges) from 'valuesBorders'
    nValuesBordersGroups = size(valuesBorders, 1);

    % Iterate over each group of value borders
    for i = 1:nValuesBordersGroups
        % Update the logical vector to true for values within the current range
        isValuesBetweenBorders = isValuesBetweenBorders | ...
            (values >= valuesBorders(i, 1) & values <= valuesBorders(i, 2));
    end
end
