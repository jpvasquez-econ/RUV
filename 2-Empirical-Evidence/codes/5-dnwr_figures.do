/*
General information:
ADH13 extension to 2006-2020 using 3-year pooled ACS data
Recreated econometric analysis for each year; and coefficient graphs with interaction of downward wage rigidity measures. Changes in emp/pop outcomes are in decadal changes. 

Inputs:
	1. temp/workfile_china_RUV.dta (produced in 1-ipums_acs.do)
	2. temp/cps_rigmeasures.dta (produced in 4-cps1990_rigmeasures.do)
Outputs:
	0. temp/state_workfile_china
	1. results/figures/Figure_2A.png
	2. results/figures/Figure_2B.png
	3. results/figures/Figure_A2A.png
	4. results/figures/Figure_A2B.png
	5. results/figures/Figure_A3A.png
	6. results/figures/Figure_A3B.png
	7. results/figures/Figure_A4A.png
	8. results/figures/Figure_A4B.png
	9. results/figures/Figure_A5A.png
	10. results/figures/Figure_A5B.png
	11. results/figures/Figure_A6A.png
	12. results/figures/Figure_A6B.png
	13. results/figures/Figure_A7A.png
	14. results/figures/Figure_A7B.png
	15. results/figures/Figure_A8A.png
	16. results/figures/Figure_A8B.png
*/
program drop _all
clear
set more off
capture log close
global outputs results
*ssc install ivreg2 , replace 
*ssc install ranktest , replace
************************************************************************
************************************************************************
*                          MAIN PROGRAM
************************************************************************
************************************************************************
prog main

