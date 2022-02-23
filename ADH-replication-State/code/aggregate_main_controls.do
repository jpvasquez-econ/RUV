/*
Aggregate main controls and merge

In this code, we aggregate the variables at the state level from the CZ level. 
Also, we add the variables built in previous steps and save the final dataset. 

Input files/base codes: 

1. dta/0-raw_data/workfile_china.dta ADH main replication file
2. data/2-final_data/ipw.dta Imports to USA and OT from China. 
3. data/2-final_data/lnchg_popworkage.dta Ten-year equivalent changes in 
working age population 

Output files: 
1. data/2-final_data/workfile_china_agg.dta Final datase4t
*/

* Import dataset
use ../data/0-raw_data/workfile_china.dta, clear

* Keep variables of interest
keep statefip t2 l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f ///
l_sh_routine33 l_task_outsource reg* d_sh_unempl d_sh_nilf d_avg_lnwkwage_mfg /// 
d_avg_lnwkwage_nmfg l_popcount l_no_workers_totcbp timepwt48  /// 
l_sh_empl_mfg l_sh_empl_nmfg

* Calculate CZ population and employment shares conditional on State
bysort statefip t2: egen state_pop = total(l_popcount)
gen cz_pop_share = l_popcount / state_pop
bysort statefip t2: egen state_workers = total(l_no_workers_totcbp)
gen cz_workers_share = l_no_workers_totcbp / state_workers
bysort statefip t2: egen mfg_sh = total(l_sh_empl_mfg)
gen cz_mfg_share = l_sh_empl_mfg / mfg_sh
bysort statefip t2: egen nmfg_sh = total(l_sh_empl_nmfg)
gen cz_nmfg_share = l_sh_empl_nmfg / nmfg_sh

* Recover level from shares
replace l_shind_manuf_cbp = l_shind_manuf_cbp * l_no_workers_totcbp
replace l_sh_popedu_c = l_sh_popedu_c * l_popcount
replace l_sh_popfborn = l_sh_popfborn * l_popcount
replace l_sh_empl_f = l_sh_empl_f * l_no_workers_totcbp
replace l_sh_routine33 = l_sh_routine33 * l_no_workers_totcbp

* Reweight by workers
replace l_task_outsource = cz_workers_share * l_task_outsource

* Recover levels from changes (weight by workers share)
replace d_sh_unempl = cz_workers_share * d_sh_unempl
replace d_sh_nilf = cz_workers_share * d_sh_nilf
* Apply exp to recover wages from log
replace d_avg_lnwkwage_mfg = cz_mfg_share * d_avg_lnwkwage_mfg // weight by mfg workers share
replace d_avg_lnwkwage_nmfg = cz_nmfg_share * d_avg_lnwkwage_nmfg // weight by nmfg workers share

* Collapse the dataset
collapse (sum) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f ///
l_sh_routine33 d_sh_unempl d_sh_nilf d_avg_lnwkwage_mfg d_avg_lnwkwage_nmfg ///
l_popcount l_no_workers_totcbp l_task_outsource timepwt48 (mean) reg*, by(statefip t2)

* Keep the most common census division
replace reg_midatl = round(reg_midatl)
replace reg_encen = round(reg_encen)
replace reg_wncen = round(reg_wncen) 
replace reg_satl = round(reg_satl) 
replace reg_escen = round(reg_escen) 
replace reg_wscen = round(reg_wscen) 
replace reg_mount = round(reg_mount) 
replace reg_pacif = round(reg_pacif)

* Recover level from shares
replace l_shind_manuf_cbp = l_shind_manuf_cbp / l_no_workers_totcbp
replace l_sh_popedu_c = l_sh_popedu_c / l_popcount
replace l_sh_popfborn = l_sh_popfborn / l_popcount
replace l_sh_empl_f = l_sh_empl_f / l_no_workers_totcbp
replace l_sh_routine33 = l_sh_routine33 / l_no_workers_totcbp

* Merge previous datasets
merge 1:1 statefip t2 using ../data/2-final_data/ipw.dta, keep(3) nogen
merge 1:1 statefip t2 using ../data/2-final_data/lnchg_popworkage.dta, keep(3) nogen

* Save the dataset
save ../data/2-final_data/workfile_china_agg.dta, replace