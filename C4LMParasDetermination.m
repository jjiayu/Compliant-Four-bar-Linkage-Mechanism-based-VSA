%   Name: C4LMParasDetermination
%   Description: Matlab Code for determining the parameters of the
%   compliant four-bar linkage mechanism. Use lsqnonlin (non-linear least
%   square algorithm) to fit the paratemeters of C4LM to meet the required
%   torque profile
%   Author: Jiayi Wang
%   Date: 27/04/2017

%% Clean workspace
%clc;
clear;

%% Determine parameters of torque profiles (a1, a1), given desired sfiffness

%Define disired stiffness range(N*m/rad), format: [lower_bound upper_bound]
StiffnessRange = [0.3 120];
disp(['Stiffness Range: ',num2str(StiffnessRange(1)),' to ',num2str(StiffnessRange(2)),' Nm/rad']);
disp(' ');

%Define maximum positive and negative deflection angle of the C4LM
%format:[lower_bound upper_bound]
%   Deflection Angle (epsilon): the angle between the C4LM and shaft (The relative 
%   displacement between the C4LM and the shaft, not the one between the link 
%   and desired position of the joint)
DeflectionAngle = [-pi/6 pi/6];
disp(['Maximum C4LM Deflection Angle Range: ',num2str(DeflectionAngle(1)),' to ',num2str(DeflectionAngle(2)),' rad']);
disp(' ');

%Map the stiffness range to the deflection angle range
%   Minimum and Maximum stiffness achieved at both two C4LM components reach maximum
%   negative and postive deflection, respectively
epsilonMin = DeflectionAngle(1);
epsilonMax = DeflectionAngle(2);
StiffnessMin = StiffnessRange(1);
StiffnessMax = StiffnessRange(2);

a2 = 1/4*(StiffnessMax-StiffnessMin)/(epsilonMax-epsilonMin);
a1 = 1/2*StiffnessMax-2*a2*epsilonMax;

disp(['a2 = ',num2str(a2),' Nm/rad^2']);
disp(['a1 = ',num2str(a1),' Nm/rad']);
disp(' ');


%% Generate and plot torque profile determined by a2 and a1
epsilonMin = -0.1273*pi;
epsilonMax = 0.1273*pi;
epsilons = linspace(epsilonMin,epsilonMax,100);
%epsilons = epsilonMin:1e-4:epsilonMax;
TorquesProfile = a2*epsilons.^2+a1*epsilons; %TorqueProfile of a single compiant transmission element

plot(epsilons,TorquesProfile)
title(['Torque-Deflection Profile for a Single Compliant Transmission Element(CTE) a_{1} = ', num2str(a1), ', a_{2} = ',num2str(a2)])
xlabel('Deflection of the Entire Compliant Transmission Element {\epsilon} (rad)')
ylabel('Torques {\tau} (Nm)')

%% fit parameters of C4LM
n = 3; %define numbers of C4LM in a single compliant transimission element
disp(['Number of C4LM in a Single CTE(Compliant Transmission Element): ',num2str(n)])

refTorque = TorquesProfile/n; %y: desired torque profile for a single four-bar linkage mechanism

%Parameters need to be fitted: alpha0,r1,r2,r3,r4,k2,k3,k4
%initial guess of variables to be optimized
alpha0 = pi/3; r1 = 50.0; r2 = 50.0; r3 = 50.0; r4 = 50.0; k2 = 10.0; k3 = 10.0; k4 = 10.0;
%alpha0 = 0.4; r1 = 0.02; r2 = 0.02; r3 = 0.01; r4 = 0.02; k2 = 1.5; k3 = 3.0; k4 = 4.0;
%alpha0 = pi/n; r1 = 30/1000; r2 = 15/1000; r3 = 10/1000; r4 = 12/1000; k2 = 1.0; k3 = 1.0; k4 = 1.0;
x0 = [alpha0, r1, r2, r3, r4, k2, k3, k4]; %put into vector form

lb = [0.1,3,3,3,3,0.2,0.2,0.2];
ub = [pi/2/n,46/3,46/3,46/3,46/3,3,3,3];
%ub = [2*pi/n,46/2/1000,(46-18)/2/1000,(46-18)/2/1000,(46-18)/2/1000,10,10,10];

fun = @(x)C4LMTorque(x,epsilons,refTorque);
x = lsqnonlin(fun,x0,lb,ub)

%% Draw CTE (Compliant Transimission Ele1ment) Torque-Deflection Curves
FinalTorque = n*CTETorque(x,epsilons);
plot(epsilons,FinalTorque)
hold on
plot(epsilons,TorquesProfile)
legend('fitted torque','ref torque')
hold off
