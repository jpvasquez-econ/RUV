/*

General information: this code creates a panel of employment indicators by CZ from 2006 to 2020. It follows the data construction from ADH 2013.

Inputs:
	1. raw_data/workfile_china.dta (from ADH 2013 replication package)
	2. raw_data/ipums_2005_2021.dta (from IPUMS-ACS webpage)
	3. raw_data/cw_puma2000_czone.dta (from David Dorn data webpage)
	4. raw_data/cw_puma2010_czone.dta (from David Dorn data webpage)
Outputs:
	1. temp/workfile_china_RUV.dta
*/

clear
clear all
clear mata
set more off
set matsize 1000

* This dataset has pooled ACS data from 2005 to 2021 for people with ages betweeen 16 and 64

quiet{
forval yr = 2005(1)2019 { 

use year puma perwt age classwkrd gq empstat ind1990 statefip using raw_data/ipums_2005_2021.dta, clear
global yr `yr'
global y1 = ${yr} 
global y2 = ${yr} + 1
global y3 = ${yr} + 2

keep if inlist(year,${y1},${y2},${y3}) // years  

* Run David Dorn ind1990dd recode (https://www.ddorn.net/data.htm)
qui do "codes/subfile_ind1990dd"

cap keep if age >= 16 & age <= 64
* drop unpaid family workers
drop if classwkrd == 29
* institutional group quarters
drop if gq == 3

* Define count of nilf, manuf employment, non-manuf and unemployment
gen empl = (empstat==1)
gen unempl = (empstat==2)
gen nilf = (empstat==3)

* 
* Define employment in manufacturing using ind1990dd (David Dorn Webpage, https://www.ddorn.net/data.htm, [C9] pdf file)
gen mfg = 0
replace mfg = 1 if inrange(ind1990dd,100,122) & empl == 1 //employ in manuf
replace mfg = 1 if ind1990dd == 130 & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,132,152) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,230,241) & empl == 1 //employ in manuf
replace mfg = 1 if ind1990dd == 242 & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,160,162) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,171,172) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,180,192) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,200,201) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,210,212) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,221,222) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,250,262) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,270,301) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,310,342) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,351,372) & empl == 1 //employ in manuf
replace mfg = 1 if inrange(ind1990dd,390,392) & empl == 1 //employ in manuf


* Define PUMA codes for merging with PUMA-to-CZ crosswalk
* Check https://www.ddorn.net/data.htm, [E5] and [E6] ReadMe files on the crosswalk implementation and reweighting
	
	if ${y3} <= 2011 {
	
		rename statefip st
		label val st
		tostring puma st, replace
		gen length = length(puma)
		replace puma = "0" + puma if length == 3
		gen puma2000 = st + puma
		destring puma2000, replace
		joinby puma2000 using raw_data/cw_puma2000_czone.dta
		
	}
	
	if ${y3} == 2012 | ${y3} == 2013 {
	
		rename statefip st
		label val st
		tostring puma st, replace
		gen length = length(puma)
		replace puma = "0" + puma if length == 3
		gen puma2000 = st + puma if year < 2012
		replace puma = "0" + puma if length == 3
		replace puma = "0" + puma if length == 4
		gen puma2010 = st + puma if year >= 2012
		destring puma2000 puma2010, replace
		
		joinby puma2000 using raw_data/cw_puma2000_czone.dta, unm(master) _merge(m2)
		joinby puma2010 using raw_data/cw_puma2010_czone.dta, unm(master) _merge(m1) update
	
		
	}
	
	if ${y3} >= 2014 {
	
		rename statefip st
		label val st
		tostring puma st, replace
		gen length = length(puma)
		replace puma = "00" + puma if length == 3
		replace puma = "0" + puma if length == 4
		gen puma2010 = st + puma
		destring puma2010, replace
		joinby puma2010 using raw_data/cw_puma2010_czone.dta
		
	}
	
	qui describe
	dis "Obs for year ${y2}: `r(N)'"

	* multiply sample weight (perwt) by afactor to map from PUMA's to CZ
	
	gen weight = perwt * afactor 
	
	* population by czone
	bys czone: egen pop_cz = sum(weight) 

tempfile temp
preserve
gcollapse (mean) pop_cz, by(czone)
save `temp', replace
restore

***
*** collapse by CZ
***	

  gcollapse (sum) mfg nilf empl unempl [iw=weight] , by(czone)
  merge 1:1 czone using `temp', nogen
  

* Gen variable of year for merge and save temp file
gen yr = ${y2}
tempfile temp
* save temp file to merge with ADH2013 dataset
save `temp', replace

*************************************************************************
****
**** Merging workfile_china (from ADH13 replication package) with new ACS data
**** from 2006-2020
****
*************************************************************************
	noi dis "Merging ${y2} data to workfile_china dataset"
	if ${y3} == 2007 {

	use "raw_data/workfile_china.dta", clear
	* we expand the 2000-2007 period to 15 rows to crete a panel from 2006 to 2020
	expand 15 if yr == 2000
	bys czone (yr): gen obs = _n
	qui sum obs
	
	* here we built the year observations
	global tag ${y2}
		foreach i of num  2/`r(max)' {
			replace yr = ${tag} if obs == `i'
			global tag =  ${tag} + 1
				}
	* replace base year to 2000 (for simplicity in code)			
	replace yr = 2000 if yr == 1990
	* update information for first year
	merge m:1 czone yr using `temp', nogen keep(1 3)
}
	else {
* Merge and update outcome variables for other years (2007-2020)
		  *sleep 1000
		  use "temp/workfile_china_RUV.dta", clear
		  merge m:1 czone yr using `temp', update
		  drop if _m == 2
		  drop _m
		}
 
save "temp/workfile_china_RUV.dta", replace

}

noi dis "Done!"
}


*******************************************************************************
*end 
*******************************************************************************
