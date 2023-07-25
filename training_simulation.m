%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Training Network with plasticity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set target distribution
%target_distr = set_target(RnumClusters);
load('./data/target_distr2.mat');

%track learning
weights_error = zeros(1,nb_its);
weights_kldiv = zeros(1,nb_its);
samples_all = zeros(1,nb_its);

for its = 1:nb_its

its
    
%take samples
[samples,times,T] = sample_target(nb_samples,RnumClusters,target_distr);
samples_all(1+(its-1)*nb_samples:its*nb_samples) = samples;

%reset external input
dynamics_parameters;
external_input;

%variable to plot low-pass filter
x = zeros(EneuronNum,T/dt);
y = zeros(REneuronNum,T/dt);

wRE_step = zeros(size(wRE));


%Uniform sampler init
rast = zeros(neuronNum,T/dt + 1);          %Matrix storing spike times for raster plots
rast_binary = zeros(neuronNum,T/dt + 1);   %same but with binary numbers
lastAP  = -50 * ones(1,neuronNum);         %last action potential for refractor period calculation (just big number negative put)
memVol = Vreset+(V_T-Vreset)*rand(1,neuronNum);
v = zeros(1,neuronNum);

%Read-out init
rast_R = zeros(RneuronNum, T/dt+1);
rast_binary_R = zeros(RneuronNum, T/dt+1);
lastAP_R = -50*ones(1,RneuronNum);
memVol_R = Vreset+(V_T-Vreset)*rand(1,RneuronNum);
v_R = zeros(1,RneuronNum);


k = 1;
for i =2:T/dt

if its<=400
    if k<=nb_samples && i*dt == times(k)  
        rRx((samples(k)-1)*sizeClusters+1:samples(k)*sizeClusters) = rRex + 30;
    elseif k<=nb_samples && i*dt == times(k) + 50 
        rRx((samples(k)-1)*sizeClusters+1:samples(k)*sizeClusters) = rRex;
        k = k+1;
    end        
