Here we present a description of all the raw data files that we need to construct `2-Empirical-Evidence\unemp_pop\unemp_pop.dta`: our dataset for 1990-2020 unemployment and population at the CZ level.

We take the population between 15 and 65 years old for each county from the [Surveillance, Epidemiology, and End Results (SEER) Program](https://seer.cancer.gov/popdata/download.html#single).  Select `County-level Population Files -Single-year Age Groups` and download the `.gz` file for "1969-2022  
White, Black, Other" (specifically, the "All States Combined" file). That is how we get `2-Empirical-Evidence\raw_data\us.1969_2022.singleages.adjusted.txt`. 

We take the unemployment for each county
from the [Local Area Unemployment Statistics (LAUS)](https://data.bls.gov/PDQWeb/la). We select all the counties for each state (after choosing `F Counties and equivalents`), and we save them in `.xlsx` files with the name of each state (since you can only download 200 counties per selection, we had to save the Texas' counties in `Texas1.xlsx` and `Texas2.xlsx`).

To go from the county level to the CZ level, we follow David Autor and David Dorn. "The Growth of Low Skill Service Jobs and the Polarization of the U.S. Labor Market." American Economic Review, 103(5), 1553-1597, 2013. The E8 crosswalk file [here](https://www.ddorn.net/data.htm#Local%20Labor%20Market%20Geography) is `2-Empirical-Evidence\raw_data\cw_cty_czone.dta`.
