function [y] = expander(arr, m)
% function [y] = expander(a, m)
%   Expands all elements of arr m elements down (down-expand)
    y=reshape(repmat(arr,1,m)', length(arr(1,:)), m*length(arr(:,1)))'; 
end

