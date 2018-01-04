close all
clear all
clc

dataFolder = '/Volumes/DATA2/TwoMuscleSystemData/MotorUnit/TwitchForce';
%dataFolder = '/Volumes/DATA2/TwoMuscleSystemData/MotorUnit/MotorUnitNumber';
codeFolder = '/Users/akira/Documents/Github/Afferented-Muscle/Two-muscle System/Combined Model';
%load ('Input')
Fs = 1000;
t = 0:1/Fs:15;
N_temp = 50:50:1000;
amp_temp = 0.05:0.05:1;
RP_temp = 10:10:150;

for k = 1:length(RP_temp)
    trialN = k+20; 
    % predefine model parameters
    amp = 0.3;
    modelParameter.amp = amp;
    U = [zeros(1,1*Fs) (amp/2)*(0:1/Fs:2) amp*ones(1,length(t)-3*Fs-1)];
    
    modelParameter.N = 120;    
    modelParameter.RR = 30;    
    modelParameter.MFR = 8;   
    modelParameter.g_e = 1;    
    modelParameter.PFR1 = 35;   
    modelParameter.PFRD = 10;
    modelParameter.cv = 0.1;    
    modelParameter.RP = RP_temp(k);    
    modelParameter.T_L = 90;    
    modelParameter.RT = 3;   
    modelParameter.P_amp = 0.03;
    
    Data = cell(1,10);
    parfor i = 1:10   
        % Run motor unit model
        output = MotorUnitModel(t,U,modelParameter,Fs);       
        Data{i} = output;
    end
    cd (dataFolder)
    save(['Trial_' num2str(trialN)],'Data','-v7.3')
    cd (codeFolder)
    
    output_temp = Data{1};
    figure(1)
    plot(t,output_temp.TotalForce)
    hold on
    k
end


