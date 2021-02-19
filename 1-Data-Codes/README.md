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

2) Calculates the sector-country bilateral trade flows $X_{ij,k}$ when $i\in US\;  \&\;  j \notin US$ (exports from each state to each country) and $i\notin US\;  \&\;  j \in US$ (imports from each country to each state), for all sectors $k$ (except services).

## Code 3:

1) Creates the CFS base, which contains the state to state trade flow.

2) Uses CFS plus proportionality to calculate $X_{ij,k}$ for $i\in US\;  \&\;   j \in US$, for all manufacturing sectors (all sectors except services and agriculture).

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

## Code 7:

1) This code computes the employment level for each state and sector in year 2000, $L_{2000}$. 

2) This code computes the US mobility matrices (as shares of initial allocation of workers in a specific state-sector) for years 2000-2006, $\mu_{yr}$. The matrices are constructed so that flows go from rows to columns.  

3) This code computes the employment distribution by sector for each country and each year 1999-2007. It also applies proportionality to $L_{2000}$ of step 1 so that the matrix is consistent with WIOD. 

4) This code computes the labor distribution matrices (all regions) for years 1999-2007, $L_{yr}$.