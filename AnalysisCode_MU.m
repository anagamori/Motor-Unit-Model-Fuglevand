close all
clear all
clc

dataFolder = '/Volumes/DATA2/TwoMuscleSystemData/MotorUnit/ActivationLevel';
codeFolder = '/Users/akira/Documents/Github/Afferented-Muscle/Two-muscle System/Combined Model';
%load ('Input')
Fs = 1000;
t = 0:1/Fs:15;
amp_temp = 0.05:0.05:1;
CoVAll = zeros(10,length(amp_temp));
pxxAll = zeros(length(amp_temp),301);

for k = 1:length(amp_temp)
    trialN = k+20; 
    % predefine model parameters
    
    CoV = zeros(1,10);
    pxx = zeros(10,301);
    cd (dataFolder)
    load(['Trial_' num2str(trialN)])
    cd (codeFolder)
    for i = 1:10
        output = Data{i};
        Force = output.TotalForce(end-5*Fs+1:end);
        CoV(i) = std(Force)/mean(Force);
        [pxx(i,:),f] = pwelch(Force-mean(Force),gausswin(5*Fs),2.5*Fs,0:0.1:30,Fs,'power');
        pxx(i,:) = pxx(i,:)./sum(pxx(i,:));
        pxx(i,:) = smooth(pxx(i,:),10);
    end
    CoVAll(:,k) =  CoV;
    pxxAll(k,:) = mean(pxx);
    
end

figure(1)
plot(amp_temp,mean(CoVAll*100))

figure(2)
plot(f,pxxAll)

cd (dataFolder)
save('CoV_300','CoVAll')
save('pxx_300','pxxAll')
cd (codeFolder)