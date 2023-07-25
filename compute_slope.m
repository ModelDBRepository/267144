% computing slope change with learning

%1. Load weights  
%2. Run simulation for two seconds, record spikes
%3. Decode dynamics 
%4. Compute the function, integrate and repeat from 1.

clear

slopes = zeros(5,60);
for h=1:60
h
for k=1:5

createUniform;
createReadOutRNN;

wRE = zeros(REneuronNum,EneuronNum);

dynamics_parameters;

plasticity_parameters;

external_input;

dt = 0.1; %Euler discretization time step [ms]
T = 2000; %total simulation time [ms]

prior = 'load_unitobim';
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
input = [3.5,5.5];
for inp = 1:2
    f_int = 0;
    for i=1:T/dt
        f = 2*(find(dyn_avg(:,i)) < input(inp))-1; %compute function
        f_int = f_int + (dt/1000)*(f(1) - f_int); %integrate
        rec_exp(inp,i) = f_int;
    end
end

slopes(k,h) = ( rec_exp(2,end) - rec_exp(1,end) )/2;
end


end



y = mean(slopes);
x = 1:120;
figure

curve1 = y + std(slopes);
curve2 = y - std(slopes);
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];
fill(x2, inBetween, 'r','FaceAlpha',.3,'EdgeAlpha',.0);
hold on;
plot(x,y, 'r', 'LineWidth', 2);
hold on
yline(0.3806); %unimodal psych slope
hold on
yline(0.0766); %bimodal psych slope
box off

save('data/slopes_unitobim.mat','slopes');