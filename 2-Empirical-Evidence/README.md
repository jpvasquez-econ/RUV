*codes/1-ipums_acs.do*

 - **Goal:** 
Create a panel of employment indicators by CZ from 2006 to 2020 following the data construction from ADH (2013).
 - **Input:** 
1. `raw_data/workfile_china.dta`
2. `raw_data/ipums_2005_2021.dta`
3. `raw_data/cw_puma2000_czone.dta`
4. `raw_data/cw_puma2010_czone.dta`

 - **Output:**
1. `temp/workfile_china_RUV.dta`

*codes/2-unemp_pop.do*

 - **Goal:** 
Create a panel of employment indicators by CZ from 2006 to 2020. Using LAU and SEER data.
 - **Input:** 
1. `raw_data/us.1969_2022.singleages.adjusted.txt`
2. `raw_data/LAU/state.xlsx`
3. `raw_data/cw_cty_czone.dta`

 - **Output:**
1. `temp/unemp_pop.dta.dta`

*codes/3-coefs_graphs_decadal.do*

 - **Goal:** 
Run regressions in the spirit of ADH 21 for 2006-2020 but using the data construction and exposure measures from ADH 13.
 - **Input:** 
1. `temp/workfile_china_RUV.dta`
2. `raw_data/ToPlotwithADH2021.xlsx`

 - **Output:**
1. `results/figures/Figure_1A.png`
2. `results/figures/Figure_1B.png`
3. `results/figures/Figure_1C.png`
4. `results/figures/Figure_7A.png`
5. `results/figures/Figure_7B.png`
6. `results/figures/Figure_7C.png`
7. `results/figures/Figure_7D.png`
8. `results/figures/Figure_A1.png`

*codes/4-cps1990_rigmeasures.do*

 - **Goal:** 
Create downward nominal wage rigidity measures.
 - **Input:** 
1. `raw_data/cps_86_90.dta`
2. `raw_data/morgyear.dta`

 - **Output:**
1. `temp/cps1990_rigmeasures.dta`

*codes/5-dnwr_figures.do*

 - **Goal:** 
Create trade exposure coef graphs on outcomes with rigidity interaction.
 - **Input:** 
1. `temp/workfile_china_RUV.dta`
2. `temp/cps_rigmeasures.dta`

 - **Output:**
1. `results/figures/Figure_2A.png`
2. `results/figures/Figure_2B.png`
3. `results/figures/Figure_A2A.png`
4. `results/figures/Figure_A2B.png`
5. `results/figures/Figure_A3A.png`
6. `results/figures/Figure_A3B.png`
7. `results/figures/Figure_A4A.png`
8. `results/figures/Figure_A4B.png`
9. `results/figures/Figure_A5A.png`
10. `results/figures/Figure_A5B.png`
11. `results/figures/Figure_A6A.png`
12. `results/figures/Figure_A6B.png`
13. `results/figures/Figure_A7A.png`
14. `results/figures/Figure_A7B.png`
15. `results/figures/Figure_A8A.png`
16. `results/figures/Figure_A8B.png`

More detailed description
============================================================================================
Here we present a description of all the raw data files that we need to construct `2-Empirical-Evidence\unemp_pop\unemp_pop.dta`: our dataset for 1990-2020 unemployment and population at the CZ level.

