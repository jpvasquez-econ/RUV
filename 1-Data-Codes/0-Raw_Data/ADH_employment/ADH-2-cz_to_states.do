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
use $cz_industry_2000 , clear
tostring sic4, replace
replace sic4="0"+sic4 if length(sic4)<4
gen sic4_2d=substr(sic4,1,2)

*wiod
gen wiod_sector=.
*Agriculture, Hunting, Forestry and Fishing
replace wiod_sector=1 if inlist(sic4_2d,"01", "02", "03")
*Mining and Quarrying
replace wiod_sector=2 if inlist(sic4_2d,"05", "06", "07", "08", "09")
*Food, Beverages and Tobacco
replace wiod_sector=3 if inlist(sic4_2d,"10", "11", "12")
*Textiles and Textile Products
replace wiod_sector=4 if inlist(sic4_2d,"13", "14")
*Leather, Leather and Footwear
replace wiod_sector=5 if inlist(sic4_2d,"15")
*Wood and Products of Wood and Cork
replace wiod_sector=6 if inlist(sic4_2d,"16")
*Pulp, Paper, Paper , Printing and Publishing
replace wiod_sector=7 if inlist(sic4_2d,"17", "18")
*Coke, Refined Petroleum and Nuclear Fuel
replace wiod_sector=8 if inlist(sic4_2d,"19")
*Chemicals and Chemical Products
replace wiod_sector=9 if inlist(sic4_2d,"20", "21")
*Rubber and Plastics
replace wiod_sector=10 if inlist(sic4_2d,"22")
*Other Non-Metallic Mineral
replace wiod_sector=11 if inlist(sic4_2d,"23")
*Basic Metals and Fabricated Metal
replace wiod_sector=12 if inlist(sic4_2d,"24", "25")
*Machinery, Nec
replace wiod_sector=13 if inlist(sic4_2d,"28")
*Electrical and Optical Equipment
replace wiod_sector=14 if inlist(sic4_2d,"26", "27")
*Transport Equipment
replace wiod_sector=15 if inlist(sic4_2d,"29", "30")
*Manufacturing, Nec; Recycling
replace wiod_sector=16 if inlist(sic4_2d,"31", "32", "33")
*Electricity, Gas and Water Supply
replace wiod_sector=17 if inlist(sic4_2d,"35", "36", "37", "38", "39")
*Construction
replace wiod_sector=18 if inlist(sic4_2d,"41", "42", "43")
*Sale, Maintenance and Repair of Motor Vehicles and Motorcycles; Retail Sale of Fuel
replace wiod_sector=19 if inlist(sic4_2d,"45")
*Wholesale Trade and Commission Trade, Except of Motor Vehicles and Motorcycles
replace wiod_sector=20 if inlist(sic4_2d,"46")
*Retail Trade, Except of Motor Vehicles and Motorcycles; Repair of Household Goods
replace wiod_sector=21 if inlist(sic4_2d,"47")
*Hotels and Restaurants
replace wiod_sector=22 if inlist(sic4_2d,"55", "56")
*Inland Transport
replace wiod_sector=23 if inlist(sic4_2d,"49")
*Water Transport
replace wiod_sector=24 if inlist(sic4_2d,"50")
*Air Transport
replace wiod_sector=25 if inlist(sic4_2d,"51")
*Other Supporting and Auxiliary Transport Activities; Activities of Travel Agencies
replace wiod_sector=26 if inlist(sic4_2d,"52", "79")
*Post and Telecommunications
replace wiod_sector=27 if inlist(sic4_2d,"53", "58", "59", "60", "61", "62", "63")
*Financial Intermediation
replace wiod_sector=28 if inlist(sic4_2d,"64", "65", "66")
*Real Estate Activities
replace wiod_sector=29 if inlist(sic4_2d,"68")
*Renting of M&Eq and Other Business Activities
replace wiod_sector=30 if inlist(sic4_2d, "69", "70", "71", "72", "73", "74")
replace wiod_sector=30 if inlist(sic4_2d, "75", "77", "78", "80", "81", "82")
replace wiod_sector=30 if inlist(sic4_2d, "90", "91", "92", "93")
*Public Admin and Defence; Compulsory Social Security
replace wiod_sector=31 if inlist(sic4_2d,"84")
*Education
replace wiod_sector=32 if inlist(sic4_2d,"85")
*Health and Social Work
replace wiod_sector=33 if inlist(sic4_2d,"86", "87", "88")
*Other Community, Social and Personal Services
replace wiod_sector=34 if inlist(sic4_2d,"94", "95", "96")
*Private Households with Employed Persons
replace wiod_sector=35 if inlist(sic4_2d,"97", "98", "99")
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
*share in manuf USA
egen sh_manuf_USA=total(emp_state_sector)
replace sh_manuf=sh_manuf_USA/tot_US
summ sh_manuf 

rename ruv_ sector
rename share share_empl
rename state region
keep sector region share
replace region=lower(region)
replace region=subinstr(region," ","",.)
rename share share_adh
compress

save $output , replace


