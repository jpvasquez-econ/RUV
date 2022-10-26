drop _all

********************************************************************************
* THIS FILE SHOWS TRADE SHOCKS, WELFARE IMPACTS, AND OBSERVED EMP/POP CHANGES 
* ON A MAP
********************************************************************************

********************************************************************************
* DATA PREP FOR PROJECTED IMPACTS
********************************************************************************

foreach p in 9112 {

	if `p'==9107 {
	local base1 = 1991
	local base2 = 2000
	local end1 = 2000
	local end2 = 2007
	local end3 = 2007
	local beta_yi = -2.252 /*coefficient for change in personal income per capita, 2000-2019*/
	local beta_tp2 = -0.840 /*coefficient for change in wage & salary emp-pop, 2000-2019*/
	local beta_ep = -.8370414 /* coefficient for ACS employment to population, 2000-2019*/
	}

	if `p'==9112 {
	local base1 = 1991
	local base2 = 2000
	local end1 = 2000
	local end2 = 2012
	local end3 = 2019
	local beta_yi = -2.658 /*coefficient for change in personal income per capita, 2000-2019*/
	local beta_tp2 = -1.739 /*coefficient for change in wage & salary emp-pop, 2000-2019*/
	local beta_ep = -1.237376 /* coefficient for ACS employment to population, 2000-2019*/
    }

*ADJ R SQUARED ADJUSTMENT TERM	
local adjr = .57
*OUTCOME VARIABLES CONSIDERED
local yi_lab = "log personal income per capita"
local tp2_lab = "wage & salary emp./pop 18-64"
local ep_lab = "employment-to-population (ACS)"
local VAR1 = "yi"
local VAR2 = "tp2"
local M = "Deviation from mean"
*AGGREGATE WELFARE IMPACT 2000-07 FROM GRCY '20 
local Mline = 0.22

*LOAD CZ POPULATION DATA
use "${data}//ADH_pop_emp_transfers.dta" , clear
keep if year==2000
keep year czone Pop PInc pop* Wage_salary_employ
*CALCULATE POPULATION WEIGHTS
egen tPop=sum(Pop)
gen wt=Pop/tPop
gen pop=Pop/1000

*MERGE IN CONTROL VARIABLES
merge 1:1 czone year using "${data}/ADH_control_vars.dta"
keep if year==2000
tab _m
drop _m 

*MERGE IN CZ NAMES
merge 1:1 czone using "${data}/cz_msa_names.dta", keep(3) nogen keepusing(cz_name)

*PREPARE TRADE SHOCKS CONSTRUCTED FROM DAVID DORN'S MODIFIED DO FILE FOR LATER MERGE
merge 1:1 czone using "${data}/czone_exposure_by_period_v5_gh.dta", keep(3) nogen

*CREATE TP2 VARIABLE
gen tp2=((Wage_salary_employ)/pop_1864_all)

*USE IPR WHERE WE KEEP INDUSTRY ABSORPTION FIXED IN BEGINNING YEAR
keep cz* ba* Pop tPop wt pop tp2 l_shind_manuf_cbp *p1*`base1'_`end1' d_trade*p1*`base2'_`end2' d_trade*p1*`base1'_`end2'


