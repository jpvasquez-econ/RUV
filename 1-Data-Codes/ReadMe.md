Summary and codes to run
===========================================================================================

*1-Data-Codes/1-WIOD_VA_shares_io_shares_distances.Rmd*

 - **Goal:** 
1) Calculate bilateral trade flows between countries for all sectors.
2) Calculate the share of value-added for each sector in each country
3) Calculate the input-output matrix shares for each country. 
4) Calculate the distances between all regions.
5) Calculate the distance elasticity and own dummy coefficients for trade flows in services and agriculture.
 - **Source:** `1-Data-Codes/0-Raw_Data`
 - **Outputs:** `1-Data-Codes/1-Intermediate_Processed_Data` and `1-Data-Codes/2-Final_Data`

*1-Data-Codes/2-State_country.Rmd*

 - **Goal:** Calculate state-country bilateral flows for all sectors except services. 
- **Source:** `1-Data-Codes/0-Raw_Data`
and `1-Data-Codes/1-Intermediate_Processed_Data` 
 - **Outputs:** 
`1-Data-Codes/1-Intermediate_Processed_Data` 

*1-Data-Codes/3-State_state.Rmd*

 - **Goal:** Calculate state-state bilateral flows for all sectors except services and agriculture. 
 - **Source:** `1-Data-Codes/0-Raw_Data`
and `1-Data-Codes/1-Intermediate_Processed_Data` 
 - **Output:** `1-Data-Codes/1-Intermediate_Processed_Data` 

*1-Data-Codes/4-Gravity_services.Rmd*

 - **Goal:** Calculate state-state and state-country bilateral flows for services using a gravity system approach. 
 - **Source:** `1-Data-Codes/0-Raw_Data`
and `1-Data-Codes/1-Intermediate_Processed_Data` 
 - **Output:** `1-Data-Codes/1-Intermediate_Processed_Data` 

*1-Data-Codes/5-Gravity_agriculture.Rmd*

 - **Goal:** Calculate state-state bilateral flows for agriculture using a gravity system approach. 
 - **Source:** `1-Data-Codes/0-Raw_Data`
and `1-Data-Codes/1-Intermediate_Processed_Data` 
 - **Output:** `1-Data-Codes/1-Intermediate_Processed_Data` 

 *1-Data-Codes/6-Matrices_VA_shares_states.Rmd*

 - **Goal:** 
1) Combine the results of the previous 5 scripts to obtain the final matrix of bilateral flows (for all sectors and regions) for the years 2000-2007.
2) Calculate the share of value added in gross output for each US state and sector.
 - **Source:** `1-Data-Codes/0-Raw_Data`
and `1-Data-Codes/1-Intermediate_Processed_Data`
 - **Output:** `1-Data-Codes/1-Intermediate_Processed_Data` and `1-Data-Codes/2-Final_Data`

 *1-Data-Codes/7-Exposure.Rmd*

 - **Goal:** 
1) Calculate employment levels by state-sector for the year 2000 using BLS and CENSUS.
2) Calculate the 2000-2007 change in imports from China to the US and other advanced economies to run a linear regression using the change of sector US imports from China as the dependent variable and the change of sector advanced economies' imports from China as the independent variable. 
3) Compute the exposure measures of equation (16) from the manuscript.
 - **Source:** `1-Data-Codes/0-Raw_Data`
and `1-Data-Codes/1-Intermediate_Processed_Data`
 - **Output:** `1-Data-Codes/1-Intermediate_Processed_Data` and `1-Data-Codes/2-Final_Data`

*1-Data-Codes/8-Employment_1999_2000.Rmd*

 - **Goal:** 
1) Compute the employment level for each state and sector in 2000 using CBS data.
2) Compute the employment level for each state and sector in 2000 and 1999 using BLS data.
3) Compute the employment level for each country and sector in 1999 and year 2000 using ILO and SEA data.
4) Combine the previous outputs and apply proportionality to ensure consistency with WIOD SEA.
 - **Source:** `1-Data-Codes/0-Raw_Data`
 - **Output:** `1-Data-Codes/1-Intermediate_Processed_Data`

*1-Data-Codes/9-Migration_matrix.Rmd*

 - **Goal:** 
