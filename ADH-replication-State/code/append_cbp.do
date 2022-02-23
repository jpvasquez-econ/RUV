/*
Append CBP datasets

In this code, we append the CBP datasets from previous steps and calculate the 
employment shares by sector

Input files/base codes: 

1. data/1-intermediate_data/cbp*.dta Cleaned CBP datasets from previous step. 

Output files: 
1. data/2-final_data/emp_shares.dta Clean file with state, sector and 
employment.

*/
clear
* Change directory
cap cd "../data/1-intermediate_data/"

* Append files
append using `: dir . files "cbp*.dta"'

* Generate share employment variables
* Total employment by state and year
bysort year statefip: egen l_st_yremp = total(emp)

* Employment by sector and year
bysort year sic87dd: egen l_us_sectemp = total(emp)

* calculate employment share in the state 
gen emp_share=emp / l_st_yremp 

* Calculate share
gen l_sh_ipw = emp_share / l_us_sectemp

* Create lagged share for instrument
sort statefip sic87dd year
egen group=group(statefip sic87dd)
xtset group year, y   delta(10)
gen asa = l.l_sh_ipw

by statefip sic87dd (year): gen l1_sh_ipw = l_sh_ipw[_n-1]

* Drop year and create treatment variables as in ADH
drop if year == 1980
gen t2 = (year == 2000)

* Keep variables of interest
keep t2 statefip sic87dd l_sh_ipw l1_sh_ipw

* Save dataset
save ../2-final_data/emp_shares.dta, replace

