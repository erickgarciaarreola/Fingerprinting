clc;
clear all;
close all;

path = 'C:\Users\Erick\Desktop\Adverts\';
chirpspath='\chirps_rec\fixed_cel_source\';
audiopath_in = 'exp\Audio_fixed_200';
audiopath_out = 'exp\Audio_fixed_emulated_200';
chirps= dir(fullfile(path,chirpspath));
chirps(1) = []; %Removing patern file names "." and ".."
chirps(1) = [];
audiofiles = dir(fullfile(path,audiopath_in));
audiofiles(1) = []; %Removing patern file names "." and ".."
audiofiles(1) = [];
num_chirps=size(chirps,1);
num_files = size(audiofiles,1);

for i=1:1:num_chirps(1)
    fprintf('%d,',i)
    audiofile = fullfile(path,chirpspath, chirps(i).name);
    [audio,fs] = audioread(audiofile);
    %audio = resample(audio,16000,fs);
    chirps(i).audio = audio;
    chirps(i).fs =fs;
end
fprintf('\n,')

Overlap = 99;
Fs = fs;
BlockLen = 4096; 

for i=1:1:num_chirps
    [ chirps(i).TransferFunction, chirps(i).FrequencyResponse, chirps(i).FreqVector] = TF_Calculation( chirps(i).audio(:,1),chirps(1).audio(:,2) , BlockLen, Overlap, Fs);
    time = 1:size(chirps(i).TransferFunction,1);
    time = time/chirps(i).fs;
    figure
    plot(chirps(i).TransferFunction)
    figure
    plot(chirps(i).FreqVector,20*log(chirps(i).FrequencyResponse))
end

tf = chirps(1).TransferFunction;

fprintf('Creating audio files\n')
start = 1;
stop = num_files(1);


for i=start:1:stop
    %fprintf('%d,',i);
    fprintf('\n%d: %s',i,audiofiles(i).name);
    audiofile_in  = fullfile(path,audiopath_in, audiofiles(i).name);
    audiofile_out  = fullfile(path,audiopath_out, audiofiles(i).name);
    [audio_in,fs] = audioread(audiofile_in);
    audio_in = resample(audio_in,16000,fs);
   	fs = 16000;
    audio_out = filter(tf,1,audio_in);
    audio_out_r = resample(audio_out,44100,fs);
    fs=44100;
    audiowrite(audiofile_out,audio_out_r,fs,'BitRate',192);
        
end
fprintf('\n');

time = 1:size(audio_in,1);
time = time/fs;
figure
subplot(2,1,1)
plot(time,audio_in)
subplot(2,1,2)  
plot(time,audio_out)
