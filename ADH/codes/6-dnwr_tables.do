
clear
clear all
clear mata
set more off
set matsize 1000

global alonso = 1

if $alonso == 1 {
	global main "C:\Users\alove\Documents\GitHub\RUV\ADH"
	}
if $alonso == 0  {
	global main "RUV/ADH"
	}
	
cd "$main"	

********************************************************************************
********************************************************************************
* MERGING THE DIFFERENT MEASURES OF RIGIDITY TO ADH2013
********************************************************************************
********************************************************************************
forval i = 1/2 {  //state and CZs

***********************************************
*Merging ADH datasets and rigidity measures
***********************************************
if `i' == 1 {
	use "raw_data/workfile_china.dta", clear
	global unit st
	}
	else{
	use "temp/state_workfile_china.dta", clear
	global unit czs
	}

*Here we merge right2work laws and rigidity measures from Ms. Joo CPS dataset

		* right-to-work laws
		merge m:1 statefip using "raw_data/right2work.dta" , nogen
		* CPS rigidity measures for 2000 from Joo-Jo,Y.(2022)
		merge m:1 statefip using "temp/Jo_state_level_dnwr_proc.dta", keep(3) nogen
		* CPS rigidity measures for 1990 (constructed)
		merge m:1 statefip yr using"temp/cps1990_rigmeasures.dta", update replace 
		drop if _merge == 2
		drop _merge
		cap sort czone yr
		
* RIGHT TO WORK DUMMY BY YEAR
cap drop N_total total_sticky total_nonzero 
gen r2w= (yr>year_r2w)
replace r2w = 1 if statefip == 40 & yr == 2000  //replace Oklahoma r2w law on 2nd period, since it was introduced in 2001
	
/*******************************************************************************
                       ---RIGIDITY MEASURES BY STATE----
1. r2w: dummy = 1 if right-to-work laws are applied. Time-variant.
2. dnwr: negative changes share of total wage changes. SIPP 96 and SIPP 87 Panel. Time-variant. Quarterly wage changes.
3. dnwr_nonzero: negative wage changes of total nonzero wage changes. SIPP 96 and SIPP 87 Panel. Time-variant. Quarterly wage changes.
4. adj_rate: nonzero wage changes of total wage changes. SIPP 96 and SIPP 87 Panel. Time-variant. Quarterly wage changes.
5. ngtv_ratio: negative-to-zero wage changes ratio. SIPP 96 and SIPP 87 Panel. Time-variant. Quarterly wage changes.
6. dnwr_yjj: negative changes share of total changes. CPS 1997-2000. Time-invariant. Year-over-year wage changes.
7. dnwr_nonzero_yjj: negative wage changes of total nonzero changes. CPS 1997-2000. Time-invariant. Year-over-year wage changes.
8. adj_rate_yjj: nonzero wage change of total changes. CPS 1997-2000. Time-invariant. Year-over-year wage changes.
9. ngtv_ratio_yjj: negative-to-zero wage changes ratio. CPS 1997-2000. Time-invariant. Year-over-year wage changes.
10. _dmy1: indicates dummy variable = 1 if values are above median.
11. _dmy2: indicates dummy variable = 1 if values are above mean.

*** NOTES ***
1.Time-variant means values change from 1990 to 2000 for each individual. Time-invariant means the same values are used for both periods.	

2. SIPP1987 was constructed from NBER web page. Quarterly wage changes for this database were adjusted using the code of Baratierri et al. (2014) 
replication package. Measures were manually created using available data.

3. SIPP 1996 data was taken from the Barattieri et al. (2014) replication package (.dta and codes) and measures were manually created using available data.

4. Measures ending with "_yjj" were constructed using the data from the Joo, Y (2022) paper. We were provided with total observations, total wage changes, share of negative changes, share of zero changes, and share of positive changes at the state level for the 1997-2020 period. Measures were manually created using the 1997-2000 period.
********************************************************************************/
****
**** Label rigidity measure variables
****
global r2w "Indicator variable ==1 if state has right-to-work laws"
global dnwr_yjj "Share of neg wage changes in total population. CPS 1997-2000. Year-over-year wage changes."
global dnwr_yjj_dmy1 "Indicator==1 if state dnwr (share of neg changes in pop CPS) is above MEDIAN"
global dnwr_yjj_dmy2 "Indicator==1 if state dnwr (share of neg changes in pop CPS) is above MEAN"
global dnwr_nonzero_dmy1 "Indicator==1 if state neg share of nonzero wage changes SIPP above MEDIAN"
global dnwr_nonzero_dmy2 "Indicator==1 if state neg share of nonzero wage changes SIPP above MEAN"
global dnwr_nonzero_yjj_dmy1 "Indicator==1 if state neg share in nonzero wage changes CPS Time-INVARIANT above MEDIAN"
global dnwr_nonzero_yjj_dmy2 "Indicator==1 if state neg share in nonzero wage changes CPS Time-INVARIANT above MEAN"

********************************************************************************
********************************************************************************
* REGRESSIONS
********************************************************************************
********************************************************************************
order r2w dnwr_yjj_dmy1 dnwr_yjj_dmy2 dnwr_nonzero_yjj_dmy1 dnwr_nonzero_yjj_dmy2 

*lnchg_popworkage d_avg_lnwkwage_mfg d_avg_lnwkwage_nmfg
*ds r2w dnwr_yjj-ngtv_ratio_dmy2
capture log close
log using "results/log/adh_regressions_${unit}", replace
quiet{
foreach outcome in d_sh_unempl {
foreach rig_measure of varlist r2w dnwr_yjj_dmy1 dnwr_yjj_dmy2 dnwr_nonzero_yjj_dmy1 dnwr_nonzero_yjj_dmy2  {
capture drop inter_*
capture gen inter_rigidity = d_tradeusch_pw * `rig_measure'
capture gen inter_rigidity_iv = d_tradeotch_pw_lag * `rig_measure'
label var inter_rigidity "Exposure interac."
label var d_tradeusch_pw "Exposure to China"
*global label_var : variable label `rig_measure'

estimates clear 

ivregress 2sls `outcome' (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
estimates store reg1

ivregress 2sls `outcome' d_tradeusch_pw `rig_measure'  inter_rigidity l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
estimates store reg2

ivregress 2sls `outcome' (d_tradeusch_pw  = d_tradeotch_pw_lag ) inter_rigidity `rig_measure'  l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
estimates store reg3

ivregress 2sls `outcome' (d_tradeusch_pw inter_rigidity =d_tradeotch_pw_lag inter_rigidity_iv) `rig_measure'  l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
estimates store reg4

	noi display "Dependent variable: ${dep_`outcome'}  All education levels. Full controls"
	noi display "Column 1 is ADH replic. Column 2 adds regidity interaction (no IV for interaction). Column 3 with IV for interaction"
	noi dis "Regression uses variable `rig_measure' as rigidity measure (see def in next line)"
	noi dis "${`rig_measure'}"

noi esttab reg*,  ///
 star(* 0.10 ** 0.05 *** 0.01) varwidth(30) modelwidth(7) ///
 cells("b(fmt(3) star )" "se(par fmt(3))" ) ///
	mlabel("ADH" "Exp/Rig OLS" "Rigidity OLS" "Rigidity IV", depvar) alignment(c) keep(d_tradeusch_pw inter_rigidity) ///
    replace noconstant label nodepvar collabels(none) compress
	
}
}
}

capture log close
capture translate "results/log/adh_regressions_${unit}.smcl" "results/log/adh_regressions_${unit}.txt", replace linesize(250)
capture erase "results/log/adh_regressions_${unit}.smcl"


}
