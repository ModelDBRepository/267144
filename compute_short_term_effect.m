% computing short-term dependencies

%1. Load weights  
%2. Run simulation for two seconds, record spikes
%3. Decode dynamics 
%4. Compute the function, integrate and repeat from 1.
%5. Fit linear regressor to predict output from previous samples.

clear

outputs = zeros(1,400);
for k=1:400
k
createUniform;
createReadOutRNN;

wRE = zeros(REneuronNum,EneuronNum);

dynamics_parameters;

plasticity_parameters;

external_input;

dt = 0.1; %Euler discretization time step [ms]
T = 2000; %total simulation time [ms]

prior = 'load_bimodal'; %load_bim'; to load plastic weight matrices
test_setup_exp; %set connectivity between networks
spontaneous_simulation; %no plasticity

dyn_avg = zeros(8,T/dt);
gauss = exp(-(-400:1:400).^2/(2*100^2));
for i=1:REneuronNum
    conv_spks(i,:) = conv(rast_binary_R(i,:),gauss,'same');
end
for i=1:8
    dyn_avg(i,:) = mean(conv_spks(1+(i-1)*sizeClusters:i*sizeClusters,:));
end
for i=1:T/dt
    dyn_avg(:,i) = dyn_avg(:,i)==max(dyn_avg(:,i));
end

rec_exp = zeros(2,T/dt);
input = [4.5,8.5];
for inp = 1:2
    f_int = 0;
    for i=1:T/dt
        f = 2*(find(dyn_avg(:,i)) < input(inp))-1; %compute function
        f_int = f_int + (dt/1000)*(f(1) - f_int); %integrate
        rec_exp(inp,i) = f_int;
    end
end

outputs(1,k) = ( rec_exp(1,end) + rec_exp(2,end) )/ (2*rec_exp(2,end));
end

outputs_probs = outputs>rand(1,400);
load('/home/ahm17/Documents/Learning statistical structure/data/samples_bim.mat')

% figure
% scatter(samples_all(5:5:end),outputs)

% md = fitglm(samples_all(5:5:end),outputs_probs, 'Distribution', 'binomial');

samples = samples_all(5:5:end);

means = zeros(1,400);
for i=1:400
    means(i) = mean(samples_all(1+(i-1)*5:i*5));
end
figure
scatter(means,outputs)

coeffs = [means',ones(400,1)]\outputs';

hold on
plot(1.8:0.01:7,coeffs(1)*(1.8:0.01:7)+coeffs(2))

lm = fitlm(means,outputs)

% save('data/recent_history_outputs_noplast.mat','outputs');

%how are the errors distributed
errs = outputs - (coeffs(1)*means+coeffs(2));
figure
histogram(errs,15)