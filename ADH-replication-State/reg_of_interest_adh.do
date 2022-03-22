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
* Table 4. Panel C. Column 1
* Dependent variables: Ten-year equivalent changes in log population counts (in log pts)
* All education levels
* Full controls
******************************************************************************************************************************************************************************************

ivregress 2sls lnchg_popworkage (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)

******************************************************************************************************************************************************************************************
* Table 5: Change in Employment, Unemployment and Non-Employment
* Panel B. Change in population shares All
******************************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************************
* Table 5. Panel B. Column 3. Unemp
******************************************************************************************************************************************************************************************
ivregress 2sls d_sh_unempl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
******************************************************************************************************************************************************************************************
* Table 5. Panel B. Column 4. NILF
******************************************************************************************************************************************************************************************
ivregress 2sls d_sh_nilf (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
***
*** CHANGE DELTA LOG EMPLOYMENT
***
ivregress 2sls lnchg_no_empl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
gen asa=lnchg_no_empl-lnchg_popworkage
ivregress 2sls asa (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
*log change pop 
gen pop2=d_popcount + l_popcount
gen log_pop_diff= log(pop2)-log(l_popcount)
gen log_emp_pop=lnchg_no_empl-log_pop_diff
ivregress 2sls log_emp_pop (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
ivregress 2sls log_emp_pop (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)

***
*** CHANGE EMPLOYMENT SHARE
***
ivregress 2sls d_sh_empl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
preserve 

*AAE
predict temp_delta_income_pc
*pop share per CZ
bys statefip: egen double pop_share_state=total(l_popcount)
replace pop_share_state=l_popcount/pop_share_state
gen double delta_income_pc=temp_delta_income_pc*pop_share_state
collapse (sum) delta_income_pc pop_share_state, by(statefip)
summ delta_income_pc, det
restore 

***
*** CHANGE LOG EMP SHARE
***
gen new_sh= d_sh_empl + l_sh_empl
gen d_log_sh_empl=100*(log(new_sh)-log(l_sh_empl))
replace d_log_sh_empl=d_log_sh_empl if yr==2000
ivregress 2sls d_log_sh_empl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
preserve
*AAE
predict temp_delta_income_pc
*pop share per CZ
bys statefip: egen double pop_share_state=total(l_popcount)
replace pop_share_state=l_popcount/pop_share_state
gen double delta_income_pc=temp_delta_income_pc*pop_share_state
collapse (sum) delta_income_pc pop_share_state, by(statefip)
summ delta_income_pc, det
restore
hola
******************************************************************************************************************************************************************************************
* Table 7: Dependent variables: Ten-year equivalent changes in log workers and average log weekly wages
* Panel B. Change in average log wage 
******************************************************************************************************************************************************************************************
* Table 7. Panel B. Column 1. ALL WORKERS MANUFACTURING
******************************************************************************************************************************************************************************************
ivregress 2sls d_avg_lnwkwage_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
******************************************************************************************************************************************************************************************
* Table 7. Panel B. Column 4. ALL WORKERS NON-MANUFACTURING
******************************************************************************************************************************************************************************************
ivregress 2sls d_avg_lnwkwage_nmfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
******************************************************************************************************************************************************************************************
* Table 9: Dependent variable: Ten-year equivalent percentage change in average annual household income per working-age adult
* PANEL A: percentage change
******************************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************************
* Table 9. Panel A. Column 1. Total Average HH income/adult
******************************************************************************************************************************************************************************************
ivregress 2sls relchg_avg_hhincsum_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)

******************************************************************************************************************************************************************************************
* Table 9. Panel A. Column 2. WAGE SALARY Average HH income/adult
******************************************************************************************************************************************************************************************
ivregress 2sls relchg_avg_hhincwage_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
global coeff = _b[d_tradeusch_pw]
predict temp_delta_income_pc


*let's follow eq 8 in the ADH-persistance paper wuth average HH income
*tot pop share
egen pop_share_tot=total(l_popcount)
replace pop_share= l_popcount/pop_share_tot
egen diff_CZ=total(pop_share_tot*d_tradeusch_pw)  
replace diff=${coeff}*(d_tradeusch_pw-diff)

*pop share per CZ
bys statefip: egen double pop_share_state=total(l_popcount)
replace pop_share_state=l_popcount/pop_share_state
gen double delta_income_pc=diff*pop_share_state
collapse (sum) delta_income_pc pop_share_state, by(statefip)

summ delta_income_pc, det
