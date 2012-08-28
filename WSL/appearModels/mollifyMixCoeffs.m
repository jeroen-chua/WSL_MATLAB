function [mix] = mollifyMixCoeffs(mix,minMix)
    mix = max(mix,minMix);
    mix = mix/sum(mix);
end

