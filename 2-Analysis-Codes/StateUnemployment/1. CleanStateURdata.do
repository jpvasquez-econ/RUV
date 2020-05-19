/*------------------------------------------------------------------------------
********** Explanation of what the file does
--------------------------------------------------------------------------------

This file imports the State Unemployment excel spreadsheet and cleans it for
further analysis, it also imports the model based state unemployment and cleans
it, and then merges the two databases

--------------------------------------------------------------------------------
********** Input files needed
--------------------------------------------------------------------------------

DataStateUR.xlsx, sheet "Monthly"
StateInfo.xlsx, sheet "staadata"
ModelStateUR.xlsx, sheet "Sheet1"
Exposure.xlsx, sheet "Sheet1"

--------------------------------------------------------------------------------
********** Output files produced
--------------------------------------------------------------------------------

dataUR.dta
dataMore.dta
modelUR.dta
exposure.dta
jointUR.dta */

********************************************************************************

* Setup

clear all

* Import data on state unemployment

import excel DataStateUR.xlsx, firstrow sheet(Monthly) clear

* Generate Year indicators

gen Year=year(DATE)
drop DATE

* Collapse to the year level

collapse (mean) ??UR, by(Year)

* Switch around name

rename ??UR UR??

* Reshape

reshape long UR, i(Year) j(State) string

* Generate variables for state long name and state code in the order of CDP

gen statelong=""
gen statecode=.

* Fill in the new variables

replace statelong="Alabama" if State=="AL" 
replace statecode=1 if State=="AL" 
replace statelong="Alaska" if State=="AK" 
replace statecode=2 if State=="AK" 
replace statelong="Arizona" if State=="AZ" 
replace statecode=3 if State=="AZ" 
replace statelong="Arkansas" if State=="AR" 
replace statecode=4 if State=="AR" 
replace statelong="California" if State=="CA" 
replace statecode=5 if State=="CA" 
replace statelong="Colorado" if State=="CO" 
replace statecode=6 if State=="CO" 
replace statelong="Connecticut" if State=="CT" 
replace statecode=7 if State=="CT" 
replace statelong="Delaware" if State=="DE" 
replace statecode=8 if State=="DE" 
replace statelong="Florida" if State=="FL" 
replace statecode=9 if State=="FL" 
replace statelong="Georgia" if State=="GA" 
replace statecode=10 if State=="GA"
replace statelong="Hawaii" if State=="HI" 
replace statecode=11 if State=="HI"
replace statelong="Idaho" if State=="ID" 
replace statecode=12 if State=="ID"
replace statelong="Illinois" if State=="IL" 
replace statecode=13 if State=="IL"
replace statelong="Indiana" if State=="IN" 
replace statecode=14 if State=="IN"
replace statelong="Iowa" if State=="IA" 
replace statecode=15 if State=="IA"
replace statelong="Kansas" if State=="KS" 
replace statecode=16 if State=="KS"
replace statelong="Kentucky" if State=="KY" 
replace statecode=17 if State=="KY"
replace statelong="Louisiana" if State=="LA" 
replace statecode=18 if State=="LA"
replace statelong="Maine" if State=="ME" 
replace statecode=19 if State=="ME"
replace statelong="Maryland" if State=="MD" 
replace statecode=20 if State=="MD"
replace statelong="Massachusetts" if State=="MA" 
replace statecode=21 if State=="MA"
replace statelong="Michigan" if State=="MI" 
replace statecode=22 if State=="MI"
replace statelong="Minnesota" if State=="MN" 
replace statecode=23 if State=="MN"
replace statelong="Mississippi" if State=="MS" 
replace statecode=24 if State=="MS"
replace statelong="Missouri" if State=="MO" 
replace statecode=25 if State=="MO"
replace statelong="Montana" if State=="MT" 
replace statecode=26 if State=="MT"
replace statelong="Nebraska" if State=="NE" 
replace statecode=27 if State=="NE"
replace statelong="Nevada" if State=="NV" 
replace statecode=28 if State=="NV"
replace statelong="NewHampshire" if State=="NH" 
replace statecode=29 if State=="NH"
replace statelong="NewJersey" if State=="NJ" 
replace statecode=30 if State=="NJ"
replace statelong="NewMexico" if State=="NM" 
replace statecode=31 if State=="NM"
replace statelong="NewYork" if State=="NY" 
replace statecode=32 if State=="NY"
replace statelong="NorthCarolina" if State=="NC" 
replace statecode=33 if State=="NC"
replace statelong="NorthDakota" if State=="ND" 
replace statecode=34 if State=="ND"
replace statelong="Ohio" if State=="OH" 
replace statecode=35 if State=="OH"
replace statelong="Oklahoma" if State=="OK" 
replace statecode=36 if State=="OK"
replace statelong="Oregon" if State=="OR" 
replace statecode=37 if State=="OR"
replace statelong="Pennsylvania" if State=="PA" 
replace statecode=38 if State=="PA"
replace statelong="RhodeIsland" if State=="RI" 
replace statecode=39 if State=="RI"
replace statelong="SouthCarolina" if State=="SC" 
replace statecode=40 if State=="SC"
replace statelong="SouthDakota" if State=="SD" 
replace statecode=41 if State=="SD"
replace statelong="Tennessee" if State=="TN" 
replace statecode=42 if State=="TN"
replace statelong="Texas" if State=="TX" 
replace statecode=43 if State=="TX"
replace statelong="Utah" if State=="UT" 
replace statecode=44 if State=="UT"
replace statelong="Vermont" if State=="VT" 
replace statecode=45 if State=="VT"
replace statelong="Virginia" if State=="VA" 
replace statecode=46 if State=="VA"
replace statelong="Washington" if State=="WA" 
replace statecode=47 if State=="WA"
replace statelong="WestVirginia" if State=="WV" 
replace statecode=48 if State=="WV"
replace statelong="Wisconsin" if State=="WI" 
replace statecode=49 if State=="WI"
replace statelong="Wyoming" if State=="WY" 
replace statecode=50 if State=="WY"

