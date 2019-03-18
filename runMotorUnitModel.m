close all
clear all
clc

Fs = 1000;
t = 0:1/Fs:15;
N_temp = 50:50:1000;
amp_temp = 0.1:0.1:1;
RP_temp = 10:10:150;


data_directory = '/Volumes/DATA2/Motor Unit Model Data/Fuglevand/';
code_directory = '/Users/akira/Documents/Github/Motor-Unit-Model-Fuglevand/';

maxForce = 1.9758e+04;
for k = 1 %:length(amp_temp)
    trialN = k; %+30; 
    % predefine model parameters
    amp = 0.1; %[0.15 0.41]; %amp_temp(k); 0.15 for 0.05
    modelParameter.amp = amp(k);
    t_sin = [1:7*Fs]/Fs;
    U = [zeros(1,1*Fs) (amp(k)/2)*(0:1/Fs:2) amp(k)*ones(1,length(t)-3*Fs-1)];
    
    modelParameter.N = 300;    
    modelParameter.RR = 17;    
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
    for i = 1
        % Run motor unit model        
        output = MotorUnitModel(t,U,modelParameter,Fs);       
        Data{i} = output;
    end
    toc
    
%     cd (data_directory)
%     save(['Trial_' num2str(trialN)],'Data','-v7.3')
%     cd (code_directory)
    
    output_temp = Data{1};
    
    Force = output_temp.TotalForce(4*Fs+1:end)/maxForce;
    meanForce = mean(Force) 
    SD = std(Force)
    CoV = std(Force)/mean(Force)

    figure(1)
    plot(t,output_temp.TotalForce)
    xlabel('Time (s)','FontSize',14)
    ylabel('Force (AU)','FontSize',14)
    hold on
    
    k
    
    [pxx,f] = pwelch(Force-mean(Force),[],[],0:0.1:30,Fs,'power');
    figure(2)
    plot(f,pxx./sum(pxx)*100)
    xlabel('Frequency (Hz)','FontSize',14)
    ylabel('Power (%Total Power)','FontSize',14)
    hold on

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
% xlim([8 9])
%%
figure_unit = 2;
figure(6)
plot(t,output.Force(figure_unit,:),'k','LineWidth',2)
xlim([8 9])
%ylim([1 10])
CoV_unit = std(output.Force(figure_unit,8*Fs:9*Fs))/mean(output.Force(figure_unit,8*Fs:9*Fs))

%%
figure(6)
plot(t,output.TotalForce,'k','LineWidth',2)
xlim([8 9])
ylim([450 550])
CoV_unit = std(output.TotalForce(8*Fs:9*Fs))/mean(output.TotalForce(8*Fs:9*Fs))

%ylim([6 9.5])

% CS = sum(output.SpikeTrain);
% 
% [pxx,f] = pwelch(Force-mean(Force),[],[],0:0.1:50,Fs,'power');
% [pxx2,f] = pwelch(CS-mean(CS),[],[],0:0.1:50,Fs,'power');
% figure(2)
% plot(f,pxx)
% 
% figure(3)
% plot(f,pxx2)
