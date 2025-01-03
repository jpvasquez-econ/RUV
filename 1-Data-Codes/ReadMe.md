Summary and codes to run
===========================================================================================

*1-Data-Codes/1-WIOD_VA_shares_io_shares_distances.Rmd*

 - **Goal:** 
1) Calculate bilateral trade flows between countries for all sectors.
2) Calculate the share of value-added for each sector in each country
3) Calculate the input-output matrix shares for each country. 
4) Calculate the distances between all regions.
5) Calculate the distance elasticity and own dummy coefficients for trade flows in services and agriculture.
 - **Input:** 
1. `0-Raw_Data/regions.csv`
2. `0-Raw_Data/sectors.csv`
3. `0-Raw_Data//Population_geography//UN_coordinates.xls`
4. `0-Raw_Data//Population_geography//Full_population.xlsx`
5. `0-Raw_Data/Fips/us_states_coordinates_counties.xlsx`
6. `0-Raw_Data/Fips/state_codes.csv`
7. `0-Raw_Data/WIOD/wiot_.xlsx`
 - **Output:**
1. `Intermediate_Processed_Data/WiodFixAgg, i,".csv`
2. `1-Intermediate_Processed_Data/wiot_full.csv`
3. `1-Intermediate_Processed_Data//WIOD_countries.csv`
4. `1-Intermediate_Processed_Data/country_country_step_.csv`
5. `1-Intermediate_Processed_Data/labor_shares_countries.csv`
6. `1-Intermediate_Processed_Data//value_added_countries", yr, ".csv`
7. `1-Intermediate_Processed_Data/io_shares.csv`
8. `2-Final_Data/io_allyears.xlsx`
9. `1-Intermediate_Processed_Data//country_coordinates.csv`
10. `1-Intermediate_Processed_Data/distances.csv`

*1-Data-Codes/2-State_country.Rmd*

 - **Goal:** Calculate state-country bilateral flows for all sectors except services. 
 - **Input:**
1. `0-Raw_Data/regions.csv`
2. `0-Raw_Data/sectors.csv`
3. `0-Raw_Data//State-Exports-Imports//State Exports by NAICS Commodities-i.csv`
4. `0-Raw_Data//State-Exports-Imports//State Imports by NAICS Commodities-i.csv`
5. `1-Intermediate_Processed_Data/country_country_step_.csv` 
 - **Output:** 
1. `1-Intermediate_Processed_Data//census_exports.csv`
2. `1-Intermediate_Processed_Data//census_imports.csv`
3. `1-Intermediate_Processed_Data/state_imports_exports.csv`
4. `1-Intermediate_Processed_Data//state_country_step_y_.csv`
5. `1-Intermediate_Processed_Data//state_country_step_e_.csv`

*1-Data-Codes/3-State_state.Rmd*

 - **Goal:** Calculate state-state bilateral flows for all sectors except services and agriculture. 
 - **Input:**
1. `0-Raw_Data/CFS/NAICS to CFS Crosswalk.xlsx`
2. `0-Raw_Data/CFS/CFS_2012_00A18_with_ann.csv`
3. `0-Raw_Data/CFS/CFS2007.xlsx`
4. `0-Raw_Data/CFS/CFS2002mine.xlsx`
5. `0-Raw_Data/CFS/CF1200A24.csv` (this file was too heavy, so it was compressed in a .zip folder with the same name; it must be taken out of the folder to run the script)
6. `0-Raw_Data/Fips/statefips.csv`
7. `0-Raw_Data/regions.csv`
8. `0-Raw_Data/sectors.csv`
9. `1-Intermediate_Processed_Data/country_country_step_.csv`
 - **Output:**
1. `1-Intermediate_Processed_Data/CFSapportionment.csv`
2. `1-Intermediate_Processed_Data/CFS_Xijk.csv`
3. `1-Intermediate_Processed_Data/state_cfs_step_.csv` 

*1-Data-Codes/4-Gravity_services.Rmd*

 - **Goal:** Calculate state-state and state-country bilateral flows for services using a gravity system approach. 
 - **Input:**
