function  y = clip( x, lo, hi )
    y = (x .* [x<=hi])  +  (hi .* [x>hi]);
    y = (y .* [x>=lo])  +  (lo .* [x<lo]);
end