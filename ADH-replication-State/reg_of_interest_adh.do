***********************************************
* Impact of Chines Imports on Local Labor Markets
***********************************************

* David Dorn, July 28, 2010
* Final version, April 11, 2012

* Input file: workfile9007.dta

* This file creates the results for Tables 2-10, Appendix Tables 1-5


***********************************************
* Administrative Commands
***********************************************
use "112670-V1/Public-Release-Data/dta/workfile_china.dta", clear

******************************************************************************************************************************************************************************************
* Table 4: Population Change
******************************************************************************************************************************************************************************************
* Panel C
******************************************************************************************************************************************************************************************
* Column 1
******************************************************************************************************************************************************************************************

ivregress 2sls lnchg_popworkage (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)

******************************************************************************************************************************************************************************************
* Table 5: Change in Employment, Unemployment and Non-Employment
******************************************************************************************************************************************************************************************
* Panel B
******************************************************************************************************************************************************************************************
* Column 3
******************************************************************************************************************************************************************************************

ivregress 2sls d_sh_unempl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
*ivregress 2sls d_sh_unempl_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
*ivregress 2sls d_sh_unempl_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)


******************************************************************************************************************************************************************************************
* Column 4
******************************************************************************************************************************************************************************************

ivregress 2sls d_sh_nilf (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
*ivregress 2sls d_sh_nilf_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
*ivregress 2sls d_sh_nilf_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)

******************************************************************************************************************************************************************************************
* Table 7: Manufacturing vs. Non-Manufacturing
******************************************************************************************************************************************************************************************
* Panel B
******************************************************************************************************************************************************************************************
* Column 1
******************************************************************************************************************************************************************************************

ivregress 2sls d_avg_lnwkwage_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)

******************************************************************************************************************************************************************************************
* Column 4
******************************************************************************************************************************************************************************************

ivregress 2sls d_avg_lnwkwage_nmfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