foreach unit in cz state {
global unit `unit'

****				   
*** State or CZ (unit of analysis) 
****	
use temp/workfile_china_RUV.dta, clear			  		
	quiet $unit

***	
*** Rigidity measures from CPS
***
		rename yr year
		gen yr = 1990 if year == 2000
		replace yr = 2000 if year > 2000
		* CPS rigidity measures for 2000 from Joo-Jo,Y.(2022) and for 1990 (constructed)
		merge m:1 statefip yr using "temp/cps_rigmeasures.dta", assert(1 3) nogen 
		cap drop N_total total_neg total_nonzero 
drop yr 
rename year yr

***
*** define control variables for adh13 and dwrm descriptions
*** 
 * rigidity measures descriptions for graphs
    
global dnwr_yjj_dmy1 "Indicator==1 if state dnwr (share of neg changes in pop CPS) is above MEDIAN"
global dnwr_yjj_dmy2 "Indicator==1 if state dnwr (share of neg changes in pop CPS) is above MEAN"
global dnwr_nonzero_yjj_dmy1 "Indicator==1 if state neg share in nonzero wage changes CPS above MEDIAN"
global dnwr_nonzero_yjj_dmy2 "Indicator==1 if state neg share in nonzero wage changes CPS above MEAN"
		

* order rigidity measures
order dnwr_yjj dnwr_nonzero_yjj

***
*** create estimates and coef graphs
***
*  Rigidity Measures Interaction Graphs
* logfile
cap log close
 log using "$log" , replace
	dnwr_figures_diff
	dnwr_figures_both
cap log close 
capture translate "$log.smcl" "$log.txt", 	replace linesize(250)
capture erase "$log.smcl"	
	
}
end
************************************************************************
*                      State-level analysis 
************************************************************************
prog state
	
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
end 
************************************************************************
*                       CZ-level analysis
************************************************************************
prog cz 

	global unit "czs"
	*define globals
	global log "$outputs/log/unempl_dnwr_czs"
	global cluster ",cluster(statefip)"
	global uofa "Community Zone (N=1444)"
	
	***
	*** create decadal change of shares for each outcome by CZ
	***

	* this rename command help us in the loops code
	rename (d_sh_empl_mfg d_sh_empl_nmfg l_sh_empl_mfg l_sh_empl_nmfg pop_cz) (d_sh_mfg d_sh_nmfg l_sh_mfg l_sh_nmfg pop_1664)

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
end

************************************************************************
*                           dnwr_figures_diff
************************************************************************
program dnwr_figures_diff

	foreach outcome in unempl {	
	global outc ""		
	foreach rig_measure of varlist dnwr_yjj_dmy2 dnwr_yjj_dmy1 dnwr_nonzero_yjj_dmy1 dnwr_nonzero_yjj_dmy2 {
	estimates clear
	global outcome `outcome' 
	global rig_measure `rig_measure'
	* create interaction with rigidity measure and trade shock
	capture drop exposure_rig* 
	capture drop inter_*
	gen exposure_rig = d_tradeusch_pw 
	gen exposure_rig_iv = d_tradeotch_pw_lag 
    gen inter_rigidity = d_tradeusch_pw * (1-${rig_measure}) // diff high vs low 
    gen inter_rigidity_iv = d_tradeotch_pw_lag * (1-${rig_measure})
	
	global estimates
	global estimates2
	forvalues i = 2006(1)2020 {
	global i = `i'
	* here we estimate the main regressions of adh13 for each outcome
	eststo mp_2000_`i' : qui ivreg2 d_sh_${outcome}_${i} ${rig_measure} l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* (exposure_rig inter_rigidity = exposure_rig_iv inter_rigidity_iv) [aw=timepwt48] $cluster

		global b_mp_2000_${i} = _b[exposure_rig]
		global se_mp_2000_${i} = _se[exposure_rig]
		global b_rm_2000_${i} = _b[inter_rigidity]
		global se_rm_2000_${i} = _se[inter_rigidity]
		global estimates "${estimates} mp_2000_${i}"
		global estimates2 "${estimates2} rm_2000_${i}"

}

 * display coefficientes for log file
	noi dis "Coefficients for `outcome' variable with `rig_measure' interaction"
	noi dis "${`rig_measure'}"
	noi esttab mp_2000_2006 mp_2000_2007 mp_2000_2008 mp_2000_2009 mp_2000_2010 mp_2000_2011 mp_2000_2012 mp_2000_2013 , ar2 nocon keep(exposure_rig inter_rigidity)
	noi esttab mp_2000_2014 mp_2000_2015 mp_2000_2016 mp_2000_2017 mp_2000_2018 mp_2000_2019 mp_2000_2020, ar2 nocon keep(exposure_rig inter_rigidity)
		
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
	
	***
	*** difference high vs low
	***
	global legend ""Difference high vs low DNWR""
	tw	(connected b_rm z, mcolor(cranberry) msymbol (D) lcolor(red%20) lpattern(shortdash)) (rarea lb_rm ub_rm z, vertical col(red%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("") ///
		xline(2007, lpattern(dash) lcolor(red)) ///
		 xlabel(`xlabline', grid gstyle(dot)) ylab(#5,labsize(small) grid gstyle(dot) ) ///
		graphregion(fcolor(white)) text(${pos} 2007 "`marker'") legend(order(1 ${legend})) yscale(r(-0.1 0.8))
		*note("Ten-year equivalent changes" "Specification: ADH13 with rigidity measure interaction" "Unit: ${uofa}", size(*0.9)) caption("Interaction: ${`rig_measure'}", size(*0.65)) 
if "$rig_measure" == "dnwr_yjj_dmy2" {
	if "$unit" == "czs" {
		graph export "$outputs/figures/Figure_2A.png", as(png) name("Graph") replace		
	}
	if "$unit" == "state"{
		graph export "$outputs/figures/Figure_A5A.png", as(png) name("Graph") replace				
	}
}
if "$rig_measure" == "dnwr_yjj_dmy1" {
	if "$unit" == "czs" {
		graph export "$outputs/figures/Figure_A2A.png", as(png) name("Graph") replace		
	}
	if "$unit" == "state"{
		graph export "$outputs/figures/Figure_A6A.png", as(png) name("Graph") replace				
	}
}
if "$rig_measure" == "dnwr_nonzero_yjj_dmy2"{
	if "$unit" == "czs" {
		graph export "$outputs/figures/Figure_A3A.png", as(png) name("Graph") replace		
	}
	if "$unit" == "state"{
		graph export "$outputs/figures/Figure_A7A.png", as(png) name("Graph") replace				
	}
}
if "$rig_measure" == "dnwr_nonzero_yjj_dmy1" {
	if "$unit" == "czs" {
		graph export "$outputs/figures/Figure_A4A.png", as(png) name("Graph") replace		
	}
	if "$unit" == "state"{
		graph export "$outputs/figures/Figure_A8A.png", as(png) name("Graph") replace				
	}
}
	restore
	} //quiet

	global count = ${count} + 1
  } //rigidity measures

  
} //outcomes

end 
************************************************************************
*                           dnwr_figures_both
************************************************************************
program dnwr_figures_both


	foreach outcome in unempl  {	
	global outc ""	
	foreach rig_measure of varlist dnwr_yjj_dmy2 dnwr_yjj_dmy1 dnwr_nonzero_yjj_dmy1 dnwr_nonzero_yjj_dmy2 {
	estimates clear 
	global outcome `outcome' 
	global rig_measure `rig_measure'
	* create interaction with rigidity measure and trade shock
	capture drop exposure_rig* 
	capture drop inter_*
	gen exposure_rig = d_tradeusch_pw * (1-${rig_measure}) //effect high rigidity
	gen exposure_rig_iv = d_tradeotch_pw_lag * (1-${rig_measure})
    gen inter_rigidity = d_tradeusch_pw * ${rig_measure} //effect low rigidity
    gen inter_rigidity_iv = d_tradeotch_pw_lag * ${rig_measure}
	
	global estimates
	global estimates2
	forvalues i = 2006(1)2020 {
	global i = `i'
	* here we estimate the main regressions of adh13 for each outcome
	eststo mp_2000_`i' : qui ivreg2 d_sh_${outcome}_${i} ${rig_measure} l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* (exposure_rig inter_rigidity = exposure_rig_iv inter_rigidity_iv) [aw=timepwt48] $cluster

		global b_mp_2000_${i} = _b[exposure_rig]
		global se_mp_2000_${i} = _se[exposure_rig]
		global b_rm_2000_${i} = _b[inter_rigidity]
		global se_rm_2000_${i} = _se[inter_rigidity]
		global estimates "${estimates} mp_2000_${i}"
		global estimates2 "${estimates2} rm_2000_${i}"

}

 * display coefficientes for log file
	noi dis "Coefficients for `outcome' variable with `rig_measure' interaction"
	noi dis "${`rig_measure'}"
	noi esttab mp_2000_2006 mp_2000_2007 mp_2000_2008 mp_2000_2009 mp_2000_2010 mp_2000_2011 mp_2000_2012 mp_2000_2013 , ar2 nocon keep(exposure_rig inter_rigidity)
	noi esttab mp_2000_2014 mp_2000_2015 mp_2000_2016 mp_2000_2017 mp_2000_2018 mp_2000_2019 mp_2000_2020, ar2 nocon keep(exposure_rig inter_rigidity)
		
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
	***
	*** BOTH
	***
	global legend1 ""High rigidity""
	global legend2 ""Low rigidity""
	tw (connected b z, mcolor(forest_green) msymbol(O) lcolor(forest_green%20) lpattern(shortdash) ) ///
		(rarea lb ub z , vertical col(forest_green%10)) /// 
		|| (connected b_rm z, mcolor(midblue) msymbol (Th) lcolor(midblue%20) lpattern(shortdash)) (rarea lb_rm ub_rm z, vertical col(midblue%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("") ///
		xline(2007, lpattern(dash) lcolor(red)) ///
		legend(order(1 ${legend1} 3 ${legend2})) xlabel(`xlabline', grid gstyle(dot)) ylab(#5,labsize(small) grid gstyle(dot) ) ///
		graphregion(fcolor(white)) yscale(r(-0.1 0.8))
		
		*note("Ten-year equivalent changes" "Specification: ADH13 with rigidity measure interaction" "Unit: ${uofa}", size(*0.9)) caption("Interaction: ${`rig_measure'}", size(*0.65)) 
if "$rig_measure" == "dnwr_yjj_dmy2" {
	if "$unit" == "czs" {
		graph export "$outputs/figures/Figure_2B.png", as(png) name("Graph") replace		
	}
	if "$unit" == "state"{
		graph export "$outputs/figures/Figure_A5B.png", as(png) name("Graph") replace				
	}
}
if "$rig_measure" == "dnwr_yjj_dmy1" {
	if "$unit" == "czs" {
		graph export "$outputs/figures/Figure_A2B.png", as(png) name("Graph") replace		
	}
	if "$unit" == "state"{
		graph export "$outputs/figures/Figure_A6B.png", as(png) name("Graph") replace				
	}
}
if "$rig_measure" == "dnwr_nonzero_yjj_dmy2"{
	if "$unit" == "czs" {
		graph export "$outputs/figures/Figure_A3B.png", as(png) name("Graph") replace		
	}
	if "$unit" == "state"{
		graph export "$outputs/figures/Figure_A7B.png", as(png) name("Graph") replace				
	}
}
if "$rig_measure" == "dnwr_nonzero_yjj_dmy1" {
	if "$unit" == "czs" {
		graph export "$outputs/figures/Figure_A4B.png", as(png) name("Graph") replace		
	}
	if "$unit" == "state"{
		graph export "$outputs/figures/Figure_A8B.png", as(png) name("Graph") replace				
	}
}
	restore
	} //quiet

	global count = ${count} + 1
  } //rigidity measures
  
  
} //outcomes
	
end 

************************************************************************
************************************************************************
*         RUN MAIN ITERATIONS OVER CZ AND STATE LEVEL REGRESSIONS
************************************************************************
************************************************************************
	main 
