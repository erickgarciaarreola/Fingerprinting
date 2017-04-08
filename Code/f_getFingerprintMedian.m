%
%
%
%
function fp = f_getFingerprintMedian(audio,peaks,window,n_overlap,n_fft,fs)
    
    fdomain_audio = spectrogram(audio,window,n_overlap,n_fft,fs,'yaxis');
    mclt = zeros(size(fdomain_audio,1)-1,size(fdomain_audio,2));

    for i=1:1:size(fdomain_audio,2)
        mclt(:,i) = f_getMclt(fdomain_audio(:,i));
    end

    lmclt=sign(mclt).*log(abs(mclt)+1);  % LMCLT 
    slog = lmclt.*conj(lmclt);           % This is power now 

    %Process median filter 
    r = 3; %freq window
    s = 3; %time window
    M = medfilt2(slog,[r s]);
    slm=slog;
    slm(slm<M)=0;
 
    %Removing low energy 
    e = rms(slm,1);     % rms power
    k = medfilt1(e,10); % 10th median filter for energy 
    z = e;
    z(z<k)=0;           % removing whatever has not enough energy
    wslm = slm;
    wslm(:,z==0)=0;     %making zero the windows that have low enery 
    
    %removing low freq, most files look same here
    wslm(1:10,:)=0;  %150Hz and below are eliminated 
    
    fp = zeros(peaks*size(wslm,2),3); %creating the fp array
    npeaks = peaks;
    t = 1;
    for i=1:1:size(wslm,2)
        for j=1:1:npeaks
            [val,index]=max(wslm(:,i));
            wslm(index,i) = 0;
            fp(t,1)= i;      %time
            fp(t,2)= index;  %freq
            fp(t,3)= val;    %amplitude
            t = t+1;
        end
    end

    fpi=fp(fp(:,3)~=0,:); %removing the zero amplitude peaks 
    fp = fpi;

end
