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
keep statefip yr l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f ///
l_sh_routine33 l_task_outsource reg* d_sh_unempl d_sh_nilf d_avg_lnwkwage_mfg /// 
d_avg_lnwkwage_nmfg l_popcount l_no_workers_totcbp timepwt48  /// 
l_sh_empl_mfg l_sh_empl_nmfg d_sh_empl lnchg_no_empl
rename yr year

* Calculate CZ population and employment shares conditional on State
bysort statefip year: egen state_pop = total(l_popcount)
gen cz_pop_share = l_popcount / state_pop
bysort statefip year: egen state_workers = total(l_no_workers_totcbp)
gen cz_workers_share = l_no_workers_totcbp / state_workers

*shares
ds *_sh_* l_task d_avg* l_shind_manuf_cbp
foreach v in `r(varlist)'{
	capture drop temp
	bys year statefip: egen temp = wtmean(`v'), weight(cz_workers_share)
	replace `v'=temp
	
}

*regions 
ds reg_* 
foreach v in `r(varlist)'{
	capture drop temp
	bys statefip: egen temp = max(`v')
	replace `v'=temp
}

*vars to add 
ds l_popcount l_no_workers_totcbp timepwt48 
foreach v in `r(varlist)'{
	capture drop temp
	bys statefip year: egen temp = total(`v')
	replace `v'=temp
}

bys statefip year: gen dup=cond(_N==1,0,_n)
drop if dup>1
drop temp dup 

* Merge previous datasets
merge 1:1 statefip year using ../data/2-final_data/ipw.dta, keep(3) nogen
merge 1:1 statefip year using ../data/2-final_data/lnchg_popworkage.dta, keep(3) nogen

***
*** MERGE NET-EXPORTS EXPOSURE FROM MAU
***
preserve
import excel "../data/0-raw_data/NXExposure.xlsx", sheet("Sheet1") firstrow clear
drop Statenum
rename State name
replace name="Rhode Island" if name=="RhodeIsland"
merge 1:1 name using "../data/0-raw_data/fips.dta"
drop if _m==2
drop _m 
rename fips statefip
gen year=2000
tempfile netexports
save `netexports', replace
restore
merge 1:1 statefip year using `netexports'
drop if _m==2
drop _m

* Save the dataset
save ../data/2-final_data/workfile_china_agg.dta, replace
