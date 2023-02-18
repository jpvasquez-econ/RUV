drop _all

/*******************************************************************************
	
	THIS FILE COMPARES EMP/POP MEASURES IN REIS VS ACS DATA FOR
	2000-10 , 2000-14, AND 2000-19
	
	TRADE SHOCKS ARE 2000-2012 

	Also performs robustness checks for 
	1) different definitions of emp/pop
	2) different time horizons (2006-08, 2011-13, 2017-19)
	
*******************************************************************************/

*DEFINE THE BASE PERIODS FOR THE TIME DIFFERENCES
local yr_1990 "2000 2010 2014 2019"
local yr_2000 "2010 2014 2019"
local beg1990_1=1991
local beg1990_2=1992 
local beg2000_1=1999
local beg2000_2=2000
local end1991 "1999 2000 2007 2010 2011"
local end1992 "1997 2002 2004 2007 2012"
local end1999 "2004 2007 2011"
local end2000 "2010 2014 2019"

*Define control variable sets
local control0 "reg2-reg9"  
local control1 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9"  
local control2 "l_shind_manuf_cbp_lag l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9"
local control3 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9 sh_65up_all sh_4064_all sh_0017_all sh_00up_nw"  
local control4 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9 sh_65up_all sh_4064_all sh_0017_all sh_00up_nw dlnpop7090"  

* For the emp-pop regressions, use the control3 specification
local control_ep = "`control3'"

* for the log population regressions, use the control4 specifications
local control_lp = "`control4'"

* Set some labels for graphs	
local ep_lab "employment/population"
local lp_lab "log working-age population"
local hp_lab "hours worked per FTE"
local ai_lab "log annual earnings"
local wi_lab "log weekly earnings"
local hi_lab "log hourly earnings"

* what do you want the file to do? set to 1 if you want to
global main 1 			 	// run main analysis compares 2000 to 2010-14 and 2015-2019 outcomes
global robust_periods 1		// run robustness to different time horizons (2006-08, 2011-13, 2017-19)

*******************************************************************************

*PREPARE DATA
*CONTROL VARIABLES (FROM WWD AERi PAPER) FOR LATER MERGE
foreach x in 1990 2000 {
	use "${data}/ADH_control_vars"
	keep if year==`x'
	drop year
	save temp_`x', replace
}

