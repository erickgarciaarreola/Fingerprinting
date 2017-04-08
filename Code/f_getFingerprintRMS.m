%
%
%
%
function y = f_getFingerprintRMS(audio,cons,window,n_overlap,n_fft,fs)

    fdomain_audio = spectrogram(audio,window,n_overlap,n_fft,fs,'yaxis');
    energy = rms(fdomain_audio,1);
    m = max(energy);
    relevant_energy_indexes= find(energy >= (m*cons));
    [maxAmp,maxAmp_index] = max(abs(fdomain_audio(:,relevant_energy_indexes)));
    
    data = zeros(length(relevant_energy_indexes),3);
    data(:,1) = relevant_energy_indexes'; %time
    data(:,2) = maxAmp_index'; %freq
    data(:,3) = maxAmp'; %amp
    y = data;
 
end