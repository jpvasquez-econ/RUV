*******************************************************************
* SHARE OF EMPLOYMENT PER SECTOR IN 2000 ACCORDING TO BLS
*******************************************************************

* JP, May 2020

* Input files: 
*1. BLS employment
global bls ""0-Raw_Data\emp_SAEMP25S_BLS.csv""
global adh ""1-Intermediate_Processed_Data/state_emp_2000.dta""

* Output file:  state_emp_2000.dta
global output ""1-Intermediate_Processed_Data/state_emp_share_2000.dta""

*******************************************************************
* Administrative Commands
*******************************************************************
cap log close
set more off
clear
set memory 8g

*******************************************************************
* CLEANING EMPLOYMENT FILE
*******************************************************************
import delimited $bls, varnames(1) clear
*dropping footnotes
drop if _n>6180
destring geofips, replace
destring jobs, replace force
drop if jobs==.
*dropping totals
drop if linecode<=60 | linecode==80
*number of indents
gen indent=.
local temp_space "  "
local spaces_1 "  "
forvalue i=2/5{
local bef=`i'-1
local spaces_`i' "`spaces_`bef''`temp_space'"
}
forvalue i=5(-1)1{
replace indent=`i' if strpos(description,"`spaces_`i''")>0 & ind==.
}
*keeping sectors (or farm employment) or manuf (disaggregated) or services
keep if indent==3 | linecode==70 | (linecode>=400 & linecode<=480) ///
| (linecode>=800 & linecode<=880) | (linecode>=500 & linecode<=540) ///
| linecode==560 | linecode==570 | (linecode>=700 & linecode<=736) ///
| (linecode>=621 & linecode<=628) | (linecode>=540 & linecode<=544)

*dropping total manuf, total durables, total non-durables
drop if linecode==410 | linecode==450 | linecode==400 | linecode==800 ///
| linecode==500 | linecode==700 | linecode==730 | linecode==620 | linecode==540
**
** check: sum of employment = total employment of USA
**
bys geoname: egen double tot_emp=total(jobs)
sort  geofips linecode
summ tot_emp if geoname=="United States"
assert `r(mean)'==165370800
drop indent tot_emp 
replace description=subinstr(description, "          ", "",.) 
compress
*******************************************************************
* ASSIGNING SECTORS
*******************************************************************
*wiod
gen wiod_sector=.
*Agriculture, Hunting, Forestry and Fishing
replace wiod_sector=1 if inlist(linecode,100)
*Mining and Quarrying
replace wiod_sector=2 if inlist(linecode,200)
*Food, Beverages and Tobacco
replace wiod_sector=3 if inlist(linecode,453, 456)
*Textiles and Textile Products
replace wiod_sector=4 if inlist(linecode,459,462)
*Leather, Leather and Footwear
replace wiod_sector=5 if inlist(linecode,480)
*Wood and Products of Wood and Cork
replace wiod_sector=6 if inlist(linecode,413)
*Pulp, Paper, Paper , Printing and Publishing
replace wiod_sector=7 if inlist(linecode,465,468)
*Coke, Refined Petroleum and Nuclear Fuel
replace wiod_sector=8 if inlist(linecode,474)
*Chemicals and Chemical Products
replace wiod_sector=9 if inlist(linecode,471)
*Rubber and Plastics
replace wiod_sector=10 if inlist(linecode,477)
*Other Non-Metallic Mineral
replace wiod_sector=11 if inlist(linecode,420)
*Basic Metals and Fabricated Metal
replace wiod_sector=12 if inlist(linecode,423,426)
*Machinery, Nec
replace wiod_sector=13 if inlist(linecode,429)
*Electrical and Optical Equipment
replace wiod_sector=14 if inlist(linecode,432)
*Transport Equipment
replace wiod_sector=15 if inlist(linecode,435, 438)
*Manufacturing, Nec; Recycling
replace wiod_sector=16 if inlist(linecode,417, 441, 444)
*Electricity, Gas and Water Supply
replace wiod_sector=17 if inlist(linecode,570)
*Construction
replace wiod_sector=18 if inlist(linecode,300)
*Sale, Maintenance and Repair of Motor Vehicles and Motorcycles; Retail Sale of Fuel
replace wiod_sector=19 if inlist(linecode,624)
*Wholesale Trade and Commission Trade, Except of Motor Vehicles and Motorcycles
replace wiod_sector=20 if inlist(linecode,610)
*Retail Trade, Except of Motor Vehicles and Motorcycles; Repair of Household Goods
replace wiod_sector=21 if inlist(linecode,621,622,623,625,626,627,628)
*Hotels and Restaurants
replace wiod_sector=22 if inlist(linecode,805)
*Inland Transport
replace wiod_sector=23 if inlist(linecode,510,520)
*Water Transport
replace wiod_sector=24 if inlist(linecode,530)
*Air Transport
replace wiod_sector=25 if inlist(linecode,542)
*Other Supporting and Auxiliary Transport Activities; Activities of Travel Agencies
replace wiod_sector=26 if inlist(linecode,541,543,544)
*Post and Telecommunications
replace wiod_sector=27 if inlist(linecode,560)
*Financial Intermediation
replace wiod_sector=28 if inlist(linecode,710,731,732,733,735,736)
*Real Estate Activities
replace wiod_sector=29 if inlist(linecode,734)
*Renting of M&Eq and Other Business Activities
replace wiod_sector=30 if inlist(linecode, 820, 825, 830, 875, 880)
*Public Admin and Defence; Compulsory Social Security
replace wiod_sector=31 if inlist(linecode,910,920,930)
*Education
replace wiod_sector=32 if inlist(linecode,855)
*Health and Social Work
replace wiod_sector=33 if inlist(linecode,845,860)
*Other Community, Social and Personal Services
replace wiod_sector=34 if inlist(linecode,810,835,840,865,870)
*Private Households with Employed Persons
replace wiod_sector=35 if inlist(linecode,815,850)
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
replace ruv_sector=13 if ruv_sector>=13 & ruv_sector<23 & ruv_sector!=.
replace ruv_sector=14 if ruv_sector==23
*******************************************************************
* REGIONS= US STATES
*******************************************************************
rename geoname region
replace region=lower(region)
replace region=subinstr(region," ","",.)
*regions adh data
preserve
use $adh, clear
collapse sector, by(region)
keep region
tempfile regions
save `regions', replace
restore
*merging regions
merge m:1 region using `regions'
keep if _m==3 | region=="alaska" | region=="hawaii"
*******************************************************************
* COMPUTING EMPLOYMENT SHARES
*******************************************************************
**
** emp per state
**
bys region: egen double emp_state=total(jobs)
bys region ruv_sector: egen double emp_state_sector=total(jobs)
collapse emp_state emp_state_sector, by(region ruv_sec)
*tot emp US
egen double tot_US=total(emp_state_sector)
summ tot_US
drop if ruv_==.
gen share_sector_state=emp_state_sector/emp_state
*keep manufacturing
keep if ruv_sector<=12
*share in manuf USA
egen sh_manuf_USA=total(emp_state_sector)
replace sh_manuf=sh_manuf_USA/tot_US
summ sh_manuf 
*keeping important variables
keep region ruv_sector share_
rename ruv_s sector
rename share share_bls
*******************************************************************
* MERGING WITH ADH VALUES
*******************************************************************
merge 1:1 region sector using $adh
replace share_bls=0 if _m==2
drop _m
egen group=group(region)
xtset group sector
tsfill
replace region="alaska" if region=="" & group==2
replace share_bls=0 if share_bls==.
drop group
*******************************************************************
* comparing with adh
*******************************************************************
*they are not super correlated
scatter sh*
corr sh*
reg sh*
*gen diff=abs(share_bl-share_adh)
*bys sector: summ diff
save $output, replace
