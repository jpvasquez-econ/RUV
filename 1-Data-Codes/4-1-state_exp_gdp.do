capture log close
* Written by JP 
clear all
set more off
set linesize 150

log using 3-Log_Files\4-1-state_exp_gdp.log, replace
/*
***********************************************************************************************************************************************
***  	THIS DO FILE DOES THE FOLLOWING:
***********************************************************************************************************************************************
1. Constructs the data of GDP by state
2. Constructs the data of EXPENDITURE by state
3. Merges GDP with Expenditure
4. Proportionality with WIOD
*/
********************** 
***  INPUT FILES   ***  
**********************
global state_code ""0-Raw_Data\Fips\state_codes.txt""
global BEA_RAW ""0-Raw_Data\Expenditure\SAEXP1_1997_2017_ALL_AREAS_.csv""
global WIOD_countries "2-Final_Data\WIOD_countries.dta"
global SAGDP "0-Raw_Data\SAGDP\"
********************** 
***  OUTPUT FILES  ***  
**********************
global state_exp_gdp_services "2-Final_Data\state_exp_gdp_services.dta"
********************** 
***  State codes   ***  
**********************
import delimited $state_code , delimiter("-") 
rename v1 state
gen code = subinstr(v2," ","",.) 
drop v2
levelsof code, local(state_code) 
display `state_code'
*************** 
***  WIOD   ***  
***************
{
use $WIOD_countries, clear
gen serv=(sector==13)
keep if serv==1
***
*** EXPORTS OF US
***
preserve
keep value_USA year
bys year: egen double val_=total(value_USA)
bys year: gen dup=cond(_N==1,0,_n)
drop if dup>1
levelsof year, local(levels) 
foreach l of local levels {
display "`l'"
summ val_ if year == `l'
global wiod_us_all_`l'=`r(mean)'
}
restore
***
*** IMPORTS OF US
***
keep imp* year val*
keep if importer_c=="USA"
egen double val_=rowtotal(value*)
levelsof year, local(levels) 
foreach l of local levels {
display "`l'"
summ val_ if year == `l'
global wiod_all_us_`l'=`r(mean)'
}
}
***********************************************************************************************************************************************
***	1. Constructs the data of GDP by state
***********************************************************************************************************************************************
{
****************************** 
***  LOOPING OVER STATES   ***  
******************************
foreach l of local state_code {
display "Importing State `l'"
quiet{
import delimited "${SAGDP}\\SAGDP2N_`l'_1997_2018.csv", delimiter(comma) clear 
drop table component unit
drop if region==.
gen code="`l'"
*value for years
ds v*,
local vari `r(varlist)'
scalar i=1997
foreach v of local vari{
rename `v' value`=i'
destring value`=i', replace force
scalar i=`=i'+1 
}
drop value2018
tempfile file`l'
save `file`l'', replace
}
}
******************** 
***  APPENDING   ***  
********************
clear
set obs 1
gen temp=0
foreach l of local state_code {
display "APPENDING STATE `l'"
quiet{
append using `file`l''
}
}
drop if temp==0
drop temp
distinct code 
assert `r(ndistinct)'==50
************************** 
***  SERVICE SECTORS   ***  
**************************
/*
***********************************************************************************************************************************************
***  	SECTORS USED AND THEIR MAPPING TO WIOD (indexed by ci)
***********************************************************************************************************************************************
13.	(NAICS XX) Construction (c18); 
14.	(NAICS 42-45) Wholesale and Retail Trade (c19–c21); 
15.	(NAICS 481-488) Transport Services (c23–c26);
16.	(NAICS 511–518) Information Services (c27); 
17.	(NAICS 521–525) Finance and Insurance (c28); 
18.	(NAICS 531-533)  Real Estate (c29–c30); 
19.	(NAICS 61) Education (c32); 
20.	(NAICS 621–624) Health Care (c33); 
21.	(NAICS 721–722) Accommodation and Food Services (c22); 
22.	(NAICS 493, 541, 55, 561, 562, 711–713, 811-814) Other Services (c34).
*/
rename industryclass naics
rename geoname state
gen cdp_sector=.
*13.	((NAICS 23) Construction (c18); 
replace cdp_sector=13 if naics=="23"
*14.	(NAICS 42-45) Wholesale and Retail Trade (c19–c21); 
replace cdp_sector=14 if naics=="42" | naics=="43" | naics=="44-45"
*15.	(NAICS 481-488) Transport Services (c23–c26);
replace cdp_sector=15 if naics=="481" | naics=="482" | naics=="483" | ///
naics=="484" | naics=="485" | naics=="486" | naics=="487-488, 492" 
*16.	(NAICS 511–518) Information Services (c27);
replace cdp_sector=16 if naics=="511" | naics=="512" | naics=="515, 517"  | naics=="518, 519"
*17.	(NAICS 521–525) Finance and Insurance (c28); 
replace cdp_sector=17 if naics=="521-522" | naics=="523" | naics=="524"  | naics=="525"  
*18.	(NAICS 531-533)  Real Estate (c29–c30); 
replace cdp_sector=18 if naics=="531" | naics=="532-533"  
*19.	(NAICS 61) Education (c32); 
replace cdp_sector=19 if naics=="61"
*20.	(NAICS 621–624) Health Care (c33);
replace cdp_sector=20 if naics=="621" | naics=="622" | naics=="623"  | naics=="624"  
*21.	(NAICS 721–722) Accommodation and Food Services (c22); 
replace cdp_sector=21 if naics=="721" | naics=="722"
*22.	(NAICS 493, 541, 55, 561, 562, 711–713, 811-814) Other Services (c34).
replace cdp_sector=22 if naics=="493" | naics=="54" | naics=="55" | ///
naics=="561" | naics=="562" | naics=="711-712" | naics=="713" | naics=="81"
* exports of china in Manuf
keep if cdp_sector!=. 
***************************** 
***  SETTING FINAL DATA   ***  
*****************************
* only sending sector
rename cdp_s sector
collapse (sum) value* , by(state code sector)
reshape long value, i(state code sector) j(year)
rename value gdp
keep if sector>=13
collapse (sum) gdp, by(state code year) 
tempfile gdp
save `gdp', replace
}
***********************************************************************************************************************************************
***	2. Constructs the data of EXPEDITURE by state
***********************************************************************************************************************************************
{
***  IMPORTING BEA DATA
import delimited $BEA_RAW, clear
**  KEEPING AND RENAMING RELEVANT VARIABLES
***
*** keeping only states
***
*removing quotes from geofios
replace geofips = subinstr(geofips, `"""', "",.) 
*making it a number instead of string
destring geofips, replace force
*dropping regions (leaving only states)
drop if geofips>90000
drop if geofips==0
*dropping DC
drop if geoname=="District of Columbia"
*keeping relevant variables
keep geoname line description v*
*renaming 
rename geoname state
ds v*
local variab `r(varlist)'
local n_years : word count `variab'
local year=1997
forval j=1/`n_years' {
    local vari `: word `j' of `variab''
	rename `vari' exp`year'
	local year=`year'+1
}
***********************************************************************************************************************************************
***  	KEEPING RELEVANT LINES
***********************************************************************************************************************************************
*keeping only services
keep if line==13
format exp* %16.0g
drop line descrip
distinct state
assert `r(ndistinct)'==50
reshape long exp, i(state) j(year)
format exp %16.0g
}
***********************************************************************************************************************************************
***	3. Merging Expenditure with GDP
***********************************************************************************************************************************************
{
merge 1:1 year state using `gdp'
summ _m
assert `r(mean)'==3
drop _m
order state code year exp gdp
}
***********************************************************************************************************************************************
***	4. Proportionality with WIOD
***********************************************************************************************************************************************
compress
gen double exp2=exp
drop exp
rename exp2 exp
levelsof year, local(levels)

bys year: egen double tot_exp=total(exp)
bys year: egen double tot_gdp=total(gdp)
gen double sh_exp=exp/tot_exp
gen double sh_gdp=gdp/tot_gdp
keep if year<=2011
keep if year>=2000

levelsof year, local(levels)
display "`levels'"

foreach l of local levels {
display `l'
replace exp= ${wiod_all_us_`l'} * sh_exp if year==`l'
replace gdp= ${wiod_us_all_`l'} * sh_gdp if year==`l'
}

preserve
collapse (sum)  gdp exp, by(year)
levelsof year, local(levels)
foreach l of local levels {
assert round(gdp)==round(${wiod_us_all_`l'}) if year==`l'
assert round(exp)==round(${wiod_all_us_`l'}) if year==`l'
}
restore
keep state exp gdp year
compress

save $state_exp_gdp_services, replace
