/*------------------------------------------------------------------------------
********** Explanation of what the file does
--------------------------------------------------------------------------------

This runs some analyses on the state unemployment data

--------------------------------------------------------------------------------
********** Input files needed
--------------------------------------------------------------------------------

jointUR.dta

--------------------------------------------------------------------------------
********** Output files produced
--------------------------------------------------------------------------------

tempX.dta */

********************************************************************************

* Setup

clear all

* Set the directory

cd "C:\Dropbox\NK trade\StateUnemployment"

* Call dataset

use jointUR.dta, clear

* Drop irrelevant years

drop if Year<2000
drop if Year>2011

foreach var of varlist U* L* {
	bysort State: gen `var'1=`var' if Year==2000
	by State: egen `var'first=total(`var'1)
	gen `var'diff=`var'-`var'first
	gen `var'dc=`var'diff*10/7
}

drop *1 *first

* Set panel 

xtset statecode Year

* Run some rolling regressions to obtain coefficient on exposure

* First run them on the data

preserve
rolling2 _b _se, window(3) clear onepanel: regress UPdc Exposure
gen Year=(start+end)/2
rename _b_Exposure BetaData
rename _se_Exposure SEData
keep Year BetaData SEData
save temp1.dta,replace
restore

* Then run them on the model

preserve
rolling2 _b _se, window(3) clear onepanel: regress UPmodeldc Exposure
gen Year=(start+end)/2
rename _b_Exposure BetaModel
rename _se_Exposure SEModel
keep Year BetaModel SEModel
save temp2.dta,replace
restore

* Then merge the two

use temp1.dta, clear
merge 1:1 Year using temp2

* Generate 90% error bands

gen BetaModel_up=BetaModel+1.65*SEModel
gen BetaModel_lo=BetaModel-1.65*SEModel
gen BetaData_up=BetaData+1.65*SEData
gen BetaData_lo=BetaData-1.65*SEData

* Plot

twoway (line BetaData Year, lcolor(blue) lpattern(solid)) ///
	   (rarea BetaData_up BetaData_lo Year, color(blue%10)) ///
       (line BetaModel Year, lcolor(red) lpattern(solid)) ///
	   (rarea BetaModel_up BetaModel_lo Year, color(red%10)), ///
xtitle("Year") xlabel(2001(1)2010) ///
ytitle("Coefficient on Exposure") ///
title("Coefficient on Exposure for Unemployment") ///
legend(order(1 2 3 4) ///
label(1 "Data Coefficient") ///
label(2 "Data 90% CI") ///
label(3 "Model Coefficient") ///
label(4 "Model 90% CI") ///
rows(2) ring(3) position(7)) ///
graphregion(color(white)) bgcolor(white) ///
name(Unemployment, replace)
	   
* Same thing but for LFP

* Call dataset

use jointUR.dta, clear

* Drop irrelevant years

drop if Year<2000
drop if Year>2011

foreach var of varlist U* L* {
	bysort State: gen `var'1=`var' if Year==2000
	by State: egen `var'first=total(`var'1)
	gen `var'diff=`var'-`var'first
	gen `var'dc=`var'diff*10/7
}

drop *1 *first

* Set panel 

xtset statecode Year

* First run them on the data

preserve
rolling2 _b _se, window(3) clear onepanel: regress LFPRdc Exposure
gen Year=(start+end)/2
rename _b_Exposure BetaData
rename _se_Exposure SEData
keep Year BetaData SEData
save temp1.dta,replace
restore

* Then run them on the model

preserve
rolling2 _b _se, window(3) clear onepanel: regress LFPRmodeldc Exposure
gen Year=(start+end)/2
rename _b_Exposure BetaModel
rename _se_Exposure SEModel
keep Year BetaModel SEModel
save temp2.dta,replace
restore

* Then merge the two

use temp1.dta, clear
merge 1:1 Year using temp2

* Generate 90% error bands

gen BetaModel_up=BetaModel+1.65*SEModel
gen BetaModel_lo=BetaModel-1.65*SEModel
gen BetaData_up=BetaData+1.65*SEData
gen BetaData_lo=BetaData-1.65*SEData

* Plot

twoway (line BetaData Year, lcolor(blue) lpattern(solid)) ///
	   (rarea BetaData_up BetaData_lo Year, color(blue%10)) ///
       (line BetaModel Year, lcolor(red) lpattern(solid)) ///
	   (rarea BetaModel_up BetaModel_lo Year, color(red%10)), ///
xtitle("Year") xlabel(2001(1)2010) ///
ytitle("Coefficient on Exposure") ///
title("Coefficient on Exposure for LFP") ///
legend(order(1 2 3 4) ///
label(1 "Data Coefficient") ///
label(2 "Data 90% CI") ///
label(3 "Model Coefficient") ///
label(4 "Model 90% CI") ///
rows(2) ring(3) position(7)) ///
graphregion(color(white)) bgcolor(white) ///
name(LFP, replace)

/*
********************************************************************************

* Another option is just to regress unemployment data on state and time fixed
* effects and obtain the residuals and plot them against each other

use jointUR.dta, clear

* Drop irrelevant years

drop if Year<2003
drop if Year>2004

* Do regressions and obtain residuals

reg UP i.Year i.statecode
predict resdata, residuals

reg UPmodel i.Year i.statecode
predict resmodel, residuals

* Do a scatter plot of the residuals

scatter resdata resmodel

********************************************************************************
* New try

use jointUR.dta, clear

* Drop irrelevant years

drop if Year<2006
drop if Year>2006

* Do regressions and obtain residuals

reg UP
predict resdata, residuals

reg UPmodel
predict resmodel, residuals

* Do a scatter plot of the residuals

graph twoway (scatter resdata resmodel) (lfit resdata resmodel)
*/

