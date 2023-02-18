drop _all

********************************************************************************
*THIS FILE RUNS PRETRENDS ANALYSIS FROM 1976-1991
********************************************************************************

*DEFINE THE BASE PERIODS FOR THE TIME DIFFERENCES
local base1=1991
local base2=2000
local start1=`base1'+1
local start2=`base2'+1
local end1=2000
local end2=2012
local beg=1970
local beg1=`beg'+1
local mid=`beg'+5
local mid1=`mid'+1
local fin=1991

*CAPTURE CENSUS REGION DUMMIES
use "${data}/ADH_control_vars.dta"
keep if year==1990
keep czone region state

*ANNUAL DATA ON POPULATION BY CZ (FROM JULIETTE FORNIER IN DATA VIZ FOLDER)
merge 1:m czone using "${data}/pop-czone-1970-2016.dta" 
foreach x in all wm wf nwm nwf {
	gen pop_00up_`x' = pop2539_`x' + pop5564_`x' + pop1824_`x' + pop4054_`x' + pop0017_`x' + pop65up_`x'
	gen pop_1864_`x' = pop2539_`x' + pop5564_`x' + pop1824_`x' + pop4054_`x'
	gen pop_1839_`x' = pop2539_`x' + pop1824_`x'
	gen pop_2539_`x' = pop2539_`x'
	gen pop_1824_`x' = pop1824_`x'
	}
foreach x in all wm wf nwm nwf {
	label var pop_00up_`x' "Population of `x', 0 and up"
	label var pop_1864_`x' "Population of `x', 18 to 64"
	label var pop_1839_`x' "Population of `x', 18 to 39"
	label var pop_2539_`x' "Population of `x', 25 to 39"
	label var pop_1824_`x' "Population of `x', 18 to 24"
	}
foreach x in 65up 0017 _1839 {
    gen sh_`x'_all = pop`x'_all/pop_00up_all
	}
gen sh_00up_nw = (pop_00up_nwf + pop_00up_nwm)/pop_00up_all	
tab year
keep year czone reg* state* pop_00up* pop_1864* pop_1839* pop_1824* pop_2539* sh*
save temp1, replace
	
*MERGE IN REIS DATA ON PERSONAL INCOME, GOV'T TRANSFERS TO CALCULATE ON PER CAPITA BASIS
merge 1:1 czone year using "${data}/CA4_CZ.dta"
tab year if _m==2
drop _m
merge 1:1 czone year using "${data}/CA35_CZ.dta"
drop _m
merge 1:1 czone year using "${data}/CA5-6_appended.dta"
drop _m
keep if year<=2000
merge 1:1 czone year using "${data}/CA25S_CZ.dta" 
drop _m

*MERGE IN TRADE SHOCKS CONSTRUCTED USING MODIFIED VERSION OF DAVID DORN'S DO FILE
merge m:1 czone using "${data}/czone_exposure_by_period_v5_gh.dta"
tab czone if _m==1
drop if _m==1
codebook czone
drop _m
*DECADALIZE VALUES
foreach y in 1 2 {
foreach x in `end1' `end2' {    
	if `x' == `base`y'' {
		noi di "next"
	}
	else {
		replace d_tradeusch_p1_`base`y''_`x'=100*d_tradeusch_p1_`base`y''_`x'*(10/(`x'-`base`y''))
	}
}
}

*RESTRICT SAMPLE PERIOD FOR PRETRENDS ANALYSIS
keep if year>=1970 & year<=1991

*CREATE DEPENDENT VARIABLES
*EMPLOYMENT-POPULATION RATIOS
gen ppltn=Pop
gen tp3=((Emp_priv_nonfarm)/pop_1864_all)
gen tp2=((Wage_salary_employ)/pop_1864_all)
gen mp=(Manuf/pop_1864_all)
gen np=tp3-mp
*LOG POPULATION HEADCOUNTS
gen wkpop=log(pop_1864_all)
gen ygpop=log(pop_1839_all)
gen odpop=log(pop_1864_all-pop_1839_all)
gen allpop=log(Pop)
*PERSONAL INCOME PER CAPITA, GOV'T TRANSFERS PER CAPITA AND AS SHARE OF PERSONAL INCOME, COMPONENTS OF GOV'T TRANSFERS
gen yi=log(PInc/ppltn)
gen tc=log(Indv_gov_transfer/ppltn)
gen ssa=log(Social_sec_bene/ppltn)
gen mca=log(Medicare_bene/ppltn)
*EXPRESS DOLLARS PER CAPITA IN COMMON DECIMAL TERMS
foreach y of var yi-mca {
    gen `y'_usd = (exp(`y')*1000)/100
	}
