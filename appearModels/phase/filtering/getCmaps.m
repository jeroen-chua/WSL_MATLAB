function C = getCmaps(basisOutputs)
%
% Given the basis maps from the G2/H2 filters, compute filter power as
% a function of orientation in terms of the coefficients of a harmonic
% series with frequencies  0, 2theta, 4theta, and 6theta.
%    E = C1 + C2 cos[2theta] + C3 sin[2theta] +
%        C4 cos[4theta] + C5 sin[4theta] + C6 cos[6theta] + C7 sin[6theta]

G2a = basisOutputs{1,1};
G2b = basisOutputs{1,2};
G2c = basisOutputs{1,3};
H2a = basisOutputs{1,4};
H2b = basisOutputs{1,5};
H2c = basisOutputs{1,6};
H2d = basisOutputs{1,7};

C{1} = 0.5*G2b.^2 + 0.25*G2a.*G2c + 0.375*(G2a.^2+G2c.^2) + ...
       0.3125*(H2a.^2+H2d.^2) + 0.5625*(H2b.^2+H2c.^2) + ...
       0.375*(H2a.*H2c + H2b.*H2d);
C{2} = 0.5*(G2a.^2 - G2c.^2) + 0.46875*(H2a.^2 - H2d.^2) + ...
       0.28125*(H2b.^2 - H2c.^2) + 0.1875*(H2a.*H2c - H2b.*H2d);
C{3} = G2a.*G2b + G2b.*G2c + 0.9375*(H2c.*H2d + H2a.*H2b) + ...
       1.6875*H2b.*H2c + 0.1875*H2a.*H2d;
C{4} = 0.125*(G2a.^2 + G2c.^2) - 0.5*G2b.^2 - 0.25*G2a.*G2c + ...
       0.1875*(H2a.^2 + H2d.^2) - 0.5625*(H2b.^2 + H2c.^2) - ...
       0.375*(H2a.*H2c + H2b.*H2d);
C{5} = 0.5*(G2a.*G2b - G2b.*G2c) + 0.75*(H2a.*H2b - H2c.*H2d);
C{6} = 0.03125*(H2a.^2 - H2d.^2) + 0.28125*(H2c.^2 - H2b.^2) + ...
       0.1875*(H2b.*H2d - H2a.*H2c);
C{7} = -0.5625*H2b.*H2c - 0.0625*H2a.*H2d + 0.1875*(H2c.*H2d + H2a.*H2b);


