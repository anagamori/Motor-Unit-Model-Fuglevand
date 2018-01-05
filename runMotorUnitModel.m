close all
clear all
clc

Fs = 1000;
t = 0:1/Fs:15;
N_temp = 50:50:1000;
amp_temp = 0.05:0.05:1;
RP_temp = 10:10:150;

for k = 1
    trialN = k; 
    % predefine model parameters
    amp = 0.2;
    modelParameter.amp = amp;
    U = [zeros(1,1*Fs) (amp/2)*(0:1/Fs:2) amp*ones(1,length(t)-3*Fs-1)];
    
    modelParameter.N = 120;    
    modelParameter.RR = 30;    
    modelParameter.MFR = 8;   
    modelParameter.g_e = 1;    
    modelParameter.PFR1 = 35;   
    modelParameter.PFRD = 10;
    modelParameter.cv = 0.2;    
    modelParameter.RP = 30;    
    modelParameter.T_L = 90;    
    modelParameter.RT = 3;   
    modelParameter.P_amp = 0.03;
    
    Data = cell(1,10);
    for i = 1
        % Run motor unit model
        output = MotorUnitModel(t,U,modelParameter,Fs);       
        Data{i} = output;
    end
    
    output_temp = Data{1};
    figure(1)
    plot(t,output_temp.TotalForce)
    hold on
    k
end

CS = sum(output.SpikeTrain);
Force = output_temp.TotalForce(5*Fs+1:end);
std(Force)/mean(Force)
[pxx,f] = pwelch(Force-mean(Force),[],[],0:0.1:30,Fs,'power');
[pxx2,f] = pwelch(CS-mean(CS),[],[],0:0.1:30,Fs,'power');
figure(2)
plot(f,pxx)

figure(3)
plot(f,pxx2)


