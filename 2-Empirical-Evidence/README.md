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
2. `temp/unemp_pop.dta`
3. `raw_data/ToPlotwithADH2021.xlsx`

 - **Output:**
1. `temp/models_coefs.dta`
2. `results/figures/Figure_1A.png`
3. `results/figures/Figure_1B.png`
4. `results/figures/Figure_1C.png`
5. `results/figures/Figure_7A.png`
6. `results/figures/Figure_7B.png`
7. `results/figures/Figure_7C.png`
8. `results/figures/Figure_7D.png`
9. `results/figures/Figure_A1.png`

*codes/4-cps1990_rigmeasures.do*

 - **Goal:** 
Create downward nominal wage rigidity measures.
 - **Input:** 
1. `raw_data/cps_86_90.dta`
2. `raw_data/morgyear.dta`
3. `raw_data/Jo_state_level_dnwr.dta`

 - **Output:**
1. `temp/Jo_state_level_dnwr_proc.dta`
2. `temp/cps1990_rigmeasures.dta`
3. `temp/cps_rigmeasures.dta`

*codes/5-dnwr_figures.do*

 - **Goal:** 
Create trade exposure coefficient graphs on outcomes with rigidity interaction.
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

## DNWR and Persistence in the Employment Effects of the China Shock

We estimate the dynamic effect of the China Shock following a regression specification in the spirit of Autor et al. (2021):

$$\Delta Y_{i, t+h}=\alpha_{t}+\beta_{1 h} \Delta I P_{i, \tau}^{c u}+X_{i, t}^{\prime} \beta_{2}+\varepsilon_{i, t+h} (1)$$

where $\Delta Y_{i, t+h}$ is a vector of ten-year equivalent changes in outcome $Y$ for $\mathrm{CZ} i$ between 1990 and 2000 stacked with the changes in the same outcome between years 2000 and $2000+h$, for $h=1, \ldots, 20$. The term $I P_{i, \tau}^{c u}$ is the growth in Chinese import competition in the $\tau$ intervals 1990-2000 and 2000-2007, respectively (which, as in Autor et al. (2021), we keep fixed regardless of $h$ ).

We use the American Community Survey (ACS) for employment data, which is processed in our first script (and the second script uses an alternative construction of the unemployment-to population ratio, based on BLS county-level unemployment data and SEER working-age population data). We use the exact import exposure definition in ADH. We use the same controls $X_{i, t}^{\prime}$ as in ADH , which we take from ADH's replication file.

The third script estimates one regression per year using equation $(1)$ for $h=6, \ldots, 20$, implementing the same two-stage least squares strategy as in ADH. The third script also plots the coefficient estimates (with respect to $h$); in the case of Figure 7, it also plots the effects in our model when the China shock lasts between 2001 and 2011, and the effects in our baseline model when the China shock lasts between 2001 and 2007.

## Cross-sectional Evidence for DNWR in the Adjustment to the China Shock

We borrow measures of DNWR from the empirical macro literature (e.g., Jo, 2022; Jo and Zubairy, 2023) and show that regions (CZs or States) with more stringent pre-shock measures of DNWR experienced significantly higher unemployment effects from the China Shock. We enrich the regression specification in equation $(1)$ to add a differential effect depending on the degree of DNWR:

$$\Delta U_{i, t+h}=\gamma_{t}+\beta_{1, h} \Delta I P_{i, \tau}^{c u}+\beta_{2, h} Rig_{s(i), \tau}+\beta_{3, h} Rig_{s(i), \tau} \times \Delta I P_{i, \tau}^{c u}+X_{i, t}^{\prime} \beta_{4}+\varepsilon_{i, t+h} (2)$$


where $\Delta U_{i, t+h}$ now refers to the change in unemployment-to-population ratio in a region (CZ or state). The variable $Rig_{s(i), \tau}$ represents a state-level proxy for the DNWR present in the state $s$ to which CZ $i$ belongs.

We use two main proxies for DNWR following Jo and Zubairy (2023). The first one is based on the share of workers with negative year-over-year hourly wage changes among all workers. The second one is based on the share of individuals with negative wage changes to total individuals with nonzero wage changes. Both measures are constructed based on individual-level year-over-year wage changes from CPS data. We pool observations from 1987 to 1990 to define the rigidity shares for the 1990-2000 decade and observations from 1997 to 2000 to determine the rigidity shares post 2000. We then define $Ri g_{s(i), \tau}$ as a dummy, taking a value of one if a given state is below the mean share. Script 4 calculates the rigidity measures and script 5 estimates $(2)$ and plots the coefficients of interest.

Note 1: Raw data not in GitHub
============================================================================================

The raw-data files that were not stored in the GitHub repository can be accessed [here](https://www.dropbox.com/scl/fo/82behprekhrbmlcw60mbr/h?rlkey=040evytauyt2pah44xo1q1pcq&e=1&dl=0). These files are the following:

1) For script 1: `raw_data/ipums_2005_2021.dta` was too heavy to be uploaded. However, a code-book file is available in `raw_data/ipums_2005_2021_query.txt`. This document contains the query requested from the IPUMS USA  [webpage](https://usa.ipums.org/usa). A log-in is necessary to download the data. After an account is created, data can be downloaded from the "Select Data"->"Select samples"" window. Tick on all ACS files (we use 1% sample).
2) For script 2: `raw_data/us.1969_2022.singleages.adjusted.txt` was too heavy to be uploaded. However, we explain in the raw data ReadMe file how to download it.
3) For script 4: `raw_data/cps_86_90.dta` was too heavy to be uploaded. However, the query is available in the file `raw_data/cps_86_90_query.txt`, the data is taken from IPUMS CPS [webpage](https://cps.ipums.org/cps/).

Note 2: The script without number
============================================================================================

*codes/subfile_ind1990dd.dta* was taken from David Dorn's data [webpage](https://www.ddorn.net/data.htm). It recodes the ind1990 variable into ind1990dd. This crosswalk code helps to replicate the classification of employment into manufacture and non-manufacture.