*DECADALIZE VALUES, MULTIPLY BY ADJUSTED R SQUARED FROM 1ST STAGE REGRESSION, AND CALCULATE POPULATION WEIGHTED AVERAGE VALUES
foreach x in d_tradeusch_p1 {
	
	*trade shock magnitude
	foreach t in 1 2 {
		gen ipr_`base`t''_`end`t'' = 100*`x'_`base`t''_`end`t''*(10/(`end`t''-`base`t''))
	}
	gen ipr_`base1'_`end2' = 100*`x'_`base1'_`end2'*(10/(`end2'-`base1'))

foreach y in yi tp2 ep {

	*direct trade shock impact	
	foreach t in 1 2 {
		gen ip_`base`t''_`end`t''_`y' = `beta_`y''*`adjr'*100*`x'_`base`t''_`end`t''*(10/(`end`t''-`base`t''))
	}
	gen ip_`base1'_`end2'_`y' = `beta_`y''*`adjr'*100*`x'_`base1'_`end2'*(10/(`end2'-`base1'))

	format ip* %9.3f
	*deviation from mean for trade shock impact
	foreach z in `base1'_`end1' `base2'_`end2' `base1'_`end2' {
	    sum ip_`z'_`y' [aw=wt]
		gen Mip_`z'_`y' = (ip_`z'_`y'-r(mean))
		}
	format ip* Mip* %9.3f	
	}
	}
	
*RENAME CZONE VARIABLE TO CONSTRUCT MAPS
ren czone cz

* MAPS FOR TRADE SHOCKS
foreach x in `base2' {
	foreach z in `end2' {
		if (`x' == 1991 & `z' == 2007) {
			noi di "next"
		}
		else {
			* bottom four quintiles and then the top two deciles
			xtile cuts_ipr_`x'_`z' = ipr_`x'_`z', nq(10)
			replace cuts_ipr_`x'_`z' = 1 if inrange(cuts_ipr_`x'_`z',1,2)
			replace cuts_ipr_`x'_`z' = 2 if inrange(cuts_ipr_`x'_`z',3,4)
			replace cuts_ipr_`x'_`z' = 3 if inrange(cuts_ipr_`x'_`z',5,6)
			replace cuts_ipr_`x'_`z' = 4 if inrange(cuts_ipr_`x'_`z',7,8)
			replace cuts_ipr_`x'_`z' = 5 if cuts_ipr_`x'_`z' == 9
			replace cuts_ipr_`x'_`z' = 6 if cuts_ipr_`x'_`z' == 10
			forvalues i=2/6 {
				qui sum ipr_`x'_`z' if cuts_ipr_`x'_`z' == `i'
				local cut`i' : di %9.3f	`r(min)'
			}
			maptile ipr_`x'_`z' , geo(cz1990) conus twopt(legend(title("`x'-`z' trade shock", size(small)))) cutv(`cut2' `cut3' `cut4' `cut5' `cut6')
			gr export "${output}/bpea_fig_4.pdf", replace
		}
	}
}
	
* MAPS FOR PROJECTED IMPACT ON PERSONAL INCOME
foreach x in 2 {
foreach y in tp2 {
foreach z in M {
	
	* bottom two deciles and then top four quintiles  
	xtile cuts_`z'ip_`base`x''_`end`x''_`y' = `z'ip_`base`x''_`end`x''_`y', nq(10)
	replace cuts_`z'ip_`base`x''_`end`x''_`y' = 3 if inrange(cuts_`z'ip_`base`x''_`end`x''_`y',3,4)
	replace cuts_`z'ip_`base`x''_`end`x''_`y' = 4 if inrange(cuts_`z'ip_`base`x''_`end`x''_`y',5,6)
	replace cuts_`z'ip_`base`x''_`end`x''_`y' = 5 if inrange(cuts_`z'ip_`base`x''_`end`x''_`y',7,8)
	replace cuts_`z'ip_`base`x''_`end`x''_`y' = 6 if inrange(cuts_`z'ip_`base`x''_`end`x''_`y',9,10)
	forvalues i=2/6 {
		qui sum `z'ip_`base`x''_`end`x''_`y' if cuts_`z'ip_`base`x''_`end`x''_`y' == `i'
		local cut`i' : di %9.3f	`r(min)'
	}
	
	maptile `z'ip_`base`x''_`end`x''_`y' , ///
		geo(cz1990) rev conus cutv(`cut2' `cut3' `cut4' `cut5' `cut6') ///
		twopt( ///
		legend(title("Deviation from mean", size(small)) ))
	gr export "${output}/bpea_fig_6b.pdf", replace
	
	}
	}
	}
}

********************************************************************************
* DATA PREP FOR OBSERVED DATA
********************************************************************************

*DEFINE THE BASE PERIODS FOR THE TIME DIFFERENCES
local yr_1990 "2000 2010 2014 2019"
local yr_2000 "2019"
local base0=1991
local base1=1991
local base2=2000
local base3=2001
local base4=2000
local base5=2000
local base6=2000
local start1=`base1'+1
local start2=`base2'+1
local start3=`base3'+1
local end0=2000
local end1=2012
local end2=2012
local end4=2007
local end5=2010
local end6=2014
local fin=2019

*PREPARE REIS OUTCOMES
use czone year Pop Wage_salary_employ pop_1864_all Manuf_emp ///
	using "${data}/ADH_pop_emp_transfers.dta", clear
gen tp2=(Wage_salary_employ/pop_1864_all)
gen mp=((Manuf_emp)/pop_1864_all)
gen np=((Wage_salary_employ-Manuf_emp)/pop_1864_all)
foreach x in `base2' {
		*Define total population weights for base yar
		egen tPop=sum(Pop), by(year)
		gen p_`x' = Pop/tPop if year==`x'
		egen pop_`x' = mean(p_`x'), by(czone)
		drop p_`x' tPop
		*Define wking age population weights for base yar
		egen tPop=sum(pop_1864_all), by(year)
		gen p_`x' = Pop/tPop if year==`x'
		egen popwk_`x' = mean(p_`x'), by(czone)
		drop p_`x' tPop
if `x' == `base2' {
foreach z in `base3' {
foreach y of var tp2 mp np { 
		*Define base year for outcome variable
		gen `y'`z' = `y' if year==`z'
		egen `y'_`z' = mean(`y'`z'), by(czone)
	foreach u of numlist `start3'(1)2019 {	
		*Construct progressively longer time differences
		gen d`y'_`z'_`u' = 100*(`y' - `y'_`z') if year==`u'
		sum d`y'_`z'_`u' [aw=popwk_2000]
		gen Md`y'_`z'_`u' = (d`y'_`z'_`u'-r(mean))
		}
		drop `y'`z' `y'_`z'
		}
	}
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
	foreach x in all {
		gen ep_bl_`x'=employed_bl_`x'/population_bl_`x'
		gen lp_bl_`x'=log(population_bl_`x')
	}
	foreach x in mf no_mf {
		gen ep_bl_`x'=employed_bl_`x'/population_bl_all	
	}
	
*CREATE CHANGES IN POP AND EMPLOYMENT VARIABLES FOR EACH TIME DIFFERENCE WITH ALTERNATIVE BASE YEARS AND END YEAR 2019
*FIRST CREATE WEIGHTS FOR REGRESSION (WORKING AGE POP IN BASE YEAR)
qui ds ep* lp*
local yvars `r(varlist)'
foreach x of num 2000 {
	gen p_`x' = population_bl_all if year==`x'
	egen pop_`x' =mean(p_`x'), by(czone)
	drop p_`x'
	
	foreach y in `yvars' {
		gen `y'`x' = `y' if year==`x'
		egen `y'_`x' = mean(`y'`x'), by(czone)
		drop `y'`x'
		
		foreach z of num `yr_`x''  {	
			gen d`y'_`x'_`z' = 100*(`y' - `y'_`x') if year==`z'
			sum d`y'_`x'_`z' [aw=pop_`x']
			gen Md`y'_`x'_`z' = (d`y'_`x'_`z'-r(mean))
		}
		drop `y'_`x'
	}
}

