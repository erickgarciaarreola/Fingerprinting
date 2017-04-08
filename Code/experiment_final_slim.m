clc;
clearvars ;
clear all;
close all;
diary off;

e_s=tic;
date_start = datestr(now);
date_start_m = date_start;
path = 'C:\Users\Erick\Desktop\Adverts\';
diary_subfolder = 'Results_110';
date_start_m(:,date_start == ':')='-';
date_start_m(:,date_start == ' ')='-';
diary(fullfile(path,diary_subfolder,sprintf('%s.txt',date_start_m)));

diary on

fprintf('\nWabba lubba dub dub!!\n');
fprintf('\nDiary file: %s\n',sprintf('%s.txt',date_start_m));
fprintf('Date: %s\n',date_start);
audio_subfolder = 'Audio_1000';
noise_type = {'Audio_noisy\car','Audio_noisy\kinder','Audio_noisy\pub'};
sample_subfolder_values = {'Audio_fixed_emulated_200','10_200','5_200','0_200'};
sample_subfolder_keys = {'Clean','10','5','0'};
sample_subfolder = containers.Map(sample_subfolder_keys,sample_subfolder_values);
fingerprints_subfolder = 'Fingerprints';

sample_files = dir(fullfile(path,sample_subfolder('Clean')));
sample_files(1) = []; %Removing patern file names "." and ".."
sample_files(1) = [];

fingerprint_files = dir(fullfile(path,fingerprints_subfolder));
fingerprint_files(1) = []; %Removing patern file names "." and ".."
fingerprint_files(1) = [];

%Parameters for spectrogram
window=hann(1024);             % Windows size 
n_overlap=length(window)*.5;   % 50% overlap
n_fft=1024;                    % Number of fft points, resolution sample_rate/n_fft
fs = 16000;

num_samples = size(sample_files,1);  
num_fingerprints = size(fingerprint_files,1);

start_s = 1;
stop_s = num_samples;

%load fingerprints, both original and samples
fps = struct([]);
peaks = zeros(1,1);
fprintf('\nLoading reference fingerprints\n')
for i=1:1:num_fingerprints
    fprintf('%d,',i)
    %audiofile = fullfile(path,audio_subfolder, fingerprint_files.name);
    load(fullfile(path,fingerprints_subfolder,fingerprint_files(i).name),'fingerprints')
    fps{i} = fingerprints;
    peaks(1,i) = fps{i}(1).peaks;
end

%*********For debug************
debug = 0;
how_many = 1;
if debug == 1
    num_references = how_many; 
    num_samples = how_many;
    num_fingerprints = size(fingerprint_files,1);
    peaks= [10];
end
%******************************

%debug
if debug == 1
    reference_files = reference_files(1:num_references);
    sample_files = sample_files(1:num_references); 
end


%Experiment start 

%noise_levels = {'Clean' '10' '5' '0'};
%noise_levels = {'0','5','10','Clean'};
noise_levels = {'Clean'};
results = zeros(size(noise_levels,2),size(peaks,2));
time = zeros(size(noise_levels,2),size(peaks,2));

x = 0;
y = 0;

