% computing weight correlation decay

corrs = zeros(360,41);

for i=1:360
    
load(['/home/ahm17/Documents/Learning statistical structure/data/wRE_bim_' num2str(i) '.mat'])
weights = wRE;

for k = 1:41

    load(['/home/ahm17/Documents/Learning statistical structure/data/wRE_bim_' num2str(i+k-1) '.mat']);
    corrs(i,k) = sum(sum(abs(weights-wRE)))/(size(wRE,1)*size(wRE,2));

end

end

y = mean(corrs);
x = 1:41;
figure

curve1 = y + std(corrs);
curve2 = y - std(corrs);
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];
fill(x2, inBetween, 'r','FaceAlpha',.3,'EdgeAlpha',.0);
hold on;
plot(x,y, 'r', 'LineWidth', 2);
box off
