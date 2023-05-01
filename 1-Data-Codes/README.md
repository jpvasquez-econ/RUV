# Data Construction Codes

This file explains the general purpose of each code associated with the data construction. The specific names of the outputs produced in each code are documented within each code file. 

## Code 1:

1) Maps WIOD's sectors to the 14 relevant sectors in this paper.

2) Computes the sector-country bilateral trade flows $X_{ij,k}$ between countries using data from WIOD.

3) Calculates the share of value-added (mapped in the model to the labor share) for each country, each sector, and each year using data from WIOD. 

4) Calculates the input output matrix shares for each sector, country and year using data from WIOD. Each entry is the share of expenditure of each buying sector (for each country-year, the sum across rows of each column sums up to one). 

5) Produces the Country_Coordinates Base that contains information about the most populated cities in each country, the cities' coordinates and population, and each country's population.

6) Calculates the distances between all regions. 

7) Computes the distance elasticity and own-dummy coefficients for trade flows in services and agriculture between countries (including the US).


## Code 2:

1) Takes imports and exports data from census and changes the sectors to final relevant sectors 1-14.

2) Calculates the sector-country bilateral trade flows $X_{ij,k}$ when $i\in US \;$ \&  $\;  j \notin US$ (exports from each state to each country) and $i\notin US\;$  \& $\;  j \in US$ (imports from each country to each state), for all sectors $k$ (except services).

## Code 3:

1) Creates the CFS base, which contains the state to state trade flow.

2) Uses CFS plus proportionality to calculate $X_{ij,k}$ for $i\in US\;$  \& $\;   j \in US$, for all manufacturing sectors (all sectors except services and agriculture).

## Code 4:

1) Constructs the Revenue and Expenditure services data by state.

2) Generates the inputs of the services gravity system and solves it.

## Code 5:

1) Creates a file that contains information about distances between regions, agricultural production for all regions and agricultural consumption for countries. In doing so, the code also applies the usual proportionality rule so that aggregate expenditure and production matches WIOD. 

2) Generates the inputs of the agricultural gravity system and solves it.

## Code 6:

1) Combines the previous steps in order to obtain a new Final Trade Flow Matrix for 2000 through 2007: $X_{ij,k}^{year}$.

2) Calculates region-sector level deficits. 

3) Calculates the share of value added in gross output for each US state, for each sector.


## Code 7 (2 versions):

1) This code computes the employment level for each state and sector in year 2000, $L_{2000}$. 

2) This code computes the US mobility matrices (as shares of initial allocation of workers in a specific state-sector) for years 1999-2006, $\mu_{yr}$. The matrices are constructed so that flows go from rows to columns.  

3) This code computes the employment distribution by sector for each country and each year 1999-2007. It also applies proportionality to $L_{2000}$ of step 1 so that the matrix is consistent with WIOD. 

4) This code computes the final (all regions) employment distribution, L, for 1999-2007 and the mobility matrix 1999.

5) This code recreates CDP's Table I (percentages of moving workers' categories) and produces an histogram for the diagonal values of mobility matrix 1999.

## Code 8:

1) Calculates the share of employment by state-sector in 2000 using data from BLS. 

3) Save BLS shares in "state_emp_share_2000.dta"

## Code 9:

1) This code imports WIOD data to create the 2000-2007 change in imports from China to the US, $\Delta X_{C,US,s}^{2007-2000}$, and other advanced economies, $\Delta X_{C,OC,s}^{2007-2000}$ (Australia, Germany, Denmark, Spain, Finland and Japan; New Zealand and Switzerland are not included in the WIOD). Then, runs a linear regression (with and without constant) using the change of sectoral US imports from China as the dependent variable and the change of sectoral  advanced economies' imports from China as the independent variable. Finally, the predicted values are computed, $\widehat{\Delta X_{C,US,s}^{2007-2000}}$.

2) This code computes de exposure measure using i) level el state-sector employment, ii) predicted values of regression in step 1) and iii) total US 2000 sales by sector. The exposure measure for each state $i$ is given by $$E_{i} \equiv \sum_{s=1}^{12} \frac{L_{i,s,2000}}{L_{i,2000}}\frac{\widehat{\Delta X_{C,US,s}^{2007-2000}}}{R_{US,s,2000}}$$, where $R_{US,s,2000}\equiv\sum_{i \in US}\sum_{j} X_{ij,s,2000}$ is total U.S. sales in sector s in the year 2000, $L_{i,s,2000}$ is the employment of state i in manufacturing sector s in year 2000, and  $$L_{i,2000}\equiv\sum_{s}^{14}L_{i,s,2000}$$ is the TOTAL employment of state i. This values of employment come from code 7. Finally, $\widehat{\Delta X_{C,US,s}^{2007-2000}}$ is the predicted 2000-2007 change in U.S. imports in sector s from China (computed in the first step).

## Code 10:

1) This code creates employment vectors by year (1998-2009), state and sector. The information was taken from BLS for sector 0 (unemployment and out of labor force) and BEA's SAEMP25 series for the rest of the sectors.  

2) This code produces the level migration flows for state-sector for options 1-5, including the distances between states. Options 1-4 were old tests that are no longer used. Option 5 are the outputs of code 7-Employment_migration. 

3) This code runs a regression on the shares of mobility matrix 1999. The X variables are: no constant, log distance between origin-destination states, same origin-destination state and sector dummy, same origin-destination state dummy, same origin-destination sector dummy; $$I_{is}^{\delta}$$ dummy equal to one if the origin sector is s and the origin state is i; $$I_{jk}^{\eta}$$ dummy equal to one if the destination sector is k and the destination state is j; $$I_{sk}^{\mu}$$ dummy equal to one if the origin sector is s and the destination sector is k; interaction $$I_{\text{same-st}} * I_{sk}^{\mu}$$. Because of multicollinearity, indicator variable $I_{jk}^{\eta}$ when the destination state j is Wyoming and the destination sector s is the last one of our sectors (sector 14) is dropped, as well as other dummies $$I_{sk}^{\mu}$$. This code's final output is a variant of the predicted values of the regression: $$Z_{is,jk}^{t,t+1} = \hat{\mu_{is,jk}^{t,t+1}} - \sum_{i}\sum_{s}\theta_{is}I_{is}^{\delta}-\sum_{j}\sum_{k}\gamma_{jk}I_{jk}^{\eta}$$ 

