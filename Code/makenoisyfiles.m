clc;
clear all;
close all;
path = 'C:\Users\Erick\Desktop\Adverts';
noise_subfolder = 'Noise';
audiopath_input = 'Audio_fixed_emulated_200';
audiopath_output = {'10_200','5_200','0_200'};
audiopath_type = {'Audio_noisy\car','Audio_noisy\kinder','Audio_noisy\pub'};
audiofiles = dir(fullfile(path,audiopath_input));
audiofiles(1) = []; %Removing patern file names "." and ".."
audiofiles(1) = [];
num_files = size(audiofiles,1);

noise_files = dir(fullfile(path,noise_subfolder));
noise_files(1) = []; %Removing patern file names "." and ".."
noise_files(1) = [];
num_noises = size(noise_files,1);
fs = 44100;

fprintf('\nLoading noisefiles\n')
for i=1:1:num_noises
    fprintf('%d,',i)
    noisefile = fullfile(path,noise_subfolder, noise_files(i).name);
    [noise,FS] = audioread(noisefile);
    stereo = size(noise,2);
    if stereo == 2
        noise = (noise(:,1)+noise(:,2))/2;
    end
    noise = resample(noise,fs,FS);
    noise = [noise ; noise; noise; noise; noise];
    noise_files(i).noise = noise;
    
end

fprintf('\nMaking noisy files!\n')
start = 1;
stop =  num_files(1);
%stop =  10;

noise_levels = [10 5 0];

for type=1:1:1
    for i=1:1:stop
        %fprintf('%d,',i)
        fprintf('\n%d: %s',i,audiofiles(i).name)
        for j=3:1:size(noise_levels,2)
            audiofile_i  = fullfile(path,audiopath_input, audiofiles(i).name);
            audiofile_o  = fullfile(path,char(audiopath_type(type)),char(audiopath_output(j)), audiofiles(i).name);
            [sample,FS] = audioread(audiofile_i);
            sample = resample(sample,fs,FS);

            target = noise_levels(j);
            noise = noise_files(type).noise(1:size(sample,1),1);
            error = target - snr(sample,noise);  %fixed to the car noise for now
            error_p = error;
            kp = .1;
            iterations =0;
            e_t = .05;
            inc = .1;
            sc = 0;
            while (abs(error) > e_t )
                iterations = iterations +1;
                kp= -1*sign(error)*inc + kp;
                output=snr(sample,kp*noise);
                error_p = error;  %saving previous error
                error = (target-output);

                if(sign(error)~= sign(error_p))
                    sc = sc +1;
                end
                if(sc > 4)
                    sc = 0;
                    inc = inc*.1;
                end
            end
            sample_dirty = sample + kp*noise;      
            audiowrite(audiofile_o,sample_dirty,fs,'BitRate',192);
        end

    end
end



