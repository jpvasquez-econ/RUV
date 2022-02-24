/* Create IPW and its instrument

This code calculates the import changes from other rich countries to USA by 
sector and year. We build the Bartik instrument from shares in population 
calculated in previous steps. 

Input files: 

1. "data/2-final_data/emp_shares.dta" CBP employment shares by sector and year. 
Previous step
2. "data/1-intermediate_data/imports_changes.dta" Import changes in USA and 
other high income countries from China

Output files. 

1. "data/1-intermediate_data/imports_changes.dta" This dataset stores the 
10-year equivalent import changes by sector. (USCH and OTCH)

*/

* Import dataset
use ../data/2-final_data/emp_shares.dta, clear

* Merge datasets
merge m:1 year sic87dd using "../data/1-intermediate_data/imports_changes.dta", keep(3) nogen

* Create IPW and instrument 1: Multiply shares by changes in imports
gen d_tradeusch_pw_pre_sum = l_sh_ipw * import_chg_usch
gen d_tradeotch_pw_lag_pre_sum = l1_sh_ipw * import_chg_otch

* Sum over sectors
collapse (sum) d_tradeusch_pw=d_tradeusch_pw_pre_sum /// 
(sum) d_tradeotch_pw_lag=d_tradeotch_pw_lag_pre_sum, by(statefip year)

* Save the dataset
save ../data/2-final_data/ipw.dta, replace
