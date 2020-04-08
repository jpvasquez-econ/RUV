capture log close
* Written by JP with initial code of Mau
clear all
set more off
set linesize 150
log using 3-Log_Files\3-1-CFS-to-Sectors-Cross.log, replace

/*
***********************************************************************************************************************************************
***  	THIS DO FILE DOES THE FOLLOWING:
***********************************************************************************************************************************************
Associates each commodity code with a NAICS code and then transforms the latter in the 14 desired sector categories.
It is important to note that each commodity can be associated with more than one NAICS, depending on the industry that that
commodity was produced in. 
The code takes CFS 2007 and 2012 for the US, and calculates the proportion of the amount of commodity c associated with
NAICS n, with respect to the total amount of commodity c. This gives a matrix of (#commodities)x14 for each year. 
In general, this do file gives a matrix that shows how to redistribute the amount of each commodity into 14 sectors for the US
for 2002, 2007 and 2012; the matrix for 2002 is the same as the one for 2007. 
*/

*********************** 
***  OUTPUT FILES   ***  
***********************
global CFSapportionment "1-Intermediate_Processed_Data\CFSapportionment.dta"
********************** 
***  INPUT FILES   ***  
**********************
global data_2007 "import excel "0-Raw_Data\CFS\NAICS to CFS Crosswalk.xlsx", sheet("CF0700A18") cellrange(A1) firstrow clear"
global data_2012 "import delimited "0-Raw_Data\CFS\CFS_2012_00A18_with_ann.csv", varnames(1) rowrange(3) clear"

foreach year in 2007 2012{

* Import CFS data with both NAICS and CFS codes
${data_`year'}
* Keep just total data for all of the US, not separated by state. 
capture keep if GEOTYPE==1

* Recode manufacturing as NAICS 3 and destring NAICS code
capture rename NAICS2002 NAICS`year'
capture rename NAICS2002_MEANING NAICS`year'_MEANING
capture rename naicsid NAICS`year'

replace NAICS`year'="3" if NAICS`year'=="31-33"
capture replace NAICS`year'="4931" if NAICS`year'=="4931(CF1)"
destring NAICS`year', replace force

* Keep just relevant variables, NAICS code, SCTG code and value shipped
capture rename naicsdisplaylabel NAICS`year'_MEANING
capture rename commid COMM
capture rename commdisplaylabel COMM_MEANING
capture rename val VAL
capture destring VAL, replace force

keep NAICS* COMM COMM_MEANING VAL

* Drop all commodities category and unknown commodity category
capture tostring COMM, replace
foreach v in 07 08 17 18 {
capture replace COMM="`v'" if COMM=="`v'-R"
}
capture destring COMM, replace
drop if COMM==0 | COMM==99

* Also drop superflous NAICS and turn them all into 3 digit numbers
drop if NAICS`year'==3 
drop if NAICS`year'==423 | NAICS`year'==424
drop if NAICS`year'>4230 & NAICS`year'<4250
replace NAICS`year'=421 if NAICS`year'==42
replace NAICS`year'=454 if NAICS`year'==4541
replace NAICS`year'=455 if NAICS`year'==45431
replace NAICS`year'=493 if NAICS`year'==4931
replace NAICS`year'=511 if NAICS`year'==5111
replace NAICS`year'=551 if NAICS`year'==551114

* The 22 sectors in CDP are:

* 01) Food, Beverage, and Tobacco Products (NAICS 311-312); 
* 02) Textile, Textile Product Mills, Apparel, Leather, and Allied Products (NAICS 313-316);
* 03) Wood Products, Paper, Printing, and Related Support Activities (NAICS 321-323); 
* 04) Petroleum and Coal Products (NAICS 324); 
* 05) Chemical (NAICS 325); 
* 06) Plastics and Rubber Products (NAICS 326); 
* 07) Nonmetallic Mineral Products (NAICS 327);
* 08) Primary Metal and Fabricated Metal Products (NAICS 331-332); 
* 09) Machinery (NAICS 333);
* 10) Computer and Electronic Products, and Electrical Equipment and Appliance (NAICS 334-335); 
* 11) Transportation Equipment (NAICS 336); 
* 12) Furniture and Related Products, and Miscellaneous Manufacturing (NAICS 337-339); 
* 14) Trade (NAICS 42-45);
* 13) Construction (NAICS 23);
* 15) Transport Services (NAICS 481-488); 
* 16) Information Services (NAICS 511-518);
* 17) Finance and Insurance (NAICS 521-525); 
* 18) Real Estate (NAICS 531-533); 
* 19) Education (NAICS 61); 
* 20) Health Care (NAICS 621-624); 
* 21) Accommodation and Food Services (NAICS 721-722); 
* 22) Other Services (NAICS 493, 541, 55, 561, 562, 711-713, 811-814);
*23.	(NAICS 111-115) Agriculture, Forestry, Fishing, and Hunting (c1)
*Mining, Quarrying, and Oil and Gas Extraction (c2). 

* Switch from NAICS to CDP sectors

recode NAICS`year' ///
(311 = 1 ) ///
(312 = 1 ) /// 
(313 = 2 ) ///
(314 = 2 ) ///
(315 = 2 ) ///
(316 = 2 ) ///
(321 = 3 ) ///
(322 = 3 ) ///
(323 = 3 ) ///
(324 = 4 ) ///
(325 = 5 ) ///
(326 = 6 ) ///
(327 = 7 ) ///
(331 = 8 ) /// 
(332 = 8 ) ///
(333 = 9 ) ///
(334 = 10) ///
(335 = 10) ///
(336 = 11) ///
(337 = 12) ///
(339 = 12) ///
(421 = 14) ///
(454 = 14) ///
(455 = 14) ///
(493 = 22) ///
(511 = 16) /// 
(551 = 22) ///
(nonmissing = .), gen(cdp)

drop if cdp==.
collapse (sum) VAL, by(cdp COMM)
*Services
replace cdp=13 if (cdp>=13 & cdp<=22)==1
collapse (sum) VAL, by(cdp COMM)

order COMM cdp VAL
sort COMM cdp

by COMM: egen totalsent=total(VAL)
gen portion=VAL/totalsent

xtset COMM cdp

tsfill, full

replace portion=0 if portion==.

drop VAL totalsent

reshape wide portion, i(COMM) j(cdp)
gen year=`year'
tempfile data`year'
save `data`year'', replace
}
***
*** APPENDING YEARS
***
use `data2007', clear
replace year=2002
append using `data2007'
append using `data2012'

save $CFSapportionment, replace
