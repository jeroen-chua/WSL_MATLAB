function ls = logsum(xx,dim)
% ls = logsum(x,dim)
%
% returns the log of sum of logs, summing over dimension dim
% computes ls = log(sum(exp(x),dim))
% but in a way that tries to avoid underflow/overflow
%
% basic idea: shift before exp and reshift back
% log(sum(exp(x))) = alpha + log(sum(exp(x-alpha)));
%

if(size(xx,dim)<=1) ls=xx; return; end

alpha = max(xx,[],dim);
ls = alpha+log(sum(exp(bsxfun(@minus,xx,alpha)),dim));


