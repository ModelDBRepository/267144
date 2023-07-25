%% Learning statistical structure
% This script sets the uniform sampler network and the network tuned to the
% input (read-out network, even though it is the network receiving the
% input)

clear
spontaneous = true; %boolean: spontaneous dynamics or training simulation

%% Set up weight matrix of recurrent networks
% the network parameters can be changed in the scripts

createUniform;
createReadOutRNN;

%% Set up connectivity between the recurrent networks
% the read-out network parameters can be changed in the scripts

wRE = zeros(REneuronNum,EneuronNum);

%% Parameters for neural and synaptic dynamics of E and I neurons
% standard parameters from literature

dynamics_parameters;

%% Short and long term plasticity

plasticity_parameters;

%% External input to E-RNN and I-RNN

external_input;

%% Launch simulation

dt = 0.1; %Euler discretization time step [ms]
T = 1000; %total simulation time [ms]

if spontaneous
    test_setup; %set connectivity between networks
    seq_nb = 1;
    spontaneous_simulation; %no plasticity
else
    nb_its = 100; %number of iterations
    nb_samples = 5; %number of samples taken from target distribution in each iteration
    test_setup; %set initial connectivity between networks
    training_simulation; %supervisor input and plasticity
end

%% Plotting dynamics

if spontaneous
    figure()
    subplot(2,1,1)
    plotUNIFORMRASTER
    subplot(2,1,2)
    plotReadOutRASTER   
    xlabel('Time [s]')
    box off
end
