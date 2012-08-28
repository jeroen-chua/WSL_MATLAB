function [phase] = wrapPhase(phase)
    phase = mod(phase+1,2)-1;
end

