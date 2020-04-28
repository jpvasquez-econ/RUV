capture log close
* Written by JP 
clear all
set more off
set linesize 150
/*
***********************************************************************************************************************************************
***  	THIS DO FILE DOES THE FOLLOWING:
***********************************************************************************************************************************************
1. Imports coordinates by county and crosses each county with the others
2. Calculates distance in km
3. Renames variables
4. Merging populations
5. Applying formula

FORMULA 
d_{ij} = (\sum_{r \in i} \sum_{s \in j} (\dfrac{pop_r}{pop_i}) (\dfrac{pop_s}{pop_j}) d_{rs}^\theta)^{1/ \theta}

*/
********************** 
***  INPUT FILES   ***  
**********************
global state_code ""0-Raw_Data\Fips\state_codes.txt""
global coordinates_counties "0-Raw_Data\Fips\us_states_coordinates_counties.xlsx"
global state_exp_gdp_services "1-Intermediate_Processed_Data\state_exp_gdp_services.dta"
global country_coordinates "1-Intermediate_Processed_Data\country_coordinates.dta"
global WIOD "1-Intermediate_Processed_Data\WIOD_countries.dta"
********************** 
***  OUTPUT FILES  ***  
**********************
global outputfile ""1-Intermediate_Processed_Data\data_services.csv""

*************************************************** 
***  EXPENDITURE AND GDP AT THE COUNTRY LEVEL   ***  
***************************************************
use $WIOD, clear
keep if sector==13
***Services consumption
preserve
keep if importer_country!= "USA"
egen exp=rowtotal(value*)
rename importer_c country
keep country year exp
tempfile exp
save `exp', replace
restore
***countries
preserve
drop if importer==1
collapse year, by(importer_country importer)
drop year
rename importer num_country
rename importer_c country
tempfile countries
save `countries', replace
restore
***Services production
collapse (sum) value* , by(year)
drop value_USA
ds value*
local vari `r(varlist)'
scalar j=51
foreach v of local vari{
rename `v' gdp`=j'
scalar j=`=j'+1
}
reshape long gdp , i(year) j(num_country)
merge m:1 num_country using `countries'
summ _m
assert `r(mean)'==3
keep country year gdp
merge 1:1 country year using `exp'
summ _m
assert `r(mean)'==3
keep country year gdp exp
tempfile country_gdp_exp_services
save `country_gdp_exp_services', replace
****************************** 
***  EXPENDITURE AND GDP   ***  
******************************
{
***
*** STATES
***
use $state_exp_gdp_services, clear
keep if year>=2000
preserve
rename state iso_o
rename gdp Y_i
keep iso_o Y_i year
tempfile gdp
save `gdp', replace
restore
rename state iso_d
rename exp X_j
keep iso_d X_j year
tempfile exp
save `exp', replace
***
*** COUNTRIES
***
use `country_gdp_exp_services', clear
preserve
rename country iso_o
rename gdp Y_i
keep iso_o Y_i year
append using `gdp'
save `gdp', replace
restore
rename country iso_d
rename exp X_j
keep iso_d X_j year
append using `exp'
save `exp', replace
}
********************** 
***  State codes   ***  
**********************
{
import delimited $state_code , delimiter("-") clear
rename v1 State
gen code = subinstr(v2," ","",.) 
replace State=substr(State,1,strlen(State) - 1)
drop v2
tempfile codes
save `codes', replace
}
***********************************************************************************************************************************************
***	1. Imports coordinates by county and crosses each county with the others
***********************************************************************************************************************************************
*****************
***  States   ***  
*****************
import excel $coordinates_counties , sheet("Sheet1") firstrow clear
rename *, lower
drop if state=="DC"
rename state code
*merging codes
merge m:1 code using `codes' 
summ _m
assert `r(mean)'==3
egen state=group(State)
tempfile state_0
save `state_0', replace
***
*** ISO AND REGION NUMBER
***
* COUNTRIES
preserve
use `country_gdp_exp_services', clear
collapse year, by(country)
drop year
rename country iso_o
gen state_i=_n+50
tempfile country_number
save `country_number', replace
restore
* STATES
preserve
collapse fips, by(state State)
keep state State
rename state state_i
rename State iso_o
*APPENDING COUNTRIES
append using `country_number'
tempfile state_i
save `state_i'
rename state_i state_j
rename iso_o iso_d
tempfile state_j
save `state_j'
restore
***
*** POPULATIONS
***
{
*COUNTRIES
use $country_coordinates, clear
drop if country_name_ori=="United States of America"
destring year, replace
keep if year==2010
*one missing value
replace city_pop=124.391 if country=="IRL" & city=="Cork"
egen state=group(country)
replace state=state+50
replace city=country_name_original+"_"+city if country=="RoW"
replace city="Xinyi2" if city=="Xinyi" & round(Lati)==22
egen double fips=group(country city)
replace fips=fips*1000000
rename city_pop pop
replace pop=pop/country_population
preserve
keep state fips  Latitude Longitude
rename  Latitude lat
rename  Longitude lon
tempfile country_coor
save `country_coor', replace
restore
keep state fips pop
tempfile country_pop
save `country_pop', replace

*STATES
use `state_0', clear
keep state fips pop
rename popu pop
bys state: egen double tot_pop=total(pop)
replace pop=pop/tot_pop
drop tot_pop
*appending countries
append using `country_pop'
rename state state_i
rename fips fips_r_in_i
rename pop pop_r_i
tempfile pops_i
save `pops_i', replace
rename state_i state_j 
rename fips_r_in_i fips_s_in_j 
rename pop_r_i pop_s_j
tempfile pops_j
save `pops_j', replace
}
**********************
***  COORDINATES   ***  
**********************

