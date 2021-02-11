clc; clear all;
%%%A(:,:,:) are the matrices built based on customer inputs.
%%%The order of the matrix equals number of loads
%%%t1 comprises the hours at which customer inputs are recorded
%%%t is the timestep for which customer inputs are needed
%%%runtime=runtime of loads
%%%wattage=wattage of loads
%%%RRTP = Residential Real time pricing
%%%prices = day ahead hourly prices
A(:,:,1) = [1,2,8,1/7;1/2,1,5,1/6;1/8,1/5,1,1/7;7,6,7,1];
A(:,:,2) = [1,1/8,4,1/9;8,1,7,1/7;1/4,1/7,1,1/9;9,7,9,1];
A(:,:,3) = [1,1/2,1/9,5;2,1,1/8,2;9,8,1,9;1/5,1/2,1/9,1];
A(:,:,4) = [1,1/5,1/2,7;5,1,1/3,4;2,3,1,1/5;1/7,1/4,5,1];
A(:,:,5) = [1,2,8,1/3;1/2,1,5,1/2;1/8,1/5,1,1/4;3,2,4,1];
t=15;
t1=[1 6 12 18 24];
runtime = [4,4,5,4];
wattage = [1.6,1.6,2.5,3.3];
RRTP=[3.1,3.1,3.1,2.6,2.1,0.9,1.7,2.1,3.2,4.0,3.8,3.9,4.5,4.4,5.7,7.7,12.4,6.6,6.0,5.2,4.9,4.4,4.1,3.6];
prices=[2.9,2.6,2.4,2.1,2,2,2.1,2.6,3,3.3,3.5,3.8,4.2,4.4,4.8,5.4,5.8,6,4.7,4,3.8,3.8,3.4,3.2];
[W] = lsm(A,t1,t,runtime,wattage,prices,RRTP);