end

    %E-RNN
    forwardInputsE = zeros(1,neuronNum);
    forwardInputsI = zeros(1,neuronNum);
    %Read-out
    forwardInputsRE = zeros(1,RneuronNum);
    forwardInputsRI = zeros(1,RneuronNum);
    %Plasticity
    %wRE_step = zeros(REneuronNum,EneuronNum);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%   Uniform sampler   %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %external input
    while true
        idx = i*dt > nextx;
        if sum(idx) == 0
            break
        end
        idx = find(idx);
        nextx(idx) = nextx(idx) + exprnd(1,1,size(idx,2))./rx(idx);
        forwardInputsEPrev(idx) = forwardInputsEPrev(idx) + Jex(idx);
    end

    %connectivity
    xerise = xerise -dt*xerise/tauerise + forwardInputsEPrev;
    xedecay = xedecay -dt*xedecay/tauedecay + forwardInputsEPrev;
    xirise = xirise -dt*xirise/tauirise + forwardInputsIPrev;
    xidecay = xidecay -dt*xidecay/tauidecay + forwardInputsIPrev;
    
    gE = (xedecay - xerise)/(tauedecay - tauerise);
    gI = (xidecay - xirise)/(tauidecay - tauirise);

    %adaptation and plasticity excitatory
    x_E = zeros(1,EneuronNum);%x_E + (dt/tau_xE)*(-x_E);
    w = w + (dt/tau_w)*(a*(memVol(1:EneuronNum) - V_E) - w);           %adaptation current
    EVthreshold = EVthreshold + (dt/tau_T)*(V_T - EVthreshold);  %adapting threshold

    %cell dynamics excitatory
    v(1:EneuronNum) = memVol(1:EneuronNum) + (dt/tau_E)*(-memVol(1:EneuronNum) + V_E + DET*exp((memVol(1:EneuronNum)-EVthreshold)/DET)) ...
        + (dt/C)*(gE(1:EneuronNum).*(E_E - memVol(1:EneuronNum)) + gI(1:EneuronNum).*(E_I - memVol(1:EneuronNum)) - w);

    %cell dynamics inhibitory
    v(EneuronNum+1:neuronNum) = memVol(EneuronNum+1:neuronNum) + (dt/tau_I)*(-memVol(EneuronNum+1:neuronNum) + V_I) + ...
        (dt/C)*(gE(EneuronNum+1:neuronNum).*(E_E - memVol(EneuronNum+1:neuronNum)) + gI(EneuronNum+1:neuronNum).*(E_I - memVol(EneuronNum+1:neuronNum)));

    %refractory period
    v(lastAP>=i-tau_abs/dt) = Vreset;
    x_E(lastAP(1:EneuronNum)>=i-15/dt) = 1;
    
    %spike recorded excitatory
    idx = v(1:EneuronNum)>Vthres;
    v(idx) = Vreset;
    lastAP(idx) = i;
    rast(idx,i) = find(idx);
    rast_binary(idx,i) = 1;
    forwardInputsE = forwardInputsE + [sum(weightsEE(:,idx),2);sum(weightsIE(:,idx),2)]'; %recurrent
    forwardInputsRE(1:REneuronNum) = forwardInputsRE(1:REneuronNum) + sum(wRE(:,idx),2)'; %to read-out
    EVthreshold(idx) = EVthreshold(idx) + A_T;
    w(idx) = w(idx) + b;
    x_E(idx) = 1;
    
    %spike recorded inhibitory
    idx = find(v(EneuronNum+1:neuronNum)>V_T)+EneuronNum;
    v(idx) = Vreset;
    lastAP(idx) = i;
    rast(idx,i) = idx;
    rast_binary(idx,i) = 1;
    forwardInputsI = forwardInputsI + [sum(weightsEI(:,idx-EneuronNum),2);sum(weightsII(:,idx-EneuronNum),2)]';

   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%   READ-OUT NETWORK   %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %external input
    while true
        idx = i*dt > nextRx;
        if sum(idx) == 0
            break
        end
        idx = find(idx);
        nextRx(idx) = nextRx(idx) + exprnd(1,1,size(idx,2))./rRx(idx);
        forwardInputsREPrev(idx) = forwardInputsREPrev(idx) + Jex(idx);
    end
    
    %connectivity
    xRerise = xRerise -dt*xRerise/tauerise + forwardInputsREPrev;
    xRedecay = xRedecay -dt*xRedecay/tauedecay + forwardInputsREPrev;
    xRirise = xRirise -dt*xRirise/tauirise + forwardInputsRIPrev;
    xRidecay = xRidecay -dt*xRidecay/tauidecay + forwardInputsRIPrev;
    
    gRE = (xRedecay - xRerise)/(tauedecay - tauerise);
    gRI = (xRidecay - xRirise)/(tauidecay - tauirise);

    y_E = zeros(1,REneuronNum);%y_E - (dt/tau_yE)*y_E; %plasticity variable
    wR = wR + (dt/tau_w)*(a_R*(memVol_R(1:REneuronNum) - V_E) - wR);  %adaptation current            
    EVthresholdR = EVthresholdR + (dt/tau_T)*(V_T - EVthresholdR);  %adapting threshold

    %cell dynamics excitatory
    v_R(1:REneuronNum) = memVol_R(1:REneuronNum) + (dt/tau_E)*(-memVol_R(1:REneuronNum) + V_E + DET*exp((memVol_R(1:REneuronNum)-EVthresholdR)/DET)) ...
        + (dt/C)*(gRE(1:REneuronNum).*(E_E - memVol_R(1:REneuronNum)) + gRI(1:REneuronNum).*(E_I - memVol_R(1:REneuronNum)) - wR);

    %cell dynamics inhibitory
    v_R(REneuronNum+1:RneuronNum) = memVol_R(REneuronNum+1:RneuronNum) + (dt/tau_I)*(-memVol_R(REneuronNum+1:RneuronNum) + V_I) + ...
        (dt/C)*(gRE(REneuronNum+1:RneuronNum).*(E_E - memVol_R(REneuronNum+1:RneuronNum)) + gRI(REneuronNum+1:RneuronNum).*(E_I - memVol_R(REneuronNum+1:RneuronNum)));

    %refractory period
    v_R(lastAP_R>=i-tau_abs/dt) = Vreset;
    y_E(lastAP_R(1:REneuronNum)>=i-15/dt) = 1;

    %spike recorded excitatory
    idx = v_R(1:REneuronNum)>Vthres;
    v_R(idx) = Vreset;
    lastAP_R(idx) = i;
    rast_R(idx,i) = find(idx);
    rast_binary_R(idx,i) = 1;
    forwardInputsRE = forwardInputsRE + [sum(weightsREE(:,idx),2);sum(weightsRIE(:,idx),2)]'; %recurrent 
    EVthresholdR(idx) = EVthresholdR(idx) + A_T;
    wR(idx) = wR(idx) + b_R;
    y_E(idx) = 1;

    %spike recorded inhibitory
    idx = find(v_R(REneuronNum+1:RneuronNum)>V_T)+REneuronNum;
    v_R(idx) = Vreset;
    lastAP_R(idx) = i;
    rast_R(idx,i) = idx;
    forwardInputsRI = forwardInputsRI + [sum(weightsREI(:,idx-REneuronNum),2);sum(weightsRII(:,idx-REneuronNum),2)]'; %recurrent    

    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%   PLASTICITY E-RNN -> Read-outs   %%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if i>100/dt %start-up time
        wRE = wRE + 0.5*dt*(y_E'*x_E);
        wRE = wRE + (dt/100)*(-sum(wRE,1) + 500); %maybe it has to be faster, I tried tau=100ms
        idx = find(wRE<w_Emin); %minimum weight is w_Emin
        wRE(idx) = w_Emin;
        idx = find(wRE>w_Emax); %maximum weight is w_Emax
        wRE(idx) = w_Emax;
    end
    
    %E-RNN
    memVol = v;
    forwardInputsEPrev = forwardInputsE;
    forwardInputsIPrev = forwardInputsI;
    %Read-out
    memVol_R = v_R;
    forwardInputsREPrev = forwardInputsRE;
    forwardInputsRIPrev = forwardInputsRI;    
    %plasticity
    %wRE = wRE_step;
    
    x(:,i) = x_E';
    y(:,i) = y_E';

end

if mod(its,5) == 0
figure()
subplot(3,1,1)
plotUNIFORMRASTER
subplot(3,1,2)
plotReadOutRASTER
subplot(3,1,3)
imagesc(wRE)
colorbar
end

[weights_error(its),weights_kldiv(its)] = compute_error(wRE,target_distr);

%save weights every iteration
save(['data/wRE10_50_100_small_v4_' num2str(its) '.mat'],'wRE');

end

%save target distribution and learning
save('data/weights_error10_50_100_small_v4.mat','weights_error');
save('data/weights_kldiv10_50_100_small_v4.mat','weights_kldiv');
save('data/samples10_50_100_small_v4.mat','samples_all');

figure
plot(weights_error)