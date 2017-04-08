%audio: Full audio samples from which we are geting the fragment
%fs: sample rate
%start: position in miliseconds to start getting teh audio, positive and no
%       longer than the song
%duration: how many secons you need the fragment to last

%returns: fragment samples

function y = f_getAudioFragment(audio,fs,random,duration,start)
    if(random)
        start = randi([1 size(audio,1)-round(fs*duration)]);
        y=audio(start:start+round(fs*duration),1); 
    else
        y=audio(round(fs*start)+1:round(fs*start)+round(fs*duration),1); 
    end

end
    