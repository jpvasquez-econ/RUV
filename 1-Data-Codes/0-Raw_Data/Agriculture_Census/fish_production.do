***********************************************************
* COMPILING DATA FROM FISH PRODUCTION
***********************************************************
clear
import excel "fish_raw.xlsx", sheet("all") firstrow
*
* YEARLY DATA
*
forvalue i=2000/2007{
preserve
keep name_`i' value_`i'
rename name_`i' iso_o
rename value_`i' fish_prod`i'
destring fish, replace force
gen year`i'=`i'
collapse (sum) fish, by(year iso_o)
tempfile file`i'
save `file`i'', replace
restore
}
*
* MERGING EACH YEAR
* 
use `file2000', clear
forvalue i=2001/2007{
merge 1:1 iso_o using `file`i''
drop _m 
} 
*
* DROPPING UNNECESSARY OBSERVATIONS
*
drop if strpos(iso_o, ":") > 0
drop if strpos(iso_o, "Total") > 0
* renaming
replace iso_o="Florida" if strpos(iso_o, "Florida") > 0
collapse (sum) fish* (mean) year* , by(iso_o)
replace iso_o = subinstr(iso_o, " ", "", .)
*indiana has zero in all years anyway
drop if iso_o=="Indiana"
*
* COMPLETING THE LIST OF US STATES
*
preserve
cd ..
import excel "regions.xlsx", sheet("Sheet1") firstrow clear
keep if status=="state"
drop number
rename region iso_o
tempfile states
save `states', replace
restore
*merging 
merge 1:1 iso_o using `states'
*checking that we find 50 states
assert _N==50
drop status
drop _m
*
* RESHAPING
*
drop year*
reshape long fish_prod , i(iso_o) j(year)
replace fish=0 if fish==.
sort year iso_o
*
* EXPORTING TO CSV
*
export delimited using "Agriculture_Census\data_fish.csv", replace
