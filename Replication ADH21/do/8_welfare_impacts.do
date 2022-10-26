drop _all
clear

********************************************************************************
*THIS FILE CONSTRUCTS ESTIMATES OF THE IMPACT OF TRADE SHOCKS ON PERSONAL INCOME PER CAPITA, MOTIVATED BY THE GRCY IMPLIED REDUCED FORM FORMULAS
	*WE MULTIPLY THE TRADE SHOCK BY THE ADJUSTED R SQUARED FROM THE 1ST STAGE REGRESSION, AND THEN BY THE COEFFICIENT ESTIMATE OF THE TRADE SHOCK FOR THE DESIRED OUTCOME AT THE CZ LEVEL 
	*WE CONSTRUCT THE MEAN DEVIATION FOR THE TRADE SHOCK IMPACT 
********************************************************************************

********************************************************************************
* AGGREGATE IMPACTS ON COMMUTING ZONES
********************************************************************************

foreach p in 9112 {

	if `p'==9107 {
	local base1 = 1991
	local base2 = 2000
	local end1 = 2000
	local end2 = 2007
	local end3 = 2007
	local beta_1 = -2.252 /*coefficient for change in personal income per capita, 2000-2019*/
	local beta_2 = -0.840 /*coefficient for change in personal income per capita, 2000-2019*/
	}

	if `p'==9112 {
	local base1 = 1991
	local base2 = 2000
	local end1 = 2000
	local end2 = 2012
	local end3 = 2019
	local beta_1 = -2.658 /*coefficient for change in personal income per capita, 2000-2019*/
	local beta_2 = -1.739 /*coefficient for change in wage and salary employment-population, 2000-2019*/
    }

*ADJ R SQUARED ADJUSTMENT TERM	
local adjr = .57
*OUTCOME VARIABLES CONSIDERED
local var1 = "log personal income per capita, `base2'-`end3'"
local var2 = "wage and salary employment/working-age pop, `base2'-`end3'"
local VAR1 = "yi"
local VAR2 = "tp2"
local M = "Deviation from mean"
*AGGREGATE WELFARE IMPACT 2000-07 FROM GRCY '20 
local Mline = 0.22

*LOAD CZ POPULATION DATA
use "${data}/ADH_pop_emp_transfers.dta" 
keep if year==2000
keep year czone Pop PInc
*CALCULATE POPULATION WEIGHTS
egen tPop=sum(Pop)
gen wt=Pop/tPop
gen pop=Pop/1000

*MERGE IN CONTROL VARIABLES
merge 1:1 czone year using "${data}/ADH_control_vars.dta"
keep if year==2000
tab _m
drop _m 

*MERGE IN CZ NAMES
merge 1:1 czone using "${data}/cz_msa_names.dta" 
keep if _m==3
drop _m cz_id cz_pop

*PREPARE TRADE SHOCKS CONSTRUCTED FROM DAVID DORN'S MODIFIED DO FILE FOR LATER MERGE
merge 1:1 czone using "${data}/czone_exposure_by_period_v5_gh.dta"
keep if _m==3
drop _m
*USE IPR WHERE WE KEEP INDUSTRY ABSORPTION FIXED IN BEGINNING YEAR
keep cz* ba* Pop tPop wt pop l_shind_manuf_cbp *p1*`base1'_`end1' d_trade*p1*`base2'_`end2' d_trade*p1*`base1'_`end2'

*DECADALIZE VALUES, MULTIPLY BY ADJUSTED R SQUARED FROM 1ST STAGE REGRESSION, AND CALCULATE POPULATION WEIGHTED AVERAGE VALUES
foreach x in d_tradeusch_p1 {
foreach y in 1 2 {
	*trade shock magnitude
	gen ipr_`base2'_`end2'_`y' = 100*`x'_`base2'_`end2'*(10/(`end2'-`base2'))
	*direct trade shock impact
	gen ip_`base2'_`end2'_`y' = `beta_`y''*`adjr'*100*`x'_`base2'_`end2'*(10/(`end2'-`base2'))
	format ip* %9.3f
	*deviation from mean for trade shock impact
	foreach z in `base2'_`end2' {
	    sum ip_`z'_`y' [aw=wt]
		gen Mip_`z'_`y' = (ip_`z'_`y'-r(mean))
		}
	format ip* Mip* %9.3f	
	}
	}
*SUM STATS ON DEVIATION FROM MEAN	
foreach x in ip M {
	sum `x'* [aw=wt], det
	disp r(p90)-r(p10)
	sum `x'*, det 
	disp r(p90)-r(p10)
	}
sum pop l_shind_manuf_cbp ba_pop, det 
sum pop l_shind_manuf_cbp ba_pop [aw=wt], det

*CONSTRUCT HISTOGRAMS FOR SHOCKS
foreach x in 2 {
foreach y in 1 {
foreach z in M {		
	*Histogram of z scores for shock impacts on designated outcome
	format ip* Mip* %9.0f	
	hist `z'ip_`base`x''_`end`x''_`y' if `z'ip_`base`x''_`end`x''_`y'>-10, bin(36) xline(0) ylab(0(.1).5, labsize(small)) xlab(-8(2)2, labsize(small)) lcolor(black) mcolor(black) msize(vsmall) bcolor(navy) scheme(s2color) graphregion(color(white)) plotregion(color(white)) xtitle("``z'' for impact on `var`y''", size(small)) 
	gr export "${output}/bpea_fig_14.pdf", replace
	sort `z'ip_`base`x''_`end`x''_`y'
	format l_shind_manuf* pop ba* %9.1f
	format ip* Mip* %9.2f
	sum `z'ip_`base`x''_`end`x''_`y', det
	l cz_n pop l_shind_manuf_cbp ba_pop ipr_`base2'_`end2'_`y' `z'ip_`base`x''_`end`x''_`y' if `z'ip_`base`x''_`end`x''_`y'<r(p10), clean noobs
	disp " "
	disp "No. CZs with predicted change more than 2% below mean"
	count if `z'ip_`base`x''_`end`x''_`y'<-2
	disp " "
	disp "No. CZs with predicted change more than 1.25% below mean"
	count if `z'ip_`base`x''_`end`x''_`y'<-1.25
	disp " "
	disp "No. CZs with predicted change more than 1% below mean"
	count if `z'ip_`base`x''_`end`x''_`y'<-1
	disp " "
	disp "No. CZs with predicted change more than .5% below mean"
	count if `z'ip_`base`x''_`end`x''_`y'<-.5
	disp " "
	disp "No. CZs with predicted change more than .44% below mean"
	count if `z'ip_`base`x''_`end`x''_`y'<-.44
	disp "No. CZs with predicted change more than .22% below mean"
	count if `z'ip_`base`x''_`end`x''_`y'<-.22
	*Sum population in CZs whose projected real income loss is greater than 2X the positive ACR gains from trade
	preserve
	gen pop_losers = Pop*(`z'ip_`base`x''_`end`x''_`y'<-.22)
	collapse (sum) Pop pop_losers
	gen sh_losers = pop_losers/Pop
	sum
	restore
	}
	}
	}
	
drop _all
}
	
