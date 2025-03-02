/*
General information: Data cleaning for CPS 86-90 and rigidity measures 
Inputs
	1. raw_data/cps_86_90.dta (from CPS webpage)
	2. raw_data/morg`i'.dta (from NBER webpage)
	3. raw_data/Jo_state_level_dnwr.dta (provided by Yoon Joo Jo)
Ouputs:
	1. temp/Jo_state_level_dnwr_proc.dta
	2. temp/cps1990_rigmeasures.dta
	3. temp/cps_rigmeasures.dta
*/


clear
cd "D:\RUV\2-Empirical-Evidence"
set more off
ssc install ivreg2
***
*** CPS 86-90
*** 
forvalue i = 86/90 {
	 global i `i'
     tempfile temp`i'	 
	 
	 * IPUMS-CPS (16 or older) 1986-1990
	 use raw_data/cps_86_90, clear
	 rename (month hrhhid) (intmonth hhid)
	 * we drop people not in the universe of hourly wages
	 drop if inlist(hourwage,999.99) 
	 keep if year == 19${i}
	 * we merge the Outgoing Rotation Groups of CPS to obtain allocation flag of hourly wages (following Joo-Jo, Y.(2022))
	 merge 1:m year intmont hhid lineno using "raw_data/morg${i}", update keepusing(I25c I25b)  keep(3)
	 * we drop imputed wages and paid by hour dummy 
	 keep if I25c == 0 & I25b == 0
	 * save temp file by year
	 save `temp`i'', replace
	 }

	* Here we append each year to generate the panel data 
	use `temp86', clear
	forval i = 87/90 {
	append using `temp`i''
	}

    * eliminates duplicates in terms of all variables
	duplicates drop
	drop if hourwage == 99.99
	* we keep cpsidp (individuals) with more than one observation in the panel
	bys cpsidp: gen N = _N
	drop if N == 1
	* we set the panel data and construct the wage changes
	xtset cpsidp year
	gen delta = hourwage - l.hourwage
	* count of zero, positive and negative wage changes 
	gen zero = (delta == 0)
	gen tot = (delta != .)
	gen neg = (delta < 0)
	gen pos = (delta > 0)
	replace pos = 0 if delta == .
	drop if delta == .
	
	collapse (sum) zero total_pos = pos total_neg = neg N_total = tot [iw=earnwt], by(statefip)

****
**** creation of rigidity measures described in ReadMe file
****
gen total_nonzero = total_pos + total_neg
gen dnwr_yjj = 100 *total_neg / N_total
gen dnwr_nonzero_yjj = 100 * total_neg / total_nonzero

		foreach i of varlist dnwr_yjj dnwr_nonzero_yjj  {
		qui sum `i', detail
		global p50 = r(p50)
		global mean = r(mean)
		gen `i'_dmy1 = (`i' > $p50 )
		gen `i'_dmy2 = (`i' > $mean )
		}
		
cap drop zero total_pos total_nonzero total_neg total_nonzero N_total
gen yr = 1990 // for merge
drop if statefip == 2 | statefip == 15 | statefip == 11 //dropping Alaska and Hawaii and DC (not in ADH's data)
save "temp/cps1990_rigmeasures", replace
clear 
	
	
	
************************************************************************
*		Data from Yoon Joo Jo "Establishing Downward Nominal Wage
*           Rigidity Through Cyclical Changes in the Wage Distribution" 
*                               (2022)                         
************************************************************************
* General Information
* This codes uses data provided by Yoon Joo Joo for the period 1997-2020 and creates rigidity measures
* Input: Jo_state_level_dnwr.dta
* Output: Jo_state_level_dnwr_proc.dta

clear all
use raw_data/Jo_state_level_dnwr, clear

****
**** keep data before 2000 
****
keep if year <= 2000 

****
**** total observations from percentages
****
replace pdlhwzero0 = (pdlhwzero0/100) * dlhw
replace pdlhwpos = (pdlhwpos/100) * dlhwn
replace pdlhwneg = (pdlhwneg/100) * dlhwn 
gen nonzero = pdlhwneg + pdlhwpos

****
**** wage changes (observations/nonzero/negative) and collapse by statefip code
**** 
		collapse (sum) N_total=dlhwn total_neg=pdlhwneg total_nonzero=nonzero pos = pdlhwpos, by(statefip)

****
**** creation of rigidity measures describe in ReadMe file
****
gen dnwr_yjj = 100* total_neg / N_total
gen dnwr_nonzero_yjj = 100* total_neg / total_nonzero


		foreach i of varlist dnwr_yjj dnwr_nonzero_yjj {
		qui sum `i', detail
		global p50 = r(p50)
		global mean = r(mean)
		gen `i'_dmy1 = (`i' > $p50 )
		gen `i'_dmy2 = (`i' > $mean )
		}
		
****
**** save data 
****
drop  N_total total_nonzero total_neg pos
rename statefips statefip
gen yr = 2000 // for merge
drop if statefip == 2 | statefip == 15 | statefip == 11 //dropping Alaska and Hawaii and DC (not in ADH's data)
save "temp/Jo_state_level_dnwr_proc.dta", replace

***
*** appending 
***
use "temp/cps1990_rigmeasures" , clear
append using "temp/Jo_state_level_dnwr_proc.dta"
save "temp/cps_rigmeasures.dta", replace 