* Order

sort Year statecode
order Year State statelong statecode

* Save

rename UR URdata
save dataUR.dta, replace

********************************************************************************

* Now import state data more generally

import excel StateInfo.xlsx, firstrow sheet(staadata) clear

destring Year, replace
drop if statelong=="Los Angeles County"
drop if statelong=="District of Columbia"
drop if statelong=="New York city"
replace statelong = subinstr(statelong," ","",.)
gen UP=U/Population*100
drop FIPS Population LFP E ER U

********************************************************************************
*** QUESTION: is UR the same as URdata in the dataUR.dta file?
********************************************************************************
preserve

merge 1:1 statelong Year using dataUR.dta
keep if _m==3
gen diff=abs(UR/URdata-1)
summ diff
*ANSWER: THERE ARE SOME VERY SMALL DIFFERENCES BETWEEN THE TWO UR

restore
********************************************************************************
********************************************************************************
********************************************************************************

* Save

save dataMore.dta, replace

********************************************************************************

* Now import model stuff

import excel ModelStateUR.xlsx, firstrow sheet(Sheet1) clear

* Reshape

reshape long UR UP LFPR, i(Statecode) j(Year)

* Generate unemployment

replace UR=(1-UR)*100
replace UP=UP*100
replace LFPR=LFPR*100

* Put dataset in same format

rename State statelong
rename Statecode State
rename UR URmodel
rename UP UPmodel
rename LFPR LFPRmodel

* Remove spaces

replace statelong = subinstr(statelong," ","",.)

* Save

save modelUR.dta, replace

********************************************************************************

* Now import exposure data

import excel Exposure.xlsx, firstrow sheet(Sheet1) clear
rename ADHExposure Exposure
summ Exposure
local meanexposure=r(mean)
replace Exposure=Exposure*2.63/`meanexposure'
rename State statelong

* Save

save exposure.dta, replace

********************************************************************************

use modelUR.dta, clear

* Merge with data unemployment rates

merge 1:1 State Year using dataUR
drop _merge

* Merge with more data

merge 1:1 statelong Year using dataMore
drop if _merge==1
drop _merge
********************************************************************************
*** QUESTION: why dropping URdata constructed in dataUR.dta? 
********************************************************************************
drop URdata

* Merge with exposure

merge m:1 statelong using exposure
drop _merge

* Sort and order

sort Year statecode
order Year State statelong statecode URmodel UR UPmodel UP LFPRmodel LFPR

* Save

save jointUR.dta, replace
