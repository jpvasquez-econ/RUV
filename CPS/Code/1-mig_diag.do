**
** QUICK AND DIRTY STATS FOR THE DIAGONALS

***
*** YEAR
***
clear
use clean_data.dta , clear 
drop if statefip == 15 //hawaii
sort id year month mish
*CASE 1: ONLY ONE OBSERVATION BY PERSON
*(NEED TO PREPARE CASE 2 THAT INCLUDES mish == 2 | 6, mish == 3 | 7, mish == 4 | 8)
keep if mish == 1 | mish == 5
sort id mish
bys id: gen n=_N
keep if n==2
egen time = group(mish)
xtset id time
gen ori = sector
gen dest = f.sector
keep if ori!=. & dest!=.
keep if year == 1999 // just one year but we need to consider the pooling like in R
gen wtfinl2 = 1 // to get number of respondents after collapse 
collapse (sum) wtfinl2 wtfinl , by(ori dest statefip)
*adding zeros
egen group = group(ori dest)
preserve
keep ori dest group 
duplicates drop 
tempfile temp
save `temp', replace
restore
drop ori dest 
xtset state group
tsfill ,  full
merge m:1 group using `temp', assert(3) nogen
bys state ori: egen tot2 = total(wtfinl2) // total number of respondents who started in a given state-sector 
** we might want to drop cases with very few respondents 
*drop if tot2<10
bys state ori: egen tot = total(wtfinl)
gen sh = wtfinl/tot
replace sh = 0 if sh == . & ori!=dest
summ sh if ori==dest, det
replace sh = `r(p50)' if sh == . & ori == dest // "correcting diagonals" when there aren't obs. We need to go back to the formula used in R. This is just a quick and dirty shortcut. 
summ sh if ori == dest, det // descriptive stats without weighting each state-sector 
summ sh if ori == dest [aw=wtfinl], det // with weights
***
*** QUARTER
***
clear
use clean_data.dta , clear
drop if statefip == 15 //hawaii
sort id year month mish
keep if mish == 1 | mish == 4 | mish == 5 | mish == 8
sort id mish
bys id: gen n=_N
keep if n==2 | n==4
egen time = group(mish)
xtset id time
gen ori = sector
gen dest = f.sector
keep if time ==1 | time == 3
keep if ori!=. & dest!=.
*keep if year == 1999 
gen quarter = .
replace quarter = 1 if month < 4
replace quarter = 2 if month >=4 & month < 7
replace quarter = 3 if month >=7 & month < 10
replace quarter = 4 if month >=10 & month !=.
*no weights
gen wtfinl2 = 1
collapse (sum) wtfinl wtfinl2, by(ori dest statefip quarter)
*adding zeros
egen group = group(ori dest)
egen ids = group(state quarter)
preserve
keep ori dest group 
duplicates drop 
tempfile temp
save `temp', replace
restore
preserve
keep state quarter ids 
duplicates drop 
tempfile ids
save `ids', replace
restore
drop ori dest quarter state 
xtset ids group
tsfill ,  full
merge m:1 group using `temp', assert(3) nogen
merge m:1 ids using `ids', assert(3) nogen
bys state ori quarter : egen tot2 = total(wtfinl2) // total number of respondents who started in a given state-sector 
** we might want to drop cases with very few respondents 
*drop if tot2<10
bys state ori quarter: egen tot = total(wtfinl)
gen sh = wtfinl/tot
replace sh = 0 if sh == . & ori!=dest
summ sh if ori==dest, det
replace sh = `r(p50)' if sh == . & ori == dest
replace wtfinl = 0 if wtfinl == .
bys quarter: summ sh if ori == dest , det
bys quarter: summ sh if ori == dest [aw=wtfinl], det
