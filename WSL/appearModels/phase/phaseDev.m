function [dev] = phaseDev(phaseA, phaseB)
    dev = phaseA-phaseB;
    if (abs(dev) > 10)
        display('Warning: big phase warp!');
        dev = dev - round(dev/(2))*2;
    end
    while (dev > 1)
        dev = dev - 2;
    end
    while (dev <= -1)
        dev = dev + 2;
    end
end