1) Compute ACS total state-to-state migration movements (knowing the sector of destination, but not the sector of origin) by year for 1999-2001.
2) Compute IRS total state-to-state migration movements (not knowing the sector of origin nor the sector of destination) for 1999.
3) Compute CPS total state-to-state migration movements (knowing both the sector of origin and the sector of destination) by year for 1999-2001. 
4) Combine the data from the previous three steps to compute our final sector-state to-sector-state mobility flows. Then, we calculate the corresponding mobility sharesmigration and a case without migration (that is, not allowing state-to- in a case with state movements, just allowing sector reallocation).
 - **Source:** `1-Data-Codes/0-Raw_Data`
 - **Output:** `1-Data-Codes/1-Intermediate_Processed_Data` and `1-Data-Codes/2-Final_Data`

More detailed description
============================================================================================

## Input-output coefficients and value-added shares (for countries)

The first script calculates the input-output matrix for countries. Defining $\alpha_{j,ks}$ for region $j$ as the share of purchases of sector $s$ that come from sector $k$ in the total purchases of sector $s$:

$$
\alpha_{j,ks}=\dfrac{\sum_{i}X_{ij,ks}}{\sum_{r}\sum_{i}X_{ij,rs}}=\dfrac{X_{j,ks}}{\sum_{r}X_{j,rs}}
$$
This script also calculates the share of value-added (mapped in the model to the labor share) for each country, each sector, and each year using data from WIOD.In particular, 
$$Labor \; share = \frac{VA_{i,k}}{R_{i,k}}$$
where $R_{i,k}$ denotes total revenue in sector $k$ of country $i$. 

## Bilateral trade flows

Finally, the first script begins the necessary steps to construct a matrix of bilateral trade flows. Specifically, it calculates the bilateral trade flows ($X_{ij,k}$) between countries for all sectors directly from WIOD data.

However, for bilateral flows that involve states, there are region-sector combinations that we can not observe directly from the data. For those combinations, we use (in later scripts) a gravity system approach to derive the corresponding transactions. In particular, the "problematic" sectors are agriculture and services. Hence, the last thing that the first script does is to calculate the distance elasticity and own-dummy coefficients for trade flows in services and agriculture between countries (including the US) estimating:
$$
\ln X{ij,t}=\lambda_t + \delta_{i}^{o}+\delta_{j}^{d}+\beta_{0}\iota_{ij}+\beta_{1}\ln dist_{ij}+\xi_{ij,t}
$$
where $\lambda_t$ is a time fixed effect, $\delta_{i}^{o}$ is an origin fixed effect, $\delta_{j}^{d}$ is a destination fixed effect, and $\iota_{ij}$ is an indicator variable equal to 1 if $i=j$, and zero otherwise. As usual $X_{ij,t}$ is what country $i$ sells to country $j$ in year $t$. The coefficients of interest are $\beta_0$ and $\beta_1$ that we use to construct:

$$
\tilde{\tau}_{ij}=\exp(\hat{\beta}_{0}\iota_{ij}+\hat{\beta}_{1}\ln d_{ij})
$$

After script 2 calculates state-country bilateral flows for all sectors except services, from CENSUS data (and a proportionality rule that makes state flows sum up to US flows according to WIOD), and script 3 calculates state-state bilateral flows for all sectors except services and agriculture, from CFS data (and a proportionality rule that makes state flows sum up to US flows according to WIOD). Script 4 calculates the remaining combinations for services (country-state and state-state flows) and Script 5 calculates the remaining combinations for agriculture (state-state flows), both using a gravity approach.

Specifically, from the trade resistances implied by the first script we calculate the corresponding bilateral flows using the following formula:

$$
X_{ij}=\tilde{\tau}_{ij}\tilde{\Pi}_{i}^{-1}\tilde{P}_{j}^{-1}R_{i}E_{j}
$$

where $R_{i}$ is total revenue of region $i$; $E_{j}$ is total expenditure of region $j$; and $\tilde{\Pi}_{i}$, $\tilde{P}_{j}$ are price indices that solve the gravity system (see scripts 4 and 5 for a detailed exposition of the system).

Having all the bilateral trade flows, script 6 combines them all in a single matrix.

