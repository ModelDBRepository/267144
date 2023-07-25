%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plasticity uniform sampler to read-out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w_Emax = 5;     %maximal read-out weight strength
w_Emin = 0;     %minimal read-out weight strength 

tau_xE = 15;     %low-pass filter time constant pre
tau_yE = 15;     %low-pass filter time constant post

x_E = zeros(1,EneuronNum);
y_E = zeros(1,REneuronNum);

x_E_stdp = zeros(1,EneuronNum);
y_E_stdp = zeros(1,REneuronNum);