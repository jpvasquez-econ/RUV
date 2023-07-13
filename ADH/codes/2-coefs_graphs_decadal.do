/*
"Trade with Nominal Rigidities: Understanding the unemployment and welfare effects of the China Shock" 
Rodriguez-Clare, A., Ulate, M., Vasquez, J.P.

ADH13 extension for the period 2006-2020 using 3-year pooled ACS data
Author: Alonso Venegas
Date: 18 Nov 2022
General information: Recreated econometric analysis for each year and creates coefficient graphs. Changes in emp/pop outcomes are in decadal changes.
Inputs
	1. workfile_china_RUV
Ouputs:
	1. Figures
*/
clear
macro drop _all
clear mata
set more off
set matsize 1000

* define main program
prog main

* clean data and prepare variables
data_cleaning 
* main figures, effects on outcomes
coef_graphs
* prepare model estimates
models_coefs
* main figures with model's coefs
coef_graphs_and_models

end 




***
*** create outcome variables for each year
***
prog data_cleaning
quiet{

use "temp/workfile_china_RUV.dta", clear

* this rename command help us in the loops code
rename (d_sh_empl_mfg d_sh_empl_nmfg l_sh_empl_mfg l_sh_empl_nmfg pop_cz lnchg_popworkage ) (d_sh_mfg d_sh_nmfg l_sh_mfg l_sh_nmfg pop_1664 d_sh_lnpop)
gen nmfg = empl - mfg

* gen log popcount changes for working age population
gen sh_lnpop = ln(pop_1664)*100
gen l_sh_lnpop = ln(l_popcount)*100

* here we create the outcomes as shares of the working pop
foreach var in mfg nmfg nilf unempl {
gen sh_`var' = 100*(`var'/pop_1664) 
}

* here the 10 year differences are created (l_* vars are data of 2000)
forval year = 2006/2020 {
foreach var in mfg nmfg unempl nilf lnpop {

	if `year' == 2007 {
	gen d_sh_`var'_`year' = d_sh_`var' if  yr == 2007 | yr == 2000
	}
	else {
 * Gen ten-year equivalent changes in pop shares by employment status
	gen d_sh_`var'_`year' = (10/(`year'-2000)) * (sh_`var' - l_sh_`var' ) if yr == `year'
	replace d_sh_`var'_`year' = d_sh_`var' if yr == 2000 
	}
}
}
}


***
*** define control variables for adh13 or adh21 especification
*** 

*for adh13
	
	global controls "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2"
		
end 

prog coef_graphs
***
*** create estimates for coef graphs
*** 
	cap log close
	log using "results/log/ACS_coefs_adh13"
	

quiet{

	foreach outcome in mfg nmfg nilf unempl lnpop {
	
	global estimates
	forvalues i = 2006(1)2020 {

	* here we estimate the main regressions of adh13 for each outcome
	eststo mp_2000_`i' : qui ivreg2 d_sh_`outcome'_`i' $controls (d_tradeusch_pw=d_tradeotch_pw_lag) [aw=timepwt48], cluster(statefip) 

		global b_mp_2000_`i' = _b[d_tradeusch_pw]
		global se_mp_2000_`i' = _se[d_tradeusch_pw]
		global estimates "${estimates} mp_2000_`i'"

}
 * display coefficientes for log file
	noi dis "Coefficients for `outcome' variable"
	noi esttab mp_2000_2006 mp_2000_2007 mp_2000_2008 mp_2000_2009 mp_2000_2010 mp_2000_2011 mp_2000_2012 mp_2000_2013 , ar2 nocon keep(d_tradeusch_pw)
	noi esttab mp_2000_2014 mp_2000_2015 mp_2000_2016 mp_2000_2017 mp_2000_2018 mp_2000_2019 mp_2000_2020, ar2 nocon keep(d_tradeusch_pw)


		***
		*** creates graph
		***
		
	preserve
	clear 
	local k : word count ${estimates}
	set obs `k'
	gen estimate = ""
	gen b = . // coefficient of interest
	gen se = . // se of coefficient
	local count 1

	
	foreach est in  $estimates {
		replace estimate = "`est'"		if _n == `count'
		replace b		 = ${b_`est'}	if _n == `count'
		replace se		 = ${se_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	gen ub = b + invnormal(0.975)*se // upper bound of 95% CI
	gen lb = b - invnormal(0.975)*se // lower bound of 95% CI
	gen z = substr(estimate,-4,4) // year variable
	destring z, replace
	qui sum z

	* x axis labels
		foreach x in 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 {
			local xlabline `xlabline' 20`x' `"`x'"'
		}
	global pos = ${b_mp_2000_2007} + 0.05
	local marker : display %9.3f ${b_mp_2000_2007}
	* coeffplots	
	tw	(connected b z, mcolor(navy) msymbol(O) lcolor(navy%20) lpattern(shortdash) ) ///
		(rarea lb ub z , vertical col(navy%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("") ///
		xline(2007, lpattern(dash) lcolor(red)) ///
		legend(off) xlabel(`xlabline', grid gstyle(dot)) ylab(#5,labsize(small) grid gstyle(dot) ) ///
		graphregion(fcolor(white)) text(${pos} 2007 "`marker'") note("Ten-year equivalent changes" "Regression specification: ADH${adh}" "Unit: Commuting Zone")
		
		
		graph export "results/figures/`outcome'_decadal_adh13.pdf", as(pdf) name("Graph") replace

	restore

}
}

cap log close 
capture translate "results/log/ACS_coefs_adh13.smcl" "results/log/ACS_coefs_adh13.txt", 	replace linesize(250)
capture erase "results/log/ACS_coefs_adh13.smcl"

end 

*******************************************************************************
**************************** SECOND SECTION  **********************************
********************** COMPARING MODELS AND DATA ******************************
*******************************************************************************
***
*** Prepare matilde and baseline data

prog models_coefs
preserve
	import excel "raw_data/ADHCoeffsModel.xlsx", sheet("Sheet1") firstrow clear
	keep if _n < 26
	keep year bs* mtld*
	gen adj = 10/(year-2000)
	foreach var of varlist bs* mtld* {
	replace `var' = `var'*adj
	}
	save temp/models_coefs.dta, replace
restore
end 

***
*** create estimates for coef graphs
*** 

prog coef_graphs_and_models
quiet{

	foreach outcome in mfg nmfg unempl nilf lnpop  {
	
	global estimates
	forvalues i = 2006(1)2020 {

	* here we estimate the main regressions of adh13 for each outcome
	eststo mp_2000_`i' : qui ivreg2 d_sh_`outcome'_`i' $controls (d_tradeusch_pw=d_tradeotch_pw_lag) [aw=timepwt48], cluster(statefip) 

		global b_mp_2000_`i' = _b[d_tradeusch_pw]
		global se_mp_2000_`i' = _se[d_tradeusch_pw]
		global estimates "${estimates} mp_2000_`i'"

}
 * display coefficientes for log file
	noi dis "Coefficients for `outcome' variable"
	noi esttab mp_2000_2006 mp_2000_2007 mp_2000_2008 mp_2000_2009 mp_2000_2010 mp_2000_2011 mp_2000_2012 mp_2000_2013 , ar2 nocon keep(d_tradeusch_pw)
	noi esttab mp_2000_2014 mp_2000_2015 mp_2000_2016 mp_2000_2017 mp_2000_2018 mp_2000_2019 mp_2000_2020, ar2 nocon keep(d_tradeusch_pw)


	***
	*** creates graph
	***
		
	preserve
	clear 
	local k : word count ${estimates}
	set obs `k'
	gen estimate = ""
	gen b = . // coefficient of interest
	gen se = . // se of coefficient
	local count 1

	
	foreach est in  $estimates {
		replace estimate = "`est'"		if _n == `count'
		replace b		 = ${b_`est'}	if _n == `count'
		replace se		 = ${se_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	gen ub = b + invnormal(0.975)*se // upper bound of 95% CI
	gen lb = b - invnormal(0.975)*se // lower bound of 95% CI
	gen z = substr(estimate,-4,4) // year variable
	destring z, replace
	qui sum z

	* x axis labels
		foreach x in 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 {
			local xlabline `xlabline' 20`x' `"`x'"'
		}
	global pos = ${b_mp_2000_2007} + 0.02
	local marker : display %9.3f ${b_mp_2000_2007}
	
	
	*** merge baseline and matilde lines
	gen year = 2005 + _n
	merge 1:1 year using temp/models_coefs.dta, nogen keep(3)
	
	* coeffplots	
	tw	(connected b z, mcolor(navy) msymbol(O) lcolor(navy%20) lpattern(shortdash) ) ///
		(connected bs_`outcome' z, mcolor(midgreen) lcolor(midgreen) lpattern(shortdash)) (connected mtld_`outcome' z, mcolor(black) lcolor(black) lpattern(shortdash)) (rarea lb ub z , vertical col(navy%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("") ///
		xline(2007, lpattern(dash) lcolor(red)) ///
		xlabel(`xlabline', grid gstyle(dot)) ylab(#5,labsize(small) grid gstyle(dot) ) ///
		graphregion(fcolor(white)) text(${pos} 2007 "`marker'") note("Ten-year equivalent changes" "Regression specification: ADH${adh}" "Unit: Commuting Zone") legend(row(1) order(1 "Beta" 2 "Baseline" 3 "Matilde"))
		
		graph export "$main/results/figures/`outcome'_models_coefs.pdf", as(pdf) name("Graph") replace

	restore

}
}
end
* end of dofile


*** run main
main

