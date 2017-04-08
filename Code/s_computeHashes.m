clc;
clear all;
close all;

%Path variables, making easyer to experiment
path = 'C:\Users\Erick\Desktop\Adverts\';
audio_subfolder = 'Audio_fixed_7k';
fingerprints_subfolder = 'Fingerprints';
audiofiles = dir(fullfile(path,audio_subfolder));
audiofiles(1) = []; %Removing patern file names "." and ".."
audiofiles(1) = [];  
num_files = size(audiofiles,1);

%Hash settings
peaks = [10 13 15]; 
fan_out = 1;

%Parameters for spectrogram
window=hann(1024);             % Windows size 
n_overlap=length(window)*.5;   % 50% overlap
n_fft=1024;                    % Number of fft points, resolution sample_rate/n_fft
fs = 16000;
    
header = 'fingerprints_7k_nolowfreq';

for peak=peaks
    tail = strcat('_w',num2str(length(window)),'w_o',num2str(n_overlap/length(window)*100),'o_n',num2str(n_fft),'n_p',num2str(peak),'p');
    fingerprint_name = strcat(header,tail);

    %Data structure for fingerprints
    fingerprints = struct;

    
    for i=1:1:num_files(1)
        %fprintf('Computing firgerprint for: %d: %s\n',i,audiofiles(i).name)
        audiofile = fullfile(path,audio_subfolder, audiofiles(i).name);
        try
            [audio,FS] = audioread(audiofile);

        catch ME
            copyfile(fullfile('E:\Adverts',audio_subfolder, audiofiles(i).name),audiofile,'f')
            [audio,FS] = audioread(audiofile);
            fprintf('Bad read compiying file from back up: %d: %s\n',i,audiofiles(i).name)
        end
        audio = resample(audio,fs,FS);
        fingerprints(i).name=audiofiles(i).name;
        %fingerprints(i).fingerprint = f_getFingerprintMedian(audio,peak,window,n_overlap,n_fft,fs);  %Here can go any fingerprint extraction method  
        fingerprint = f_getFingerprintMedian(audio,peak,window,n_overlap,n_fft,fs);
        
        fprintf('Computing firgerprint for: %d\n',i);
        %fprintf('Computing hash for: %d: %s\n',i,audiofiles(i).name)
        %fingerprints(i).hash = f_getHash_optimized(fingerprints(i).fingerprint,fan_out);
        fingerprints(i).hash_s = f_getHash_optimized(fingerprint,fan_out);
        fingerprints(i).peaks = peak;
    end
    save(fullfile(path,fingerprints_subfolder,fingerprint_name),'fingerprints','-v7.3');

end
