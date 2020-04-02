%% Section 0: Description of the file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Explanation of what the file does
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This file imports a vector and a matrix and finds
% a solution to the gravity system. 
% data for RUV using a gravity approach
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Input files needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% FOR SERVICES:
% matrix_B_`year`.csv
% vector_lambda_`year`.csv
%
% FOR AGRICULTURE:
% agric_mat_B_`year`.csv
% agric_vec_lambda_`year`.csv
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Output files produced
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FOR SERVICES: 
% vector_solution_`year`.csv
%
% FOR AGRICULTURE:
% vec_agric_solution_`year`.csv
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Matlab functions invoked
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% gravity_system

%% Section 1: Setup

clear all
clc

% Define globals

global matrixB vectorlambda

% Optimization parameters

tolfun         = 1e-8;
tolx           = 1e-8;
optfs          = optimoptions('fsolve','Display','iter','TolFun',tolfun,'TolX',tolx,'MaxIter',500000,'MaxFunEvals',500000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SERVICES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=2000:2007
matB= sprintf('1-Intermediate_Processed_Data/matrix_B_%s.csv',num2str(k) );
veclambda= sprintf('1-Intermediate_Processed_Data/vector_lambda_%s.csv',num2str(k) );

% Import data
matrixB        = table2array(readtable(matB));
vectorlambda   = table2array(readtable(veclambda));
init           = ones(174,1);
init(100:140)  = 150;
solution       = fsolve(@gravity_system,init,optfs);

% Save solution to an excel spreadsheet

vecsol= sprintf('1-Intermediate_Processed_Data/vector_solution_%s.xls',num2str(k));
xlswrite(vecsol,solution,'Sheet1','A1:A174')

% Compute residuals

Residual       = vectorlambda.*solution - matrixB * (solution.^(-1));
disp(sum(Residual.^2)) 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% AGRICULTURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=2000:2007
matB= sprintf('1-Intermediate_Processed_Data/agric_mat_B_%s.csv',num2str(k) );
veclambda= sprintf('1-Intermediate_Processed_Data/agric_vec_lambda_%s.csv',num2str(k) );

% Import data
matrixB        = table2array(readtable(matB));
vectorlambda   = table2array(readtable(veclambda));
init           = ones(174,1);
init(100:140)  = 150;
solution       = fsolve(@gravity_system,init,optfs);

% Save solution to an excel spreadsheet

vecsol= sprintf('1-Intermediate_Processed_Data/vec_agric_solution_%s.xls',num2str(k));
xlswrite(vecsol,solution,'Sheet1','A1:A174')

% Compute residuals

Residual       = vectorlambda.*solution - matrixB * (solution.^(-1));
disp(sum(Residual.^2)) 

end