drop _all

*******************************************************************************
*THIS FILE RUNS BARTIK REGRESSIONS FOR GREAT RECESSION SHOCK ON EMPLOYMENT, INCOME, POPULATION, AND GOV'T TRANSFERS  
*******************************************************************************

*******************************************************************************
* DATA PREP
*******************************************************************************

*DEFINE BASE-END PERIODS FOR THE TIME DIFFERENCES AND TRADE SHOCKS
local base0=1980
local base1=1980
local start1=`base0'+1
local end1=2019

*LOAD ANNUAL DATA ON POPULATION, EMPLOYMENT, GOV'T TRANSFERS BY CZ
use "${data}/pop-czone-1970-2016.dta"
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
save temp1, replace
use "${data}/czone_pop_all.dta"
foreach x in all wm wf nwm nwf {
foreach y in 1864 1839 1824 2539 {
	ren age`y'_`x' pop_`y'_`x'
	label var pop_`y'_`x' "Population of `x', ages `y'"
	}
	}
keep if year>=2017 
tab year
append using temp1
drop pop0017_all-pop_00up_nwf
merge 1:1 czone year using "${data}/CA4_CZ.dta"
drop _m
merge 1:1 czone year using "${data}/CA30_CZ.dta"
drop _m
merge 1:1 czone year using "${data}/CA35_CZ.dta"
drop _m

*MERGE IN TRADE SHOCKS CONSTRUCTED USING MODIFIED VERSION OF DAVID DORN'S DO FILE
merge m:1 czone using "${data}/czone_exposure_by_period_v5_gh.dta"
tab czone if _m==1
drop if _m==1
drop _m

*MERGE IN BARTIK COAL, STEEL SHOCKS
merge m:1 czone using "${data}/bartik_coal_steel"
keep if _m==3
drop _m

*DECADALIZE VALUES FOR TRADE SHOCKS
replace d_tradeusch_p1_2000_2012=100*d_tradeusch_p1_2000_2012*(10/(2012-2000))

*CREATE DEPENDENT VARIABLES
*EMPLOYMENT-POPULATION RATIOS
gen tp1=(Employment/pop_1864_all)
gen tp2=(Wage_salary_employ/pop_1864_all)
gen li=log((Wages_salaries+Supp_wage_sal)) - log(Wage_salary_employ)
gen ltp1=log(tp1)
gen ltp2=log(tp2)
*LOG POPULATION HEADCOUNTS
gen wkpop=log(pop_1864_all)
gen wkmen=log(pop_1864_wm+pop_1864_nwm)
gen wkfem=log(pop_1864_wf+pop_1864_nwf)
gen ygpop=log(pop_1839_all)
gen odpop=log(pop_1864_all-pop_1839_all)
gen allpop=log(Pop)
*PERSONAL INCOME PER CAPITA, GOV'T TRANSFERS PER CAPITA AND AS SHARE OF PERSONAL INCOME, COMPONENTS OF GOV'T TRANSFERS
gen lnpop =log(Pop)
gen yi=log(PInc) - lnpop
gen ti=log((PInc-Indv_gov_transfer)) - wkpop
gen pi=log((Proprietor_inc)) - lnpop
gen di=log((Div_int_rent)) - lnpop
gen tc=log(Indv_gov_transfer) - lnpop
gen unm=log(Unemploy_insur_comp) - lnpop
gen ret=log(Retire_insur_bene+Medicare_bene) - lnpop
gen oth=log(Indv_gov_transfer-Retire_insur_bene-Medicare_bene-Unemploy_insur_comp) - lnpop
gen ssa=log(Retire_insur_bene) - lnpop
gen mca=log(Medicare_bene) - lnpop
gen mcd=log(Pub_ass_med) - lnpop
gen inc=log(Incm_main_bene) - lnpop
gen ssi=log(SSI) - lnpop
gen eit=log(EITC) - lnpop
gen snp=log(SNAP) - lnpop
gen oim=log(Other_bene) - lnpop
gen edt=log(Educ_assist) - lnpop
	
*CREATE CHANGES IN POP AND EMPLOYMENT VARIABLES FOR EACH TIME ANNUAL DIFFERENCE WITH ALTERNATIVE BASE YEARS AND END YEAR 2016
*FIRST CREATE WEIGHTS FOR REGRESSION (WORKING AGE POP IN BASE YEAR FOR EMP-POP RATIOS, TOTAL POP FOR PERSONAL INCOME, GOV'T TRANSFERS)
foreach x in `base0' {
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
	}
