/*
ADH13 extension to 2006-2020 using 3-year pooled ACS data
Author: Alonso Venegas
Date: 18 Nov 2022
General information: Recreated econometric analysis for each year and creates coefficient graphs with interaction of downward wage rigidity measures. Changes in emp/pop outcomes are in decadal changes. 
Unit of analysis are define in globals: Statefip (48 obs per year x 2 periods) or Community Zones (722 obs per year x 2 periods). 
*/
program drop _all
clear
set more off
set matsize 1000


************************************************************************


************************************************************************
************************************************************************
*                           DEFINE PROGRAMS
************************************************************************
************************************************************************
program cpi_data

* PREPARE INFLATION DATA BY STATE
	use "raw_data/local_cpi_panel.dta", clear
	rename (fips_state year) (statefip yr)
	* adj factor for 10 year equivalent changes
	gen adj = 1
	replace adj = 10/(yr - 2000) if yr > 2000
	* 2000 cpi inflation
	bys statefip (yr): gen cpi2000 = cpi_final[3]
	bys statefip (yr): gen d_cpi = cpi_final - cpi_final[_n-1]
	replace d_cpi = cpi_final - cpi2000 if yr >= 2001
	replace d_cpi = d_cpi*adj
	drop if yr == 1980
	by statefip (yr): gen d_cpi1990 = d_cpi[1]
	by statefip (yr): gen d_cpi_lag = d_cpi[2]
	replace d_cpi_lag = d_cpi1990 if yr == 2000
	drop if yr == 1990
	* keep vars
	keep yr statefip d_cpi d_cpi_lag
	* above/below mean variations
	
	foreach var in d_cpi d_cpi_lag {
	forval yr = 2000(1)2015 {
	qui sum `var' if yr == `yr', det
	cap gen `var'_dmy = (`var'>`r(mean)') if yr == `yr'
	replace `var'_dmy = (`var'>`r(mean)') if yr == `yr'
	}
	}
	
	
	* merge key 
	gen year = yr
	save temp/cpi_state_4unempl, replace

end



