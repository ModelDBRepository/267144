%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE WEIGHT MATRIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mult = 1;
REneuronNum = 800*mult;
RIneuronNum = REneuronNum/4;
RneuronNum = REneuronNum + RIneuronNum;
sizeClusters = 100;
RnumClusters = REneuronNum/sizeClusters;


WRatio  = 10;             %Ratio of Win/Wout (synaptic weight of within group to neurons outside of the group)
f = 1/sqrt(mult);           %Factor to scale by synaptic weight parameters by network size

wREI     = f*175;          %Average weight of inhibitory to excitatory cells
wRIE     = f*5;           %Average weight of excitatory to inhibitory cells 
wREE     = f*5;           %Average weight of excitatory to excitatory cells
wRII     = f*35;          %Average weight of inhibitory to inhibitory cells


p = 0.2;                                                        %connection probability

weightsREI = random('binom',1,p,[REneuronNum,RIneuronNum]);        %Weight matrix of inhibitory to excitatory LIF cells
weightsREI = wREI.* weightsREI;

weightsRIE = random('binom',1,p,[RIneuronNum, REneuronNum]);       %Weight matrix of excitatory to inhibitory cells
weightsRIE = wRIE.* weightsRIE;

weightsRII = random('binom',1,p,[RIneuronNum, RIneuronNum]);     %Weight matrix of inhibitory to inhibitory cells
weightsRII = wRII.* weightsRII;

weightsREE = random('binom',1,p,[REneuronNum, REneuronNum]);     %Weight matrix of excitatory to excitatory cells
weightsREE = wREE.* weightsREE;


%Create the group weight matrices and update the total weight matrix
for i = 1:RnumClusters
    weightsREE((i-1)*REneuronNum/RnumClusters+1:i*REneuronNum/RnumClusters,(i-1)*REneuronNum/RnumClusters+1:i*REneuronNum/RnumClusters) = WRatio.*weightsREE((i-1)*REneuronNum/RnumClusters+1:i*REneuronNum/RnumClusters,(i-1)*REneuronNum/RnumClusters+1:i*REneuronNum/RnumClusters);
end


%Ensure the diagonals are zero
weightsRII = weightsRII - diag(diag(weightsRII));
weightsREE = weightsREE - diag(diag(weightsREE));