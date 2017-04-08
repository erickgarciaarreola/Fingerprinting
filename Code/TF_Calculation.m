function [ TransferFunction, FrequencyResponse, FreqVector] = TF_Calculation( In, Out, BlockLen, Overlap, Fs)
%[ Filt ] = TF_Calculation( In, Out )
%   Detailed explanation goes here

Advance = round(BlockLen*(100-Overlap));

Ini = 1;
n   = 1;

TransferFunction  = zeros(BlockLen, 1);
FrequencyResponse = zeros(BlockLen, 1);

Win = tukeywin(BlockLen,0.5);

while Ini < (length(In) - BlockLen) 
    
    In_Block = Win.*In(Ini:Ini + BlockLen - 1);
    Out_Block = Win.*Out(Ini:Ini + BlockLen - 1);
    
    Ini = Ini + Advance;
    
    n = n+1;
    
    Sxx = fft(In_Block).*conj(fft(In_Block));
    Sxy = fft(Out_Block).*conj(fft(In_Block));
    
    FrequencyTemp = Sxy./Sxx;
    
    Temp = ifft(FrequencyTemp);
    
    TransferFunction = TransferFunction + Temp;
    
    FrequencyResponse = FrequencyResponse + abs(FrequencyTemp);
    
end

FrequencyResponse = FrequencyResponse(1:BlockLen/2)/n;

TransferFunction = TransferFunction/n;

FreqVector = linspace(1,Fs/2,length(FrequencyResponse));