%Forloop for peaks
for peak=1:1:1%size(peaks,2)
    y = y+1;
    x = 0;
    reference_files = fps{peak}; 
    %Forloop for noises
    for noise_level=1:1:size(noise_levels,2)
        x = x+1;
        fprintf('\n\nFinding matches for %d peaks at a SRN: %s\n',peaks(peak) ,char(noise_levels(noise_level)))
        m = struct;
        fails = zeros(1,2);
        for k=start_s:1:stop_s
            %Loading sample file
            fprintf('\nLoading sample file: %d',k)
            if(strcmp(noise_levels(noise_level),'Clean'))
                audiofile = fullfile(path,char(sample_subfolder(char(noise_levels(noise_level)))), sample_files(k).name);
            else %Randombly selecting a noisy file from the 3 avilable
                %audiofile = fullfile(path,char(noise_type(randi([1 size(noise_type,2)]))),char(sample_subfolder(char(noise_levels(noise_level)))), sample_files(k).name);
                audiofile = fullfile(path,char(noise_type(3)),char(sample_subfolder(char(noise_levels(noise_level)))), sample_files(k).name);
            end
            %in case read fails 
            
            try
                [sample_dirty,FS] = audioread(audiofile);

            catch ME
                if(strcmp(noise_levels(noise_level),'Clean'))
                    copyfile(fullfile('E:\Adverts',char(sample_subfolder(char(noise_levels(noise_level)))), sample_files(k).name),audiofile,'f')
                else
                    %delete(audiofile)
                    copyfile(fullfile('E:\Adverts',char(noise_type(3)),char(sample_subfolder(char(noise_levels(noise_level)))), sample_files(k).name),audiofile,'f')
                end
                fprintf('Bad read compiying file from back up')
                [sample_dirty,FS] = audioread(audiofile);
                
            end
            
            %[sample_dirty,FS] = audioread(audiofile);
            sample_dirty = resample(sample_dirty,fs,FS);
            %sample_dirty = f_getAudioFragment(sample_dirty,fs,0,6,0);
            sample_dirty = f_getAudioFragment(sample_dirty,fs,1,9.99,0);  
            
            %Compute sample fingerprint
            fingerprint = f_getFingerprintMedian(sample_dirty,peaks(peak),window,n_overlap,n_fft,fs);
            hash_s = f_getHash_optimized(fingerprint,1);
            
            fprintf('\nFinding match')
            t_s=tic;  %Start timer
            %Find most suitable matching index within reference hashes
            match_data = f_findMatch_uint(reference_files,hash_s);
            t = toc(t_s);  %Stop timer
            %m(k).d = match_data;
            %m(k).d.t = t;
            fprintf('\nSample:\t%s,\t%d',sample_files(k).name,k)
            fprintf('\nMatch:\t%s,\t%d',reference_files(match_data.match_index_t).name,match_data.match_index_t)
            fprintf('\nTime to find across reference hashes\t%0.3fs\n',t)
            time(x,y) = time(x,y)+t; %Add the time it takes to find each of the 110 samples across the 110 references
            if(strcmp(reference_files(match_data.match_index_t).name,sample_files(k).name))
               results(x,y)= results(x,y) + 1; 
            else
               fails(k,1)= 1;
               fails(k,2)= match_data.match_index_t(:,1); 
            end
        end
    fprintf('\nResults for %d peaks at a SRN: %s\n',peaks(peak) ,char(noise_levels(noise_level)))
    disp(results);
    disp(time);
    end 
end
totaltime = toc(e_s);
date_end = datestr(now);
fprintf('Experiment filename:\t %s.txt\n',date_start_m);
fprintf('Experiment started:\t %s\n',date_start);
fprintf('Experiment ended:\t %s\n',date_end);
fprintf('\nTotal time to executing experiment\t%0.3fs\n',totaltime)
diary off


return
%debug 
fail = [find(fails(:,1)==1) fails(find(fails(:,1)==1),2)];
disp(fail);

for f=1:1:size(fail,1)
    fprintf('\nSample:\t\t%d: %s\nMistake:\t%d: %s',fail(f,1), reference_files(fail(f,1)).name,fail(f,2),reference_files(fail(f,2)).name);
    fprintf('\n');
end

me = zeros(1,size(m,2));
ma = zeros(1,size(m,2));
for c=1:1:size(m,2)
    me(1,c) = mean(m(c).d.n_offsets_t(:,1));
    ma(1,c) = m(c).d.match_t;
end


for g=1:1:size(fail,1)
    figure
    subplot(3,1,1)
    plot(m(fail(g,1)).d.n_offsets_t(:,1))
    subplot(3,1,2)  
    plot(m(fail(g,1)).d.histo(fail(1,1)).h_t)
    subplot(3,1,3)  
    plot(m(fail(g,1)).d.histo(fail(1,2)).h_t)
end

figure
subplot(3,1,1)
plot(m(14).d.n_offsets_t(:,1))
subplot(3,1,2)  
plot(m(14).d.histo(14).h_t)
subplot(3,1,3)  
plot(m(14).d.histo(105).h_t)
