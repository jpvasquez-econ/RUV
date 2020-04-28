capture log close
* Written by JP 
clear all
set more off
set linesize 150

/*
***********************************************************************************************************************************************
***  	THIS DO FILE DOES THE FOLLOWING:
***********************************************************************************************************************************************
Takes imports and exports data from census and changes the 
sectors for those we use
*/

********************** 
***  INPUT FILES   ***  
**********************
global imports ""1-Intermediate_Processed_Data\census_imports.dta""
global exports ""1-Intermediate_Processed_Data\census_exports.dta""

********************** 
***  OUTPUT FILES  ***  
**********************
global state_imports_exports "1-Intermediate_Processed_Data\state_imports_exports.dta"

foreach v in exports imports {
use ${`v'}, clear
destring year, replace
***
*** COUNTRIES OF CDP/WIOD
***
capture rename origin country
capture rename destination country
capture rename exports value
capture rename imports value
quiet{
drop if state=="Dist of Columbia"
drop if state=="Puerto Rico"
drop if state=="US Virgin Islands"
drop if state=="Unknown"

drop if country=="APEC - Asia Pacific Economic Co-operation"
drop if country=="ASEAN - Association of Southeast Asian Nations"
drop if country=="Asia"
drop if country=="Australia and Oceania"
drop if country=="Central American Common Market"
drop if country=="Euro Area"
drop if country=="Europe"
drop if country=="European Union"
drop if country=="LAFTA - Latin American Free Trade Association"
drop if country=="NATO (North Atlantic Treaty Organization) Allies"
drop if country=="NICS - Newly Industrialized Countries"
drop if country=="OECD - Organization for Economic Co-operation and Development"
drop if country=="OPEC - Organization of Petroleum Exporting Countries"
drop if country=="North America"
drop if country=="Pacific Rim Countries"
drop if country=="South/Central America"
drop if country=="Twenty Latin American Republics"
drop if country=="US Trade Agreements Partners"
drop if country=="Western Sahara"
gen region=""
replace region="AUS" if country=="Australia"
replace region="AUT" if country=="Austria"
replace region="BEL" if country=="Belgium"
replace region="BRA" if country=="Brazil"
replace region="BGR" if country=="Bulgaria"
replace region="CAN" if country=="Canada"
replace region="CHN" if country=="China"
replace region="CYP" if country=="Cyprus"
replace region="CZE" if country=="Czech Republic"
replace region="DNK" if country=="Denmark"
replace region="EST" if country=="Estonia"
replace region="FIN" if country=="Finland"
replace region="FRA" if country=="France"
replace region="GBR" if country=="United Kingdom"
replace region="DEU" if country=="Germany"
replace region="GRC" if country=="Greece"
replace region="HUN" if country=="Hungary"
replace region="IND" if country=="India"
replace region="IDN" if country=="Indonesia"
replace region="IRL" if country=="Ireland"
replace region="ITA" if country=="Italy"
replace region="JPN" if country=="Japan"
replace region="KOR" if country=="Korea, South"
replace region="LTU" if country=="Lithuania"
replace region="MEX" if country=="Mexico"
replace region="NLD" if country=="Netherlands"
replace region="POL" if country=="Poland"
replace region="PRT" if country=="Portugal"
replace region="ROU" if country=="Romania"
replace region="RUS" if country=="Russia"
replace region="SVK" if country=="Slovakia"
replace region="SVN" if country=="Slovenia"
replace region="ESP" if country=="Spain"
replace region="SWE" if country=="Sweden"
replace region="TWN" if country=="Taiwan"
replace region="TUR" if country=="Turkey"
distinct region
assert `r(ndistinct)'==36
replace region="RoW" if region=="" 
collapse (sum) value, by(state naics year region)
if "`v'"=="exports"{
rename state origin
rename region destination
}
if "`v'"=="imports"{
rename state destination 
rename region origin
}
}

***
*** SECTORS OF CDP/WIOD
***
drop if naics3d=="All Commodities"
gen sec_naics=substr(naics3d,1,3)
destring sec_naics, replace
/*
***********************************************************************************************************************************************
***  	 SECTORS USED AND THEIR MAPPING TO WIOD (indexed by ci)
***********************************************************************************************************************************************
1.	(NAICS 311ñ312) Food Products, Beverage, and Tobacco Products (c3);
2.	(NAICS 313ñ316) Textile, Textile Product Mills, Apparel, Leather, and Allied Products (c4ñc5); 
3.	(NAICS 321ñ323) Wood Products, Paper, Printing, and Related Sup- port Activities (c6ñc7); 
4.	(NAICS 324 , 211-213) Petroleum and Coal Products and mining (c2, c8);
5.	(NAICS 325) Chemical (c9); 
6.	(NAICS 326) Plastics and Rubber Products (c10); 
7.	(NAICS 327) Nonmetallic Mineral Products (c11); 
8.	(NAICS 331ñ332) Primary Metal and Fabricated Metal Products (c12); 
9.	(NAICS 333); Machinery (c13); 
10.	(NAICS 334ñ335) Computer and Electronic Products, and Electrical Equipment and Appliances (c14);
11.	(NAICS 336) Transportation Equipment (c15); 
12.	(NAICS 337ñ 339) Furniture and Related Products, and Miscellaneous Manufacturing (c16); 
13.	((NAICS XX) Construction (c18); 
14.	(NAICS 42-45) Wholesale and Retail Trade (c19ñc21); 
15.	(NAICS 481-488) Transport Services (c23ñc26);
16.	(NAICS 511ñ518) Information Services (c27); 
17.	(NAICS 521ñ525) Finance and Insurance (c28); 
18.	(NAICS 531-533)  Real Estate (c29ñc30); 
19.	(NAICS 61) Education (c32); 
20.	(NAICS 621ñ624) Health Care (c33); 
21.	(NAICS 721ñ722) Accommodation and Food Services (c22); 
22.	(NAICS 493, 541, 55, 561, 562, 711ñ713, 811-814) Other Services (c34).
23.	(NAICS 111-115) Agriculture (c1).
*/
gen sector=.
*1.	(NAICS 311ñ312) Food Products, Beverage, and Tobacco Products (c3);
replace sector=1 if sec_naics==311 | sec_naics==312
*2.	(NAICS 313ñ316) Textile, Textile Product Mills, Apparel, Leather, and Allied Products (c4ñc5);
replace sector=2 if sec_naics==313 | sec_naics==314 | sec_naics==315 | sec_naics==316
*3.	(NAICS 321ñ323) Wood Products, Paper, Printing, and Related Sup- port Activities (c6ñc7); 
replace sector=3 if sec_naics==321 | sec_naics==322 | sec_naics==323
*4.	(NAICS 324, 211-213) Petroleum and Coal Products (c8) and mining (c2);
replace sector=4 if sec_naics==324 | sec_naics==211 | sec_naics==212 |sec_naics==213
*5.	(NAICS 325) Chemical (c9);
replace sector=5 if sec_naics==325
*6.	(NAICS 326) Plastics and Rubber Products (c10); 
replace sector=6 if sec_naics==326
*7.	(NAICS 327) Nonmetallic Mineral Products (c11); 
replace sector=7 if sec_naics==327
*8.	(NAICS 331ñ332) Primary Metal and Fabricated Metal Products (c12); 
replace sector=8 if sec_naics==331 | sec_naics==332
*9.	(NAICS 333); Machinery (c13); 
replace sector=9 if sec_naics==333
*10.	(NAICS 334ñ335) Computer and Electronic Products, and Electrical Equipment and Appliances (c14);
replace sector=10 if sec_naics==334 | sec_naics==335
*11.	(NAICS 336) Transportation Equipment (c15); 
replace sector=11 if sec_naics==336
*12.	(NAICS 337ñ 339) Furniture and Related Products, and Miscellaneous Manufacturing (c16); 
replace sector=12 if sec_naics==337 | sec_naics==338 | sec_naics==339
*16.	(NAICS 511ñ518) Information Services (c27);
replace sector=16 if sec_naics==511 
*14.	(NAICS 111-115, 211-213) Agriculture and Mining (c1).
replace sector=14 if sec_naics<=115 
keep if sector!=. 
*checks that we have all manuf sectors
distinct sector 
assert `r(ndistinct)'==14

* only sending sector
collapse (sum) value , by(year sector destination origin)
if "`v'"=="exports"{
gen file="i in US, j not in US"
}
if "`v'"=="imports"{
gen file="i not in US, j in US"
}
tempfile `v'
save ``v'', replace
}
clear
use `exports'
append using `imports'
replace sector=13 if sector>12 & sector!=14

replace origin = subinstr(origin, " ", "", .)
replace destination = subinstr(destination, " ", "", .)

save $state_imports_exports, replace
