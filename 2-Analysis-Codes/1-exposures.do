capture log close
* Written by JP
clear all
set more off
set linesize 150
cd ..
/*
***********************************************************************************************************************************************
***  	THIS DO FILE DOES THE FOLLOWING:
***********************************************************************************************************************************************

1. CALCULATES THE VALUE ADDED EXPOSURE (ANALOGOUS TO ADH EXPOSURE) AND THE NET EXPORT (NX)
EXPOSURE. (also other exposure measures)

*/
********************** 
***  OUTPUT FILES  ***  
**********************
global exposures ""2-Analysis-Codes\2-Final_Data\exposures.dta""

********************** 
***  INPUT FILES   ***  
**********************
global year_=2000
global va_shares ""1-Data-Codes\2-Final_Data\va_shares_allyears.xlsx""
global bilat_trade ""1-Data-Codes\2-Final_Data\bilat_matrix_allyears.xlsx""
global instrument ""2-Analysis-Codes\1-Intermediate_Processed_Data\0-instrument.dta""
local reference "USA"
global emp_shares ""2-Analysis-Codes/1-Intermediate_Processed_Data/state_emp_share_2000.dta""
***********************************************************************************************************************************************
***********************************************************************************************************************************************
***  	1. VALUE ADDED EXPOSURE (ANALOGOUS TO ADH EXPOSURE) AND THE NET EXPORT (NX) EXPOSURE.
***********************************************************************************************************************************************
***********************************************************************************************************************************************
***********************************************************************************************************************************************
***  	VALUE ADDED AS SHARE OF SALES
***********************************************************************************************************************************************
import excel $va_shares, sheet("Sheet1") firstrow
keep if year==$year_
keep if _n<=50
drop year
ds region, not
*renaming variables
local vari `r(varlist)'
local i=1
foreach v of local vari{
rename `v' va_sh`i'
local i=`i'+1
}
gen state=_n
*keep manuf
keep region va_sh*
reshape long va_sh, i(region) j(sector)
replace region=lower(region)
egen state=group(region)
tempfile va_sh
save `va_sh', replace

***********************************************************************************************************************************************
***  	SALES
***********************************************************************************************************************************************
import excel $bilat_trade , sheet("year${year_}") firstrow clear
replace sector=sector-100
ds importer sector, not
*keep states
local vari `r(varlist)'
foreach v of local vari{
if length("`v'")==3{
drop `v'
}
}
* sales 
ds importer sector, not
local tradevars `r(varlist)'
collapse (sum) `tradevars' , by(sector)
*reshaping 
local i=1
quiet{
foreach v of local tradevars{
preserve
keep sector `v' 
rename `v' Y
gen state=`i'
gen region=lower("`v'")
tempfile state_`i'
save `state_`i'', replace
local i=`i'+1
restore
}
*appending
use `state_1', clear
forvalue i=2/50{
append using `state_`i''
}
}
***********************************************************************************************************************************************
***  	TOTAL VA PER SECTOR AND STATE
***********************************************************************************************************************************************
* VALUE ADDED
merge 1:1 sector region state using `va_sh'
asser _m==3
drop _m
***
*** NEW VARIABLES
***
gen VA_ij=va_sh*Y
bys region: egen VA_i=total(VA_ij)
bys region: egen Y_i=total(Y)
gen weight_VA=VA_ij/VA_i
*tot sales per sector
bys sector: egen Y_tot_j=total(Y)
keep if sector<=12

* IMPORT EXPOSURE (adh)
merge m:1 sector using ${instrument}
asser _m==3
drop _m
***
*** NEW VARIABLES new
***
gen VA_ij_man=va_sh*Y
bys region: egen VA_i_man=total(VA_ij)
bys region: egen Y_i_man=total(Y)
gen weight_VA_man=VA_ij_man/VA_i_man
*tot sales per sector
bys sector: egen Y_tot_j_man=total(Y)
***********************************************************************************************************************************************
***  	EXPOSURES
***********************************************************************************************************************************************
* ADH EXPOSURE (before summing across sectors)
gen ADH_EXP= weight_VA* delta_M_i/Y_tot_j
* ADH EXPOSURE (OTHERS)

gen ADH_EXP_pred_nocons= weight_VA* hat_delta_M_i_nocons/Y_tot_j
gen ADH_EXP_pred= weight_VA* hat_delta_M_i/Y_tot_j
*gen ADH_EXP_predicted_man= weight_VA_man* hat_delta_M_i/Y_tot_j_man
*gen ADH_EXP_others= weight_VA* delta_M_others/Y_tot_j

merge 1:1 region sector using $emp_shares
assert _m==3


*gen ADH_EXP_predicted_adh= share_adh* hat_delta_M_i/Y_tot_j
gen ADH_EXP_pred_bls_nocons= share_bls* hat_delta_M_i_nocons/Y_tot_j
gen ADH_EXP_pred_bls= share_bls* hat_delta_M_i/Y_tot_j

collapse (sum) ADH_EXP_pred*  , by(region) 
*reg ADH_EXP ADH_EXP_others, r
*predict ADH_EXP_predicted_adh, xb
*COMPARING 
corr ADH*
*the ADH weights could be weird because the sectors are sic4. Need to correct
*drop ADH_EXP_predicted_adh ADH_EXP_predicted_man
order region ADH_EXP_pred_nocons ADH_EXP_pred ADH_EXP_pred_bls_nocons ADH_EXP_pred_bls
save $exposures, replace
