drop _all

/*******************************************************************************

	THIS FILE RUNS CHINA SHOCK REGRESSIONS USING ADH AERi 2020 CONTROLS 
	ON EMPLOYMENT, INCOME, POPULATION, AND GOV'T TRANSFERS

	- REGRESSIONS ARE RUN AS A SINGLE TIME DIFFERENCE FOR EACH TIME CHANGE 
	  FROM 2000 TO 2019 (FOR MOST VARIABLES) OR 2001 TO 2019 
	  (FOR NAICS BASED VARIABLES)
	- BASELINE TRADE SHOCKS ARE 2000 TO 2012
	- EARLY ANALYSIS EXAMINES DYNAMICS IN ADJUSTMENT, 
	  MIDDLE ANALYSIS ADDS IN GRAVITY-BASED TRADE SHOCKS, 
	  LATER ANALYSIS EXAMINES HETEROGENEITY IN ADJUSTMENT 
	  
*******************************************************************************/

*DEFINE BASE-END PERIODS FOR THE TIME DIFFERENCES AND TRADE SHOCKS
global base0=1991
global base1=1991
global base2=2000
global base3=2001
global base4=2000
global base5=2000
global base6=2000
global start1=${base1}+1
global start2=${base2}+1
global start3=${base3}+1
global end0=2000
global end1=2012
global end2=2012
global end4=2007
global end5=2010
global end6=2014
global fin=2019

* what do you want the file to do? set to 1 if you want to
global sumstats 1 		// PRELIMINARIES, SUM STATS, 1ST STAGE REGRESSION
global dynamics 1 		// (I) EVALUATE DYNAMICS
global reis 1 			// (II) RESULTS FOR REIS OUTCOMES 
global gravity 1 		// (III) RESULTS FOR GRAVITY BASED TRADE SHOCKS
global heterogeneity 1 	// (IV) RUN SEPARATE REGRESSIONS FOR CZs ABOVE-BELOW MEDIAN COLLEGE SHARE, EMP-POP RATIO, OCCUPATION, INDUSTRY SPECIALIZATION IN 2000

*******************************************************************************
* DATA PREP
*******************************************************************************

*PREPARE CONTROL VARIABLES (FROM WWD AERi PAPER) FOR LATER MERGE
use "${data}/ADH_control_vars", clear
preserve 
keep if year==1990
drop year
save temp_${base1}, replace
restore
preserve 
keep if year==2000
drop year
save temp_${base2}, replace
restore
drop _all

*LOAD REIS ANNUAL DATA ON POPULATION, EMPLOYMENT, GOV'T TRANSFERS BY CZ
use "${data}/ADH_pop_emp_transfers.dta"

*MERGE IN TRADE SHOCKS CONSTRUCTED USING MODIFIED VERSION OF DAVID DORN'S DO FILE
merge m:1 czone using "${data}/czone_exposure_by_period_v5_gh.dta"
tab czone if _m==1
drop if _m==1
codebook czone
drop _m
*MERGE IN GRAVITY BASED TRADE SHOCKS INSPIRED BY ADAO ARKOLAKIS & ESPOSITO
merge m:1 czone using "${data}/ipr_gravity"
drop _m

*SUM STATS ON TRADE SHOCKS BEFORE DECADALIZING
sum d_tradeusch_p1_2000* [aw=Pop] if year==2000
sum d_tradeusch_p1_1991* [aw=Pop] if year==1990

*DECADALIZE VALUES FOR TRADE SHOCKS
foreach y in 0 1 2 4 5 6 {
	global y=`y'
	replace d_tradeusch_p1_${base${y}}_${end${y}}=100*d_tradeusch_p1_${base${y}}_${end${y}}*(10/(${end${y}}-${base${y}}))
	replace d_tradeotch_p1_lag_${base${y}}_${end${y}}=100*d_tradeotch_p1_lag_${base${y}}_${end${y}}*(10/(${end${y}}-${base${y}}))
	d d_tradeusch_p1_${base${y}}_${end${y}} d_tradeotch_p1_lag_${base${y}}_${end${y}}, full
	sum d_tradeusch_p1_${base${y}}_${end${y}} d_tradeotch_p1_lag_${base${y}}_${end${y}}
	}
foreach y in 2 {
	global y=`y'
	replace gr1_d_tradeusch_p1_${base${y}}_${end${y}}=100*gr1_d_tradeusch_p1_${base${y}}_${end${y}}*(10/(${end${y}}-${base${y}}))
	replace gr1_d_tradeotch_p1_lag_${base${y}}_${end${y}}=100*gr1_d_tradeotch_p1_lag_${base${y}}_${end${y}}*(10/(${end${y}}-${base${y}}))
	d gr1_d_tradeusch_p1_${base${y}}_${end${y}} gr1_d_tradeotch_p1_lag_${base${y}}_${end${y}}, full
	sum gr1_d_tradeusch_p1_${base${y}}_${end${y}} gr1_d_tradeotch_p1_lag_${base${y}}_${end${y}}
	}

