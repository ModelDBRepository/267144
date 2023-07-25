% computing expectations

%1. Set weights to correspond to distribution (uniform, unimodal, bimodal,
%biased)
%2. Run simulation, record spikes
%3. Decode dynamics 
%4. Compute the function and integrate

clear

psych_curves = zeros(20,9);
for k=1:20
k
createUniform;
createReadOutRNN;

wRE = zeros(REneuronNum,EneuronNum);

dynamics_parameters;

plasticity_parameters;

external_input;

dt = 0.1; %Euler discretization time step [ms]
T = 200; %total simulation time [ms]

%note on the time: if simulation time is short (i.e. few hundred ms which
%means a few samples) then you need to average over many more trials to see
%a somewhat clean psychometric curve. If simulation time is long (i.e.
%multiple seconds) then you need only a handful of trials to get a very
%smooth psychometric curve.

%h = 110; 
prior = 'unimodal';
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

rec_exp = zeros(9,T/dt);
input = 0.5:8.5;
for inp = 1:9
    f_int = 0;
    for i=1:T/dt
        f = 2*(find(dyn_avg(:,i)) < input(inp))-1; %compute function
        f_int = f_int + (dt/1000)*(f(1) - f_int); %integrate
        rec_exp(inp,i) = f_int;
    end
end

psych_curves(k,:) = rec_exp(:,end)';
end

rec_exp = rec_exp(:,1:10:end);
figure
plot(rec_exp')
box off

y = mean(psych_curves);
x = input;
figure

curve1 = y + std(psych_curves);
curve2 = y - std(psych_curves);
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];
fill(x2, inBetween, 'r','FaceAlpha',.3,'EdgeAlpha',.0);
hold on;
plot(x,y, 'r', 'LineWidth', 2);

box off

save('data/psych_unimodal_200ms.mat','psych_curves');