function [samples,times,total_time] = sample_target(nb_samples,RnumClusters,target_distr)

time_intervals = 200; %time between presentation of external stimuli, can be changed later to make it random for example at a certain rate
total_time = nb_samples*200+80; %in ms
times = 100:200:total_time;

target_cdf = zeros(1,RnumClusters);
for j=1:RnumClusters
    target_cdf(j) = sum(target_distr(1:j));
end

temp = target_cdf - rand(nb_samples,1);
temp(temp<0) = 0;
temp(temp>0) = 1;
[~,ids] = max(temp,[],2);
samples = ids;

    
end