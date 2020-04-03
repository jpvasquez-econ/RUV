capture log close
* Written by JP 
clear all
set more off
set linesize 150
log using 3-Log_Files\1-wiod.log, replace

/*
***********************************************************************************************************************************************
***  	THIS DO FILE DOES THE FOLLOWING:
***********************************************************************************************************************************************
Takes WIOD and maps to the 14 relevant sectors that we consider
*/

********************** 
***  INPUT FILES   ***  
**********************
global wiot ""1-Intermediate_Processed_Data\wiot_full.dta""

********************** 
***  OUTPUT FILES  ***  
**********************
global WIOD_countries "2-Final_Data\WIOD_countries.dta"

use $wiot, clear

***********************************************************************************************************************************************
***********************************************************************************************************************************************
*** 2. ASSIGNS SAME CORRESPONDANCES AS IN CDP, SO THAT THE SECTORS ARE EQUIVALENT AS THOSE
*** IN WIOD.
***********************************************************************************************************************************************
***********************************************************************************************************************************************
/*
***********************************************************************************************************************************************
***  	MANUFACTURING SECTORS USED AND THEIR MAPPING TO WIOD (indexed by ci)
***********************************************************************************************************************************************
1.	(NAICS 311-312) Food Products, Beverage, and Tobacco Products (c3);
2.	(NAICS 313-316) Textile, Textile Product Mills, Apparel, Leather, and Allied Products (c4-c5); 
3.	(NAICS 321-323) Wood Products, Paper, Printing, and Related Sup- port Activities (c6-c7); 
4.	(NAICS 211-213, 324) Mining; and Petroleum and Coal Products (c2 and c8);
5.	(NAICS 325) Chemical (c9); 
6.	(NAICS 326) Plastics and Rubber Products (c10); 
7.	(NAICS 327) Nonmetallic Mineral Products (c11); 
8.	(NAICS 331-332) Primary Metal and Fabricated Metal Products (c12); 
9.	(NAICS 333); Machinery (c13); 
10.	(NAICS 334-335) Computer and Electronic Products, and Electrical Equipment and Appliances (c14);
11.	(NAICS 336) Transportation Equipment (c15); 
12.	(NAICS 337- 339) Furniture and Related Products, and Miscellaneous Manufacturing (c16); 
13.	((NAICS 23) Construction (c18); 
14.	(NAICS 42-45) Wholesale and Retail Trade (c19-c21); 
15.	(NAICS 481-488) Transport Services (c23-c26);
16.	(NAICS 511-518) Information Services (c27); 
17.	(NAICS 521-525) Finance and Insurance (c28); 
18.	(NAICS 531-533)  Real Estate (c29-c30); 
19.	(NAICS 61) Education (c32); 
20.	(NAICS 621-624) Health Care (c33); 
21.	(NAICS 721-722) Accommodation and Food Services (c22); 
22.	(NAICS 493, 541, 55, 561, 562, 711-713, 811-814) Other Services (c34).
23.	(NAICS 111-115) Agriculture (c1).
*/
gen row_sector=.
*1.	(NAICS 311-312) Food Products, Beverage, and Tobacco Products (c3);
replace row_sector=1 if row_item==3
*2.	(NAICS 313-316) Textile, Textile Product Mills, Apparel, Leather, and Allied Products (c4-c5);
replace row_sector=2 if row_item==4 | row_item==5
*3.	(NAICS 321-323) Wood Products, Paper, Printing, and Related Sup- port Activities (c6-c7); 
replace row_sector=3 if row_item==6 | row_item==7
*4.	(NAICS 211-213, 324) Petroleum and Coal Products (c8);
*Mining, Quarrying, and Oil and Gas Extraction (c2). 
replace row_sector=4 if row_item==8 | row_item==2
*5.	(NAICS 325) Chemical (c9);
replace row_sector=5 if row_item==9
*6.	(NAICS 326) Plastics and Rubber Products (c10); 
replace row_sector=6 if row_item==10
*7.	(NAICS 327) Nonmetallic Mineral Products (c11); 
replace row_sector=7 if row_item==11
*8.	(NAICS 331-332) Primary Metal and Fabricated Metal Products (c12); 
replace row_sector=8 if row_item==12
*9.	(NAICS 333); Machinery (c13); 
replace row_sector=9 if row_item==13
*10.	(NAICS 334-335) Computer and Electronic Products, and Electrical Equipment and Appliances (c14);
replace row_sector=10 if row_item==14
*11.	(NAICS 336) Transportation Equipment (c15); 
replace row_sector=11 if row_item==15
*12.	(NAICS 337-339) Furniture and Related Products, and Miscellaneous Manufacturing (c16); 
replace row_sector=12 if row_item==16
*13.	((NAICS 23) Construction (c18); 
replace row_sector=13 if row_item==18
*14.	(NAICS 42-45) Wholesale and Retail Trade (c19-c21); 
replace row_sector=14 if row_item==19 | row_item==20 | row_item==21 
*15.	(NAICS 481-488) Transport Services (c23-c26);
replace row_sector=15 if row_item==23 | row_item==24 | row_item==25 | row_item==26 
*16.	(NAICS 511-518) Information Services (c27);
replace row_sector=16 if row_item==27 
*17.	(NAICS 521-525) Finance and Insurance (c28); 
replace row_sector=17 if row_item==28 
*18.	(NAICS 531-533)  Real Estate (c29-c30); 
replace row_sector=18 if row_item==29 | row_item==30  
*19.	(NAICS 61) Education (c32); 
replace row_sector=19 if row_item==32 
*20.	(NAICS 621-624) Health Care (c33);
replace row_sector=20 if row_item==33 
*21.	(NAICS 721-722) Accommodation and Food Services (c22); 
replace row_sector=21 if row_item==22 
*22.	(NAICS 493, 541, 55, 561, 562, 711-713, 811-814) Other Services (c34).
replace row_sector=22 if row_item==34 
*23.	(NAICS 111-115) Agriculture, Forestry, Fishing, and Hunting (c1)
replace row_sector=23 if row_item==1  
keep if row_sector!=. 
*checks that we have 23 manuf sectors
distinct row_sector 
assert `r(ndistinct)'==23

* only sending sector
collapse (sum) value , by(*_country row_sector year)
***********************************************************************************************************************************************
***  	Relevant countries
***********************************************************************************************************************************************
gen importer=.
gen exporter=.
replace col_country="ROU" if col_country=="ROM"
replace row_country="ROU" if row_country=="ROM"
replace importer=1 if col_country=="USA"
replace exporter=1 if row_country=="USA"

scalar j=51
local countries "AUS AUT BEL BGR BRA CAN CHN CYP CZE DEU DNK ESP EST FIN FRA GBR GRC HUN IDN IND IRL ITA JPN KOR LTU MEX NLD POL PRT ROU RoW RUS SVK SVN SWE TUR TWN"
foreach v of local countries{
replace importer=`=j' if col_country=="`v'"
replace exporter=`=j' if row_country=="`v'"
scalar j=`=j'+1
}

drop if importer==. | exporter==.
distinct row_country if importer!=. 
assert `r(ndistinct)'==38
distinct row_country if exporter!=. 
assert `r(ndistinct)'==38
***********************************************************************************************************************************************
***  	GENERATE MATRIX
***********************************************************************************************************************************************
keep value col_country importer row_sector exporter year
reshape wide value, i(col_country importer row_sector year) j(exporter)

rename value1 value_USA
scalar j=51
local countries "AUS AUT BEL BGR BRA CAN CHN CYP CZE DEU DNK ESP EST FIN FRA GBR GRC HUN IDN IND IRL ITA JPN KOR LTU MEX NLD POL PRT ROU RoW RUS SVK SVN SWE TUR TWN"
foreach v of local countries{
rename value`=j' value_`v'
scalar j=`=j'+1
}
rename col_country importer_country
rename row_sector sector
***********************************************************************************************************************************************
***  	SERVICES AND AGRICULTURE
***********************************************************************************************************************************************
*SERVICES IN ONE SECTOR
gen serv=(sector>=13 & sector<23)
ds value_*
foreach v in `r(varlist)'{
capture drop temp*
gen double temp=serv*`v'
bys importer_c year importer: egen temp2=total(temp)
replace `v'=temp2 if serv==1
drop temp*
}
drop if sector>13 & sector<23
drop serv
*agriculture as sector 14
replace sector=14 if sector==23
sort year sector importer

save $WIOD_countries, replace