use `state_0', clear
keep state fips lat lon
rename lati lat
rename long lon
replace lon = substr(lon,2,.)
destring lon, replace 
replace lon=-lon
append using `country_coor'
tempfile cities
save `cities', replace
rename * *_s
cross using `cities'

***********************************************************************************************************************************************
***	2. Calculates distance in km
***********************************************************************************************************************************************

**** generate distances in km between cities
geodist lat lon lat_s lon_s, gen(d_rs)

keep state fips state_s fips_s d_rs 
sort state state_s fips  fips_s
order state fips state_s fips_s  , first
compress

***********************************************************************************************************************************************
***	3. Renames variables
***********************************************************************************************************************************************
rename state state_i
rename state_s state_j
rename fips fips_r_in_i
rename fips_s fips_s_in_j

***********************************************************************************************************************************************
***	4. Merging populations
***********************************************************************************************************************************************
merge m:1 state_i fips_r_in_i using `pops_i'
drop _m
merge m:1 state_j fips_s_in_j using `pops_j'
drop _m

***********************************************************************************************************************************************
***	5. Applying formula
***********************************************************************************************************************************************
scalar theta=-1
gen double dist= pop_r_i* pop_s_j*d_rs^(`=theta')
collapse (sum) dist, by(state_i state_j)
replace dist=dist^(1/`=theta')
***
*** Merging back states
***
merge m:1 state_i using `state_i'
drop _m
merge m:1 state_j using `state_j'
drop _m

keep iso_o iso_d dist
sort iso_o iso_d

tempfile years
save `years'
gen year=.
forvalue i=2000/2011{
replace year=`i' if year==.
append using `years'
}
drop if year==.
***
*** Merging EXPENDITURE AND GDP
***
merge m:1 year iso_o using `gdp'
drop _m
merge m:1 year iso_d using `exp'
drop _m
sort year iso_o iso_d
order year iso_o iso_d dist Y_i X_j, first

replace iso_o = subinstr(iso_o, " ", "", .)
replace iso_d = subinstr(iso_d, " ", "", .)

export delimited using $outputfile, replace
