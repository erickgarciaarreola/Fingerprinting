function X = f_getMclt(f_data)
% FMCLT - Compute MCLT of a vector via double-length FFT
%
% H. Malvar, September 2001 -- (c) 1998-2001 Microsoft Corp.
%
% Syntax: X = fmclt(x)
%
% Input: x : real-valued input vector of length 2*M
%
% Output: X : complex-valued MCLT coefficients, M subbands
% in Matlab, by default j = sqrt(-1)
% determine # of subbands, M
L = length(f_data)-1;
M = L;
% normalized FFT of input
U = sqrt(1/(2*M)) * (f_data);
% compute modulation function
k = [0:M]';
c = f_W(8,2*k+1) .* f_W(4*M,k);
% modulate U into V
V = c .* U(1:M+1);
% compute MCLT coefficients
X = 1i * V(1:M) + V(2:M+1);
return; 