## Value-added shares 
Finally, script 6 calculates the share of value added in gross output for each US state, for each sector (as we noted above, value-added shares for countries were already calculated in the first script).

## Exposure meassures
The calibration of the key model parameters is based on matching moments
that capture the relative effect of the China shock on labor. These moments are captured by an exposure measure that follows the one proposed by ADH and that we calculate in script 7:

$$Exposure_i \equiv \sum_{s=1}^S\frac{L_{i,s,2000}}{L_{i,2000}}\frac{\widehat{\Delta X_{C,US,s}^{2007-2000}}}{R_{US,s,2000}}$$

where $L_{i,s,2000}$ are the employment levels by state-sector for year 2000; $L_{i,2000}\equiv\sum_sL_{i,s,2000}$ (script 7 calculates $Exposure_i$ using labor shares coming from Census data without person weights, and coming from BLS data); $R_{US,s,2000}$ is total US 2000 sales by sector; and ($\widehat{\Delta X_{C,US,s}^{2007-2000}}$) are the predicted values of a linear regression (that script 7 also estimates) using the change of sector US imports from China as the dependent variable and the change of sector  advanced economies' imports from China as the independent variable.

## Employment total
Script 8 does a rather "separated" task. It computes the employment level for each state and sector in year 2000 using CBS data; the employment level for each state and sector in year 2000 and year 1999 using BLS data; and the employment level for each country and sector in year 1999 and year 2000 using ILO and SEA data. Finally, script 8 combines the previous US employment levels, and applies proportionality to ensure consistency with WIOD SEA.
## Labor flows
Finally, script 9 calculates migration flows between US states. Specifically, script 9 computes migration from state $n$ to state $i$ and sector $q$, according to ACS ($L_{ACS}^{n?,iq}$) by year for 1999-2001; migration from state $n$ to state $i$, according to IRS ($L_{IRS}^{n,i}$) for 1999; and migration from state $n$ and sector $j$ to state $i$ and sector $k$, according to CPS ($L_{CPS}^{{nj,ik}}$) by year for 1999-2001.
We combine the data from the previous three migration measures to compute our final $L^{{nj,ik}}$'s. For movements between sectors within the same state we use the following proportionality rule:

$$L^{n j, n k}=L_{I R S}^{n, n} \times \frac{L_{C P S}^{n j, n k}}{\sum_q \sum_h L_{C P S}^{n h, n q}} \quad \forall n \in U S A, \forall j, k$$

For all the other cases, we use the following proportionality rule:

$$L^{nj,ik}=\frac{L_{CPS}^{ij,ik}}{\sum_{h}L_{CPS}^{ih,ik}}\times L_{IRS}^{n,i}\times\frac{\sum_{i}L_{ACS}^{n?,ik}}{\sum_{i}\sum_{q}L_{ACS}^{n?,iq}}$$

Then we calculate the corresponding mobility shares:

$$\mu_{nj,ik}=\frac{L^{nj,ik}}{\sum_{p=1}^{N}\sum_{q=1}^{J}L^{nj,pq}}$$

We also calculate $\mu_{nj,ik}$'s for a non-migration case (that is, not allowing state to state movements, just allowing sector reallocation).

Note: Raw data not in GitHub
============================================================================================
1) For script 3: `0-Raw_Data/CFS/CF1200A24.csv`  was too heavy, so it was compressed in a .zip folder with the same name; it must be taken out of the folder to run the script.
2) For script 5: the collection of `0-Raw_Data/CENSUS_2000/PUMS5/PUMS5_` .txt files for each US state was too heavy to be uploaded. However, we explain in the raw data ReadMe file how to download these files directly from  U.S. Census Bureau's page. The same comment applies to script 8 and the collection of `0-Raw_Data/CENSUS_2000/REVISEDPUMS5/REVISEDPUMS5_` .txt files.
3) For script 9: the collection of `0-Raw_Data/ACS/20*/c2ssp**.csv` .txt files for each US state was too heavy to be uploaded. However, we explain in the raw data ReadMe file how to download these files directly from  U.S. Census Bureau's page.
4) For script 9: `0-Raw_Data/CPS/CPS_NBER/Inputs/cps_panel.dta` was too heavy to be uploaded. However, we explain in the raw data ReadMe file how to download it.
