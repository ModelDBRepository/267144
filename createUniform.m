%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE WEIGHT MATRIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mult = 3;%*2;
EneuronNum = 800*mult;
IneuronNum = EneuronNum/4;
neuronNum = EneuronNum + IneuronNum;
sizeClusters = 100;
numClusters = EneuronNum/sizeClusters;

f = 1/sqrt(mult);           %Factor to scale by synaptic weight parameters by network size
WRatio  =  20;%*sqrt(2);    %Ratio of Win/Wout (synaptic weight of within group to neurons outside of the group)

wEI     = f*175;         %Average weight of inhibitory to excitatory cells
wIE     = f*5;           %Average weight of excitatory to inhibitory cells 
wEE     = f*5;           %Average weight of excitatory to excitatory cells
wII     = f*35;          %Average weight of inhibitory to inhibitory cells


p = 0.2;                                                        %connection probability

weightsEI = random('binom',1,p,[EneuronNum,IneuronNum]);        %Weight matrix of inhibitory to excitatory LIF cells
weightsEI = wEI* weightsEI;

weightsIE = random('binom',1,p,[IneuronNum, EneuronNum]);       %Weight matrix of excitatory to inhibitory cells
weightsIE = wIE* weightsIE;

weightsII = random('binom',1,p,[IneuronNum, IneuronNum]);     %Weight matrix of inhibitory to inhibitory cells
weightsII = wII.* weightsII;

weightsEE = random('binom',1,p,[EneuronNum, EneuronNum]);     %Weight matrix of excitatory to excitatory cells
weightsEE = wEE.* weightsEE;


%Create the group weight matrices and update the total weight matrix
for i = 1:numClusters
    weightsEE((i-1)*EneuronNum/numClusters+1:i*EneuronNum/numClusters,(i-1)*EneuronNum/numClusters+1:i*EneuronNum/numClusters) = WRatio.*weightsEE((i-1)*EneuronNum/numClusters+1:i*EneuronNum/numClusters,(i-1)*EneuronNum/numClusters+1:i*EneuronNum/numClusters);
    %weightsEI((i-1)*EneuronNum/numClusters+1:i*EneuronNum/numClusters,(i-1)*IneuronNum/numClusters+1:i*IneuronNum/numClusters) = 0.*weightsEI((i-1)*EneuronNum/numClusters+1:i*EneuronNum/numClusters,(i-1)*IneuronNum/numClusters+1:i*IneuronNum/numClusters);
end


%Ensure the diagonals are zero
weightsII = weightsII - diag(diag(weightsII));
weightsEE = weightsEE - diag(diag(weightsEE));