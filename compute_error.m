function [error,kldiv] = compute_error(wRE,target_distr)

dims = size(wRE);
dims = dims/100;

avg_weights = zeros(dims);
for h=1:dims(1)
    for g=1:dims(2)
        avg_weights(h,g) = mean(mean(wRE(1+(h-1)*100:h*100,1+(g-1)*100:g*100)));
    end
end
error = sum( abs( target_distr' - sum( avg_weights,2)/sum(sum(avg_weights,2) ) ) )/dims(1);
kldiv = sum( target_distr'.*log( target_distr'./(sum(avg_weights,2)/sum(sum(avg_weights,2))) ) );

%note: the kl divergence is not helpful when there are zeros (or very small
%values) in the approximation of the target distribution!

% figure
% plot(target_distr,'*')
% hold on
% plot( sum(avg_weights,2)/sum(sum(avg_weights,2)),'*' )

end