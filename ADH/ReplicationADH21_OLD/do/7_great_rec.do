drop _all

********************************************************************************
*THIS FILE RUNS BARTIK REGRESSIONS FOR GREAT RECESSION SHOCK ON EMPLOYMENT, INCOME, POPULATION, AND GOV'T TRANSFERS  
********************************************************************************

********************************************************************************
* DATA PREP
********************************************************************************

*DEFINE BASE-END PERIODS FOR THE TIME DIFFERENCES AND TRADE SHOCKS
local base0=2001
local base1=2006
local start1=`base0'+1
local end1=2019

*PREPARE CONTROL VARIABLES (FROM WWD AERi PAPER) FOR LATER MERGE
use "${data}/ADH_control_vars"
keep if year==2000
drop year

*LOAD ANNUAL DATA ON POPULATION, EMPLOYMENT, GOV'T TRANSFERS BY CZ
merge 1:m czone using "${data}/ADH_pop_emp_transfers.dta"
keep if _m==3
drop _m

*MERGE IN TRADE SHOCKS CONSTRUCTED USING MODIFIED VERSION OF DAVID DORN'S DO FILE
merge m:1 czone using "${data}/czone_exposure_by_period_v5_gh.dta"
tab czone if _m==1
drop if _m==1
drop _m

*MERGE IN BARTIK GREAT RECESSION SHOCKS
merge m:1 czone using "${data}/bartik_gr.dta"
drop _m

*DECADALIZE VALUES FOR TRADE SHOCKS
replace d_tradeusch_p1_2000_2012=100*d_tradeusch_p1_2000_2012*(10/(2012-2000))
replace d_tradeotch_p1_lag_2000_2012=100*d_tradeotch_p1_lag_2000_2012*(10/(2012-2000))

*CREATE DEPENDENT VARIABLES
*EMPLOYMENT-POPULATION RATIOS
gen mp=((Manuf_emp)/pop_1864_all)
gen np=((Emp_priv_nonfarm-Manuf_emp)/pop_1864_all)
gen tp3=((Emp_priv_nonfarm)/pop_1864_all)
gen lmp=log(mp)
gen lnp=log(np)
gen ltp3=log(tp3)
gen tp1=(Employment/pop_1864_all)
gen tp2=(Wage_salary_employ/pop_1864_all)
gen li=log((Wages_salaries+Supp_wage_sal)) - log(Wage_salary_employ)
gen pi=log((Proprietor_inc)) - log(Proprietor_employ)
gen unm=log(Unemploy_insur_comp) - log(pop_1864_all)
gen ltp1=log(tp1)
gen ltp2=log(tp2)
gen up=(unemployment/pop_1864_all)
gen dp=(num_dis_w/pop_1864_all)
*LOG POPULATION HEADCOUNTS
gen wkpop=log(pop_1864_all)
gen wkmen=log(pop_1864_wm+pop_1864_nwm)
gen wkfem=log(pop_1864_wf+pop_1864_nwf)
gen yg1pop=log(pop_1824_all)
gen yg2pop=log(pop_2539_all)
gen ygpop=log(pop_1839_all)
gen odpop=log(pop_1864_all-pop_1839_all)
gen yg1fem=log(pop_1824_wf+pop_1824_nwf)
gen yg1men=log(pop_1824_wm+pop_1824_nwm)
gen yg2fem=log(pop_2539_wf+pop_2539_nwf)
gen yg2men=log(pop_2539_wm+pop_2539_nwm)
gen allpop=log(Pop)
*PERSONAL INCOME PER CAPITA, GOV'T TRANSFERS PER CAPITA AND AS SHARE OF PERSONAL INCOME, COMPONENTS OF GOV'T TRANSFERS
gen lnpop =log(Pop)
gen yi=log(PInc) - lnpop
gen ti=log((PInc-Indv_gov_transfer)) - lnpop
gen di=log((Div_int_rent)) - lnpop
gen tc=log(Indv_gov_transfer) - lnpop
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
*EXPRESS DOLLARS PER CAPITA IN COMMON DECIMAL TERMS
foreach y of var yi-edt {
    gen `y'_usd = (exp(`y')*1000)/100
	}
