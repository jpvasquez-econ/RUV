/*
Append CBP datasets

In this code, we construct employment shares by sector-state using
 CBP datasets from Dorn's website [F1]

Output files: 
1. data/2-final_data/emp_shares.dta Clean file with state, sector and 
employment.

*/
clear
* Change directory
cap cd "../data/0-raw_data/"

*getting statefip-CZ
use workfile_china.dta, clear
collapse t2, by(statefip czone)
drop t2 
tempfile cz
save `cz', replace

* use [F1] file
use cbp_czone_merged.dta, clear
merge m:1 cz using `cz'
drop _m
collapse (sum) emp, by(statefip sic87dd year)
replace year=1980 if year==1988
replace year=1990 if year==1991
replace year=2000 if year==1999
replace year=2010 if year==2007
drop if year==2011

* Generate share employment variables
* Total employment by state and year
bysort year statefip: egen double l_st_yremp = total(emp)

* Employment by sector and year
bysort year sic87dd: egen double l_us_sectemp = total(emp)

* calculate employment share in the state 
gen double emp_share=emp / l_st_yremp 

* Calculate share
gen double l_sh_ipw = emp_share / l_us_sectemp

* Create lagged share for instrument
sort statefip sic87dd year
egen double group=group(statefip sic87dd)
xtset group year, y   delta(10)
gen double l1_sh_ipw = l.l_sh_ipw

* Keep variables of interest
keep statefip sic87dd l_sh_ipw l1_sh_ipw year
compress 

* Save dataset
save ../2-final_data/emp_shares.dta, replace

