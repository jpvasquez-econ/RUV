
global root "labor_exercise_jp/Outputs"

import excel using "RUV/1-Data-Codes/0-Raw_Data/Fips/states_fips_num.xlsx", firstrow cellrange(A1:D52) clear
drop st_fips_name
tempfile state
save `state'

use "$root/clean_data.dta" , clear
drop if sector == .
rename id P_ID
decode month, gen(monthname)
drop month
gen month = substr(monthname, 1, 3)
drop monthname
rename mish inter_num
drop ind
rename statefip st_fips
merge m:1 st_fips using `state'
drop _merge st_num
drop if st_fips == 11 // DC

save "$root/clean_data_new.dta", replace




























