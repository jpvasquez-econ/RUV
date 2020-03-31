capture log close
* Written by JP 
clear all
set more off
set linesize 150

/*
***********************************************************************************************************************************************
***  	THIS DO FILE DOES THE FOLLOWING:
***********************************************************************************************************************************************
Compiles imports and exports data from census 
*/

********************** 
***  OUTPUT FILES  ***  
**********************
global Exports_data "1-Intermediate_Processed_Data\census_exports.dta"
global Imports_data "1-Intermediate_Processed_Data\census_imports.dta"
local files "1 2 3 4 5"
local types "Exports Imports"

foreach t of local types{
foreach f of local files{
import delimited "0-Raw_Data\State-Exports-Imports\State `t' by NAICS Commodities-`f'.csv", delimiter(comma) rowrange(4) clear
rename v1 state
rename v2 naics3d
rename v3 country
rename v4 year
rename v5 `t'
capture drop v6
*ammounts in numbers instead of strings
*the problem here are the commas. One needs to remove them first
replace `t' = subinstr(`t', ",", "",.)
destring `t', replace
format `t' %16.0g
compress

tempfile `t'`f'
save ``t'`f'', replace
}
clear
set obs 1
gen empty=0
foreach f of local files{
append using ``t'`f''
}
*keeping and renaming
drop if empty==0
drop empty
keep year state naics3 country `t'
rename `t' , lower
if "`t'"=="Exports"{
rename country destination
}
if "`t'"=="Imports"{
rename country origin
}
save ${`t'_data}, replace
}
