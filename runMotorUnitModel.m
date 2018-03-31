close all
clear all
clc

Fs = 1000;
t = 0:1/Fs:10;
N_temp = 50:50:1000;
amp_temp = 0.1:0.1:1;
RP_temp = 10:10:150;

data_directory = '/Volumes/DATA2/Motor Unit Model Data/Fuglevand/';
code_directory = '/Users/akira/Documents/Github/Motor-Unit-Model-Fuglevand/';

for k = 1:length(amp_temp)
    trialN = k+30; 
    % predefine model parameters
    amp = amp_temp(k);
    modelParameter.amp = amp;
    U = [zeros(1,1*Fs) (amp/2)*(0:1/Fs:2) amp*ones(1,length(t)-3*Fs-1)];
    
    modelParameter.N = 300;    
    modelParameter.RR = 30;    
    modelParameter.MFR = 8;   
    modelParameter.g_e = 1;    
    modelParameter.PFR1 = 35;   
    modelParameter.PFRD = 10;
    modelParameter.cv = 0.1;    
    modelParameter.RP = 100;    
    modelParameter.T_L = 90;    
    modelParameter.RT = 3;   
    
    
    Data = cell(1,10);
    tic
    parfor i = 1:10
        % Run motor unit model        
        output = MotorUnitModel(t,U,modelParameter,Fs);       
        Data{i} = output;
    end
    toc
    
    cd (data_directory)
    save(['Trial_' num2str(trialN)],'Data','-v7.3')
    cd (code_directory)
    
    output_temp = Data{1};
    
    Force = output_temp.TotalForce(4*Fs+1:end);
    meanForce = mean(Force)
    SD = std(Force)
    CoV = std(Force)/mean(Force)

    figure(1)
    plot(t,output_temp.TotalForce)
    xlabel('Time (s)','FontSize',14)
    ylabel('Force (AU)','FontSize',14)
    hold on
    k
end