program dnwr_figures

	foreach outcome in unempl {	
	* logfile
	cap log close
 	log using "$log"
	
	foreach rig_measure of varlist r2w dnwr_yjj_dmy1 dnwr_yjj_dmy2 dnwr_nonzero_yjj_dmy1 dnwr_nonzero_yjj_dmy2 {
	
	* create interaction with rigidity measure and trade shock
	capture drop inter_*
    capture gen inter_rigidity = (d_tradeusch_pw * `rig_measure')
    capture gen inter_rigidity_iv = (d_tradeotch_pw_lag * `rig_measure')
	
	global estimates
	global estimates2
	forvalues i = 2006(1)2020 {

	* here we estimate the main regressions of adh13 for each outcome
	eststo mp_2000_`i' : qui ivreg2 d_sh_`outcome'_`i' `rig_measure' l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* (d_tradeusch_pw inter_rigidity = d_tradeotch_pw_lag inter_rigidity_iv) [aw=timepwt48] $cluster

		global b_mp_2000_`i' = _b[d_tradeusch_pw]
		global se_mp_2000_`i' = _se[d_tradeusch_pw]
		global b_rm_2000_`i' = _b[inter_rigidity]
		global se_rm_2000_`i' = _se[inter_rigidity]
		global estimates "${estimates} mp_2000_`i'"
		global estimates2 "${estimates2} rm_2000_`i'"

}

 * display coefficientes for log file
	noi dis "Coefficients for `outcome' variable with `rig_measure' interaction"
	noi dis "${`rig_measure'}"
	noi esttab mp_2000_2006 mp_2000_2007 mp_2000_2008 mp_2000_2009 mp_2000_2010 mp_2000_2011 mp_2000_2012 mp_2000_2013 , ar2 nocon keep(d_tradeusch_pw inter_rigidity)
	noi esttab mp_2000_2014 mp_2000_2015 mp_2000_2016 mp_2000_2017 mp_2000_2018 mp_2000_2019 mp_2000_2020, ar2 nocon keep(d_tradeusch_pw inter_rigidity)
		
		***
		*** creates graph
		***
		quiet{
	preserve
	clear 
	local k : word count ${estimates}
	set obs `k'
	gen estimate = ""
	gen b = . // coefficient of trade shock
	gen se = . // se of coefficient
	gen b_rm = . //intersection
	gen se_rm = . // se of intersectino coefficient
	
	local count 1
	foreach est in  $estimates {
		replace estimate = "`est'"		if _n == `count'
		replace b		 = ${b_`est'}	if _n == `count'
		replace se		 = ${se_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	local count 1
	foreach est in $estimates2 {
		replace b_rm		 = ${b_`est'}	if _n == `count'
		replace se_rm		 = ${se_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	
	gen ub = b + invnormal(0.975)*se // upper bound of 95% CI
	gen lb = b - invnormal(0.975)*se // lower bound of 95% CI
	gen ub_rm = b_rm + invnormal(0.975)*se_rm // upper bound of 95% CI
	gen lb_rm = b_rm - invnormal(0.975)*se_rm // lower bound of 95% CI
	gen z = substr(estimate,-4,4) // year variable
	destring z, replace
	qui sum z

	* x axis labels
		foreach x in 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 {
			local xlabline `xlabline' 20`x' `"`x'"'
		}
		
	global pos = ${b_mp_2000_2007} + (${b_mp_2000_2007}/2)
	local marker : display %9.3f ${b_mp_2000_2007}
	
	
	* coeffplots	
	tw	(connected b z, mcolor(navy) msymbol(O) lcolor(navy%20) lpattern(shortdash) ) ///
		(rarea lb ub z , vertical col(navy%10)) /// 
		|| (connected b_rm z, mcolor(cranberry) msymbol (O) lcolor(red%20) lpattern(shortdash)) (rarea lb_rm ub_rm z, vertical col(red%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("") ///
		xline(2007, lpattern(dash) lcolor(red)) ///
		legend(order(1 "Trade shock" 3 "Interaction")) xlabel(`xlabline', grid gstyle(dot)) ylab(#5,labsize(small) grid gstyle(dot) ) ///
		graphregion(fcolor(white)) text(${pos} 2007 "`marker'") note("Ten-year equivalent changes" "Specification: ADH13 with rigidity measure interaction" "Unit: ${uofa}", size(*0.9)) caption("Interaction: ${`rig_measure'}", size(*0.65)) 

		
	graph export "$outputs/figures/`rig_measure'_${unit}.pdf", as(pdf) name("Graph") replace

	restore
	} //quiet

	global count = ${count} + 1
  } //rigidity measures
  
	cap log close 
	capture translate "$log.smcl" "$log.txt", 	replace linesize(250)
	capture erase "$log.smcl"
  
  
} //outcomes

end 

program cpi_figures 
	
	drop if yr > 2015
	foreach outcome in unempl {	
	* logfile
	cap log close
 	log using "$log"
	
	foreach rig_measure of varlist d_cpi d_cpi_lag d_cpi_dmy d_cpi_lag_dmy {
	
	* create interaction with rigidity measure and trade shock
	capture drop inter_*
    capture gen inter_rigidity = (d_tradeusch_pw * `rig_measure')
    capture gen inter_rigidity_iv = (d_tradeotch_pw_lag * `rig_measure')
	
	global estimates
	global estimates2
	forvalues i = 2006(1)2015 {

	* here we estimate the main regressions of adh13 for each outcome
	eststo mp_2000_`i' : qui ivreg2 d_sh_`outcome'_`i' `rig_measure' l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* (d_tradeusch_pw inter_rigidity = d_tradeotch_pw_lag inter_rigidity_iv) [aw=timepwt48] $cluster

		global b_mp_2000_`i' = _b[d_tradeusch_pw]
		global se_mp_2000_`i' = _se[d_tradeusch_pw]
		global b_rm_2000_`i' = _b[inter_rigidity]
		global se_rm_2000_`i' = _se[inter_rigidity]
		global estimates "${estimates} mp_2000_`i'"
		global estimates2 "${estimates2} rm_2000_`i'"

}

 * display coefficientes for log file
	noi dis "Coefficients for `outcome' variable with `rig_measure' interaction"
	noi dis "${`rig_measure'}"
	noi esttab mp_2000_2006 mp_2000_2007 mp_2000_2008 mp_2000_2009 mp_2000_2010 , ar2 nocon keep(d_tradeusch_pw inter_rigidity)
	noi esttab mp_2000_2011 mp_2000_2012 mp_2000_2013  mp_2000_2014 mp_2000_2015, ar2 nocon keep(d_tradeusch_pw inter_rigidity)
		
		***
		*** creates graph
		***
		quiet{
	preserve
	clear 
	local k : word count ${estimates}
	set obs `k'
	gen estimate = ""
	gen b = . // coefficient of trade shock
	gen se = . // se of coefficient
	gen b_rm = . //intersection
	gen se_rm = . // se of intersectino coefficient
	
	local count 1
	foreach est in  $estimates {
		replace estimate = "`est'"		if _n == `count'
		replace b		 = ${b_`est'}	if _n == `count'
		replace se		 = ${se_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	local count 1
	foreach est in $estimates2 {
		replace b_rm		 = ${b_`est'}	if _n == `count'
		replace se_rm		 = ${se_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	
	gen ub = b + invnormal(0.975)*se // upper bound of 95% CI
	gen lb = b - invnormal(0.975)*se // lower bound of 95% CI
	gen ub_rm = b_rm + invnormal(0.975)*se_rm // upper bound of 95% CI
	gen lb_rm = b_rm - invnormal(0.975)*se_rm // lower bound of 95% CI
	gen z = substr(estimate,-4,4) // year variable
	destring z, replace
	qui sum z

	* x axis labels
		foreach x in 06 07 08 09 10 11 12 13 14 15 {
			local xlabline `xlabline' 20`x' `"`x'"'
		}
		
	global pos = ${b_mp_2000_2007} + (${b_mp_2000_2007}/2)
	local marker : display %9.3f ${b_mp_2000_2007}
	
	
	* coeffplots	
	tw	(connected b z, mcolor(navy) msymbol(O) lcolor(navy%20) lpattern(shortdash) ) ///
		(rarea lb ub z , vertical col(navy%10)) /// 
		|| (connected b_rm z, mcolor(cranberry) msymbol (O) lcolor(red%20) lpattern(shortdash)) (rarea lb_rm ub_rm z, vertical col(red%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("") ///
		xline(2007, lpattern(dash) lcolor(red)) ///
		legend(order(1 "Trade shock" 3 "Interaction")) xlabel(`xlabline', grid gstyle(dot)) ylab(#5,labsize(small) grid gstyle(dot) ) ///
		graphregion(fcolor(white)) text(${pos} 2007 "`marker'") note("Ten-year equivalent changes" "Specification: ADH13 with CPI interaction" "Unit: ${uofa}", size(*0.9)) caption("Interaction: ${`rig_measure'}", size(*0.65)) 

		
	graph export "$outputs/figures/`rig_measure'_${unit}.pdf", as(pdf) name("Graph") replace

	restore
	} //quiet

	global count = ${count} + 1
  } //rigidity measures
  
	cap log close 
	capture translate "$log.smcl" "$log.txt", 	replace linesize(250)
	capture erase "$log.smcl"
  
  
} //outcomes

end



************************************************************************
************************************************************************
*         RUN MAIN ITERATIONS OVER CZ AND STATE LEVEL REGRESSIONS
************************************************************************
************************************************************************
* PREPARE CPI DATA
cpi_data

forval j = 1/2 {  //unit of analysis (state or CZs)

***
*** create outcome variables for each year
***
use temp/workfile_china_RUV.dta, clear

	if `j' == 1 {
	global unit "state"
	 * define some globals 
	global log "$outputs/log/unempl_dnwr_state"
	global cluster ""
	global uofa "State (N=96)"
	
	* this rename command help us in the loops code
	rename (d_sh_empl_mfg d_sh_empl_nmfg l_sh_empl_mfg l_sh_empl_nmfg) (d_sh_mfg d_sh_nmfg l_sh_mfg l_sh_nmfg)


	* 0.7 is multiplies to ten-year equivalent changes to recover original shares of 2000 and 2007
	gen popcount = (0.7)*d_popcount + l_popcount if yr > 2000
	replace popcount = d_popcount + l_popcount if yr == 2000

		bys statefip yr: egen pop_st =  sum(pop_cz)
		bys statefip yr: egen pop_st_1990_2000 = sum(l_popcount)
		bys statefip yr: egen timepwt48_st = sum(timepwt48)
		
	* recover shares for each outcome of 2000 and 2007	 
	gen unempl_007 = d_sh_unempl + l_sh_unempl if yr == 2000
	replace unempl_007 = ((0.7)*d_sh_unempl) + l_sh_unempl if yr > 2000
	replace unempl_007 = (unempl_007/100)*popcount

	* here we generate the weighted averages of states from CZs for each l_* (base period) using the l_popcount (population weights) for control variables, trade shock, and instrumental variable 
	foreach var in l_sh_unempl l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource d_tradeusch_pw d_tradeotch_pw_lag reg_midatl reg_encen reg_wncen reg_satl reg_escen reg_wscen reg_mount reg_pacif {
	bys statefip yr: egen `var'_st = sum(`var'*l_popcount)
	replace `var'_st = `var'_st/pop_st_1990_2000
	}

* collapse and keep variables of interest
	collapse (sum) unempl *_007 popcount (first) *_st, by(statefip yr)
	rename *_st *
	rename pop pop_st

* here we create the outcomes as shares of the working pop for 1990-2000 and 2000-2007 period
	
	gen sh_unempl = 100*(unempl/pop_st) 
	gen sh_unempl_007 = 100*(unempl_007/popcount)
	gen d_sh_unempl = sh_unempl_007-l_sh_unempl if yr == 2000
	replace d_sh_unempl = (10/7)*(sh_unempl_007-l_sh_unempl) if yr > 2000
	

* here the 10 year differences are created (l_* vars are data of 2000)
	forval year = 2006/2020 {

	if `year' == 2007 {
	gen d_sh_unempl_`year' = d_sh_unempl if  yr == 2007 | yr == 2000
	}
	else {
 * Gen ten-year equivalent changes in pop shares by employment status
	gen d_sh_unempl_`year' = (10/(`year'-2000)) * (sh_unempl - l_sh_unempl ) if yr == `year'
	replace d_sh_unempl_`year' = d_sh_unempl if yr == 2000 
	}
}

* crete dummy for second period
	gen t2 = (yr>2000)
	
	
	*save data for log files (tables)
	preserve
	keep if inlist(yr,2000,2007)
	drop if statefip == .
	drop d_sh_unempl
	rename d_sh_unempl_2007 d_sh_unempl
	drop d_sh_unempl_*
	save temp/state_workfile_china, replace
	restore
		

	}

	
	****				   ****
	*** CZ unit of analysis ***
	****				   ****		
	if `j' == 2 {	
	
	global unit "czs"
	*define globals
	global log "$outputs/log/unempl_dnwr_czs"
	global cluster ",cluster(statefip)"
	global uofa "Community Zone (N=1444)"
	
	***
	*** create decadal change of shares for each outcome by CZ
	***

	* this rename command help us in the loops code
	rename (d_sh_empl_mfg d_sh_empl_nmfg l_sh_empl_mfg l_sh_empl_nmfg pop_cz) (    d_sh_mfg d_sh_nmfg l_sh_mfg l_sh_nmfg pop_1664)

	* here we create the outcomes as shares of the working pop
	gen sh_unempl = 100*(unempl/pop_1664) 

	* here the 10 year differences are created (l_* vars are data of 2000)
	forval year = 2006/2020 {
		* here we replace values from ADH 2013 for year 2007
		if `year' == 2007 {
		gen d_sh_unempl_`year' = d_sh_unempl if  yr == 2007 | yr == 2000
		}
		else {
	 * Gen ten-year equivalent changes in pop shares by employment status
		gen d_sh_unempl_`year' = (10/(`year'-2000)) * (sh_unempl - l_sh_unempl ) if yr == `year'
		replace d_sh_unempl_`year' = d_sh_unempl if yr == 2000 
		} 
	} //year

	
	
} // if


*** Generate dta from excel file (right2work) 
*** from https://nrtwc.org/facts/state-right-to-work-timeline-2016/
preserve
import excel "raw_data/right2work.xlsx", sheet("Hoja1") firstrow clear
destring year_r2w, replace 
save "raw_data/right2work.dta", replace
restore


***	
*** Rigidity measures from Right-to-work and CPS
***
		rename yr year
		gen yr = 1990 if year == 2000
		replace yr = 2000 if year > 2000
		* right-to-work laws
		merge m:1 statefip using "raw_data/right2work.dta" , nogen
		* CPS rigidity measures for 2000 from Joo-Jo,Y.(2022)
		merge m:1 statefip yr using "temp/Jo_state_level_dnwr_proc.dta", nogen keep(1 3)
		* CPS rigidity measures for 1990 (constructed)
		merge m:1 statefip yr using"temp/cps1990_rigmeasures.dta", update replace 
		drop if _merge == 2
		drop _merge
			* Add data on inflation by state
		merge m:1 statefip year using "temp/cpi_state_4unempl", nogen keep(1 3)
		
		
* RIGHT TO WORK DUMMY BY YEAR
cap drop N_total total_neg total_nonzero 
gen r2w= (yr>year_r2w)
replace r2w = 1 if statefip == 40 & yr == 2000  //replace Oklahoma r2w law on 2nd period, since it was introduced in 2001


***
*** define control variables for adh13 and dwrm descriptions
*** 
 * rigidity measures descriptions for graphs
    
global r2w "Indicator variable ==1 if state has right-to-work laws"
global dnwr_yjj_dmy1 "Indicator==1 if state dnwr (share of neg changes in pop CPS) is above MEDIAN"
global dnwr_yjj_dmy2 "Indicator==1 if state dnwr (share of neg changes in pop CPS) is above MEAN"
global dnwr_nonzero_yjj_dmy1 "Indicator==1 if state neg share in nonzero wage changes CPS above MEDIAN"
global dnwr_nonzero_yjj_dmy2 "Indicator==1 if state neg share in nonzero wage changes CPS above MEAN"
		

* order rigidity measures
order dnwr_yjj dnwr_nonzero_yjj r2w 



***
*** create estimates and coef graphs
***

 *  Rigidity Measures Interaction Graphs
dnwr_figures

 * CPI Interaction Graphs
cpi_figures

}

*-----------------------------------------------------------------------------
* end of dofile
*-----------------------------------------------------------------------------