1. `0-Raw_Data/Fips/state_codes.csv`
2. `0-Raw_Data/Expenditure/SAEXP1_1997_2017_ALL_AREAS_.csv`
3. `1-Intermediate_Processed_Data/WIOD_countries.csv`
4. `0-Raw_Data/SAGDP/SAGDP2N_.csv`
5. `1-Intermediate_Processed_Data/distances.csv`
6. `0-Raw_Data/regions.csv`
7. `0-Raw_Data/sectors.csv`
8. `1-Intermediate_Processed_Data/country_country_step_.csv`
 - **Output:** 
1. `1-Intermediate_Processed_Data/state_exp_rev_services.csv`
2. `1-Intermediate_Processed_Data/data_services.csv`
3. `1-Intermediate_Processed_Data/vector_lambda_.csv`
4. `1-Intermediate_Processed_Data//matrix_B_.csv`
5. `1-Intermediate_Processed_Data//vector_solution_.csv`
6. `1-Intermediate_Processed_Data//Xij_matrix_services_.csv`

 *1-Data-Codes/5-Gravity_agriculture.Rmd*

 - **Goal:** Calculate state-state bilateral flows for agriculture using a gravity system approach. 
 - **Input:** 
1. `0-Raw_Data/regions.csv`
2. `0-Raw_Data/sectors.csv`
3. `1-Intermediate_Processed_Data//wiot_full.csv`
4. `1-Intermediate_Processed_Data/state_imports_exports.csv`
5. `1-Intermediate_Processed_Data/country_country_step_.csv`
6. `0-Raw_Data//Agriculture_Census/data_agriculture.csv`
7. `0-Raw_Data//Agriculture_Census//data_fish.csv`
8. `1-Intermediate_Processed_Data/data_services.csv`
9. `1-Intermediate_Processed_Data/state_country_step_y_.csv`
10. `1-Intermediate_Processed_Data/state_country_step_e_.csv`
11. `1-Intermediate_Processed_Data/io_shares.csv`
12. `1-Intermediate_Processed_Data/labor_shares_countries.csv`
13. `1-Intermediate_Processed_Data//state_cfs_step_.csv`
 - **Output:** 
1. `1-Intermediate_Processed_Data/data_agriculture.csv`
2. `1-Intermediate_Processed_Data/agric_mat_B_.csv`
3. `1-Intermediate_Processed_Data/agric_vec_lambda_.csv`
4. `1-Intermediate_Processed_Data//vec_agric_solution_.csv`
5. `1-Intermediate_Processed_Data//Xij_matrix_agric_.csv`

 *1-Data-Codes/6-Matrices_VA_shares_states.Rmd*

 - **Goal:** 
1) Combine the results of the previous 5 scripts to obtain the final matrix of bilateral flows (for all sectors and regions) for the years 2000-2007.
2) Calculate the share of value added in gross output for each US state and sector.
 - **Input:** 
1. `0-Raw_Data/regions.csv`
2. `0-Raw_Data/sectors.csv`
3. `1-Intermediate_Processed_Data//Xij_matrix_services_.csv`
4. `1-Intermediate_Processed_Data//Xij_matrix_agric_.csv`
5. `1-Intermediate_Processed_Data//country_country_step_.csv`
6. `1-Intermediate_Processed_Data//state_cfs_step_.csv`
7. `1-Intermediate_Processed_Data//state_country_step_e_.csv`
8. `1-Intermediate_Processed_Data//state_country_step_y_.csv`
9. `1-Intermediate_Processed_Data//value_added_countries.csv`
10. `0-Raw_Data//Labor_shares//gdp_state_.csv`
11. `0-Raw_Data//Labor_shares//taxes_state_.csv`
12. `0-Raw_Data//Labor_shares//subsidies_state_.csv`
 - **Output:** 
1. `1-Intermediate_Processed_Data//final_matrix_.csv`
2. `2-Final_Data/bilat_matrix_allyears.xlsx`
3. `1-Intermediate_Processed_Data//labor_shares_states.csv`
4. `2-Final_Data/va_shares_allyears.xlsx`

 *1-Data-Codes/7-Exposure.Rmd*

 - **Goal:** 
