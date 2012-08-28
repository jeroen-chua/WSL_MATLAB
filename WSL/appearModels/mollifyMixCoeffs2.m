function [mix] = mollifyMixCoeffs2(mix,minMix)
    mix = max(mix,minMix);
    mix = bsxfun(@rdivide, mix, sum(mix,3));
end

