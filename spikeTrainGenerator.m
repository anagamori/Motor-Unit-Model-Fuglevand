function spikeTrain = spikeTrainGenerator(t,Fs,freq)
    spikeTrain = zeros(1,length(t));
    ISI = round(1/freq*Fs);
    numSpikes = round(length(t)/ISI);
    index = [1:numSpikes]*ISI;
    index(index>length(t)) = [];
    spikeTrain(index) = 1;
    spikeTrain(1) = 1;
        
end