close all
clear all
clc

%--------------------------------------------------------------------------
% Motor unit parameters
%--------------------------------------------------------------------------
Fs = 1000;
time = 0:1/Fs:20;

modelParameter.N = 120;
modelParameter.RR = 30;
modelParameter.MFR = 8;
modelParameter.g_e = 1;
modelParameter.PFR1 = 35;
modelParameter.PFRD = 10;
modelParameter.RP = 100;
modelParameter.T_L = 90;
modelParameter.RT = 3;

N = modelParameter.N; %number of motor unit
i = 1:N; %motor unit identification index
RR = modelParameter.RR; %range of recruitment in unit of fold
a = log(RR)/N; %coefficient to establish a range of threshold values
RTE = exp(a*i); %recruitment threshold excitation
MFR = modelParameter.MFR; %minimum firing rate constant for all motoneurons
g_e = modelParameter.g_e; %missing parameter from the paper
PFR1 = modelParameter.PFR1; %the peak firing rate of the first recruited motoneuron in unit of impulse/sec
PFRD = modelParameter.PFRD; %the desired difference in peak firing rates between the first and last units in unit of impulse/sec
RTEn = exp(a*N); %recruitment threshold of the last motor unit
PFR = PFR1 - PFRD * (RTE./RTEn); %peak firing rate
PFRn = PFR1 - PFRD; %peak firing rate of the last motor unit
Emax = RTEn + (PFRn - MFR)/g_e; %maximum excitatory input


RP = modelParameter.RP; %range of twich force across motor untis in unit of fold
b = log(RP)/N; %coefficient to establish a range of twich force values
P = exp(b*i); %force generated by a motor unit as a function of its recruitment threshold
T_L = modelParameter.T_L; %the longest duration contraction time desired for the pool in unit of ms
RT = modelParameter.RT; % range of contraction time in unit of fold
c = log(100)/log(RT); %coefficient to establish a range of contraction time values
T = (T_L.* (1./P).^(1/c))./1000; %contraction time
t_twitch = 0:1/Fs:1;
twitch = zeros(N,length(t_twitch));

for j = 1:N
    twitch(j,:) =  P(j).*t_twitch./T(j).*exp(1-t_twitch./T(j));
end

