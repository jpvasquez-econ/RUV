clear all
set more off
****
**** CODE FOR THE DISCUSSION OF COSTINOT ET AL
****

*** INPUT FILES 
global sector_exposure ""/Users/jpvasquez/Dropbox/0-mycomputer/mydocuments/0-LSE/0-Research/NK_trade/JP/Data_Construction/RUV/1-Data-Codes/1-Intermediate_Processed_Data/individual_exposure.xlsx""
global welfare ""/Users/jpvasquez/Dropbox/0-mycomputer/mydocuments/0-LSE/0-Research/NK_trade/JP/Data_Construction/Para Mau/WelfareStaSec2.xlsx""
global ADH_exposure_renorm ""/Users/jpvasquez/Dropbox/0-mycomputer/mydocuments/0-LSE/0-Research/NK_trade/JP/Data_Construction/Para Mau/NXExposure.xlsx""
global ADH_exposure ""/Users/jpvasquez/Dropbox/0-mycomputer/mydocuments/0-LSE/0-Research/NK_trade/JP/Data_Construction/Para Mau/exposures.xlsx""



******************
*import exposure 
******************
import excel ${ADH_exposure}, sheet("Sheet1") firstrow clear
summ ADH_EXP_pred_nocons
global exp_mean=`r(mean)'
replace ADH_EXP_pred_nocons=ADH_EXP_pred_nocons * 2.63 / ${exp_mean}
summ ADH_EXP_pred_nocons

*exposure renorm
import excel ${ADH_exposure_renorm}, sheet("Sheet1") firstrow clear
replace State=lower(State)
tempfile exp 
save `exp', replace

******************
*import welfare
******************
import excel ${welfare}, sheet("Sheet1") cellrange(A2:M52) firstrow clear
replace State=lower(State)
*renaming 
local i = 1
foreach v in B C D E F G H I J K L M {
	rename `v' sector_`i'
	local i = `i'+1
}
*reshaping
forvalue i = 1/12{
	preserve
	keep State sector_`i'
	rename sector welfare
	gen sector=`i'
	tempfile sector_`i'
	save `sector_`i'', replace 
	restore
}
clear 
forvalue i = 1/12{
	append using `sector_`i''
}

*merge ADH exposure 
merge m:1 State using `exp'
assert _m==3
drop _m 
tempfile exp 
replace State = subinstr(State, " ", "", .)
save `exp', replace

******************************
*import individual expososure 
******************************
import excel ${sector_exposure}, sheet("Sheet1") firstrow clear
bys state: egen emp_sec=total(employ)
egen emp_usa=total(employ)
bys sector: gen dup=cond(_N==1,0,_n)
rename exposure_nocons sect_state_exp
rename state State
keep State sector sect_exp sect_state_exp emp_usa emp_sec
replace sect_state_exp= emp_usa / emp_sec * sect_state_exp * 2.63 /${exp_mean} 
replace sect_exp=  sect_exp * 2.63 /${exp_mean}
*merging back 
merge 1:m State sector using `exp'
keep sector sect_exp sect_state_exp State welfare ADHrenorm
rename welfare welfare_change

******************************
*Regressions 
******************************
label var sect_exp "Sector-Level Exposure"
label var ADHrenorm "ADH State-Level Exposure"
label var sect_state_exp "Sector-State-Level Exposure"
*replace ADHrenorm = ADHrenorm 
gen interaction=sect_exp * ADHrenorm
label var interaction "Interaction"
estimates clear
reg welfare ADHrenorm
estimates store reg_1
reg welfare sect_exp
estimates store reg_2 
reg welfare ADHrenorm sect_exp
estimates store reg_3
reg welfare sect_exp interaction
estimates store reg_4
reg welfare interaction
estimates store reg_5
reg welfare ADHrenorm sect_exp interaction
estimates store reg_6


esttab  reg_*  ,  ///
 star(* 0.10 ** 0.05 *** 0.01) varwidth(30) ///
 cells("b(fmt(3) label($\beta$) star )" "se(par fmt(3) label((SE)) )" ) ///
	stats( N , fmt(a2) labels("\# Observations"))   ///
  alignment(c) ///
 replace noconstant label nodepvar collabels(none) 	type 
