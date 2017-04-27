%   Name: C4LMParasDetermination
%   Description: Matlab Code for determining the parameters of the
%   compliant four-bar linkage mechanism. Use lsqnonlin (non-linear least
%   square algorithm) to fit the paratemeters of C4LM to meet the required
%   torque profile
%   Author: Jiayi Wang
%   Date: 27/04/2017

%% Clean workspace
clc;
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


%% Generate and plot torque profile determined by a2 and a1
epsilons = epsilonMin:1e-4:epsilonMax;
TorquesProfile = a2*epsilons.^2+a1*epsilons;

plot(epsilons,TorquesProfile)
title(['Torque-Deflection Profile a_{1} = ', num2str(a1), ', a_{2} = ',num2str(a2)])
xlabel('Deflection of the Entire Compliant Transmission Element {\epsilon} (rad)')
ylabel('Torques {\tau} (Nm)')

%% fit parameters of C4LM

