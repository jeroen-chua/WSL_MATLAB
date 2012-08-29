function arrDiff = wrapPhaseDiff(arrDiff)
    % assume phase range is [-1,1], so wrap phase difference to [-1,1]
    arrDiff = mod(arrDiff+1,2)-1;
end