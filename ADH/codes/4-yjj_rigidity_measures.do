************************************************************************
*		Data from Yoon Joo Jo "Establishing Downward Nominal Wage
*           Rigidity Through Cyclical Changes in the Wage Distribution" 
*                               (2022)                         
************************************************************************
* General Information
* This codes uses data providad by Ms. Yoon Joo Joo for the period 1997-2020 and creates rigidity measures
* Input: Jo_state_level_dnwr.dta
* Output: Jo_state_level_dnwr_proc.dta

clear
clear all
clear mata
set more off
set matsize 1000


global alonso = 1

if $alonso == 1 {
 global main = "C:\Users\alove\Documents\GitHub\RUV\ADH"
}  
if $alonso == 0{
 global main = ""

}

cd $main

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
		collapse (sum) N_total=dlhwn total_neg=pdlhwneg total_nonzero=nonzero, by(statefip)

****
**** creation of rigidity measures describe in ReadMe file
****
gen dnwr_yjj = 100* total_neg / N_total 
gen dnwr_nonzero_yjj = 100* total_neg / total_nonzero
gen zero = (N_total - total_nonzero)


		foreach i of varlist dnwr_yjj dnwr_nonzero_yjj {
		qui sum `i', detail
		global p50 = r(p50)
		global mean = r(mean)
		gen `i'_dmy1 = (`i' > $p50 )
		gen `i'_dmy2 = (`i' > $mean )
		}
		
****
**** save data for merging
****
drop  N_total total_nonzero total_neg zero
rename statefips statefip
gen yr = 2000

save "temp/Jo_state_level_dnwr_proc.dta", replace

*****************************end***********************************

