capture log close
* Written by JP
clear all
set more off
set linesize 150
log using 3-Log_Files\0-instrument.log, replace

/*
***********************************************************************************************************************************************
***  	THIS DO FILE DOES THE FOLLOWING:
***********************************************************************************************************************************************


1. IMPORTS WIOD DATA TO CREATE THE CHANGE IN IMPORTS FROM CHINA FOR THE US AND 
OTHER ADVANCED ECONOMIES (Australia, Germany, Denmark, Spain, Finland, and Japan \\
(New Zealand and Switzerland are not included in the WIOD).)

2. ASSIGNS SAME CORRESPONDANCES AS IN CDP, SO THAT THE SECTORS ARE EQUIVALENT AS THOSE
IN WIOD.

3. COMPUTES THE SECTOR LEVEL CHANGES IN IMPORTS FROM CHINA TO OTHER COUNTRIES. 
*/

********************** 
***  OUTPUT FILES  ***  
**********************
global instrument ""1-Intermediate_Processed_Data\0-instrument.dta""

********************** 
***  INPUT FILES   ***  
**********************
cd ../..
global wiod ""1-Data-Codes\1-Intermediate_Processed_Data\WIOD_countries.dta""


***********************************************************************************************************************************************
***********************************************************************************************************************************************
***  	1. IMPORTS WIOD DATA TO CREATE THE CHANGE IN IMPORTS FROM CHINA FOR THE US AND 
***		OTHER ADVANCED ECONOMIES (Australia, Germany, Denmark, Spain, Finland, and Japan 
***		(New Zealand and Switzerland are not included in the WIOD).) YEARS 2000 AND 2007	
***********************************************************************************************************************************************
***********************************************************************************************************************************************
** IN THE ROWS WE HAVE THE SELLERS. IN THE COLUMNS THE BUYERS
use $wiod, clear
keep if year==2000 | year==2007
keep year importer* sector value_CHN

*case of the US
local reference "USA"
local others "AUS DEU DNK ESP FIN JPN"
*** other developed countries
gen others=0
local other `others'
local n_countries= `: word count `other''
display `n_countries'

foreach v of local other{
replace others=1 if importer_c=="`v'"
}
*****
***** CHECKS
*****
distinct importer_c if other==1
assert `r(ndistinct)'==`n_countries'
*imports from China in AUS in 2000 in first manuf sector
summ value if importer_c=="AUS" & sector==1 & year==2000
local rounded=round(`r(mean)')
assert `rounded'==236
*imports from China in DNK in 2000 in seventh manuf sector
summ value if importer_c=="DNK" & sector==7 & year==2000
local rounded=round(`r(mean)')
assert `rounded'==18

***********************************************************************************************************************************************
***********************************************************************************************************************************************
***
*** 3. COMPUTES THE SECTOR LEVEL CHANGES IN IMPORTS FROM CHINA TO OTHER COUNTRIES. 
***
***********************************************************************************************************************************************
***********************************************************************************************************************************************
***********************************************************************************************************************************************
***  	IMPORT GROWTH FROM CHINA 2007-2000
***********************************************************************************************************************************************
**
** for others
**
preserve
collapse (sum) value , by(other sector year)
keep if other==1
reshape wide value, i(other sector) j(year)
*** calculating import changes
gen delta_M_others=value_CHN2007-value_CHN2000
rename value_CHN2000 M_2000_others
drop value*
tempfile delta
save `delta', replace
restore
**
** for US
**
keep if importer_c=="USA"
reshape wide value, i(importer_c sector) j(year)
*** calculating import changes
gen delta_M_i=value_CHN2007-value_CHN2000
rename value_CHN2000 M_2000
keep sector delta_M_i importer* M_2000
merge m:1 sector using `delta'
assert _m==3
drop _m

label var delta_M_others "$\Delta M$ Others"
label var delta_M_i "$\Delta M$ i"
keep importer* sector delta_M* M_2000*
keep if sector<=12
corr delta_M_i delta_M_others 
reg delta_M_i delta_M_others , r
predict hat_delta_M_i , xb
save $instrument, replace
log close