*CREATE DEPENDENT VARIABLES
*EMPLOYMENT-POPULATION RATIOS
gen mp=((Manuf_emp)/pop_1864_all)
gen np=((Wage_salary_employ-Manuf_emp)/pop_1864_all)
gen tp3=((Emp_priv_nonfarm)/pop_1864_all)
gen tp1=(Employment/pop_1864_all)
gen tp2=(Wage_salary_employ/pop_1864_all)
gen unm=log(Unemploy_insur_comp) - log(pop_1864_all)
gen up=(unemployment/pop_1864_all)
gen nilf= 1-tp1 - up
gen dp=(num_dis_w/pop_1864_all)
gen lmp=log(mp)
gen lnp=log(np)
gen ltp3=log(tp3)
gen ltp1=log(tp1)
gen ltp2=log(tp2)
*LOG POPULATION HEADCOUNTS
gen wkpop=log(pop_1864_all)
gen wkmen=log(pop_1864_wm+pop_1864_nwm)
gen wkfem=log(pop_1864_wf+pop_1864_nwf)
gen ygpop=log(pop_1824_all+pop_2539_all)
gen yg1pop=log(pop_1824_all)
gen yg2pop=log(pop_2539_all)
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
gen li=log((Wages_salaries+Supp_wage_sal)) - lnpop
gen pi=log((Proprietor_inc)) - lnpop
gen di=log((Div_int_rent)) - lnpop
gen tc=log(Indv_gov_transfer) - lnpop
gen ret=log(Retire_insur_bene+Medicare_bene) - lnpop
gen msc=log(Indv_gov_transfer-Retire_insur_bene-Med_bene-Incm_main_bene-Unemploy_insur-Educ_assist) - lnpop
gen ssa=log(Retire_insur_bene) - lnpop
gen mca=log(Medicare_bene) - lnpop
gen mcd=log(Pub_ass_med) - lnpop
gen inc=log(Incm_main_bene) - lnpop
gen ssi=log(SSI) - lnpop
gen eit=log(EITC) - lnpop
gen snp=log(SNAP) - lnpop
gen oim=log(Other_bene) - lnpop
gen vet=log(Veteran_bene) - lnpop
gen ust=log(State_unemploy_insur) - lnpop
gen uot=log(Exclud_state_unemploy) - lnpop
gen edt=log(Educ_assist) - lnpop
*EXPRESS DOLLARS PER CAPITA IN COMMON DECIMAL TERMS
foreach y of var yi-edt {
	global y `y'
    gen ${y}_usd = (exp(${y})*1000)/100
	}
gen mw=log(Manuf_comp/Manuf_emp)
gen nw=log((Priv_nonfarm_comp-Manuf_comp)/(Emp_priv_nonfarm-Manuf_emp))
*Components of personal income
gen li_sh=100*(Wages_salaries+Supp_wage_sal)/PInc
gen pi_sh=100*(Proprietor_inc)/PInc
gen di_sh=100*(Div_int_rent)/PInc
gen tc_sh=100*(Indv_gov_transfer)/PInc
*Definition of personal income
gen y=Wages_salaries+Supp_wage_sal+Proprietor_inc+Div_int_rent+Pers_transfers-Contb_Gov_Soc_Ins+Res_adj
sum PInc y
	
*CREATE CHANGES IN POP AND EMPLOYMENT VARIABLES FOR EACH TIME ANNUAL DIFFERENCE WITH ALTERNATIVE BASE YEARS AND END YEAR 2019
*FIRST CREATE WEIGHTS FOR REGRESSION (WORKING AGE POP IN BASE YEAR FOR EMP-POP RATIOS, TOTAL POP FOR PERSONAL INCOME, GOV'T TRANSFERS)
quiet{
global x= $base2 
*foreach x in $base2 {
		*Define total population weights for base yar
		egen tPop=sum(Pop), by(year)
		gen p_${x} = Pop/tPop if year==${x}
		egen pop_${x} = mean(p_${x}), by(czone)
		drop p_${x} tPop
		*Define wking age population weights for base yar
		egen tPop=sum(pop_1864_all), by(year)
		gen p_${x} = Pop/tPop if year==${x}
		egen popwk_${x} = mean(p_${x}), by(czone)
		drop p_${x} tPop
foreach y of var tp1-allpop yi-edt_usd {
		global y `y'
		*Define base year for outcome variable
		gen ${y}${x} = ${y} if year==${x}
		egen ${y}_${x} = mean(${y}${x}), by(czone)
		foreach z of numlist $start2 (1)2019 {	
		global z = `z'
		*Construct progressively longer time differences
		gen d${y}_${x}_${z} = 100*(${y} - ${y}_${x}) if year==${z}
		}
		drop ${y}${x} ${y}_${x}
	}
	*
if ${x} == $base2 {
foreach z in $base3 {
	global z = `z'
foreach y of var mp-allpop mw nw yi-edt_usd { 
		global y `y'
		*Define base year for outcome variable
		gen ${y}${z} = ${y} if year==${z}
		egen ${y}_${z} = mean(${y}${z}), by(czone)
	foreach u of numlist $start3 (1)2019 {	
		global u = `u'
		*Construct progressively longer time differences
		gen d${y}_${z}_${u}_2 = 100*(${y} - ${y}_${z}) if year==${u}
		}
		drop ${y}${z} ${y}_${z}
		}
	}
}
}
*/