*MERGE REIS DATA
merge 1:1 czone year using `reis', keep(1 3) nogen
format M* %9.3f	

*RENAME CZONE VARIABLE TO CONSTRUCT MAPS
ren czone cz

* MAPS FOR PROJECTED IMPACT ON PERSONAL INCOME
foreach y in ep_bl_all {
	if strpos("`y'","bl") > 0 {
		local x = 2000
	}
	else {
		local x = 2001
	}
foreach z in 2019 {	
	
	* bottom two deciles and then top four quintiles  
	xtile cuts_`y'_`x'_`z' = Md`y'_`x'_`z', nq(10)
	replace cuts_`y'_`x'_`z' = 3 if inrange(cuts_`y'_`x'_`z',3,4)
	replace cuts_`y'_`x'_`z' = 4 if inrange(cuts_`y'_`x'_`z',5,6)
	replace cuts_`y'_`x'_`z' = 5 if inrange(cuts_`y'_`x'_`z',7,8)
	replace cuts_`y'_`x'_`z' = 6 if inrange(cuts_`y'_`x'_`z',9,10)
	forvalues i=2/6 {
		qui sum Md`y'_`x'_`z' if cuts_`y'_`x'_`z' == `i'
		local cut`i' : di %9.3f	`r(min)'
	}
	
	maptile Md`y'_`x'_`z' if Md`y'_`x'_`z' != ., ///
		geo(cz1990) rev conus cutv(`cut2' `cut3' `cut4' `cut5' `cut6') ///
		twopt( ///
		legend(title("Deviation from mean", size(small)) ))
	gr export "${output}/bpea_fig_6a.pdf", replace
	
}
}
