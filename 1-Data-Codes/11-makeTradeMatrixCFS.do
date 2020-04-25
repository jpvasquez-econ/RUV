capture log close
* Written by JP with initial code of Mau
clear all
set more off
set linesize 150
log using 3-Log_Files\3-2-makeTradeMatrixCFS.log, replace

/*
***********************************************************************************************************************************************
***  	THIS DO FILE DOES THE FOLLOWING:
***********************************************************************************************************************************************
Assign state-to-state trade flows at the NAICS level. 
Calculate X_{ij,k}^{CFS} for the 12 manufacturing sectors
The previous matrix is calculated by applying the proportions of redistribution for each commodity into 13 sectors for the US,
to each commodity that flows between state origin and state destination.

*/
*********************** 
***  OUTPUT FILES   ***  
***********************
global CFS_Xijk "1-Intermediate_Processed_Data\CFS_Xijk.dta"
********************** 
***  INPUT FILES   ***  
**********************
global CFSapportionment "1-Intermediate_Processed_Data\CFSapportionment.dta"
global CFS2007 "import excel "0-Raw_Data\CFS\CFS2007.xlsx", sheet("CF0700A22") firstrow case(lower) clear"
global CFS2002 "import excel "0-Raw_Data\CFS\CFS2002mine.xlsx", sheet("sttbl1412281724") cellrange(A2:K114038) firstrow clear"
global CFS2012 "import delimited "0-Raw_Data\CFS\CF1200A24.dat", delimiter("|") varnames(1) rowrange(3) clear"
global statefips "0-Raw_Data\Fips\statefips.dta"

*fips
use $statefips, clear
levelsof statename, local(levels) 
preserve
rename statefip orig_state
rename statename origin
tempfile orig
save `orig', replace
restore
rename statefip dest_state
rename statename destination
tempfile dest
save `dest', replace
*
foreach year_ in 2002 2007 2012{
display "YEAR `year_' YEAR `year_' YEAR `year_' YEAR `year_' YEAR `year_'"
* Import CFS data from original table
*"STATE Table 22. Shipment Characteristics by Destination and Two-Digit Commodity for State of Origin: 2002"
*"Origin State","Destination State","Code","SCTG (2-Digit)","Value ($mil) 02","Value % 02","Tons (thous) 02","Tons % 02","Ton-miles (mil) 02","Ton-miles % 02","Avg miles 02"
${CFS`year_'}
***
*** Renaming variables
***
*for 2002
capture rename OriginState origin
capture rename DestinationState destination
capture rename Code commodity
capture rename Valuemil02 value
*for 2007
capture rename geography origin
capture rename ddestgeo_meaning destination
capture rename comm commodity
capture rename val value
*for 2012
capture rename ddestgeo_ttl destination 
capture rename geo_ttl origin
if `year_'==2012{
gen yes_orig=0
gen yes_dest=0
foreach l of local levels {
replace yes_orig=1 if origin == "`l'"
replace yes_dest=1 if destination == "`l'"
}
keep if yes_ori==1
keep if yes_des==1
drop yes*
}
*Convert origin/dest to fips codes
keep origin destination value commo
destring value, replace force

foreach v in origin destination{
replace `v' = subinstr(`v',"    ","",.)
replace `v' = subinstr(`v',"   ","",.)
replace `v' = subinstr(`v',".","",.)
drop if `v' == "United States"
drop if `v' == "Total"
drop if `v'=="District of Columbia"
drop if `v'==""
}
tostring commodity, replace
foreach v in origin destination {
	gen  statename=`v'
	merge m:1 statename using $statefips
	keep if _m==3
	drop _merge statename
	rename statefip `v'_fips
}

*Get two digit codes
gen code = substr(commodity, 1, 2)
destring code, force replace

keep origin destination code value
order origin destination code value
rename code COMM
drop if COMM==99 | COMM==0
gen year=`year_'

merge m:1 COMM year using $CFSapportionment
keep if _m==3
drop _merge

foreach v of varlist portion1-portion13 {
	gen a`v'=value*`v'
}

drop value por*

collapse (sum) aportion*, by(origin destination year)

rename aportion* trade*
rename trade*, lower

***
*** MATRIX
***

reshape long trade , i(origin destination) j(sector)
replace destination = subinstr(destination, " ", "", .)
replace origin = subinstr(origin, " ", "", .)
reshape wide trade, i(destination sector year) j(origin) string
ds *
local vari `r(varlist)'
foreach v of local vari{
capture replace `v'=0 if `v'==.
}
sort sector dest
rename dest importer
order year, first
tempfile data`year_'
save `data`year_'', replace
}
use `data2002', clear
append using `data2007'
append using `data2012'

save $CFS_Xijk, replace
