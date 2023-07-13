
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
	use "temp/state_workfile_china.dta", clear
	global unit st
	tempfile temp1
	rename yr year
	gen yr = 1990 if year == 2000
	replace yr = 2000 if year > 2000
	
	}
	else{
	use "raw_data/workfile_china.dta", clear
	global unit czs
	}

***	
*** Rigidity measures from Right-to-work and CPS || CPI data at the state level
***
		* right-to-work laws
		merge m:1 statefip using "raw_data/right2work.dta" , nogen
		* CPS rigidity measures for 2000 from Joo-Jo,Y.(2022)
		merge m:1 statefip yr using "temp/Jo_state_level_dnwr_proc.dta", nogen keep(1 3)
		* CPS rigidity measures for 1990 (constructed)
		merge m:1 statefip yr using "temp/cps1990_rigmeasures.dta", update replace 
		drop if _merge == 2
		drop _merge
		* Add data on inflation by state
		replace yr = 2007 if yr == 2000
		replace yr = 2000 if yr == 1990
		
		merge m:1 statefip yr using "temp/cpi_state_4unempl", nogen keep(1 3)
		
		
* RIGHT TO WORK DUMMY BY YEAR
cap drop N_total total_neg total_nonzero 
gen r2w= (yr>year_r2w)
replace r2w = 1 if statefip == 40 & yr == 2000  //replace Oklahoma r2w law on 2nd period, since it was introduced in 2001
	
/*******************************************************************************
                       ---RIGIDITY MEASURES BY STATE----
1. r2w: dummy = 1 if right-to-work laws are applied. Time-variant.
2. dnwr: negative changes share of total wage changes. SIPP 96 and SIPP 87 Panel. Time-variant. Quarterly wage changes.
3. dnwr_nonzero: negative wage changes of total nonzero wage changes. SIPP 96 and SIPP 87 Panel. Time-variant. Quarterly wage changes.
4. dnwr_yjj: negative changes share of total changes. CPS 1997-2000. Time-invariant. Year-over-year wage changes.
5. dnwr_nonzero_yjj: negative wage changes of total nonzero changes. CPS 1997-2000. Time-invariant. year-over-year wage changes.
6. _dmy1: indicates dummy variable = 1 if values are above median.
7. _dmy2: indicates dummy variable = 1 if values are above mean.

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

* save state level temp data for regressions
if `i' == 1 { 
	tempfile temp1
	save `temp1', replace
}

}

global tab = 1

quiet{

foreach rig_measure of varlist r2w dnwr_yjj_dmy1 dnwr_yjj_dmy2 dnwr_nonzero_yjj_dmy1 dnwr_nonzero_yjj_dmy2 d_cpi d_cpi_dmy d_cpi_lag d_cpi_lag_dmy  {

global rig_measure `rig_measure'
capture drop inter_*
capture gen inter_rigidity = d_tradeusch_pw * `rig_measure'
capture gen inter_rigidity_iv = d_tradeotch_pw_lag * `rig_measure'
label var inter_rigidity "Exposure interac."
label var d_tradeusch_pw "Exposure to China"
*global label_var : variable label `rig_measure'

estimates clear 

* Regressions at the CZ level
ivregress 2sls d_sh_unempl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
estimates store reg1

ivregress 2sls d_sh_unempl d_tradeusch_pw `rig_measure' inter_rigidity l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
estimates store reg2

ivregress 2sls d_sh_unempl (d_tradeusch_pw  = d_tradeotch_pw_lag ) inter_rigidity `rig_measure'  l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
estimates store reg3

ivregress 2sls d_sh_unempl (d_tradeusch_pw inter_rigidity =d_tradeotch_pw_lag inter_rigidity_iv) `rig_measure' l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
estimates store reg4

* Regressions at the state level
preserve
use `temp1', clear
capture drop inter_*
capture gen inter_rigidity = d_tradeusch_pw * ${rig_measure}
capture gen inter_rigidity_iv = d_tradeotch_pw_lag * ${rig_measure}
label var inter_rigidity "Exposure interac."
label var d_tradeusch_pw "Exposure to China"

ivregress 2sls d_sh_unempl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48]
estimates store reg5

ivregress 2sls d_sh_unempl d_tradeusch_pw ${rig_measure} inter_rigidity l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48]
estimates store reg6

ivregress 2sls d_sh_unempl (d_tradeusch_pw  = d_tradeotch_pw_lag ) inter_rigidity ${rig_measure}  l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48]
estimates store reg7

ivregress 2sls d_sh_unempl (d_tradeusch_pw inter_rigidity =d_tradeotch_pw_lag inter_rigidity_iv) ${rig_measure}  l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48]
estimates store reg8
restore

	noi display "Dependent variable: ${dep_d_sh_unempl}  All education levels. Full controls"
	noi display "Column 1 is ADH replic. Column 2 adds interaction (no IV for interaction). Column 3 with IV for interaction"
	noi dis "Regression uses variable `rig_measure' as rigidity measure (see def in next line)"
	noi dis "${`rig_measure'}"

	
noi esttab reg* using "results/tables/table${tab}.tex", prehead("\begin{table}[htbp] \caption{Employment effects of exposure to China shock: ${rig_measure}}" ///
"\centering" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\large" "\resizebox{\textwidth}{!}{%)" "\begin{tabular}{l*{8}{c}}" "\toprule") ///
 star(* 0.10 ** 0.05 *** 0.01) varwidth(30) modelwidth(7) ///
 cells("b(fmt(3) star )" "se(par fmt(3))" ) mgroups("Commuting Zone" "State", pattern(1 0 0 0 1 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
	mlabel("ADH" "Exp/Rig OLS" "Rigidity OLS" "Rigidity IV" "ADH" "Exp/Rig OLS" "Rigidity OLS" "Rigidity IV", depvar) alignment(c) keep(d_tradeusch_pw inter_rigidity) ///
    replace noconstant label nodepvar collabels(none) booktabs compress ///
	postfoot("\bottomrule" "\end{tabular}%" "}" "\end{table}")
	
	global tab = $tab + 1
}
}