1) Calculate employment levels by state-sector for the year 2000 using BLS and CENSUS.
2) Calculate the 2000-2007 change in imports from China to the US and other advanced economies to run a linear regression using the change of sector US imports from China as the dependent variable and the change of sector advanced economies' imports from China as the independent variable. 
3) Compute the exposure measures of equation (16) from the manuscript.
 - **Input:**
1. `0-Raw_Data/regions.csv`
2. `0-Raw_Data/sectors.csv`
3. `0-Raw_Data/CENSUS_2000/employment_2000.xls`
4. `0-Raw_Data/CENSUS_2000/PUMS5/PUMS5_`
5. `0-Raw_Data/emp_SAEMP25S_BLS.csv`
6. `1-Intermediate_Processed_Data/WIOD_countries.csv`
7. `1-Intermediate_Processed_Data/state_emp_2000.dta`
 - **Output:** 
1. `1-Intermediate_Processed_Data/state_emp_share_2000.dta`
2. `2-Final_Data/exposures.xlsx`

*1-Data-Codes/8-Employment_1999_2000.Rmd*

 - **Goal:** 
1) Compute the employment level for each state and sector in 2000 using CBS data.
2) Compute the employment level for each state and sector in 2000 and 1999 using BLS data.
3) Compute the employment level for each country and sector in 1999 and year 2000 using ILO and SEA data.
4) Combine the previous Output and apply proportionality to ensure consistency with WIOD SEA.
 - **Input:**
1. `0-Raw_Data/sectors.csv`
2. `0-Raw_Data/regions.csv`
3. `0-Raw_Data/CENSUS_2000/REVISEDPUMS5/REVISEDPUMS5_.txt`
4. `0-Raw_Data/CENSUS_2000/employment_2000.xls`
5. `0-Raw_Data\L_1999\Sectors\sector_\1999.annual_.csv`
6. `0-Raw_Data\L_2000\Sectors\sector_\2000.annual_.csv`
7. `0-Raw_Data\staadata.xlsx`
8. `0-Raw_Data/CENSUS_2000/L_1999_2000_countries.csv`
9. `0-Raw_Data/CENSUS_2000/EAP_2WAP_SEX_AGE_RT_A-filtered-2023-11-02.csv`
10. `0-Raw_Data/CENSUS_2000/P_World unemployment rates.xlsx`
 - **Output:**
1. `2-Final_Data//L_`2000CENSUS`.csv`   
2. `2-Final_Data//L_`1999BLS`.csv`
3. `2-Final_Data//L_`2000BLS`.csv`

*1-Data-Codes/9-Migration_matrix.Rmd*

 - **Goal:** 
1) Compute ACS total state-to-state migration movements (knowing the sector of destination, but not the sector of origin) by year for 1999-2001.
2) Compute IRS total state-to-state migration movements (not knowing the sector of origin nor the sector of destination) for 1999.
3) Compute CPS total state-to-state migration movements (knowing both the sector of origin and the sector of destination) by year for 1999-2001. 
4) Combine the data from the previous three steps to compute our final sector-state to-sector-state mobility flows. Then, we calculate the corresponding mobility sharesmigration and a case without migration (that is, not allowing state-to- in a case with state movements, just allowing sector reallocation).
 - **Input:**
1. `0-Raw_Data/regions.csv`
2. `0-Raw_Data/sectors.csv`
3. `0-Raw_Data/Fips/states_fips_num.xlsx`
4. `0-Raw_Data/ACS/20*/**.csv`
5. `0-Raw_Data/IRS/1999to2000CountyMigration/1999to2000flow.dta`
6. `0-Raw_Data/CPS/CPS_NBER/Inputs/cps_panel.dta`
 - **Output:**