gen mw=log(Manuf_comp/Manuf_emp)
gen nw=log((Priv_nonfarm_comp-Manuf_comp)/(Emp_priv_nonfarm-Manuf_emp))
	
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
foreach y of var mp-allpop mw nw yi-edt_usd {
		*Define base year for outcome variable (year prior to onset of Great Recession)
		gen `y'`x' = `y' if year==`x'
		egen `y'_`x' = mean(`y'`x'), by(czone)
		drop `y'`x'
	foreach z of numlist 2001(1)2019 {	
		*Construct time differences centered on 2006 
		gen d`y'_`x'_`z' = 100*(`y'_`x'-`y') if year==`z'
		}
	}
	}

*MERGE IN CONTROLS FOR BASE YEAR AND THEN RUN REGRESSIONS
*Define control variable sets
tab region, gen(reg)
tab year, gen(yr)
local control0 "reg2-reg9"  
local control1 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9"  
local control2 "l_shind_manuf_cbp_lag l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9"
local control3 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9 sh_65up_all sh_4064_all sh_0017_all sh_00up_nw"  
local control4 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9 sh_65up_all sh_4064_all sh_0017_all sh_00up_nw dlnpop7090"  
foreach y of var mp-dp mw nw {
	gen wt_`y' = popwk_`base0'
	local control_`y' = "`control3'"
	}
foreach y of var yi-edt_usd {
	gen wt_`y' = pop_`base0'
	local control_`y' = "`control3'"
	}
foreach y of var wkpop-allpop {
	gen wt_`y' = pop_`base0'
	local control_`y' = "`control4'"
	}


********************************************************************************
* REGRESSION ANALYSIS
********************************************************************************

*(0) SUMMARY STATISTICS
foreach x in dlempGR_tot dtp2_2006_2019 dyi_2006_2019 {
	tabstat `x' [aw=popwk_2001] if year == 2019, stat(mean sd p25 p50 p75) columns(statistics) format(%7.3f)
	}
corr dlempGR_tot d_tradeusch_p1_2000_2012 [aw=popwk_2001] if year == 2019

*(I) ANALYSIS OF BARTIK GREAT RECESSION SHOCKS TO CZ OUTCOMES
foreach y in tp2 li wkpop {
foreach u in `base1' {    
foreach w in tot {
	* globals for graphs
		global estimates
		global y = "`y'"
		global v = 2006
		global w = 2009
		global suffix "GR_`w'_`y'"
	foreach z of numlist 2001(1)2019 {
	    eststo `y'_`u'_`z' : qui reg d`y'_`u'_`z' `control_`y'' dlempGR_`w' [aw=wt_`y'], cluster(statefip) 
		global b_`y'_`u'_`z' = _b[dlempGR_`w']
		global se_`y'_`u'_`z' = _se[dlempGR_`w']
		global estimates "${estimates} `y'_`u'_`z'"
	} 
	esttab `y'_`u'_2001 `y'_`u'_2002 `y'_`u'_2003 `y'_`u'_2004 `y'_`u'_2005 `y'_`u'_2006 `y'_`u'_2007 `y'_`u'_2008, ar2 nocon keep(dlempGR_tot)
	esttab `y'_`u'_2009 `y'_`u'_2010 `y'_`u'_2011 `y'_`u'_2012 `y'_`u'_2013 `y'_`u'_2014 `y'_`u'_2015 `y'_`u'_2016 `y'_`u'_2017 `y'_`u'_2018 `y'_`u'_2019, ar2 nocon keep(dlempGR_tot)
	* plot coefficients
	qui do "${do}/coefplot_area.do"
	* clear estimates
	eststo clear
		}
		}
		}