*MERGE IN CONTROLS FOR BASE YEAR AND THEN RUN REGRESSIONS
*preserve
merge m:1 czone using temp_${x}
tab region, gen(reg)
tab year, gen(yr)
*Define control variable sets
global control0 "reg2-reg9"  
global control1 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9"  
global control2 "l_shind_manuf_cbp_lag l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9"
global control3 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9 sh_65up_all sh_4064_all sh_0017_all sh_00up_nw"  
local control4 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9 sh_65up_all sh_4064_all sh_0017_all sh_00up_nw dlnpop7090"  
***
*** the first ones are the relevants 
***
foreach y of var mp-dp mw nw {
	global y `y'
	gen wt_${y} = popwk_${x}
	global control_${y} = "${control3}"
	}
foreach y of var yi-edt_usd li_sh-tc_sh {
	global y `y'
	gen wt_${y} = pop_${x}
	global control_${y} = "${control3}"
	}
foreach y of var wkpop-allpop lmp-ltp2 {
	global y `y'
	gen wt_${y} = pop_${x}
	global control_${y} = "${control4}"
	}
*******************************************************************************	
*******************************************************************************
* REGRESSION ANALYSIS
*******************************************************************************
*******************************************************************************
*******************************************************************************
* 	ADH 2021
*******************************************************************************
*2001 T0 2019
*figure names 
global mp_2001_2012_2	ADH21_manufemp_pop_fig5a
global np_2001_2012_2	ADH21_nonmanufemp_pop_fig5b
global tp2_2001_2012_2	ADH21_totwage_pop_fig5c
global up_2001_2012_2	ADH21_unemp_pop_fig5d
global tp1_2001_2012_2	ADH21_totemp_pop
global nilf_2001_2012_2	ADH21_nilf_pop
*foreach y of varlist mp-dp yg1pop yg2pop odpop allpop mw nw yi-di {
foreach y of varlist mp np tp2 tp1 up nilf {
	global y `y'
if ${x} == ${base2} {
foreach u in $base3 {
	global u = `u'
foreach v in $end2 {  
	global v = `v'
	* globals for graphs
		global estimates
		global y = "${y}"
		global suffix "_${u}_${v}_2"  
	foreach z of numlist $start3 (1)2019 {
		global z = `z'
	    eststo ${y}_${u}_${z} : qui ivreg2 d${y}_${u}_${z}_2 ${control_${y}} (d_tradeusch_p1_2000_2012=d_tradeotch_p1_lag_2000_2012)  [aw=wt_${y}], cluster(statefip) 
		global b_${y}_${u}_${z} = _b[d_tradeusch_p1_2000_2012]
		global se_${y}_${u}_${z} = _se[d_tradeusch_p1_2000_2012]
		global estimates "${estimates} ${y}_${u}_${z}"
	} 
	esttab ${y}_${u}_2002 ${y}_${u}_2003 ${y}_${u}_2004 ${y}_${u}_2005 ${y}_${u}_2006 ${y}_${u}_2007 ${y}_${u}_2008 ${y}_${u}_2009 ${y}_${u}_2010, ar2 nocon keep(d_tradeusch_p1_2000_2012)
	esttab ${y}_${u}_2011 ${y}_${u}_2012 ${y}_${u}_2013 ${y}_${u}_2014 ${y}_${u}_2015 ${y}_${u}_2016 ${y}_${u}_2017 ${y}_${u}_2018 ${y}_${u}_2019, ar2 nocon keep(d_tradeusch_p1_2000_2012)
	* plot coefficients
	qui do "${do}/coefplot_area.do"
	* clear estimates
	eststo clear
			}
			}
			}
}
*******************************************************************************
* 	ADH 2021, state level (controls)
*******************************************************************************
preserve 
*figure names 
global mp_2001_2012_2	ADH21_manufemp_pop_state_ctrls
global np_2001_2012_2	ADH21_nonmanufemp_pop_state_ctrls
global tp2_2001_2012_2	ADH21_totwage_pop_state_ctrls
global up_2001_2012_2	ADH21_unemp_pop_state_ctrls
global tp1_2001_2012_2	ADH21_totemp_pop_state_ctrls
global nilf_2001_2012_2	ADH21_nilf_pop_state_ctrls

keep mp np tp2 tp1 up dmp* nilf dnp* dtp2* dtp1* dup* dnilf* d_tradeusch_* d_tradeotch_* statefip ${control3} popwk_2000 wt_*
bys statefip: egen state_tot_pop=total(popwk_2000)
gen cz_pop_share= popwk_2000/ state_tot_pop
ds mp np tp2 tp1 up dmp* dnp* dtp2* dtp1* dup* d_tradeusch_* d_tradeotch_*  $control3 wt_* nilf dnilf*
local r `r(varlist)'
foreach v of local r {
	replace `v'=`v'*cz_pop_share
}
collapse (sum ) `r(varlist)' , by(statefip)

foreach y of varlist mp np tp2 tp1 up nilf {
	global y `y'
if ${x} == ${base2} {
foreach u in $base3 {
	global u = `u'
foreach v in $end2 {  
	global v = `v'
	* globals for graphs
		global estimates
		global y = "${y}"
		global suffix "_${u}_${v}_2"  
	foreach z of numlist $start3 (1)2019 {
		global z = `z'
	    eststo ${y}_${u}_${z} : qui ivreg2 d${y}_${u}_${z}_2 ${control_${y}} (d_tradeusch_p1_2000_2012=d_tradeotch_p1_lag_2000_2012)  [aw=wt_${y}], cluster(statefip) 
		global b_${y}_${u}_${z} = _b[d_tradeusch_p1_2000_2012]
		global se_${y}_${u}_${z} = _se[d_tradeusch_p1_2000_2012]
		global estimates "${estimates} ${y}_${u}_${z}"
	} 
	esttab ${y}_${u}_2002 ${y}_${u}_2003 ${y}_${u}_2004 ${y}_${u}_2005 ${y}_${u}_2006 ${y}_${u}_2007 ${y}_${u}_2008 ${y}_${u}_2009 ${y}_${u}_2010, ar2 nocon keep(d_tradeusch_p1_2000_2012)
	esttab ${y}_${u}_2011 ${y}_${u}_2012 ${y}_${u}_2013 ${y}_${u}_2014 ${y}_${u}_2015 ${y}_${u}_2016 ${y}_${u}_2017 ${y}_${u}_2018 ${y}_${u}_2019, ar2 nocon keep(d_tradeusch_p1_2000_2012)
	* plot coefficients
	qui do "${do}/coefplot_area.do"
	* clear estimates
	eststo clear
			}
			}
			}
}
restore 
*******************************************************************************
* 	ADH 2021, state level (no controls)
*******************************************************************************
preserve 
*figure names 
global mp_2001_2012_2	ADH21_manufemp_pop_state_noctrls
global np_2001_2012_2	ADH21_nonmanufemp_pop_state_noctrls
global tp2_2001_2012_2	ADH21_totwage_pop_state_noctrls
global up_2001_2012_2	ADH21_unemp_pop_state_noctrls
global tp1_2001_2012_2	ADH21_totemp_pop_state_noctrls
global nilf_2001_2012_2	ADH21_nilf_pop_state_noctrls

keep mp np tp2 tp1 up dmp* dnp* dtp2* dtp1* dup* d_tradeusch_* d_tradeotch_* statefip ${control3} popwk_2000 wt_* nilf dnilf*
bys statefip: egen state_tot_pop=total(popwk_2000)
gen cz_pop_share= popwk_2000/ state_tot_pop
ds mp np tp2 tp1 up dmp* dnp* dtp2* dtp1* dup* d_tradeusch_* d_tradeotch_*  $control3 wt_* nilf  dnilf*
local r `r(varlist)'
foreach v of local r {
	replace `v'=`v'*cz_pop_share
}
collapse (sum ) `r(varlist)' , by(statefip)

foreach y of varlist mp np tp2 tp1 up nilf {
	global y `y'
if ${x} == ${base2} {
foreach u in $base3 {
	global u = `u'
foreach v in $end2 {  
	global v = `v'
	* globals for graphs
		global estimates
		global y = "${y}"
		global suffix "_${u}_${v}_2"  
	foreach z of numlist $start3 (1)2019 {
		global z = `z'
	    eststo ${y}_${u}_${z} : qui ivreg2 d${y}_${u}_${z}_2  (d_tradeusch_p1_2000_2012=d_tradeotch_p1_lag_2000_2012)  [aw=wt_${y}], cluster(statefip) 
		global b_${y}_${u}_${z} = _b[d_tradeusch_p1_2000_2012]
		global se_${y}_${u}_${z} = _se[d_tradeusch_p1_2000_2012]
		global estimates "${estimates} ${y}_${u}_${z}"
	} 
	esttab ${y}_${u}_2002 ${y}_${u}_2003 ${y}_${u}_2004 ${y}_${u}_2005 ${y}_${u}_2006 ${y}_${u}_2007 ${y}_${u}_2008 ${y}_${u}_2009 ${y}_${u}_2010, ar2 nocon keep(d_tradeusch_p1_2000_2012)
	esttab ${y}_${u}_2011 ${y}_${u}_2012 ${y}_${u}_2013 ${y}_${u}_2014 ${y}_${u}_2015 ${y}_${u}_2016 ${y}_${u}_2017 ${y}_${u}_2018 ${y}_${u}_2019, ar2 nocon keep(d_tradeusch_p1_2000_2012)
	* plot coefficients
	qui do "${do}/coefplot_area.do"
	* clear estimates
	eststo clear
			}
			}
			}
}
restore 
*******************************************************************************
*******************************************************************************
* 	Adding ADH Data
*******************************************************************************
*******************************************************************************
capture drop _m
preserve
*merge ADH 2013 exposure and IV 
use "workfile_china.dta", clear
keep if yr==2000
keep czone d_tradeusch_pw d_tradeotch_pw_lag
tempfile adh13
save `adh13' , replace
restore 
merge m:1 czone using `adh13'
drop _m

*******************************************************************************
* 	ADH 2021 with ADH 2013 shock, CZ-level
*******************************************************************************
*figure names 
global mp_2001_2012_2	ADH13_manufemp_pop_fig5a
global np_2001_2012_2	ADH13_nonmanufemp_pop_fig5b
global tp2_2001_2012_2	ADH13_totwage_pop_fig5c
global up_2001_2012_2	ADH13_unemp_pop_fig5d
global tp1_2001_2012_2	ADH13_totemp_pop
global nilf_2001_2012_2	ADH13_nilf_pop

*foreach y of varlist mp-dp yg1pop yg2pop odpop allpop mw nw yi-di {
foreach y of varlist mp np tp2 tp1 up nilf {
	global y `y'
if ${x} == ${base2} {
foreach u in $base3 {
	global u = `u'
foreach v in $end2 {  
	global v = `v'
	* globals for graphs
		global estimates
		global y = "${y}"
		global suffix "_${u}_${v}_2"  
	foreach z of numlist $start3 (1)2019 {
		global z = `z'
	    eststo ${y}_${u}_${z} : qui ivreg2 d${y}_${u}_${z}_2 ${control_${y}} (d_tradeusch_pw=d_tradeotch_pw_lag)  [aw=wt_${y}], cluster(statefip) 
		global b_${y}_${u}_${z} = _b[d_tradeusch_pw]
		global se_${y}_${u}_${z} = _se[d_tradeusch_pw]
		global estimates "${estimates} ${y}_${u}_${z}"
	} 
	esttab ${y}_${u}_2002 ${y}_${u}_2003 ${y}_${u}_2004 ${y}_${u}_2005 ${y}_${u}_2006 ${y}_${u}_2007 ${y}_${u}_2008 ${y}_${u}_2009 ${y}_${u}_2010, ar2 nocon keep(d_tradeusch_pw)
	esttab ${y}_${u}_2011 ${y}_${u}_2012 ${y}_${u}_2013 ${y}_${u}_2014 ${y}_${u}_2015 ${y}_${u}_2016 ${y}_${u}_2017 ${y}_${u}_2018 ${y}_${u}_2019, ar2 nocon keep(d_tradeusch_pw)
	* plot coefficients
	qui do "${do}/coefplot_area.do"
	* clear estimates
	eststo clear
			}
			}
			}
}

*******************************************************************************
* 	ADH 2021 with ADH 2013 shock, state-level (controls)
*******************************************************************************
preserve 
*figure names 
global mp_2001_2012_2	ADH13_manufemp_pop_state_ctrls
global np_2001_2012_2	ADH13_nonmanufemp_pop_state_ctrls
global tp2_2001_2012_2	ADH13_totwage_pop_state_ctrls
global up_2001_2012_2	ADH13_unemp_pop_state_ctrls
global tp1_2001_2012_2	ADH13_totemp_pop_state_ctrls
global nilf_2001_2012_2	ADH13_nilf_pop_state_ctrls

keep mp np tp2 tp1 up dmp* dnp* dtp2* dtp1* dup* d_tradeusch_* d_tradeotch_* statefip ${control3} popwk_2000 wt_* nilf dnilf*
bys statefip: egen state_tot_pop=total(popwk_2000)
gen cz_pop_share= popwk_2000/ state_tot_pop
ds mp np tp2 tp1 up dmp* dnp* dtp2* dtp1* dup* d_tradeusch_* d_tradeotch_*  $control3 wt_* nilf  dnilf*
local r `r(varlist)'
foreach v of local r {
	replace `v'=`v'*cz_pop_share
}
collapse (sum ) `r(varlist)' , by(statefip)

*foreach y of varlist mp-dp yg1pop yg2pop odpop allpop mw nw yi-di {
foreach y of varlist mp np tp2 tp1 up nilf {
	global y `y'
if ${x} == ${base2} {
foreach u in $base3 {
	global u = `u'
foreach v in $end2 {  
	global v = `v'
	* globals for graphs
		global estimates
		global y = "${y}"
		global suffix "_${u}_${v}_2"  
	foreach z of numlist $start3 (1)2019 {
		global z = `z'
	    eststo ${y}_${u}_${z} : qui ivreg2 d${y}_${u}_${z}_2 ${control_${y}} (d_tradeusch_pw=d_tradeotch_pw_lag)  [aw=wt_${y}], cluster(statefip) 
		global b_${y}_${u}_${z} = _b[d_tradeusch_pw]
		global se_${y}_${u}_${z} = _se[d_tradeusch_pw]
		global estimates "${estimates} ${y}_${u}_${z}"
	} 
	esttab ${y}_${u}_2002 ${y}_${u}_2003 ${y}_${u}_2004 ${y}_${u}_2005 ${y}_${u}_2006 ${y}_${u}_2007 ${y}_${u}_2008 ${y}_${u}_2009 ${y}_${u}_2010, ar2 nocon keep(d_tradeusch_pw)
	esttab ${y}_${u}_2011 ${y}_${u}_2012 ${y}_${u}_2013 ${y}_${u}_2014 ${y}_${u}_2015 ${y}_${u}_2016 ${y}_${u}_2017 ${y}_${u}_2018 ${y}_${u}_2019, ar2 nocon keep(d_tradeusch_pw)
	* plot coefficients
	qui do "${do}/coefplot_area.do"
	* clear estimates
	eststo clear
			}
			}
			}
}
restore 
*******************************************************************************
* 	ADH 2021 with ADH 2013 shock, state-level (no controls)
*******************************************************************************
preserve 
*figure names 
global mp_2001_2012_2	ADH13_manufemp_pop_state_noctrls
global np_2001_2012_2	ADH13_nonmanufemp_pop_state_noctrls
global tp2_2001_2012_2	ADH13_totwage_pop_state_noctrls
global up_2001_2012_2	ADH13_unemp_pop_state_noctrls
global tp1_2001_2012_2	ADH13_totemp_pop_state_noctrls
global nilf_2001_2012_2	ADH13_nilf_pop_state_noctrls

keep mp np tp2 tp1 up dmp* dnp* dtp2* dtp1* dup* d_tradeusch_* d_tradeotch_* statefip ${control3} popwk_2000 wt_* nilf dnilf*
bys statefip: egen state_tot_pop=total(popwk_2000)
gen cz_pop_share= popwk_2000/ state_tot_pop
ds mp np tp2 tp1 up dmp* dnp* dtp2* dtp1* dup* d_tradeusch_* d_tradeotch_*  $control3 wt_* nilf dnilf*
local r `r(varlist)'
foreach v of local r {
	replace `v'=`v'*cz_pop_share
}
collapse (sum ) `r(varlist)' , by(statefip)

foreach y of varlist mp np tp2 tp1 up nilf {
	global y `y'
if ${x} == ${base2} {
foreach u in $base3 {
	global u = `u'
foreach v in $end2 {  
	global v = `v'
	* globals for graphs
		global estimates
		global y = "${y}"
		global suffix "_${u}_${v}_2"  
	foreach z of numlist $start3 (1)2019 {
		global z = `z'
	    eststo ${y}_${u}_${z} : qui ivreg2 d${y}_${u}_${z}_2 (d_tradeusch_pw=d_tradeotch_pw_lag)  [aw=wt_${y}], cluster(statefip) 
		global b_${y}_${u}_${z} = _b[d_tradeusch_pw]
		global se_${y}_${u}_${z} = _se[d_tradeusch_pw]
		global estimates "${estimates} ${y}_${u}_${z}"
	} 
	esttab ${y}_${u}_2002 ${y}_${u}_2003 ${y}_${u}_2004 ${y}_${u}_2005 ${y}_${u}_2006 ${y}_${u}_2007 ${y}_${u}_2008 ${y}_${u}_2009 ${y}_${u}_2010, ar2 nocon keep(d_tradeusch_pw)
	esttab ${y}_${u}_2011 ${y}_${u}_2012 ${y}_${u}_2013 ${y}_${u}_2014 ${y}_${u}_2015 ${y}_${u}_2016 ${y}_${u}_2017 ${y}_${u}_2018 ${y}_${u}_2019, ar2 nocon keep(d_tradeusch_pw)
	* plot coefficients
	qui do "${do}/coefplot_area.do"
	* clear estimates
	eststo clear
			}
			}
			}
}
restore 
/*	
***
* (III) RESULTS FOR GRAVITY BASED TRADE SHOCKS
***
if $gravity == 1 {
*Outcomes over 2002 to 2019
foreach y in tp2 mp np {
	global y `y'
if ${x} == ${base2} {
foreach u in $base3 {
foreach v in $end2 {  
	* globals for graphs
		global estimates
		global y = "${y}"
		global v = 2000
		global w = 2012
		global suffix "local_${y}_${u}_${v}"    
	foreach z of numlist $start3 (1)2019 {
		global z = `z'
	    eststo ${y}_${u}_${z} : qui ivreg2 d${y}_${u}_${z}_2 ${control_${y}} (d_tradeusch_p1_2000_2012 gr1_d_tradeusch_p1_2000_2012=d_tradeotch_p1_lag_2000_2012 gr1_d_tradeotch_p1_lag_2000_2012)  [aw=wt_${y}], cluster(statefip) 
		global b_${y}_${u}_${z} = _b[d_tradeusch_p1_2000_2012]
		global se_${y}_${u}_${z} = _se[d_tradeusch_p1_2000_2012]
		global b_gr_${y}_${u}_${z} = _b[gr1_d_tradeusch_p1_2000_2012]
		global se_gr_${y}_${u}_${z} = _se[gr1_d_tradeusch_p1_2000_2012]
		global estimates "${estimates} ${y}_${u}_${z}"
	} 
	esttab ${y}_${u}_2002 ${y}_${u}_2003 ${y}_${u}_2004 ${y}_${u}_2005 ${y}_${u}_2006 ${y}_${u}_2007 ${y}_${u}_2008 ${y}_${u}_2009 ${y}_${u}_2010, ar2 nocon keep(d_tradeusch_p1_2000_2012 gr1_d_tradeusch_p1_2000_2012)
	esttab ${y}_${u}_2011 ${y}_${u}_2012 ${y}_${u}_2013 ${y}_${u}_2014 ${y}_${u}_2015 ${y}_${u}_2016 ${y}_${u}_2017 ${y}_${u}_2018 ${y}_${u}_2019, ar2 nocon keep(d_tradeusch_p1_2000_2012 gr1_d_tradeusch_p1_2000_2012)
	* plot coefficients
	qui do "${do}/coefplot_area.do"
	* clear estimates
	eststo clear
			}
			}
			}
	}
}
	
* (VI) RUN SEPARATE REGRESSIONS FOR CZs ABOVE-BELOW MEDIAN COLLEGE SHARE, EMP-POP RATIO, OCCUPATION, INDUSTRY SPECIALIZATION IN 2000
if $heterogeneity == 1 {
* set up matrix for Benjamini-Hochberg q-values
loc matrix_count = 216
matrix Pool = J(`matrix_count', 8, .)
global suffix "_by_"    

foreach y in mp tp2 wkpop yi np lnp {
	global y `y'
if ${x} == ${base2} {
foreach u in $base3 {	
foreach v in $end2 {
	global u= `u'
	global v= `v'
foreach q in ba_pop hhi_ind_emp /*emp_pop for_pop hhi_occ_emp*/ {
qui foreach z of numlist $start3 (1)2019 {
	global z = `z'
	* identify loop and heterogeneity test
	loc loop = `loop' + 1
	loc tests `tests' ${y},${z},`q'	
	* interact all control variables with q
	qui ds ${control_${y}}
	foreach var in `r(varlist)' {
		local ctrl_int_${y} `ctrl_int_${y}' i.med_`q'##c.`var'
	}
	* regressions for czones for above / below median 
	foreach r of num 0 1 {            
		eststo ${y}_${u}_${z}_`r' : ivreg2 d${y}_${u}_${z} ${control_${y}} (d_tradeusch_p1_${x}_${v}=d_tradeotch_p1_lag_${x}_${v})  [aw=wt_${y}] if med_`q'==`r', cluster(statefip) partial(${control_${y}})
		matrix b = e(b)
		matrix V = e(V)
		loc coeff_`r'_`loop' = b[1,1]
		loc se_`r'_`loop' = sqrt(V[1,1])
	} 
	* test whether coefficient for czones for above / below median are the same
	eststo ${y}_${u}_${z} : ivreg2 d${y}_${u}_${z} `ctrl_int_${y}' (i.med_`q'##c.d_tradeusch_p1_${x}_${v}=i.med_`q'##c.d_tradeotch_p1_lag_${x}_${v})  [aw=wt_${y}], cluster(statefip) partial(`ctrl_int_${y}')
	/* czones below median have coefficient d_tradeusch_p1, while those above 
	have coefficient d_tradeusch_p1 + (d_tradeusch_p1 x 1(med_`q')) 
	=> sufficient to look at p-value of (d_tradeusch_p1 x 1(med_`q')) */
	test 1.med_`q'#c.d_tradeusch_p1_${x}_${v} = 0 
	loc F_nodiff_`loop' = r(chi2)
	loc p_nodiff_`loop' = r(p)
	matrix b = e(b)
	matrix V = e(V)
	loc coeff_diff_`loop' = b[1,1]
	loc se_diff_`loop' = sqrt(V[1,1])
	* put into matrix set up above
	matrix Pool[`loop',1] = `coeff_diff_`loop''
	matrix Pool[`loop',2] = `se_diff_`loop''
	matrix Pool[`loop',3] = `F_nodiff_`loop''
	matrix Pool[`loop',4] = `p_nodiff_`loop''
	matrix Pool[`loop',5] = `coeff_0_`loop''
	matrix Pool[`loop',6] = `se_0_`loop''
	matrix Pool[`loop',7] = `coeff_1_`loop''
	matrix Pool[`loop',8] = `se_1_`loop''
} 

noi di "{bf:Results for ${y} by `q':}"
noi di "	`q' below median:"
	esttab ${y}_${u}_2002_0 ${y}_${u}_2003_0 ${y}_${u}_2004_0 ${y}_${u}_2005_0 ${y}_${u}_2006_0 ${y}_${u}_2007_0 ${y}_${u}_2008_0 ${y}_${u}_2009_0 ${y}_${u}_2010_0, nocon keep(d_tradeusch_p1_${x}_${v})
	esttab ${y}_${u}_2011_0 ${y}_${u}_2012_0 ${y}_${u}_2013_0 ${y}_${u}_2014_0 ${y}_${u}_2015_0 ${y}_${u}_2016_0 ${y}_${u}_2017_0 ${y}_${u}_2018_0 ${y}_${u}_2019_0, nocon keep(d_tradeusch_p1_${x}_${v})
noi di "	`q' above median:"
	esttab ${y}_${u}_2002_1 ${y}_${u}_2003_1 ${y}_${u}_2004_1 ${y}_${u}_2005_1 ${y}_${u}_2006_1 ${y}_${u}_2007_1 ${y}_${u}_2008_1 ${y}_${u}_2009_1 ${y}_${u}_2010_1, nocon keep(d_tradeusch_p1_${x}_${v})
	esttab ${y}_${u}_2011_1 ${y}_${u}_2012_1 ${y}_${u}_2013_1 ${y}_${u}_2014_1 ${y}_${u}_2015_1 ${y}_${u}_2016_1 ${y}_${u}_2017_1 ${y}_${u}_2018_1 ${y}_${u}_2019_1, nocon keep(d_tradeusch_p1_${x}_${v})
noi di "	Difference (Above median - below median):"
	esttab ${y}_${u}_2002 ${y}_${u}_2003 ${y}_${u}_2004 ${y}_${u}_2005 ${y}_${u}_2006 ${y}_${u}_2007 ${y}_${u}_2008 ${y}_${u}_2009 ${y}_${u}_2010, nocon keep(1.med_`q'#c.d_tradeusch_p1_${x}_${v})
	esttab ${y}_${u}_2011 ${y}_${u}_2012 ${y}_${u}_2013 ${y}_${u}_2014 ${y}_${u}_2015 ${y}_${u}_2016 ${y}_${u}_2017 ${y}_${u}_2018 ${y}_${u}_2019, nocon keep(1.med_`q'#c.d_tradeusch_p1_${x}_${v})
eststo clear
		}
		}
		}
		}
} // outcomes for part vi)
	
	* Benjamini-Hochberg minimal q-values. Note: code from Anderson (2008)
	clear
	loc testcount: word count `tests'
	set obs `testcount'
	gen initial_order = _n
	gen testname = ""
	forvalues i = 1/`testcount' {
		loc var: word `i' of `tests'
		replace testname = "`var'" if initial_order==`i'
	}
	svmat Pool
	rename Pool1 coef
	rename Pool2 se 
	rename Pool3 f_nodiff
	rename Pool4 p_nodiff 
	rename Pool5 coef_below
	rename Pool6 se_below 
	rename Pool7 coef_above
	rename Pool8 se_above 
	/* Loop that adjusts p-values for null hypothesis of no differences
	across czone baseline characteristics. Checks which hypotheses are rejected 
	at q=.999, q=.998, ..., q=0.000.      */
	gen q_equal = .
	* Sorting ascending order, unadjusted p-values
	sort p_nodiff
	qui sum p_nodiff
	drop if mi(p_nodiff)
	qui sum p_nodiff
	* Collecting total number of hypotheses tested
	loc count `r(N)'
	* Collecting rank of unadjusted p-values
	gen order_eq = _n
	forvalues qval = .999(-.001).000{
	* Generate value q'*r/M, where r is the rank and M is the total number of hypotheses being tested
		gen fdr_temp1 = `qval'*order_eq/`count'
		* Generate binary variable checking condition p(r) <= q'*r/M
		gen reject_temp1 = (fdr_temp1>=p_nodiff) if p_nodiff!=.
		* Generate variable containing p-value ranks for all p-values that meet above condition
		gen reject_rank1 = reject_temp1*order_eq
		* Record the rank of the largest p-value that meets above condition
		egen total_rejected1 = max(reject_rank1)
		* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
		replace q_equal = `qval' if order_eq <= total_rejected1 & order_eq!=.
		drop fdr_temp* reject_temp* reject_rank* total_rejected*
		sort initial_order
	}
	* Saving adjusted q-values in Stata
	recode q_equal (.=.9999)
	split testname, parse(,)
	ren (testname1  testname2  testname3) (y z q)
	destring z, replace
	drop testname order_eq
	label variable coef "(trade shock x 1(above median)) - (trade shock x 1(below median))"
	label variable se "se of coef"
	label variable p_nodiff "p-value of coef"
	label variable f_nodiff "F-test of coef"
	label variable coef_below "trade shock x 1(below median)"
	label variable se_below "se of coef_below"
	label variable coef_above "trade shock x 1(above median)"
	label variable se_above "se of coef_above"
	label variable q_equal "Benjamini-Hochberg q-value"
	label variable y "outcome"
	label variable z "end year"
	label variable q "sample cut"
	compress
	order y z q initial_order
	sort initial_order
	save "${output}/jorda_annual_partvi_BHqvalues.dta", replace
	* number of false positives 
	local unadj_fp = round(`matrix_count'*.05,.01)
	noi di "number of false positives in unadjusted procedure: `unadj_fp'" 
	sum q_equal if q_equal <= .05
	local bh_fp = round(`r(N)'*`r(max)',.01)
	noi di "number of false positives in BH procedure: `bh_fp'" 
	* make coefficient plots
	global x = ${x}
	global v = ${end2}
	* plot coefficients
	qui do "${do}/coefplot_area.do"	
}	
*restore
*}
*/	
erase temp_${base2}.dta
erase temp_${base1}.dta