%--------------------------------------------------------------------------
% Test parameters
%--------------------------------------------------------------------------
for k = 1:2
    testingUnit = 120;
    if k == 1
        test_frequency = 10;
    else
        test_frequency = 30;
    end
    ISI_cv_vec = [0 0.05 0.1 0.15 0.2 0.25 0.3];
    
    mean_force_all = zeros(1,length(ISI_cv_vec));
    SD_force_all = zeros(1,length(ISI_cv_vec));
    CoV_force_all = zeros(1,length(ISI_cv_vec));
    mean_FR_all = zeros(1,length(ISI_cv_vec));
    CoV_ISI_all = zeros(1,length(ISI_cv_vec));
    %--------------------------------------------------------------------------
    for j = 1:length(ISI_cv_vec)
        ISI_cv = ISI_cv_vec(j);
        modelParameter.cv = ISI_cv;
        cv = modelParameter.cv; %ISI variability as per coefficient of variation (=mean/SD)
        amp = - MFR/g_e + RTE(testingUnit) + test_frequency/g_e;
        U = [zeros(1,1*Fs) (amp/2)*(0:1/Fs:2) amp*ones(1,length(time)-3*Fs-1)];
        
        mean_force = zeros(1,10);
        SD_force = zeros(1,10);
        CoV_force = zeros(1,10);
        
        mean_FR = zeros(1,10);
        CoV_ISI = zeros(1,10);
        
        for k = 1:10
            %--------------------------------------------------------------------------
            % Parameter initialization
            %--------------------------------------------------------------------------
            FR_mat = zeros(1,length(time));
            g_mat = zeros(1,length(time));
            spike_train = zeros(1,length(time));
            force = zeros(1,length(time));
            for t = 1:length(time)
                if t > 1
                    FR = g_e.*(U(t) - RTE(testingUnit)) + MFR;
                    if FR < MFR
                        FR = 0;
                    elseif FR > PFR(testingUnit)
                        FR = PFR(testingUnit);
                    end
                    FR_mat(t) = FR;
                    
                    spike_train_temp = zeros(1,length(time));
                    if FR > MFR
                        if ~any(spike_train) % initial time
                            spike_train(t) = 1;
                            spike_train_temp(t) = 1;
                            mu = 1/FR;
                            Z = randn(1);
                            Z(Z>3.9) = 3.9;
                            Z(Z<-3.9) = -3.9;
                            spike_time_temp = (mu + mu*cv*Z)*Fs;
                            if spike_time_temp < 2*1000/Fs
                                spike_time_temp = 2;
                            end
                            spike_time = round(spike_time_temp) + t;
                            force_temp = conv(spike_train_temp,twitch(testingUnit,:));
                            force = force + force_temp(1:length(time));
                        else
                            if spike_time == t
                                spike_train(t) = 1;
                                spike_train_temp(t) = 1;
                                mu = 1/FR;
                                Z = randn(1);
                                Z(Z>3.9) = 3.9;
                                Z(Z<-3.9) = -3.9;
                                spike_time_temp = (mu + mu*cv*Z)*Fs;
                                if spike_time_temp < 2*1000/Fs
                                    spike_time_temp = 2;
                                end
                                spike_time = round(spike_time_temp) + t;
                                
                                ISI = (spike_time - t)/Fs;
                                %ISI = mu;
                                StimulusRate = T(testingUnit)/ISI;
                                if StimulusRate > 0 && StimulusRate <= 0.4
                                    g = 1;
                                elseif StimulusRate > 0.4
                                    S_MU = 1 - exp(-2*(StimulusRate)^3);
                                    g = (S_MU/StimulusRate)/0.3;
                                end
                                g_mat(t) = g;
                                
                                force_temp = conv(spike_train_temp,g*twitch(testingUnit,:));
                                force = force + force_temp(1:length(time));
                            elseif FR_mat(t-1) == 0
                                spike_train(t) = 1;
                                spike_train_temp(t) = 1;
                                mu = 1/FR;
                                Z = randn(1);
                                Z(Z>3.9) = 3.9;
                                Z(Z<-3.9) = -3.9;
                                spike_time_temp = (mu + mu*cv*Z)*Fs;
                                if spike_time_temp < 2*1000/Fs
                                    spike_time_temp = 2;
                                end
                                spike_time = round(spike_time_temp) + t;
                                force_temp = conv(spike_train_temp,twitch(testingUnit,:));
                                force = force + force_temp(1:length(time));
                                
                            end
                        end
                    end
                    
                end
                
            end
            
            mean_force(k) = mean(force(5*Fs+1:end));
            SD_force(k) = std(force(5*Fs+1:end));
            CoV_force(k) = SD_force/mean_force;
            
            index_spike = find(spike_train(5*Fs+1:end)==1);
            index_spike_diff = diff(index_spike)./Fs;
            mean_ISI = mean(index_spike_diff);
            SD_ISI = std(index_spike_diff);
            CoV_ISI(k) = SD_ISI/mean_ISI;
            mean_FR(k) = mean(1./index_spike_diff);
        end
        
        figure(1)
        plot(time,force)
        hold on
        
        mean_force_all(j) = mean(mean_force);
        SD_force_all(j) = mean(SD_force);
        CoV_force_all(j) = mean(CoV_force);
        
        mean(mean_FR)
        mean(CoV_ISI)
        
        mean_FR_all(j) = mean(mean_FR);
        CoV_ISI_all(j) = mean(CoV_ISI);
        
    end
    
    figure(2)
    plot(ISI_cv_vec,mean_force_all)
    xlabel('CoV of ISI (%)','FontSize',14)
    ylabel('Mean Force (AU)','FontSize',14)
    hold on
    
    figure(3)
    plot(ISI_cv_vec,SD_force_all)
    xlabel('CoV of ISI (%)','FontSize',14)
    ylabel('SD (AU)','FontSize',14)
    hold on
    
    figure(4)
    plot(ISI_cv_vec,CoV_force_all*100)
    xlabel('CoV of ISI (%)','FontSize',14)
    ylabel('CoV (%)','FontSize',14)
    hold on
    
end
figure(2)
legend('10 Hz','30 Hz')

figure(3)
legend('10 Hz','30 Hz')

figure(4)
legend('10 Hz','30 Hz')
