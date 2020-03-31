%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This program reads in the full 2000 WIOD tables and                 %%%
%%% prepares the data for subsequent analysis with intermediate goods.  %%%
%%% For details see: 'Trade Theory with Numbers:                        %%%
%%% Quantifying the Consequences of Globalization'                      %%%
%%% by Arnaud Costinot and Andrés Rodríguez-Clare                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% File edited by Mauricio Ulate, 2019-10-12

clear all                                                                  % Clean the matlab workspace
clc                                                                        % Clean everything in matlab output window

% Number of regions and sectors in the raw WIOD data

N = 41;                                                                    % Number of countries in WIOD
S = 35;                                                                    % Number of sectors in WIOD

x = dir('0-Raw_Data\WIOD\wiot*.xlsx');
k=0;

for file = x'
cd '0-Raw_Data\WIOD'
fprintf(1,'Working with %s\n',file.name)

% Read data
%names of rows
[~,names1]=xlsread(file.name,1,'C7:C1441');
[~,names2]=xlsread(file.name,1,'D7:D1441');
names_rows = strcat(names1,names2);
%names of columns
[~,names1]=xlsread(file.name,1,'E5:BKF5');
[~,names2]=xlsread(file.name,1,'E6:BKF6');
names_cols = strcat(names1,names2);

wiodTradeMatrixIO = xlsread(file.name,1,'E7:BKF1441');       % Import data
wiodTradeMatrixIO(wiodTradeMatrixIO==0) = 0.0000001;                       % Set zero flows equal to a small number
Zinit = wiodTradeMatrixIO(:,1:1435);                                       % unadjusted data on intermediate input flows
Xinit = wiodTradeMatrixIO;                                                 % unadjusted data on both flows of intermediate and final goods
Rinit = sum(Xinit,2);                                                      % unadjusted total output
% Adjust for negative inventory changes. See Handbook chapter (online appendix, page 15, footnote 1) for details.
% We model production as Rinit = A*Rinit + FINsum (where A is calculated by Zinit= A * diag(Rinit))
% With the adjustment below we will have R = A*R + Fsum (where again Z = A * diag(R) with no negative final consumption)

FIN    = Xinit(:,1436:end);                                                % Matrix of final demand and inventories adjustment
FINsum = sum(FIN,2);                                                       % This is only needed for checks
F      = FIN.*(FIN>0);                                                     % Positive component of final demand (becomes final demand after correcting for INV<0)
Fsum   = sum(F,2);                                                         % Initial final demand (remains the same)
A      = Zinit/diag(Rinit);                                                % Estimate matrix on direct input coefficients (small number is added to avoid NaN for zero-sectors)
R      = (eye(N*S)-A)\(Fsum);                                              % Compute a new vector of total output under zero decline in inventories
Z      = A*diag(R);                                                        % Compute a new matrix of intermediate goods flows
X      = [Z,F];    % Both flows of intermediate and final goods 
cd ..\..
if k<10
    my_cell = sprintf('1-Intermediate_Processed_Data/WiodFixAgg0%s.xlsx',num2str(k) );
else 
    my_cell = sprintf('1-Intermediate_Processed_Data/WiodFixAgg%s.xlsx',num2str(k) );
end
k=k+1;
% Save data to excel spreadsheet
xlswrite(my_cell,X,'Sheet1','B2:BKC1436')
xlswrite(my_cell,names_cols,'Sheet1','B1:BKC1')
xlswrite(my_cell,names_rows,'Sheet1','A2:A1436')
end