1. `1-Intermediate_Processed_Data//acs_temp.csv`
2. `1-Intermediate_Processed_Data/acs.csv`
3. `1-Intermediate_Processed_Data/irs.csv`
4. `1-Intermediate_Processed_Data/cps_nber_2_yearly.csv`
5. `2-Final_Data/mu_1999.xlsx`
6. `2-Final_Data/mu_1999_no_migration.xlsx`

More detailed description
============================================================================================

## Input-output coefficients and value-added shares (for countries)

The first script calculates the input-output matrix for countries. Defining $\alpha_{j,ks}$ for region $j$ as the share of purchases of sector $s$ that come from sector $k$ in the total purchases of sector $s$:

```math
\alpha_{j,ks}=\dfrac{\sum_{i}X_{ij,ks}}{\sum_{r}\sum_{i}X_{ij,rs}}=\dfrac{X_{j,ks}}{\sum_{r}X_{j,rs}}
```

This script also calculates the share of value-added (mapped in the model to the labor share) for each country, each sector, and each year using data from WIOD.In particular, 
$$Labor \; share = \frac{VA_{i,k}}{R_{i,k}}$$
where $R_{i,k}$ denotes total revenue in sector $k$ of country $i$. 

## Bilateral trade flows

Finally, the first script begins the necessary steps to construct a matrix of bilateral trade flows. Specifically, it calculates the bilateral trade flows ($X_{ij,k}$) between countries for all sectors directly from WIOD data.

However, for bilateral flows that involve states, there are region-sector combinations that we can not observe directly from the data. For those combinations, we use (in later scripts) a gravity system approach to derive the corresponding transactions. In particular, the "problematic" sectors are agriculture and services. Hence, the last thing that the first script does is to calculate the distance elasticity and own-dummy coefficients for trade flows in services and agriculture between countries (including the US) estimating:

```math
\ln X{ij,t}=\lambda_t + \delta_{i}^{o}+\delta_{j}^{d}+\beta_{0}\iota_{ij}+\beta_{1}\ln dist_{ij}+\xi_{ij,t}
```

where $\lambda_t$ is a time fixed effect, $\delta_{i}^{o}$ is an origin fixed effect, $\delta_{j}^{d}$ is a destination fixed effect, and $\iota_{ij}$ is an indicator variable equal to 1 if $i=j$, and zero otherwise. As usual $X_{ij,t}$ is what country $i$ sells to country $j$ in year $t$. The coefficients of interest are $\beta_0$ and $\beta_1$ that we use to construct:

```math
\tilde{\tau}_{ij}=\exp(\hat{\beta}_{0}\iota_{ij}+\hat{\beta}_{1}\ln d_{ij})
```

After script 2 calculates state-country bilateral flows for all sectors except services, from CENSUS data (and a proportionality rule that makes state flows sum up to US flows according to WIOD), and script 3 calculates state-state bilateral flows for all sectors except services and agriculture, from CFS data (and a proportionality rule that makes state flows sum up to US flows according to WIOD). Script 4 calculates the remaining combinations for services (country-state and state-state flows) and Script 5 calculates the remaining combinations for agriculture (state-state flows), both using a gravity approach.

Specifically, from the trade resistances implied by the first script we calculate the corresponding bilateral flows using the following formula:

```math
X_{ij}=\tilde{\tau}_{ij}\tilde{\Pi}_{i}^{-1}\tilde{P}_{j}^{-1}R_{i}E_{j}
```

where $R_{i}$ is total revenue of region $i$; $E_{j}$ is total expenditure of region $j$; and $`\tilde{\Pi}_{i}`$, $`\tilde{P}_{j}`$ are price indices that solve the gravity system (see scripts 4 and 5 for a detailed exposition of the system).

Having all the bilateral trade flows, script 6 combines them all in a single matrix.

## Value-added shares 
Finally, script 6 calculates the share of value added in gross output for each US state, for each sector (as we noted above, value-added shares for countries were already calculated in the first script).

## Exposure meassures
The calibration of the key model parameters is based on matching moments
that capture the relative effect of the China shock on labor. These moments are captured by an exposure measure that follows the one proposed by ADH and that we calculate in script 7:

