# RUV Data Construction	

## Data: WIOD

- **WIODFixNegative-1-1.m**: This program removes the negatives from WIOD. It has to be run separately for each year (it does not have a loop). For details see: "Trade Theory with Numbers: Quantifying the Consequences of Globalization' by Arnaud Costinot and Andrés Rodríguez-Clare. (The name of the file should be **1-1-WIODFixNegative** but Matlab does not allow file names to start with a number). 
- **1-2-WiodFixedtoStata.do**: Creates the full WIOD data without negatives by putting together all years.
- **1-3-WIOD.do**: Takes WIOD and maps to the 14 relevant sectors that we consider and for the countries we use.

## Data: state-level imports and exports

- **2-1-state_imports_exports_raw_data.do**: Compiles imports and exports data from raw census data. The folder "0-Raw_Data\State-Exports-Imports" indicates how to download the raw data.
- **2-2-state_imports_exports.do**:  Takes imports and exports data from census and changes the 
  sectors for the sector classification we use and the countries we use. 

## Data: trade in manufacturing between states. CFS

- **3-1-CFS_to_Sectors_Cross.do**: Take CFS 2007 and 2012. Assign classification from product code to NAICS level. We use the same mapping in 2002 as the one of 2007. Table CF0700A18. We take commodities 1-7 as agriculture and commodities 10-19 as mining.
- **3-2-makeTradeMatrixCFS.do**: Calculate the trade flows between states for the 12 manufacturing sectors in our data and sector 14: agriculture and mining. 

## Data: Sector 13. Services

- **4-1-state_exp_gdp.do**: Constructs the data of services GDP and expenditure by state. Data of expenditure comes from BEA and data of GDP from SAGDP. We then use proportionality to ensure that values sum up to the USA production/consumption totals in WIOD.
- **4-2-country_coordinates.Rmd**:  Produces the Country_Coordinates Base that contains information about the most populated cities in each country, the cities' coordinates and population, and each country's population. The file contains instructions describing the raw data and its sources.
- **4-3-data_services.do**:  The do file does the following: 1) Imports coordinates by county and crosses each county with the others 2) Calculates distance in km, 3) Renames variables, 4) Merging populations, 5) Applying formula of distances: <img src="https://render.githubusercontent.com/render/math?math=d_{ij} = \Big(\sum_{r \in i} \sum_{s \in j} \big(\tfrac{pop_r}{pop_i}\big)\big(\tfrac{pop_s}{pop_j}\big) d_{rs}^\theta\Big)^{1/ \theta}">
- **4-4-Country_Gravity_Services_WIOD.Rmd**: This file estimates the distance elasticity and the own-country dummy for a gravity regression using country-level data from WIOD and focused on the services sector (sector 13).  The regression equation is <img src="https://render.githubusercontent.com/render/math?math=\ln X_{ij,t}=\lambda_t %2B \delta_{i}^{o}%2B\delta_{j}^{d}%2B\beta_{0}\iota_{ij}%2B\beta_{1}\ln dist_{ij}%2B\xi_{ij,t}"> . We estimate <img src="https://render.githubusercontent.com/render/math?math=\hat\beta_{0} \approx 6.5"> and <img src="https://render.githubusercontent.com/render/math?math=\hat\beta_{1}\approx -0.7">. 
- **4-5-Gravity_services_inputs.Rmd**: This file generates the inputs of the gravity system that we take to solve in Matlab.
- **solving_gravity_system_4_6.m**: Finds a solution for the gravity system. 
- **4-7-Gravity-Step.Rmd**: Puts together the solution from the gravity system and builds the final bilateral matrix of services so that the country-level aggregates match WIOD.

## Processing: bilateral trade matrix for all sectors and all regions

### General Instructions

The goal is to obtain the bilateral trade matrix  <img src="https://render.githubusercontent.com/render/math?math=X_{ij,k}^{year}">. Region <img src="https://render.githubusercontent.com/render/math?math=i"> is the exporter region (in the columns), <img src="https://render.githubusercontent.com/render/math?math=j"> is the importer region (in the rows, under the variable "importer"), and <img src="https://render.githubusercontent.com/render/math?math=k=1,...,14"> represents the sector. Each region are either US States or Countries.

### Steps and their associated files

1. File **5-1-Country_Country-Step.Rmd**. To use WIOD data to calculate <img src="https://render.githubusercontent.com/render/math?math=X_{ij,k}^{year}"> for <img src="https://render.githubusercontent.com/render/math?math=i\notin US ,  j \notin US">, and <img src="https://render.githubusercontent.com/render/math?math=\forall k=1,...,13">. We call the output of this part <img src="https://render.githubusercontent.com/render/math?math=X_{ij,k}^{Step1}">.
2. File **5-2-State_State_CFS-Step.Rmd**. To use CFS plus proportionality to calculate <img src="https://render.githubusercontent.com/render/math?math=X_{ij,k}^{year}"> for <img src="https://render.githubusercontent.com/render/math?math=i\in US ,  j \in US">,  <img src="https://render.githubusercontent.com/render/math?math=\forall k=1,...,12,14">.  We call the output of this part <img src="https://render.githubusercontent.com/render/math?math=X_{ij,k}^{Step2}">
3. File **5-3-State_Country-Step.Rmd**. We calculate <img src="https://render.githubusercontent.com/render/math?math=X_{ij,k}^{year}$ for $i\in US,  j \notin US"> (exports from each State to each country) and <img src="https://render.githubusercontent.com/render/math?math=X_{ij,k}^{year}"> for <img src="https://render.githubusercontent.com/render/math?math=i\in US,  j \notin US"> (exports from each State to each country) and <img src="https://render.githubusercontent.com/render/math?math=i\notin US, j \in US"> (imports from each country to each State), and <img src="https://render.githubusercontent.com/render/math?math=\forall k=1,...,12,14">.  We call the output of this part <img src="https://render.githubusercontent.com/render/math?math=X_{ij,k}^{Step3}">
4. File **5-4-PuttingAllTogether.Rmd**. Puts together the previous three steps for <img src="https://render.githubusercontent.com/render/math?math=\forall k=1,...,12,14"> with sector <img src="https://render.githubusercontent.com/render/math?math=\forall k=13"> (services) that we calculate using the gravity approach. This gives us the final matrix <img src="https://render.githubusercontent.com/render/math?math=X_{ij,k}^{year}">. 

After all are completed, the final output is an excel sheet with elements <img src="https://render.githubusercontent.com/render/math?math=X_{ij,k}^{year}  \forall i,j,k, year">.  The file structure has the receiver regions in rows and sender regions in columns. The matrix has dimensions <img src="https://render.githubusercontent.com/render/math?math=87\cdot 13 \times 87">, where 87 is the sum of 50 US States and 37 countries.
