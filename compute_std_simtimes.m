% computing mean slope and standard deviation as a function of simulation time

%1. Load weights  
%2. Run simulation for a certain time, record spikes
%3. Decode dynamics 
%4. Compute the function, integrate and repeat from 1.

clear

mean_slope = zeros(1,19);
std_max = zeros(2,19);
sim_times = 200:100:2000;
for h=1:19

slope_vals = zeros(100,1);
output_vals = zeros(100,2);
for k=1:100

createUniform;
createReadOutRNN;

wRE = zeros(REneuronNum,EneuronNum);

dynamics_parameters;

plasticity_parameters;

external_input;

dt = 0.1; %Euler discretization time step [ms]
T = sim_times(h); %total simulation time [ms]

prior = 'unimodal';
test_setup_exp; %set connectivity between networks
spontaneous_simulation; %no plasticity

dyn_avg = zeros(8,T/dt);
gauss = exp(-(-400:1:400).^2/(2*100^2));
conv_spks = zeros(REneuronNum,T/dt);
for i=1:REneuronNum
    conv_spks(i,:) = conv(rast_binary_R(i,:),gauss,'same');
end
for i=1:8
    dyn_avg(i,:) = mean(conv_spks(1+(i-1)*sizeClusters:i*sizeClusters,:));
end
for i=1:T/dt
    dyn_avg(:,i) = dyn_avg(:,i)==max(dyn_avg(:,i));
end

rec_exp = zeros(5,T/dt);
input = [3.5,4.5,5.5,8.5,2.5];
for inp = 1:5
    f_int = 0;
    for i=1:T/dt
        f = 2*(find(dyn_avg(:,i)) < input(inp))-1; %compute function
        f_int = f_int + (dt/1000)*(f(1) - f_int); %integrate
        rec_exp(inp,i) = f_int;
    end
end

slope_vals(k) = ( rec_exp(3,end) - rec_exp(1,end) )/2;
output_vals(k,1) = rec_exp(2,end) ;
output_vals(k,2) = rec_exp(5,end) ;
end

mean_slope(h) = mean(slope_vals)/rec_exp(4,end);
std_max(1,h) = std(output_vals(:,1))/rec_exp(4,end);
std_max(2,h) = std(output_vals(:,2))/rec_exp(4,end);
mean_slope(h)
std_max(1,h)
std_max(2,h)
end

figure
plot(mean_slope)
box off

figure
plot(std_max(1,:))
hold on
plot(std_max(2,:))
box off

save('data/mean_simtimes.mat','mean_slope');
save('data/std_simtimes.mat','std_max');