foreach x in `base1' {
foreach y of var tp1-allpop yi-edt {
		*Define base year for outcome variable (year prior to onset of Great Recession)
		gen `y'`x' = `y' if year==`x'
		egen `y'_`x' = mean(`y'`x'), by(czone)
		drop `y'`x'
	foreach z of numlist 1970(1)2019 {	
		*Construct time differences centered on 1980
		gen d`y'_`x'_`z' = 100*(`y'_`x'-`y') if year==`z'
		}
	}
	}

*MERGE IN CONTROLS FOR BASE YEAR AND THEN RUN REGRESSIONS
*Define control variable sets
tab region, gen(reg)
tab year, gen(yr)
gen coal=dlemp_coal2000==0
local control0 "reg2-reg9"  
local control3 "coal mempsh80 ipopsh80 cpopsh80 npopsh80 fempsh80 reg2-reg9"  
local control4 "coal mempsh80 ipopsh80 cpopsh80 npopsh80 fempsh80 reg2-reg9 dlpop6080"  
foreach y of var tp1-tp2 li {
	gen wt_`y' = popwk_`base0'
	local control_`y' = "`control3'"
	}
foreach y of var yi-edt {
	gen wt_`y' = pop_`base0'
	local control_`y' = "`control3'"
	}
foreach y of var wkpop-allpop {
	gen wt_`y' = pop_`base0'
	local control_`y' = "`control4'"
	}

***
* REGRESSION ANALYSIS
***	

*(0) SUMMARY STATISTICS
foreach y in 2006 2019 {
foreach x in dlemp_coal2000 dtp2_1980_`y' dyi_1980_`y' {
	tabstat `x' [aw=popwk_1980] if year == `y', stat(mean sd p5 p10 p25 p50 p75 p90 p95) columns(statistics) format(%7.3f)
	}
	}
corr dlemp_coal2000 d_tradeusch_p1_2000_2012 [aw=popwk_1980] if year == 2019
tab coal if year==2019

*(I) ANALYSIS OF BARTIK COAL SHOCKS TO CZ OUTCOMES
foreach y of varlist tp2 li wkpop {
foreach u in `base1' {    
foreach w in coal {
	* globals for graphs
		global estimates
		global y = "`y'"
		global v = "`w'"
		global w = 2000
		global suffix "CS_`w'_`y'"
	foreach z of numlist 1970(1)2019 {
	    eststo `y'_`u'_`z' : qui reg d`y'_`u'_`z' `control_`y'' dlemp_`w'2000 [aw=wt_`y'], cluster(statefip) 
		global b_`y'_`u'_`z' = _b[dlemp_`w'2000]
		global se_`y'_`u'_`z' = _se[dlemp_`w'2000]
		global estimates "${estimates} `y'_`u'_`z'"
	} 
	esttab `y'_`u'_1970 `y'_`u'_1971 `y'_`u'_1972 `y'_`u'_1973 `y'_`u'_1974 `y'_`u'_1975 `y'_`u'_1976 `y'_`u'_1977 `y'_`u'_1978 `y'_`u'_1979, ar2 nocon keep(dlemp_coal2000)
	esttab `y'_`u'_1980 `y'_`u'_1981 `y'_`u'_1982 `y'_`u'_1983 `y'_`u'_1984 `y'_`u'_1985 `y'_`u'_1986 `y'_`u'_1987 `y'_`u'_1988 `y'_`u'_1989, ar2 nocon keep(dlemp_coal2000)
	esttab `y'_`u'_1990 `y'_`u'_1991 `y'_`u'_1992 `y'_`u'_1993 `y'_`u'_1994 `y'_`u'_1995 `y'_`u'_1996 `y'_`u'_1997 `y'_`u'_1998 `y'_`u'_1999, ar2 nocon keep(dlemp_coal2000)
	esttab `y'_`u'_2000 `y'_`u'_2001 `y'_`u'_2002 `y'_`u'_2003 `y'_`u'_2004 `y'_`u'_2005 `y'_`u'_2006 `y'_`u'_2007 `y'_`u'_2008 `y'_`u'_2009, ar2 nocon keep(dlemp_coal2000)
	esttab `y'_`u'_2010 `y'_`u'_2011 `y'_`u'_2012 `y'_`u'_2013 `y'_`u'_2014 `y'_`u'_2015 `y'_`u'_2016 `y'_`u'_2017 `y'_`u'_2018 `y'_`u'_2019, ar2 nocon keep(dlemp_coal2000)	
	* plot coefficients
	qui do "${do}/coefplot_area.do"
	* clear estimates
	eststo clear
		}
		}
		}
		
erase temp1.dta
	