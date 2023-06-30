
****************** Process 1999to2000CountyMigration data ********************

clear

global root "/Users/yyh/Documents/Github/RUV/1-Data-Codes/0-Raw_Data/IRS/1999to2000CountyMigration"


cd "$root/Inflow"

local file1: dir "`c(pwd)'" files "*.xls"
dis `file1'

gen state_dest = ""
gen state_ori = ""
gen exemption = ""

save "$root/1999to2000Inflow.dta", emptyok replace

foreach file in `file1'{
	import excel using "`file'", clear 
	drop in 1/8 if A[8] == "FIPS Code"
	drop if A == ""
	keep A C H
	rename (A C H) (state_dest state_ori exemption)
	gen year = 1999
	append using "$root/1999to2000Inflow.dta"
	save "$root/1999to2000Inflow.dta", replace
}

sort state_dest
merge m:1 state_dest using "$root/state_name.dta", nogen
rename state_name state_dest_name
merge m:1 state_ori using "$root/state_name.dta"
rename state_name state_ori_name
drop if _merge != 3
drop _merge
destring exemption, replace
bys state_dest state_ori: egen exemption_tot = total(exemption)
collapse (mean) exemption_tot, by(state_dest_name state_ori_name year)

tempfile inflow
save `inflow'

clear
cd "$root/Outflow"

local file1: dir "`c(pwd)'" files "*.xls"
dis `file1'

gen state_dest = ""
gen state_ori = ""
gen exemption = ""

save "$root/1999to2000Outflow.dta", emptyok replace

foreach file in `file1'{
	import excel using "`file'", clear 
	drop in 1/8 if A[8] == "FIPS Code"
	drop if A == ""
	keep A C H
	rename (A C H) (state_ori state_dest exemption)
	gen year = 1999
	append using "$root/1999to2000Outflow.dta"
	save "$root/1999to2000Outflow.dta", replace
}

merge m:1 state_ori using "$root/state_name.dta", nogen
rename state_name state_ori_name
merge m:1 state_dest using "$root/state_name.dta"
rename state_name state_dest_name
drop if _merge != 3
drop _merge
destring exemption, replace
bys state_ori state_dest: egen exemption_tot = total(exemption)
collapse (mean) exemption_tot, by(state_ori_name state_dest_name year)

append using `inflow'

duplicates drop state_dest state_ori, force
rename (state_ori_name state_dest_name exemption_tot) (state_ori state_dest exemption)

save "$root/1999to2000flow.dta", replace




































