function vec = removeBadIndices (vec,badIndices)
    vec(badIndices,:) = [];
end