```math
Exposure_i \equiv \sum_{s=1}^S\frac{L_{i,s,2000}}{L_{i,2000}}\frac{\widehat{\Delta X_{C,US,s}^{2007-2000}}}{R_{US,s,2000}}
```

where $L_{i,s,2000}$ are the employment levels by state-sector for year 2000; $L_{i,2000}\equiv\sum_sL_{i,s,2000}$ (script 7 calculates $Exposure_i$ using labor shares coming from Census data without person weights, and coming from BLS data); $R_{US,s,2000}$ is total US 2000 sales by sector; and ($\widehat{\Delta X_{C,US,s}^{2007-2000}}$) are the predicted values of a linear regression (that script 7 also estimates) using the change of sector US imports from China as the dependent variable and the change of sector  advanced economies' imports from China as the independent variable.

## Employment 
Script 8 computes the employment level for each state and sector in year 2000 using CBS data; the employment level for each state and sector in year 2000 and year 1999 using BLS data; and the employment level for each country and sector in year 1999 and year 2000 using ILO and SEA data. Finally, script 8 combines the previous US employment levels, and applies proportionality to ensure consistency with WIOD SEA.

## Labor flows
Finally, script 9 calculates migration flows between US states. Specifically, script 9 computes migration from state $n$ to state $i$ and sector $q$, according to ACS ($L_{ACS}^{n?,iq}$) by year for 1999-2001; migration from state $n$ to state $i$, according to IRS ($L_{IRS}^{n,i}$) for 1999; and migration from state $n$ and sector $j$ to state $i$ and sector $k$, according to CPS ($L_{CPS}^{{nj,ik}}$) by year for 1999-2001.
We combine the data from the previous three migration measures to compute our final $L^{{nj,ik}}$'s. For movements between sectors within the same state we use the following proportionality rule:

$$L^{n j, n k}=L_{I R S}^{n, n} \times \frac{L_{C P S}^{n j, n k}}{\sum_q \sum_h L_{C P S}^{n h, n q}} \quad \forall n \in U S A, \forall j, k$$

For all the other cases, we use the following proportionality rule:

$$L^{nj,ik}=\frac{L_{CPS}^{ij,ik}}{\sum_{h}L_{CPS}^{ih,ik}}\times L_{IRS}^{n,i}\times\frac{\sum_{i}L_{ACS}^{n?,ik}}{\sum_{i}\sum_{q}L_{ACS}^{n?,iq}}$$

Then we calculate the corresponding mobility shares:

```math
\mu_{nj,ik}=\frac{L^{nj,ik}}{\sum_{p}\sum_{q} L^{nj,pq}}
```

We also calculate $\mu_{nj,ik}$'s for a non-migration case (that is, not allowing state to state movements, just allowing sector reallocation).

Note: Raw data not in GitHub
============================================================================================

The raw-data files that were not stored in the GitHub repository can be accessed [here](https://www.dropbox.com/scl/fo/82behprekhrbmlcw60mbr/h?rlkey=040evytauyt2pah44xo1q1pcq&dl=0). These files are the following:

1) For script 3: `0-Raw_Data/CFS/CF1200A24.csv`  was too heavy, so it was compressed in a .zip folder with the same name; it must be taken out of the folder to run the script.
2) For script 5: the collection of `0-Raw_Data/CENSUS_2000/PUMS5/PUMS5_` .txt files for each US state was too heavy to be uploaded. However, we explain in the raw data ReadMe file how to download these files directly from  U.S. Census Bureau's page. The same comment applies to script 8 and the collection of `0-Raw_Data/CENSUS_2000/REVISEDPUMS5/REVISEDPUMS5_` .txt files.
3) For script 9: the collection of `0-Raw_Data/ACS/20*/c2ssp**.csv` .txt files for each US state was too heavy to be uploaded. However, we explain in the raw data ReadMe file how to download these files directly from  U.S. Census Bureau's page.
4) For script 9: `0-Raw_Data/CPS/CPS_NBER/Input/cps_panel.dta` was too heavy to be uploaded. However, we explain in the raw data ReadMe file how to download it.