*CONSTRUCT CZ POPULATION WEIGHTS FOR END YEAR (1991) AND CURRENT YEAR
egen tP=sum(Pop), by(year)
gen wt=(Pop/tP) if year==1991
egen pwt=mean(wt), by(czone)
drop tP wt
egen tP=sum(wkpop), by(year)
gen wt=(wkpop/tP) if year==1991
egen wwt=mean(wt), by(czone)

*CONSTRUCT INITIAL AND LAGGED MANUFACTURING SHARE, LOG POPULATION AND GROWTH
foreach x in mp allpop {
	gen x=`x' if year==`beg'
	gen xx=`x' if year==`mid'
	egen `x'_`beg'=mean(x), by(czone)
	egen `x'_`mid'=mean(xx), by(czone)
	gen d`x' = `x' - `x'_`beg'
	gen d`x'_lag = `x'_`mid' - `x'_`beg'
	drop x xx 
	sort czone year
	by czone : gen `x'_lag3 = `x'[_n-3]
	by czone : gen `x'_lag5 = `x'[_n-5]
	}
	
*CREATE CHANGES IN POP AND EMPLOYMENT VARIABLES FOR EACH TIME ANNUAL DIFFERENCE WITH ALTERNATIVE BASE YEARS AND END YEAR 1991
foreach y of var tp3-mca_usd sh* {
		gen `y'`fin' = `y' if year==`fin'
		egen `y'_`fin'= mean(`y'`fin'), by(czone)
			foreach z of numlist `beg1'(1)1990 {	
				gen d`y'_`z'_`fin' = 100*(`y'_`fin' - `y') if year==`z'
		}
	}

*DEFINE CONTROL VARIABLES
tab region, gen(reg)
tab state, gen(stt)
local control0 " "
local control1 "mp_`beg'"  
local control2 "reg2-reg9 l_shind_manuf_cbp_1980"
local control4 "reg2-reg9 mp_`beg' dallpop_lag"  
foreach x in mp np tp3 tp2 {
	gen wt_`x' = wwt
	local control_`x'="`control2'"
	}
foreach x in yi tc ssa mca {
	gen wt_`x' = wwt
	local control_`x'="`control2'"
	}
foreach x in allpop wkpop odpop ygpop {
	gen wt_`x' = pwt
	local control_`x'="`control4'"
	}
	
*PRETREND CZ REGRESSIONS
foreach y of var tp3-mca {
foreach x in `base1' `base2' {
foreach v in `end1' `end2' {
	if `x' == `v' {
		noi di "next"
	}
	else {
		* globals for graphs
			global estimates
			global y = "`y'"
			global v = `x'
			global w = `v'
			global suffix "_cz_pretrend_`y'_`x'_`v'" 
		foreach z of numlist `mid1'(1)1990 {
			eststo `y'_`fin'_`z' : qui reg d`y'_`z'_`fin' `control_`y'' d_tradeusch_p1_`x'_`v' [aw=wt_`y'] if year==`z', cluster(state) 
			global b_`y'_`z'_`fin' = _b[d_tradeusch_p1_`x'_`v']
			global se_`y'_`z'_`fin' = _se[d_tradeusch_p1_`x'_`v']
			global estimates "${estimates} `y'_`z'_`fin'"
		} 
		*PLOT COEFFICIENTS
		qui do "${do}/coefplot_area.do"	
		eststo clear
	}
}
}
}

*PRETREND CZ REGRESSIONS: VARYING CONTROLS FOR POPULATION GROWTH
foreach y of var wkpop {
foreach x in `base1' `base2' {
foreach v in `end1' `end2' {
foreach u in 0 1 2 4 {	    
	if `x' == `v' {
		noi di "next"
	}
	else {
		* globals for graphs
			global estimates
			global y = "`y'"
			global v = `x'
			global w = `v'
			global suffix "_cz_pretrend_`y'_`x'_`v'_`u'" 
		foreach z of numlist `mid1'(1)1990 {
			eststo `y'_`fin'_`z' : qui reg d`y'_`z'_`fin' `control`u'' d_tradeusch_p1_`x'_`v' [aw=wt_`y'] if year==`z', cluster(state) 
			global b_`y'_`z'_`fin' = _b[d_tradeusch_p1_`x'_`v']
			global se_`y'_`z'_`fin' = _se[d_tradeusch_p1_`x'_`v']
			global estimates "${estimates} `y'_`z'_`fin'"
		} 
		*PLOT COEFFICIENTS
		qui do "${do}/coefplot_area.do"	
		eststo clear
	}
}
}
}
}

erase temp1.dta
