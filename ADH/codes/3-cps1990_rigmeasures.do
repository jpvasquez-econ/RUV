*


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
	 global main = "RUV\ADH"
}

cd $main

forvalue i = 86/90 {

     tempfile temp`i'
	 use "raw_data/morg`i'", clear
	 destring hhid, replace
	 
	 * IPUMS-CPS (16 or older) 1986-1990
	 use raw_data/cps_86_90, clear
	 rename (month hrhhid) (intmonth hhid)
	 * we drop people not in the universe of hourly wages
	 drop if inlist(hourwage,999.99) 
	 keep if year == 19`i'
	 * we merge the Outgoing Rotation Groups of CPS to obtain allocation flag of hourly wages (following Joo-Jo, Y.(2022))
	 merge 1:m year intmont hhid lineno using "raw_data/morg`i'", update keepusing(I25c I25b) keep(3) 
	 * we drop imputed wages and paid by hour dummy 
	 keep if I25c == 0 & I25b == 0
	 tab I25c I25b
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
gen dnwr_yjj = 100 * total_neg / N_total 
gen dnwr_nonzero_yjj = 100 * total_neg / total_nonzero

		foreach i of varlist dnwr_yjj dnwr_nonzero_yjj  {
		qui sum `i', detail
		global p50 = r(p50)
		global mean = r(mean)
		gen `i'_dmy1 = (`i' > $p50 )
		gen `i'_dmy2 = (`i' > $mean )
		}
		
drop zero total_pos total_nonzero total_neg total_nonzero N_total
gen yr = 1990 // for merge

save "temp/cps1990_rigmeasures", replace
	
	
	
	
	