if $main == 1 {
*PREPARE REIS OUTCOMES
use czone year Pop Wage_salary_employ pop_1864_all Manuf_emp using "${data}/ADH_pop_emp_transfers.dta", clear
gen tp2=(Wage_salary_employ/pop_1864_all)
gen mp=((Manuf_emp)/pop_1864_all)
gen np=((Wage_salary_employ-Manuf_emp)/pop_1864_all)
foreach x in 2001 {
	*Define total population weights for base yar
	gegen tPop=sum(Pop), by(year)
	gen p_`x' = Pop/tPop if year==`x'
	gegen pop_`x' = mean(p_`x'), by(czone)
	drop p_`x' tPop
	*Define wking age population weights for base yar
	gegen tPop=sum(pop_1864_all), by(year)
	gen p_`x' = Pop/tPop if year==`x'
	gegen popwk_`x' = mean(p_`x'), by(czone)
	drop p_`x' tPop
foreach y of var tp2 mp np {
		*Define base year for outcome variable
		gen `y'`x' = `y' if year==`x'
		gegen `y'_`x' = mean(`y'`x'), by(czone)
		foreach z of numlist 2000(1)2019 {	
			*Construct progressively longer time differences
			gen d`y'_`x'_`z' = 100*(`y' - `y'_`x') if year==`z'
		}
		drop `y'`x' `y'_`x'
}
}
tempfile reis
save `reis'

*LOAD ACS-CENSUS DATA ON POPULATION, EMPLOYMENT, EARNINGS BY CZ
use "${data}/ACS_pop_emp_inc.dta"

*MERGE IN TRADE SHOCKS FROM IPR FOLDER
fmerge m:1 czone using "${data}/czone_exposure_by_period_v5_gh.dta", keep(3) nogen

*DECADALIZE VALUES FOR TRADE SHOCKS
foreach var in d_tradeusch_p1_2000_2012 d_tradeotch_p1_lag_2000_2012 {
	replace `var' = 100*`var'*(10/(2012-2000))
}

*CREATE DEPENDENT VARIABLES
*EMPLOYMENT-POPULATION RATIOS: EMPLOYED, WORKERS, HOURS
	* Main outcomes
	foreach x in all ba ba_y ba_o ba_m ba_f ba_y_m ba_y_f ba_o_m ba_o_f ///
	no_ba no_ba_y no_ba_o no_ba_m no_ba_f no_ba_y_m no_ba_y_f no_ba_o_m no_ba_o_f ///
	nb fb no_ba_nb no_ba_fb ba_nb ba_fb nb_4064 nb_2539 nb_1824 fb_4064 fb_2539 fb_1824 {
		gen ep_bl_`x'=employed_bl_`x'/population_bl_`x'
		gen lp_bl_`x'=log(population_bl_`x')
	}
	foreach x in mf no_mf {
		gen ep_bl_`x'=employed_bl_`x'/population_bl_all	
	}
	* Robustness - Alternative definitions for emp/pop
	foreach x in all mf no_mf {
		gen ep_1664_`x' = employed_bl_`x' / population_adh13_all
		gen ep_gig_`x' = employed_gig_`x' / population_bl_all	
		foreach def in adh13 reis {
			gen ep_`def'_`x' = employed_`def'_`x' / population_`def'_all		
		}
	}
	
*CREATE CHANGES IN POP AND EMPLOYMENT VARIABLES FOR EACH TIME DIFFERENCE WITH ALTERNATIVE BASE YEARS AND END YEAR 2019
*FIRST CREATE WEIGHTS FOR REGRESSION (WORKING AGE POP IN BASE YEAR)
qui ds ep* lp*
local yvars `r(varlist)'
foreach x of num 1990 2000 {
	gen p_`x' = population_bl_all if year==`x'
	egen pop_`x' =mean(p_`x'), by(czone)
	drop p_`x'
	
	foreach y in `yvars' {
		gen `y'`x' = `y' if year==`x'
		egen `y'_`x' = mean(`y'`x'), by(czone)
		drop `y'`x'
		
		foreach z of num `yr_`x''  {	
			gen d`y'_`x'_`z' = 100*(`y' - `y'_`x') if year==`z'
		}
		drop `y'_`x'
	}
}

* summary statistics
* levels of ep 
foreach y in 2000 `end2000' {
	tabstat ep_bl_all ep_bl_mf ep_bl_no_mf [aw=pop_2000] if year == `y', stat(mean sd p25 p50 p75) columns(statistics) format(%7.3f) save
	mat T = r(StatTotal)'
	putexcel set "${output}/sumstats.xlsx", modify sheet(ACS_ep_`y', replace)
	putexcel A1 = matrix(T), names
}
* changes in ep and comparison with REIS
fmerge 1:1 czone year using `reis', keep(1 3) nogen
foreach y in `end2000' {
	tabstat dep_bl_all_2000_`y' dep_bl_mf_2000_`y' dep_bl_no_mf_2000_`y' [aw=pop_2000], stat(mean sd p25 p50 p75) columns(statistics) format(%7.3f) save
	mat T = r(StatTotal)'
	putexcel set "${output}/sumstats.xlsx", modify sheet(ACS_ep_change_2000_`y')
	putexcel A1 = matrix(T), names
	
	local i = 1
	corr dep_reis_all_2000_`y' dtp2_2001_`y' 
	mat T = r(C) 
	putexcel set "${output}/sumstats.xlsx", modify sheet(ACS_ep_change_2000_`y')
	putexcel R`i' = matrix(T), names

	local i = `i' + 3
	corr dep_reis_mf_2000_`y' dmp_2001_`y'
	mat T = r(C) 
	putexcel set "${output}/sumstats.xlsx", modify sheet(ACS_ep_change_2000_`y')
	putexcel R`i' = matrix(T), names
	
	local i = `i' + 3
	corr dep_reis_no_mf_2000_`y' dnp_2001_`y'
	mat T = r(C) 
	putexcel set "${output}/sumstats.xlsx", modify sheet(ACS_ep_change_2000_`y')
	putexcel R`i' = matrix(T), names
	
}
		
* merge dlnpop7090 control variable
fmerge 1:1 czone year using "${data}/ADH_pop_emp_transfers.dta", keep(1 3) nogen keepusing(dlnpop7090)
		
* merge control variables
cap drop l_shind_manuf_cbp_1980
fmerge m:1 czone using temp_2000, nogen
tab region, gen(reg)

*******************************************************************************

* Main analysis: run regressions for 2000-2010, 2000-2014, and 2000-2019	
foreach y1 in ep lp {
foreach y2 in all ba no_ba nb fb ba_nb ba_fb no_ba_nb no_ba_fb mf no_mf nb_4064 nb_2539 nb_1824 fb_4064 fb_2539 fb_1824 {
	if ("`y1'" == "lp" & strpos("`y2'","mf")>0) | ("`y1'" != "lp" & (strpos("`y2'","2")>0 | strpos("`y2'","4")>0)) {
		di "next"
	} // no log population outcomes by manuf/non-manuf ; ignore ep and wp by age groups and place of birth
	else {
		foreach u in 2000 {
			foreach v in `end`u'' {	
			foreach z of numlist `yr_2000' {
				eststo `y1'_`y2'_2000_`z' : qui ivreg2 d`y1'_bl_`y2'_2000_`z' `control_`y1'' ///
				(d_tradeusch_p1_2000_2012=d_tradeotch_p1_lag_2000_2012)  [aw=pop_2000], cluster(statefip) 
			} // z
			} // v
		noi di "Results for `y1'_`y2' , `u' to `end`u'' :"
		esttab `y1'_`y2'_2000_2010 `y1'_`y2'_2000_2014 `y1'_`y2'_2000_2019, se ar2 nocon keep(d_tradeusch_p1_2000_2012)
		} // u
	} // valid outcomes
} // outcome suffix
}

* put into grpahs
foreach y1 in lp {
	
	* by age group
	coefplot	(`y1'_all_2000_2010, label(2000 to 2010)) /*(`y1'_all_2000_2014, label(2000 to 2014))*/ (`y1'_all_2000_2019, label(2000 to 2019)), bylab(All) || ///
			`y1'_nb_2000_2010		/*`y1'_nb_2000_2014*/		`y1'_nb_2000_2019, bylab(Native-born) || ///
			`y1'_nb_4064_2000_2010 	/*`y1'_nb_4064_2000_2014*/ 	`y1'_nb_4064_2000_2019, bylab("Native-born" "age 40-64") || ///
			`y1'_nb_2539_2000_2010 	/*`y1'_nb_2539_2000_2014*/ 	`y1'_nb_2539_2000_2019, bylab("Native-born" "age 25-39") || ///
			`y1'_nb_1824_2000_2010 	/*`y1'_nb_1824_2000_2014*/ 	`y1'_nb_1824_2000_2019, bylab("Native-born" "age 18-24") || ///
			`y1'_fb_2000_2010		/*`y1'_fb_2000_2014*/		`y1'_fb_2000_2019, bylab(Foreign-born) || ///
			`y1'_fb_4064_2000_2010 	/*`y1'_fb_4064_2000_2014*/ 	`y1'_fb_4064_2000_2019, bylab("Foreign-born" "age 40-64") || ///
			`y1'_fb_2539_2000_2010 	/*`y1'_fb_2539_2000_2014*/ 	`y1'_fb_2539_2000_2019, bylab("Foreign-born" "age 25-39") || ///
			`y1'_fb_1824_2000_2010 	/*`y1'_fb_1824_2000_2014*/ 	`y1'_fb_1824_2000_2019, bylab("Foreign-born" "age 18-24") ///
		keep(d_tradeusch_p1_2000_2012) bycoef vertical yline(0, lpattern(solid))  ///
		xtitle("", size(small)) ytitle("Coefficient for trade shock", size(small)) ///
		xlab(, labsize(vsmall)) ylab(, labsize(small)) ///
		lcolor(black) msize(small) bcolor(black) ///
		scheme(s2color) graphregion(color(white)) plotregion(color(white))  legend(pos(6) cols(3))
	gr export "${output}/bpea_fig_A6.pdf", replace

} // outcomes
} // main analysis
	
eststo clear

*******************************************************************************

* Robustness to alternative time horizons
if ${robust_periods} == 1 {

use "${data}/ACS_08_13_19.dta", clear

*MERGE IN TRADE SHOCKS FROM IPR FOLDER
fmerge m:1 czone using "${data}/czone_exposure_by_period_v5_gh.dta", keep(3) nogen

*DECADALIZE VALUES FOR TRADE SHOCKS
foreach var in d_tradeusch_p1_2000_2012 d_tradeotch_p1_lag_2000_2012 {
	replace `var' = 100*`var'*(10/(2012-2000))
}

* merge dlnpop7090 control variable
fmerge 1:1 czone year using "${data}/ADH_pop_emp_transfers.dta", keep(1 3) nogen keepusing(dlnpop7090)

* merge controls
cap drop l_shind_manuf_cbp_1980
fmerge m:1 czone using temp_2000, nogen
tab region, gen(reg)

* run regressions
foreach x in all mf no_mf no_ba_m no_ba_f ba_m ba_f no_ba_m_mf no_ba_f_mf ba_m_mf ba_f_mf {
	foreach z in 2008 2013 2019 {
		eststo ep_bl_`x'_`z' : qui ivreg2 dep_bl_`x'_2000_`z' `control3' ///
		(d_tradeusch_p1_2000_2012=d_tradeotch_p1_lag_2000_2012)  [aw=pop_2000], cluster(statefip) 
	}
	noi di "Results for ep_bl_`x' , 2000 to 2008 2013 2019 :"
	esttab ep_bl_`x'_2008 ep_bl_`x'_2013 ep_bl_`x'_2019, ar2 nocon keep(d_tradeusch_p1_2000_2012)
}

* by manuf
coefplot	(ep_bl_all_2008, label(2000 to 2007)) ///
			(ep_bl_all_2013, label(2000 to 2012)) ///
			(ep_bl_all_2019, label(2000 to 2018)), bylab(All) || ///
	ep_bl_mf_2008		ep_bl_mf_2013		ep_bl_mf_2019, bylab(Manufacturing) || ///
	ep_bl_no_mf_2008	ep_bl_no_mf_2013	ep_bl_no_mf_2019, bylab(Non-manufacturing) ///
	keep(d_tradeusch_p1_2000_2012) bycoef vertical yline(0, lpattern(solid))  ///
	xtitle("", size(small)) ytitle("Coefficient for trade shock", size(small)) ///
	xlab(, labsize(small)) ylab(, labsize(small)) ///
	lcolor(black) msize(small) bcolor(black) ///
	legend(cols(3) pos(6)) ///
	scheme(s2color) graphregion(color(white)) plotregion(color(white))  
gr export "${output}/bpea_fig_A5a.pdf", replace

* by gender, college attainment 
coefplot	(ep_bl_no_ba_m_2008, label(2000 to 2007) mcolor(navy) ciopts(color(navy)) msymbol(O)) ///
			(ep_bl_no_ba_m_2013, label(2000 to 2012) mcolor(maroon) ciopts(color(maroon)) msymbol(S)) ///
			(ep_bl_no_ba_m_2019, label(2000 to 2018) mcolor(green) ciopts(color(green)) msymbol(T)) , bylab("Non-college" "men") || ///
	ep_bl_ba_m_2008			ep_bl_ba_m_2013			ep_bl_ba_m_2019		, bylab("College" "men") || ///
	ep_bl_no_ba_f_2008		ep_bl_no_ba_f_2013		ep_bl_no_ba_f_2019	, bylab("Non-college" "women") || ///
	ep_bl_ba_f_2008			ep_bl_ba_f_2013			ep_bl_ba_f_2019		, bylab("College" "women") ///
	keep(d_tradeusch_p1_2000_2012) bycoef vertical yline(0, lpattern(solid))  ///
	title("Employment / population 18-64", size(medsmall)) ///
	xtitle("", size(small))  ///
	xlab(, labsize(medsmall)) ylab(, labsize(small)) ///
	legend(cols(3) size(*.8) pos(6)) grid(between glpattern(dot) glcolor(gray)) ///
	scheme(s2color) graphregion(color(white)) plotregion(color(white))  
graph save grph.gph, replace
coefplot	(ep_bl_no_ba_m_mf_2008, label(2000 to 2007) mcolor(navy) ciopts(color(navy)) msymbol(O)) ///
			(ep_bl_no_ba_m_mf_2013, label(2000 to 2012) mcolor(maroon) ciopts(color(maroon)) msymbol(S)) ///
			(ep_bl_no_ba_m_mf_2019, label(2000 to 2018) mcolor(green) ciopts(color(green)) msymbol(T)) , bylab("Non-college" "men") || ///
	ep_bl_ba_m_mf_2008			ep_bl_ba_m_mf_2013			ep_bl_ba_m_mf_2019		, bylab("College" "men") || ///
	ep_bl_no_ba_f_mf_2008		ep_bl_no_ba_f_mf_2013		ep_bl_no_ba_f_mf_2019	, bylab("Non-college" "women") || ///
	ep_bl_ba_f_mf_2008			ep_bl_ba_f_mf_2013			ep_bl_ba_f_mf_2019		, bylab("College" "women") ///
	keep(d_tradeusch_p1_2000_2012) bycoef vertical yline(0, lpattern(solid))  ///
	title("Manufacturing employment / population 18-64", size(medsmall)) ///
	xtitle("", size(small)) ///
	xlab(, labsize(medsmall)) ylab(, labsize(small)) ///
	legend(cols(3) size(*.8) pos(6)) grid(between glpattern(dot) glcolor(gray)) ///
	scheme(s2color) graphregion(color(white)) plotregion(color(white))  
graph save grph2.gph, replace
grc1leg grph.gph grph2.gph, ycommon legendfrom(grph.gph)
gr export "${output}/bpea_fig_A5b.pdf", replace


} // alternative time horizons
*******************************************************************************

//eststo clear
erase temp_1990.dta
erase temp_2000.dta
erase grph.gph 
erase grph2.gph

