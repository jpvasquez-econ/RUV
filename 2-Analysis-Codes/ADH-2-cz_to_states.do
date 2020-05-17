*******************************************************************
* Map Sic4 to RUV sectors and Commuting Zones to States
*******************************************************************

* JP, May 2020

* Input files: 
*1. cz_industry_2000.dta
*2. ISIC REV-4 - ISIC REV-3-1.csv
*3. cw_czone_state.dta
*4. sic_list.csv
*5. state_fips
global cz_industry_2000 ""1-Intermediate_Processed_Data/czone_industry2000.dta""
global cross_isic ""0-Raw_Data/ISIC REV-4 - ISIC REV-3-1.csv""
global cw_czone_state ""0-Raw_Data/ADH_employment/cw_czone_state/cw_czone_state.dta""
global sic ""0-Raw_Data/sic_list.csv""
global fips ""0-Raw_Data/state_fips.xlsx""


* Output file:  state_emp_2000.dta
global output ""1-Intermediate_Processed_Data/state_emp_2000.dta""
*******************************************************************
* Administrative Commands
*******************************************************************
cap log close
set more off
clear
set memory 8g



*******************************************************************
* MAP sic4 SECTORS TO WIOD SECTORS
*******************************************************************
*sic-codes
import delimited $sic , clear 
*2digit 
tostring sic4, replace
replace sic4="0"+sic4 if length(sic4)<4
gen sic4_2d=substr(sic4,1,2)
*no dup
bys sic4_2d: gen dup=cond(_N==1,0,_n)
drop if dup>1
keep sic4_2d 
tempfile sic_list
save `sic_list', replace
**
** MAP disaggregated sic3 to WIOD sectors
**
import delimited $cross_isic , rowrange(3) clear 
rename isic sic4
*2digit 
tostring sic4, replace
replace sic4="0"+sic4 if length(sic4)<4
gen sic4_2d=substr(sic4,1,2)
merge m:1 sic4_2d using `sic_list'
drop if _m==2
drop _m
rename v2 isic3_
drop v*
*isic3 2digit
tostring isic3_, replace
replace isic3_="0"+isic3 if length(isic3_)<4
gen isic3_2d_=substr(isic3_,1,2)
*wiod
gen wiod_sector=.
replace wiod_sector=1 if inlist(isic3_2d_,"01", "02", "03", "05")
replace wiod_sector=2 if inlist(isic3_2d_,"10", "11", "12", "13", "14")
replace wiod_sector=3 if inlist(isic3_2d_,"15", "16")
replace wiod_sector=4 if inlist(isic3_2d_,"17", "18")
replace wiod_sector=5 if inlist(isic3_2d_,"19")
replace wiod_sector=6 if inlist(isic3_2d_,"20")
replace wiod_sector=7 if inlist(isic3_2d_,"21", "22")
replace wiod_sector=8 if inlist(isic3_2d_,"23")
replace wiod_sector=9 if inlist(isic3_2d_,"24")
replace wiod_sector=10 if inlist(isic3_2d_,"25")
replace wiod_sector=11 if inlist(isic3_2d_,"26")
replace wiod_sector=12 if inlist(isic3_2d_,"27", "28")
replace wiod_sector=13 if inlist(isic3_2d_,"29")
replace wiod_sector=14 if inlist(isic3_2d_,"30", "31", "32", "33")
replace wiod_sector=15 if inlist(isic3_2d_,"34", "35")
replace wiod_sector=16 if inlist(isic3_2d_,"36", "37")
replace wiod_sector=17 if inlist(isic3_2d_,"40", "41")
replace wiod_sector=18 if inlist(isic3_2d_,"45")
replace wiod_sector=19 if inlist(isic3_2d_,"50")
replace wiod_sector=20 if inlist(isic3_2d_,"51")
replace wiod_sector=21 if inlist(isic3_2d_,"52")
replace wiod_sector=22 if inlist(isic3_2d_,"55")
replace wiod_sector=23 if inlist(isic3_2d_,"60")
replace wiod_sector=24 if inlist(isic3_2d_,"61")
replace wiod_sector=25 if inlist(isic3_2d_,"62")
replace wiod_sector=26 if inlist(isic3_2d_,"63")
replace wiod_sector=27 if inlist(isic3_2d_,"64")
replace wiod_sector=28 if inlist(isic3_2d_,"65", "66", "67")
replace wiod_sector=29 if inlist(isic3_2d_,"70")
replace wiod_sector=30 if inlist(isic3_2d_,"71", "72", "73", "74")
replace wiod_sector=31 if inlist(isic3_2d_,"75")
replace wiod_sector=32 if inlist(isic3_2d_,"80")
replace wiod_sector=33 if inlist(isic3_2d_,"85")
replace wiod_sector=34 if inlist(isic3_2d_,"90", "91", "92", "93", "94")
replace wiod_sector=35 if inlist(isic3_2d_,"95")
drop if wiod==.
*******************************************************************
* MAP WIOD SECTORS to RUV sectors
*******************************************************************
gen ruv_sector=.
*1.	(NAICS 311-312) Food Products, Beverage, and Tobacco Products (c3);
replace ruv_sector=1 if wiod_sector==3
*2.	(NAICS 313-316) Textile, Textile Product Mills, Apparel, Leather, and Allied Products (c4-c5);
replace ruv_sector=2 if wiod_sector==4 | wiod_sector==5
*3.	(NAICS 321-323) Wood Products, Paper, Printing, and Related Sup- port Activities (c6-c7); 
replace ruv_sector=3 if wiod_sector==6 | wiod_sector==7
*4.	(NAICS 211-213, 324) Petroleum and Coal Products (c8);
*Mining, Quarrying, and Oil and Gas Extraction (c2). 
replace ruv_sector=4 if wiod_sector==8 | wiod_sector==2
*5.	(NAICS 325) Chemical (c9);
replace ruv_sector=5 if wiod_sector==9
*6.	(NAICS 326) Plastics and Rubber Products (c10); 
replace ruv_sector=6 if wiod_sector==10
*7.	(NAICS 327) Nonmetallic Mineral Products (c11); 
replace ruv_sector=7 if wiod_sector==11
*8.	(NAICS 331-332) Primary Metal and Fabricated Metal Products (c12); 
replace ruv_sector=8 if wiod_sector==12
*9.	(NAICS 333); Machinery (c13); 
replace ruv_sector=9 if wiod_sector==13
*10.	(NAICS 334-335) Computer and Electronic Products, and Electrical Equipment and Appliances (c14);
replace ruv_sector=10 if wiod_sector==14
*11.	(NAICS 336) Transportation Equipment (c15); 
replace ruv_sector=11 if wiod_sector==15
*12.	(NAICS 337-339) Furniture and Related Products, and Miscellaneous Manufacturing (c16); 
replace ruv_sector=12 if wiod_sector==16
*13.	((NAICS 23) Construction (c18); 
replace ruv_sector=13 if wiod_sector==18
*14.	(NAICS 42-45) Wholesale and Retail Trade (c19-c21); 
replace ruv_sector=14 if wiod_sector==19 | wiod_sector==20 | wiod_sector==21 
*15.	(NAICS 481-488) Transport Services (c23-c26);
replace ruv_sector=15 if wiod_sector==23 | wiod_sector==24 | wiod_sector==25 | wiod_sector==26 
*16.	(NAICS 511-518) Information Services (c27);
replace ruv_sector=16 if wiod_sector==27 
*17.	(NAICS 521-525) Finance and Insurance (c28); 
replace ruv_sector=17 if wiod_sector==28 
*18.	(NAICS 531-533)  Real Estate (c29-c30); 
replace ruv_sector=18 if wiod_sector==29 | wiod_sector==30  
*19.	(NAICS 61) Education (c32); 
replace ruv_sector=19 if wiod_sector==32 
*20.	(NAICS 621-624) Health Care (c33);
replace ruv_sector=20 if wiod_sector==33 
*21.	(NAICS 721-722) Accommodation and Food Services (c22); 
replace ruv_sector=21 if wiod_sector==22 
*22.	(NAICS 493, 541, 55, 561, 562, 711-713, 811-814) Other Services (c34).
replace ruv_sector=22 if wiod_sector==34 
*23.	(NAICS 111-115) Agriculture, Forestry, Fishing, and Hunting (c1)
replace ruv_sector=23 if wiod_sector==1  
keep if ruv_sector!=. 
*checks that we have sectors
distinct ruv_sector 
assert `r(ndistinct)'==23
replace ruv_sector=13 if ruv_sector>=13 & ruv_sector<23
replace ruv_sector=14 if ruv_sector==23
*drop duplicates or unnecessary variables
bys sic4_2d ruv_sector: gen dup=cond(_N==1,0,_n)
drop if dup>1
drop dup 
*i need to improve the mapping here
*there cannot be a ruv sector without sic4
hola
gen equ=(isic3_2d_!=sic4_2d)
sort sic4_2d equ
by sic4_2d: gen dup=cond(_N==1,0,_n)
drop if dup>1 
keep sic4_2d ruv_sector
tempfile isic
save `isic', replace

*******************************************************************
* MERGE RUV SECTORS WITH ADH SECTORS
*******************************************************************
use $cz_industry_2000 , clear
*2digit 
tostring sic4, replace
replace sic4="0"+sic4 if length(sic4)<4
gen sic4_2d=substr(sic4,1,2)
merge m:1 sic4_2d using `isic'
drop if _m==2
drop _m
*******************************************************************
* MAP CZs to STATES
*******************************************************************
merge m:1 czone using $cw_czone_state
keep if _m==3
drop _m
**
** fips to state names
**
preserve
import excel $fips , sheet("Sheet1") firstrow clear
rename Name state
rename FIPS statefip
tempfile fip
save `fip', replace
restore
merge m:1 statefip using `fip'
keep if _m==3
distinct czone if state!="Hawaii"
*722 commuting zones in mainland US as in the paper
**
** emp per state
**
bys statefip: egen emp_state=total(imp_emp)
bys statefip ruv_sector: egen emp_state_sector=total(imp_emp)
collapse emp_state emp_state_sector, by(statefip state ruv_sec)
*tot emp US
egen tot_US=total(emp_state_sector)
summ tot_US
drop if ruv_==.
gen share_sector_state=emp_state_sector/emp_state
*keep manufacturing
keep if ruv_sector<=12
rename ruv_ sector
rename share share_empl
rename state region
keep sector region share
replace region=lower(region)
replace region=subinstr(region," ","",.)
compress
hola
save $output , replace


