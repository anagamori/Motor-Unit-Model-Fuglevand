close all
% clear all
clc
Fs = 1000;
t = 0:1/Fs:10;

spike1 = zeros(1,length(t));
spike1(1*Fs) = 1;
spike2 = zeros(1,length(t));
spike2(1*Fs+0.1*Fs) = 1;
spike3 = spike1 + spike2;
spike3 = output.SpikeTrain(1,:);

% spike3 = spikeTrainGenerator(t,Fs,4);
T = 0.03;
t_twitch = 0:1/Fs:1;
twitch=  t_twitch./T.*exp(1-t_twitch./T);

force1 = conv(spike1,twitch);
force1 = force1(1:length(t));

force2 = conv(spike2,twitch);
force2 = force2(1:length(t));

force3 = conv(spike3,twitch);
force3 = force3(1:length(t));

force4 = zeros(1,length(t));
for i = 1:length(t)
    if spike3(i) == 1
        [y,f1,f2,x0] = twitch_function(twitch(1,:),force4(i),T,Fs);
        force4(i:length(y)+i-1) = y;        
    end
end


figure(1)
plot(force3)
hold on
plot(force4)


function [y,f1,f2,x0] = twitch_function(twitch,x0,T,Fs)
peakTwitch = max(twitch);
f1 = twitch + x0;
f2 = (peakTwitch+x0)/peakTwitch*twitch;
y = [f1(1:round(T*Fs)) f2(round(T*Fs):end)];
end