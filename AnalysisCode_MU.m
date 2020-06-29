close all
clear all
clc

data_directory = '/Volumes/DATA2/New_Model/Fuglevand/N_120_CV_20';
code_directory = '/Users/akira/Documents/Github/Motor-Unit-Model-Fuglevand/';
%load ('Input')
Fs = 1000;
t = 0:1/Fs:15;
amp_temp = [0.05 0.1:0.1:1];
CoVAll = zeros(10,length(amp_temp));
meanForceAll = zeros(10,length(amp_temp));
stdAll = zeros(10,length(amp_temp));
pxxAll = zeros(length(amp_temp),301);
Force_mat = zeros(10,15*Fs+1);
for k = 0 %0:10 %length(amp_temp)
    trialN = k; 
    % predefine model parameters
    
    CoV = zeros(1,10);
    std_Force = zeros(1,10);
    mean_Force = zeros(1,10);
    pxx = zeros(10,301);
    cd (data_directory)
    load(['Trial_' num2str(trialN)])
    cd (code_directory)
    for i = 1:10
        output = Data{i};
        Force = output.TotalForce(end-5*Fs+1:end);
        mean_Force(i) = mean(Force);
        std_Force(i) = std(Force);
        CoV(i) = std(Force)/mean(Force);
        [pxx(i,:),f] = pwelch(Force-mean(Force),gausswin(5*Fs),2.5*Fs,0:0.1:30,Fs,'power');
        pxx(i,:) = pxx(i,:)./sum(pxx(i,:));
        pxx(i,:) = smooth(pxx(i,:),10);
        Force_mat(i,:) = output.TotalForce;
    end
    
    meanForceAll(:,k+1) = mean_Force;
    stdAll(:,k+1) =  std_Force;
    CoVAll(:,k+1) =  CoV;
    pxxAll(k+1,:) = mean(pxx);
    
%     cd(data_directory)
%     save(['Force_mat_' num2str(k)],'Force_mat')
%     cd(code_directory)
    
end

meanForce_plot = mean(meanForceAll)./mean(meanForceAll(:,end));
figure(1)
plot([0 amp_temp*100],[0 meanForce_plot*100])
xlabel('Excitatory Drive (%)')
ylabel('Force (%)')

figure(2)
plot(meanForce_plot*100,mean(CoVAll*100))
xlabel('Excitatory Drive (%)')
ylabel('CoV (%)')

figure(3)
plot(meanForce_plot*100,mean(stdAll))
xlabel('Excitatory Drive (%)')
ylabel('SD (AU)')

figure(4)
plot(f,pxxAll)

% cd (dataFolder)
% save('CoV_300','CoVAll')
% save('pxx_300','pxxAll')
% cd (codeFolder)