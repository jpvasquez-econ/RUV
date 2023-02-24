***********************************************
* Impact of Chinese Imports on Local Labor Markets
***********************************************
/*
In this code, we calculate the regressions of interest from Tables 4, 5 and 7 
of ADH (2013) at the State Level. 

Input file: 

1. data/2-final_data/workfile_china_agg.dta Final dataset at the state level
*/


***********************************************
* Administrative Commands
***********************************************
use ../data/2-final_data/workfile_china_agg.dta, clear
gen t2=(year==2000)
******************************************************************************************************************************************************************************************
* Table 4: Population Change
******************************************************************************************************************************************************************************************
* Panel C
******************************************************************************************************************************************************************************************
* Column 1
******************************************************************************************************************************************************************************************

ivregress 2sls lnchg_popworkage (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], robust

ivregress 2sls lnchg_popworkage (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* t2 [aw=timepwt48] 

******************************************************************************************************************************************************************************************
* Table 5: Change in Employment, Unemployment and Non-Employment
******************************************************************************
*empl

ivregress 2sls d_sh_empl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], robust

ivregress 2sls d_sh_empl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* t2 [aw=timepwt48] 

************************************************************************************************************
* Panel B
******************************************************************************************************************************************************************************************
* Column 3
******************************************************************************************************************************************************************************************

ivregress 2sls d_sh_unempl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], robust

ivregress 2sls d_sh_unempl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* t2 [aw=timepwt48] 

******************************************************************************************************************************************************************************************
* Column 4
******************************************************************************************************************************************************************************************

ivregress 2sls d_sh_nilf (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], robust

ivregress 2sls d_sh_nilf (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* t2 [aw=timepwt48] 

******************************************************************************************************************************************************************************************
* Table 7: Manufacturing vs. Non-Manufacturing
******************************************************************************************************************************************************************************************
* Panel B
******************************************************************************************************************************************************************************************
* Column 1
******************************************************************************************************************************************************************************************

ivregress 2sls d_avg_lnwkwage_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], robust

ivregress 2sls d_avg_lnwkwage_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* t2 [aw=timepwt48] 

******************************************************************************************************************************************************************************************
* Column 4
******************************************************************************************************************************************************************************************

ivregress 2sls d_avg_lnwkwage_nmfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], robust

ivregress 2sls d_avg_lnwkwage_nmfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* t2 [aw=timepwt48] 

******************************************************************************************************************************************************************************************
* REGRESSIONS WITH EXPORTS EXPOSURE
******************************************************************************************************************************************************************************************
*recall that we don't have these measures pre-2000

ivregress 2sls d_sh_empl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], robust

ivregress 2sls d_sh_empl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* t2 [aw=timepwt48] 

***
*** using variables from MAU
*** 
ivregress 2sls lnchg_no_empl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg*  [aw=timepwt48] if t2==1, robust

ivregress 2sls lnchg_no_empl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* if t2==1 [aw=timepwt48] 


estimates clear
ivregress 2sls d_sh_empl  NXrenorm if t2==1 [aw=timepwt48] 
estimates store m1

ivregress 2sls d_sh_empl (ADHrenorm=d_tradeotch_pw_lag) if t2==1 [aw=timepwt48] 
estimates store m2
ivregress 2sls d_sh_empl (ADHrenorm=d_tradeotch_pw_lag) NXrenorm if t2==1 [aw=timepwt48] 
estimates store m3

esttab m* ,  ///
 star(* 0.10 ** 0.05 *** 0.01) varwidth(30) ///
 cells("b(fmt(3) label($\beta$) star )" "se(par fmt(3) label((SE)) )" ) ///
	stats( N , fmt(a2) labels("\# Observations"))   ///
  alignment(c) ///
 replace noconstant label nodepvar collabels(none) 	type 

*controls 
estimates clear
ivregress 2sls d_sh_empl  NXrenorm  l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* if t2==1 [aw=timepwt48] 
estimates store m1

ivregress 2sls d_sh_empl (ADHrenorm=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* if t2==1 [aw=timepwt48] 
estimates store m2

ivregress 2sls d_sh_empl (ADHrenorm=d_tradeotch_pw_lag) NXrenorm l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* if t2==1 [aw=timepwt48] 
estimates store m3

esttab m* ,  ///
 star(* 0.10 ** 0.05 *** 0.01) varwidth(30) ///
 cells("b(fmt(3) label($\beta$) star )" "se(par fmt(3) label((SE)) )" ) ///
	stats( N , fmt(a2) labels("\# Observations"))   ///
  alignment(c) ///
 replace noconstant label nodepvar collabels(none) keep(ADHrenorm NXrenorm)	type 
