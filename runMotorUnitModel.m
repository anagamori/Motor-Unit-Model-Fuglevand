close all
clear all
clc

Fs = 1000;
t = 0:1/Fs:5;
N_temp = 50:50:1000;
amp_temp = 0.1:0.1:1;
RP_temp = 10:10:150;

for k = 1 %:length(amp_temp)
    trialN = k; 
    % predefine model parameters
    amp = 1; %amp_temp(k);
    modelParameter.amp = amp;
    U = [zeros(1,1*Fs) (amp/2)*(0:1/Fs:2) amp*ones(1,length(t)-3*Fs-1)];
    
    modelParameter.N = 120;    
    modelParameter.RR = 30;    
    modelParameter.MFR = 8;   
    modelParameter.g_e = 1;    
    modelParameter.PFR1 = 35;   
    modelParameter.PFRD = 10;
    modelParameter.cv = 0;    
    modelParameter.RP = 100;    
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
    Force = output_temp.TotalForce(4*Fs+1:end);
    meanForce(k) = mean(Force)
    SD(k) = std(Force)
    CoV(k) = std(Force)/mean(Force)
    k
end

% figure(2)
% plot([0 amp_temp*100],[0 meanForce./meanForce(end)*100])
% xlabel('Excitatory Drive (%)')
% ylabel('Force (%)')
% 
% figure(3)
% plot(amp_temp*100,SD)
% xlabel('Excitatory Drive (%)')
% ylabel('SD (AU)')
% 
% figure(4)
% plot(amp_temp*100,CoV*100)
% xlabel('Excitatory Drive (%)')
% ylabel('CoV (AU)')

% figure(5)
% plot(t,output.SpikeTrain(1,:))
% xlim([4 4.5])
% 
% figure(6)
% plot(t,output.Force(1,:))
% xlim([4 4.5])
% ylim([7 9.5])

% CS = sum(output.SpikeTrain);
% 
% [pxx,f] = pwelch(Force-mean(Force),[],[],0:0.1:50,Fs,'power');
% [pxx2,f] = pwelch(CS-mean(CS),[],[],0:0.1:50,Fs,'power');
% figure(2)
% plot(f,pxx)
% 
% figure(3)
% plot(f,pxx2)