We take the population between 15 and 65 years old for each county from the [Surveillance, Epidemiology, and End Results (SEER) Program](https://seer.cancer.gov/popdata/download.html#single).  Select `County-level Population Files -Single-year Age Groups` and download the `.gz` file for "1969-2022  
White, Black, Other" (specifically, the "All States Combined" file). That is how we get `2-Empirical-Evidence\raw_data\us.1969_2022.singleages.adjusted.txt`. 

We take the unemployment for each county
from the [Local Area Unemployment Statistics (LAUS)](https://data.bls.gov/PDQWeb/la). We select all the counties for each state (after choosing `F Counties and equivalents`), and we save them in `.xlsx` files with the name of each state (since you can only download 200 counties per selection, we had to save the Texas' counties in `Texas1.xlsx` and `Texas2.xlsx`).

To go from the county level to the CZ level, we follow David Autor and David Dorn. "The Growth of Low Skill Service Jobs and the Polarization of the U.S. Labor Market." American Economic Review, 103(5), 1553-1597, 2013. The E8 crosswalk file [here](https://www.ddorn.net/data.htm#Local%20Labor%20Market%20Geography) is `2-Empirical-Evidence\raw_data\cw_cty_czone.dta`.

-   ACS data was taken from [here](https://usa.ipums.org/usa). (**not in GitHub because it is too heavy**) We pooled the 2005-2021 ACS 1-year samples for people between 16 and 64 years of age. The name of this file is **ipums_2005_2021.dta** in the data file.
-   **workfile_china.dta:** data taken from the replication package of ADH13, from the dta folder. This file contains the data to replicate the main results of the paper.
-   David Dorn's crosswalk files from PUMAs to CZ were taken from his [webpage](https://www.ddorn.net/). The files are named **cw_puma2000_czone.dta** and **cw_puma2010_czone.dta.**
-   **CPS 1986-1990:** (file name cps_00006.dta) data taken from IPUMS CPS [webpage](https://cps.ipums.org/cps/).  (**not in GitHub because it is too heavy**) The file name is *cps_86_90.dta* The query is available in the file *cps86_90_query.txt*. We followed Yoon Joo Jo (2021) on the data processing procedures.
-   **Merged Outgoing Rotation Groups: 86-90:** these files are taken from [NBER](https://www.nber.org/research/data/current-population-survey-cps-merged-outgoing-rotation-group-earnings-data) webpage, from the "Stata dta files" link. These files are merged into the CPS to obtain the hourly wage allocation flag variable. Download morg86.dta - morg90.dta.
-   **Jo_state_level_dnwr.dta**: dataset provided by Yoon Joo Jo from her paper "Establishing downward nominal wage rigidity through cyclical changes in the wage distribution" (2022)

## DNWR and Persistence in the Employment Effects of the China Shock
We estimate the dynamic effect of the China Shock following a regression specification in the spirit of Autor et al. (2021):

$$\Delta Y_{i, t+h}=\alpha_{t}+\beta_{1 h} \Delta I P_{i, \tau}^{c u}+X_{i, t}^{\prime} \beta_{2}+\varepsilon_{i, t+h} \tag{1}$$

where $\Delta Y_{i, t+h}$ is a vector of ten-year equivalent changes in outcome $Y$ for $\mathrm{CZ} i$ between 1990 and 2000 stacked with the changes in the same outcome between years 2000 and $2000+h$, for $h=1, \ldots, 20$. The term $I P_{i, \tau}^{c u}$ is the growth in Chinese import competition in the $\tau$ intervals 1990-2000 and 2000-2007, respectively (which, as in Autor et al. (2021), we keep fixed regardless of $h$ ).

We use the American Community Survey (ACS) for employment data, which is processed in our first script (and the second script uses an alternative construction of the unemployment-to population ratio, based on BLS county-level unemployment data and SEER working-age population data). We use the exact import exposure definition in ADH. We use the same controls $X_{i, t}^{\prime}$ as in ADH , which we take from ADH's replication file.

The third script creates the outcome variables and estimates one regression per year using equation $(1)$ for $h=6, \ldots, 20$, implementing the same two-stage least squares strategy as in ADH. The third script also plots the coefficient estimates (with respect to $h$); in the case of Figure 7, it also plots the effects in our model when the China shock lasts between 2001 and 2011, and the effects in our baseline model when the China shock lasts between 2001 and 2007.

## Cross-sectional Evidence for DNWR in the Adjustment to the China Shock
We borrow measures of DNWR from the empirical macro literature (e.g., Jo, 2022; Jo and Zubairy, 2023) and show that regions (CZs or States) with more stringent preshock measures of DNWR experienced significantly higher unemployment effects from the China Shock. To do so, we enrich the regression specification in equation (1) to add a differential effect depending on the degree of DNWR:
$$\Delta U_{i, t+h}=\gamma_{t}+\beta_{1, h} \Delta I P_{i, \tau}^{c u}+\beta_{2, h} \operatorname{Rig}_{s(i), \tau}+\beta_{3, h} \operatorname{Rig}_{s(i), \tau} \times \Delta I P_{i, \tau}^{c u}+X_{i, t}^{\prime} \beta_{4}+\varepsilon_{i, t+h} \tag{2}$$
## Codes

-   **1-ipums_acs.do** This dofile takes as an input the pooled 2005-2021 ACS 1-year samples, subsets 3-year samples, creates intermediate variables, and then merges the information to ADH2013's dataset workfile_china.dta.

-   **2-coef_graphs_decadal.do:** This code creates the outcome variables for manufacturing, non-manufacturing, nilf, and unemployment working population ratios. It then creates the coefficient graphs (figure 1 of technote1.pdf) for the period from 2006 to 2020. Outcome changes are in a ten-year equivalent form.

-   **3-cps1990_rigmeasures.do:** creates year-over-year wage change rigidity measures from the CPS 1986-1990 database following Joo-Jo,Y.(2022)

-   **4-yjj_rigidity_measures.do:** creates year-over-year wage changes rigidity measures from the CPS database of Joo-Jo,Y.(2022). Variables were constructed using the period from 1997 to 2000.

-   **5-dnwr_figures.do:** creates and saves the figures for the rigidity measures and local CPI coefficient graphs.

-   **6-dnwr_tables.do:** creates and saves the coefficent tables of the rigidity measures and local CPI regressions. 

-   **subfile_ind1990dd:** This dofile was taken from David Dorn's data [webpage](https://www.ddorn.net/data.htm). It recodes the ind1990 variable into ind1990dd. This crosswalk code helps replicate the classification of employment into manufacture and non-manufacture.

Note: Raw data not in GitHub
============================================================================================

The raw-data files that were not stored in the GitHub repository can be accessed [here](https://www.dropbox.com/scl/fo/82behprekhrbmlcw60mbr/h?rlkey=040evytauyt2pah44xo1q1pcq&e=1&dl=0). These files are the following:

1) For script 1: `raw_data/ipums_2005_2021.dta` was too heavy to be uploaded. However, a codebook file is available in `raw_data/ipums_2005_2021_query.txt`. This document contains the query requested from the IPUMS USA webpage. A log-in is necessary to download the data. After an account is created, data can be downloaded from the "Select Data"->"Select samples"" window. Tick on all ACS files (we use 1% sample)
2) For script 2: `raw_data/us.1969_2022.singleages.adjusted.txt` was too heavy to be uploaded. However, we explain in the raw data ReadMe file how to download it.
3) 