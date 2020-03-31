% This function solves the equilibrum system to construct the data for
% RUV using a gravity approach

function B = gravity_system(x)

% Call globals

global matrixB vectorlambda

% Define system

Bfirst            = (vectorlambda.*x ./ (matrixB*x.^(-1)) - 1)*100;
Bsecond           = x(1)-100;
B                 = [Bfirst;Bsecond];
