Here we present a description of all the raw data files in `2-Empirical-Evidence`.

Files taken from David Dorn's webpage
===========================================================================================
We take four files from [David Dorn's webpage](https://www.ddorn.net/data.htm#Local%20Labor%20Market%20Geography).

Script 1 uses `raw_data\workfile_china.dta`, which is taken from the replication package of David Autor, David Dorn and Gordon Hanson. "The China Syndrome: Local Labor Market Effects of Import Competition in the United States."American Economic Review, 103(6), 2121-2168, 2013. It contains the data to replicate the main results of their paper (except for Tables 1 and 2). To get it, you have to download [P3] and go to the `dta` folder.

Script 1 also uses David Dorn's crosswalk files from PUMAs to CZ. The files are named `raw_data\cw_puma2000_czone.dta` and `raw_data\cw_puma2010_czone.dta`. You have to download them from [E5] and [E6], respectively.

Finally, on script 2, to go from the county level to the CZ level, we follow David Autor and David Dorn. "The Growth of Low Skill Service Jobs and the Polarization of the U.S. Labor Market." American Economic Review, 103(5), 1553-1597, 2013. So we have to download [E8] to get `raw_data\cw_cty_czone.dta`.

ACS data
===========================================================================================
Script 1 also uses data from the American Community Surveys (ACS) from 2005 to 2021: `raw_data/ipums_2005_2021.dta`. You can download the file from [here](https://usa.ipums.org/usa) following the query in `raw_data/ipums_2005_2021_query.txt`. We pooled the 2005-2021 ACS 1-year samples for people between 16 and 64 years of age.

LAUS and SEER data
===========================================================================================
To construct our dataset for 1990-2020 unemployment and population at the CZ level, script 2 takes the population between 15 and 65 years old for each county from the [Surveillance, Epidemiology, and End Results (SEER) Program](https://seer.cancer.gov/popdata/download.html#single).  We select `County-level Population Files -Single-year Age Groups` and download the `.gz` file for "1969-2022  
White, Black, Other" (specifically, the "All States Combined" file). That is how we get `raw_data\us.1969_2022.singleages.adjusted.txt`. 

And Script 2 also takes the unemployment for each county from the [Local Area Unemployment Statistics (LAUS)](https://data.bls.gov/PDQWeb/la). We select all the counties for each state (after choosing `Counties and equivalents`), and we save them in `.xlsx` files with the name of each state (since you can only download 200 counties per selection, we had to save the Texas' counties in `Texas1.xlsx` and `Texas2.xlsx`). Those files are stored in our `raw_data\LAU` folder.

Data from the model simulations
===========================================================================================
Script 3 uses `raw_data/ToPlotwithADH2021.xlsx`. This file comes as an output from the model simulations given the calibration of the different "long" vs "short" shock.

CPS data
===========================================================================================
Script 4 uses monthly labor force micro-data from the U.S. Current Population Survey (CPS), for 1986-1990. The name of the file is `raw_data/cps_86_90.dta`, and we downloaded it from the IPUMS CPS [webpage](https://cps.ipums.org/cps/) following the query in `raw_data/cps86_90_query.txt`. On the data processing procedures, we followed Yoon J. Jo, 2021. "Establishing downward nominal wage rigidity through cyclical changes in the wage distribution," Working Papers 20211216-001, Texas A and M University, Department of Economics.

Script 4 also uses the CPS Merged Outgoing Rotation Group Earnings data for 1986-1990. We download it from [NBER](https://www.nber.org/research/data/current-population-survey-cps-merged-outgoing-rotation-group-earnings-data). Specifically, from the `Stata dta files` link, we take our `raw_data/morg86.dta` - `raw_data/morg90.dta` files. These files are merged into the CPS to obtain the hourly wage allocation flag variable.

Data provided by Yoon Joo Jo
===========================================================================================
Finally, Script 4 uses  `raw_data\Jo_state_level_dnwr.dta` for rigidity measures. This is a dataset provided by Yoon Joo Jo from her paper: Yoon J. Jo, 2021. "Establishing downward nominal wage rigidity through cyclical changes in the wage distribution," Working Papers 20211216-001, Texas A and M University, Department of Economics.

Note: Raw data not in GitHub
============================================================================================
The raw-data files that were not stored in the GitHub repository can be accessed [here](https://www.dropbox.com/scl/fo/82behprekhrbmlcw60mbr/h?rlkey=040evytauyt2pah44xo1q1pcq&e=1&dl=0). These files are the following:

1) For script 1: `raw_data/ipums_2005_2021.dta` was too heavy to be uploaded. 
2) For script 2: `raw_data/us.1969_2022.singleages.adjusted.txt` was too heavy to be uploaded. 
3) For script 4: `raw_data/ipums_2005_2021.dta` was too heavy to be uploaded. 
