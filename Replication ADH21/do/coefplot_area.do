
* preserve data
tempfile jorda_data
save `jorda_data', replace

* set scheme
set scheme plotplainblind

* generate labels
local tp1_lab "total employment/pop 18-64" 
local tp2_lab "wage & salary employment/pop 18-64" 
local tp3_lab "private nonfarm employment/pop 18-64" 
local mp_lab "manuf. employment/pop 18-64"
local np_lab "nonmanuf. employment/pop 18-64"
local up_lab "unemployment/pop 18-64"
local dp_lab "workers on SSDI/pop 18-64 (OASDI)"
local ltp1_lab "log total employment" 
local ltp2_lab "log wage & salary employment" 
local ltp3_lab "log private nonfarm employment" 
local lmp_lab "log manuf. employment"
local lnp_lab "log nonmanuf. employment"
local wkpop_lab "log population 18-64"
local wkmen_lab "log male population 18-64"
local wkfem_lab "log female population 18-64"
local odpop_lab "log population 40-64"
local ygpop_lab "log population 18-39"
local yg1pop_lab "log population 18-24"
local yg1men_lab "log male population 18-24"
local yg1fem_lab "log female population 18-24"
local yg2pop_lab "log population 25-39"
local yg2men_lab "log male population 25-39"
local yg2fem_lab "log female population 25-39"
local allpop_lab "log total population"
local yi_lab "log personal income per capita"  
local ti_lab "log personal income (less transfers) per capita"  
local li_lab "log wages and salaries per worker"  
local pi_lab "log proprietor's income per capita"
local di_lab "log dividents, interest, rent per capita"
local mw_lab "log mfg earnings per worker"  
local nw_lab "log non-mfg earnings per worker"  
local tc_lab "log government transfers per capita"
local ret_lab "log SSA, Medicare benefits per capita"  
local ssa_lab "log SSA, disability benefits per capita"  
local msc_lab "log other government transfers per capita"  
local unm_lab "log UI benefits/pop 18-64"  
local ust_lab "log state UI benefits per capita"  
local uot_lab "log other UI benefits per capita"  
local inc_lab "log income assistance per capita"  
local mca_lab "log Medicare benefits per capita"
local mcd_lab "log Medicaid benefits per capita"
local ssi_lab "log SSI benefits per capita"
local eit_lab "log EITC payments per capita"
local snp_lab "log SNAP benefits per capita"
local oim_lab "log other income maintenance per capita"
local vet_lab "log veteran's benefits per capita"
local edt_lab "log education and training per capita"
local yi_usd_lab "personal income per capita"  
local ti_usd_lab "personal income (less transfers) per capita"  
local ci_usd_lab "prviate nonfarm compensation per capita"  
local li_usd_lab "wages, salaries, benefits per worker"  
local pi_usd_lab "proprietor's income"
local di_usd_lab "dividents, interest, rent per capita"
local mw_usd_lab "mfg earnings per worker"  
local nw_usd_lab "non-mfg earnings per worker"  
local tc_usd_lab "government transfers per capita"  
local ret_usd_lab "SSA, Medicare benefits per capita"  
local oth_usd_lab "other transfers per capita"  
local ssa_usd_lab "SSA, disability benefits per capita"  
local msc_usd_lab "other government transfers per capita"  
local unm_usd_lab "UI benefits/pop 18-64"  
local ust_usd_lab "state UI benefits per capita"  
local uot_usd_lab "other UI benefits per capita"  
local inc_usd_lab "income assistance per capita"  
local mca_usd_lab "Medicare benefits per capita"
local mcd_usd_lab "Medicaid benefits per capita"
local ssi_usd_lab "SSI benefits per capita"
local eit_usd_lab "EITC payments per capita"
local snp_usd_lab "SNAP benefits per capita"
local oim_usd_lab "other income maintenance per capita"
local vet_usd_lab "veteran's benefits per capita"
local edt_usd_lab "education and training per capita"
local ba_pop_lab "share college-educated"
local hhi_ind_emp_lab "industry employment HHI"

*SELECT MARKERS FOR VERTICAL AXIS IN GRAPHS
/*
foreach y in mp np tp1 tp2 tp3 up dp {
	local `y'_ylab="-4(1)2"
	}
qui cap ds wkpop-allpop
foreach y in `r(varlist)' {
	local `y'_ylab="-10(2)4"
	}
foreach y in lmp lnp ltp1 ltp2 ltp3 {
	local `y'_ylab="-10(5)5"
	}
foreach y in mw nw {
	local `y'_ylab="-4(2)10"
	} 	
foreach y in yi ti li pi di tc ret oth {
	local `y'_ylab="-8(2)6"
	} 
foreach y in pi {
	local `y'_ylab="-30(10)20"
	} 
foreach y in yi_usd ti_usd li_usd pi_usd di_usd {
	local `y'_ylab="-4000(1000)1000 "
	}    	
foreach y in ssa_usd med_usd unm_usd mca_usd {
	local `y'_ylab="-300(50)200"
	}    	
foreach y in ssi_usd eit_usd snp_usd oim_usd edt_usd uot_usd ust_usd {
	local `y'_ylab="-50(25)100"
	}    	
foreach y in tc_usd ret_usd mcd_usd inc_usd {
	local `y'_ylab="-300(100)500"
	}    	
foreach y in ssa med inc unm mca mcd ssi eit snp oim edt {
	local `y'_ylab="-15(5)15"
	}
foreach y in unm {
	local `y'_ylab="-30(10)30"
	}
*/   	
* figure names

global wkpop_2000_2012	bpea_fig_7a
global odpop_2000_2012	bpea_fig_7b
global yg2pop_2000_2012	bpea_fig_7c
global yg1pop_2000_2012	bpea_fig_7d

global yi_2000_2012		bpea_fig_8a
global tc_2000_2012		bpea_fig_8b
global li_2000_2012		bpea_fig_8c

global mp_by_ba_pop		bpea_fig_9a
global tp2_by_ba_pop	bpea_fig_9b
global wkpop_by_ba_pop	bpea_fig_9c
global yi_by_ba_pop		bpea_fig_9d

global mp_by_hhi_ind_emp	bpea_fig_10a
global tp2_by_hhi_ind_emp	bpea_fig_10b
global wkpop_by_hhi_ind_emp	bpea_fig_10c
global yi_by_hhi_ind_emp	bpea_fig_10d

global CS_coal_tp2		bpea_fig_12a
global CS_coal_li		bpea_fig_12b
global CS_coal_wkpop	bpea_fig_12c

global GR_tot_tp2		bpea_fig_13a
global GR_tot_li		bpea_fig_13b
global GR_tot_wkpop		bpea_fig_13c

global mp_0012_0012			 bpea_fig_A3a
global mp_0012_9100			 bpea_fig_A3b
global mp_0012_0012_9100	 bpea_fig_A3c
global mp_0012_0012_9100_res bpea_fig_A3d

global mp_0007_0007			 bpea_fig_A4a
global mp_0010_0010			 bpea_fig_A4b
global mp_0012_0012			 bpea_fig_A4c
global mp_0014_0014			 bpea_fig_A4d

global local_mp_2001_2012		 bpea_fig_A7a
global nonlocal_mp_2001_2012	 bpea_fig_A7b
global local_np_2001_2012		 bpea_fig_A7c
global nonlocal_np_2001_2012	 bpea_fig_A7d
global local_tp2_2001_2012		 bpea_fig_A7e
global nonlocal_tp2_2001_2012	 bpea_fig_A7f

global tc_usd_2000_2012		bpea_fig_A8a
global ret_usd_2000_2012	bpea_fig_A8b
global mcd_usd_2000_2012	bpea_fig_A8c
global inc_usd_2000_2012	bpea_fig_A8d

global np_by_ba_pop			bpea_fig_A9a
global lnp_by_ba_pop		bpea_fig_A9b

* standard one-variable plots in jorda_annual
if strpos("$suffix","local") == 0 & strpos("$suffix","_by_") == 0 & strpos("$suffix","GR_") == 0 & strpos("$suffix","CS_") == 0 & strpos("$suffix","_cz_pretrend_") == 0 {
	clear
	local k : word count ${estimates}
	set obs `k'
	gen estimate = ""
	gen b = . // coefficient of interest
	gen se = . // se of coefficient
	local count 1
	
	foreach est in  $estimates {
		replace estimate = "`est'"		if _n == `count'
		replace b		 = ${b_`est'}	if _n == `count'
		replace se		 = ${se_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	gen ub = b + invnormal(0.975)*se // upper bound of 95% CI
	gen lb = b - invnormal(0.975)*se // lower bound of 95% CI
	gen z = substr(estimate,-4,4) // year variable
	destring z, replace
	qui sum z
	local startcoef = `r(min)'

	* x axis labels
	if `startcoef' == 2002 {
		foreach x in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
			local xlabline `xlabline' 20`x' `"`x'"'
		}
	}
	else if `startcoef' == 2001 {
		foreach x in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
			local xlabline `xlabline' 20`x' `"`x'"'
		}
	}

	* coeffplots	
	tw	(connected b z, mcolor(navy) msymbol(O) lcolor(navy%20) lpattern(shortdash) ) ///
		(rarea lb ub z , vertical col(navy%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("") ///
		legend(off) xlabel(`xlabline') ylab(`${y}_ylab', labsize(small)) 

	gr export "${output}/${${y}${suffix}}.pdf", replace 
	
	if "${y}${suffix}" == "mp_0012_0012" {
		gr export "${output}/bpea_fig_A3a.pdf", replace 
		gr export "${output}/bpea_fig_A4c.pdf", replace 	
	}
}

* gravity-based estimates 
else if strpos("$suffix","local") > 0 & strpos("$suffix","_by_") == 0 {
	clear
	local k : word count ${estimates}
	set obs `k'
	gen estimate = ""
	gen b = . // coefficient of interest
	gen se = . // se of coefficient
	gen b_gr = . // gravity coefficient 
	gen se_gr = . // se of gravity coefficient
	local count 1
	
	foreach est in  $estimates {
		replace estimate = "`est'"		if _n == `count'
		replace b		 = ${b_`est'}	if _n == `count'
		replace se		 = ${se_`est'}	if _n == `count'
		replace b_gr	 = ${b_gr_`est'}	if _n == `count'
		replace se_gr	 = ${se_gr_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	gen ub = b + invnormal(0.975)*se // upper bound of 95% CI
	gen lb = b - invnormal(0.975)*se // lower bound of 95% CI
	gen ub_gr = b_gr + invnormal(0.975)*se_gr // upper bound of 95% CI
	gen lb_gr = b_gr - invnormal(0.975)*se_gr // lower bound of 95% CI
	gen z = substr(estimate,-4,4) // year variable
	destring z, replace
	qui sum z
	local startcoef = `r(min)'

	* x axis labels
	if `startcoef' == 2002 {
		foreach x in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
			local xlabline `xlabline' 20`x' `"`x'"'
		}
	}
	else if `startcoef' == 2001 {
		foreach x in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
			local xlabline `xlabline' 20`x' `"`x'"'
		}
	}

	* coeffplots
	* local trade shock
	tw	(connected b z, mcolor(navy) msymbol(O) lcolor(navy%20) lpattern(shortdash) ) ///
		(rarea lb ub z , vertical col(navy%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("") ///
		legend(off) ///
		xlabel(`xlabline') ylab(`${y}_ylab', labsize(small)) 
	gr export "${output}/${${suffix}}.pdf", replace 
	* gravity-based trade shock
	tw	(connected b_gr z, mcolor(maroon) msymbol(O) lcolor(maroon%20) lpattern(shortdash) ) ///
		(rarea lb_gr ub_gr z , vertical col(maroon%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("") ///
		legend(off) ///
		xlabel(`xlabline') ylab(`${y}_ylab', labsize(small)) 
	gr export "${output}/${non${suffix}}.pdf", replace 
}

* heterogeneity plots 
else if strpos("$suffix","_by_") > 0 {
	
	local tp1_lab "total employment-population 18-64" 
	local tp2_lab "wage & salary employment-population 18-64" 
	local tp3_lab "private nonfarm employment-population 18-64" 
	local mp_lab "manuf. employment-population 18-64"
	local np_lab "nonmanuf. employment-population 18-64"
	local up_lab "unemployment-population 18-64"
	
	foreach y in mp np tp3 tp2 {
		local `y'_ylab="-6(2)6"
	}
	foreach y in allpop wkpop ygpop odpop {
		local `y'_ylab="-14(2)2"
	}
	foreach y in yi {
		local `y'_ylab="-15(5)5"
	} 
	foreach y in lmp lnp {
		local `y'_ylab="-5(5)10"
	}
	foreach y in tc ret {
		local `y'_ylab="-4(4)12"
	}
		
	* load data
	use  "${output}/jorda_annual_partvi_BHqvalues.dta", clear

	* generate upper bound and lower bound for CIs
	foreach suffix in below above {
		gen ub_`suffix' = coef_`suffix' + invnormal(0.975)*se_`suffix'
		gen lb_`suffix' = coef_`suffix' - invnormal(0.975)*se_`suffix'
	}

	* offset years by a bit
	cap drop z_above z_below
	gen z_above = z + 0.15 
	gen z_below = z - 0.15 

	* x axis labels
	foreach x in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		local xlabline `xlabline' 20`x' `"`x'"'
	}

	* coeffplots 
	levelsof y, local(vars)
	levelsof q, local(hetvars)
	foreach y in `vars' {
		foreach q in `hetvars' {
			* showing estimates together
			tw	(connected coef_below z_below  if y == "`y'" & q == "`q'" , mcolor(navy) msymbol(Oh) lcolor(navy%20) lpattern(shortdash) ) ///
				(scatter coef_below z_below  if y == "`y'" & q == "`q'" & q_equal <= .05, mcolor(navy) msymbol(O) ) ///
				(connected coef_above z_above  if y == "`y'" & q == "`q'" , mcolor(maroon) msymbol(Sh) lcolor(maroon%20) lpattern(shortdash) ) ///
				(scatter coef_above z_above  if y == "`y'" & q == "`q'" & q_equal <= .05 , mcolor(maroon) msymbol(S) ) ///
				(rarea lb_below ub_below z_below if y == "`y'" & q == "`q'", vertical col(navy%10)) ///
				(rarea lb_above ub_above z_above if y == "`y'" & q == "`q'", vertical col(maroon%10)) ///
				, yline(0, lpattern(solid)) xlabel(`xlabline') ylab(``y'_ylab', labsize(small)) ///
				xtitle("Year") ytitle("Coefficient for trade shock, ${x} to ${v}", size(small)) ///
				legend(pos(6) cols(2) order(1 "Below median" 2 "Below median, q val. <= 0.05" 3 "Above median" 4 "Above median, q val. <= 0.05")) 
			gr export "${output}/${`y'${suffix}`q'}.pdf", replace
		} // hetvars
	} // depvars
} // hetplots

* great recession plots
else if strpos("$suffix","GR_") > 0 {
	
	*SELECT MARKERS FOR VERTICAL AXIS IN GRAPHS
	foreach y in tp2 mp np up {
		local `y'_ylab="-2(.5)1"
		}
	foreach y of var wkpop-allpop {
		local `y'_ylab="-2(1)3"
		}
	foreach y in mw nw {
		local `y'_ylab="-6(1)3"
		} 	
	foreach y in tc ret oth ssa inc mca mcd ssi eit snp oim edt {
		local `y'_ylab="-6(2)8"
		}
	foreach y in yi ti li ci di tc {
		local `y'_ylab="-4(2)4"
		}
	foreach y in unm {
		local `y'_ylab="-3(1)1"
		} 

	clear
	local k : word count ${estimates}
	set obs `k'
	gen estimate = ""
	gen b = . // coefficient of interest
	gen se = . // se of coefficient
	local count 1
	
	foreach est in  $estimates {
		replace estimate = "`est'"		if _n == `count'
		replace b		 = ${b_`est'}	if _n == `count'
		replace se		 = ${se_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	gen ub = b + invnormal(0.975)*se // upper bound of 95% CI
	gen lb = b - invnormal(0.975)*se // lower bound of 95% CI
	gen z = substr(estimate,-4,4) // year variable
	destring z, replace
	qui sum z
	local startcoef = `r(min)'

	* x axis labels
	if `startcoef' == 2002 {
		foreach x in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
			local xlabline `xlabline' 20`x' `"`x'"'
		}
	}
	else if `startcoef' == 2001 {
		foreach x in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
			local xlabline `xlabline' 20`x' `"`x'"'
		}
	}

	* coeffplots	
	tw	(connected b z, mcolor(navy) msymbol(O) lcolor(navy%20) lpattern(shortdash) ) ///
		(rarea lb ub z , vertical col(navy%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("Coefficient for 2006-09 Bartik shock", size(small)) ///
		legend(off) xlabel(`xlabline') ylab(`${y}_ylab', labsize(small)) 
	gr export "${output}/${${suffix}}.pdf", replace 
}

* coal and steel plots
else if strpos("$suffix","CS_") > 0 {
	
	*SELECT MARKERS FOR VERTICAL AXIS IN GRAPHS
	foreach y in tp1 {
		local `y'_ylab="-4(1)2"
		}
	foreach y of var wkpop-allpop {
		local `y'_ylab="-3(1)1"
		}
	foreach y in tc ret oth ssa inc mca mcd ssi eit snp oim edt {
		local `y'_ylab="-4(1)4"
		}
	foreach y in yi ti pi di {
		local `y'_ylab="-8(2)4"
		}
	foreach y in unm {
		local `y'_ylab="-8(2)6"
		} 
	foreach y in li {
		local `y'_ylab="-2(.5).5"
	}
	foreach y in tp2  {
		local `y'_ylab="-1(.5).5"
	}

	clear
	local k : word count ${estimates}
	set obs `k'
	gen estimate = ""
	gen b = . // coefficient of interest
	gen se = . // se of coefficient
	local count 1
	
	foreach est in  $estimates {
		replace estimate = "`est'"		if _n == `count'
		replace b		 = ${b_`est'}	if _n == `count'
		replace se		 = ${se_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	gen ub = b + invnormal(0.975)*se // upper bound of 95% CI
	gen lb = b - invnormal(0.975)*se // lower bound of 95% CI
	gen z = substr(estimate,-4,4) // year variable
	destring z, replace
	qui sum z
	local startcoef = `r(min)'

	local xlabline
	* x axis labels
	forvalues x=76/99 {
		local xlabline `xlabline' 19`x' `"`x'"'
	}
	foreach x in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		local xlabline `xlabline' 20`x' `"`x'"'
	}

	* coeffplots	
	tw	(connected b z if z >= 1976, mcolor(navy) msymbol(O) lcolor(navy%20) lpattern(shortdash) ) ///
		(rarea lb ub z if z >= 1976, vertical col(navy%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("Coefficient for 1980-2000  Bartik shock", size(small)) ///
		legend(off) xlabel(`xlabline', labsize(vsmall) angle(90)) ylab(`${y}_ylab', labsize(small)) 
	gr export "${output}/${${suffix}}.pdf", replace 
}

* cz pretrends plots
else if strpos("$suffix","_cz_pretrend_") > 0 {
	
	*SELECT MARKERS FOR VERTICAL AXIS IN GRAPHS
	foreach y in mp np tp3 tp2 {
		local `y'_ylab="-4(1)2"
		}
	foreach y in wkpop odpop ygpop allpop {
		local `y'_ylab="-12(2)4"
		}
	foreach y in yi ti li ci tc {
		local `y'_ylab="-8(2)10"
		}    

	clear
	local k : word count ${estimates}
	set obs `k'
	gen estimate = ""
	gen b = . // coefficient of interest
	gen se = . // se of coefficient
	local count 1
	
	foreach est in  $estimates {
		replace estimate = "`est'"		if _n == `count'
		replace b		 = ${b_`est'}	if _n == `count'
		replace se		 = ${se_`est'}	if _n == `count'
		local count		 = `count' + 1
	}
	
	gen ub = b + invnormal(0.975)*se // upper bound of 95% CI
	gen lb = b - invnormal(0.975)*se // lower bound of 95% CI
	gen z = substr(estimate,-9,4) // year variable
	destring z, replace
	qui sum z
	local startcoef = `r(min)'

	local xlabline
	* x axis labels
	forvalues x=80/90 {
		local xlabline `xlabline' 19`x' `"`x'"'
	}

	* coeffplots	
	tw	(connected b z if z >= 1980, mcolor(navy) msymbol(O) lcolor(navy%20) lpattern(shortdash) ) ///
		(rarea lb ub z if z >= 1980, vertical col(navy%10)) ///
		, yline(0, lpattern(solid)) xtitle("Year") ytitle("Coefficient for trade shock, ${v} to ${w}", size(small)) ///
		legend(off) xlabel(`xlabline') ylab(`${y}_ylab', labsize(small)) 
	
		* figure names
		local graphname ${suffix}
		if "${suffix}" == "_cz_pretrend_mp_1991_2000" {
			local graphname bpea_fig_A1a
			gr export "${output}/`graphname'.pdf", replace 
		}
		else if "${suffix}" == "_cz_pretrend_np_1991_2000" {
			local graphname bpea_fig_A1b
			gr export "${output}/`graphname'.pdf", replace 
		}
		else if "${suffix}" == "_cz_pretrend_tp2_1991_2000" {
			local graphname bpea_fig_A1c
			gr export "${output}/`graphname'.pdf", replace 
		}
		else if "${suffix}" == "_cz_pretrend_wkpop_1991_2012" {
			local graphname bpea_fig_A1d
			gr export "${output}/`graphname'.pdf", replace 
		}
		else if "${suffix}" == "_cz_pretrend_yi_1991_2000" {
			local graphname bpea_fig_A1e
			gr export "${output}/`graphname'.pdf", replace 
		}
		else if "${suffix}" == "_cz_pretrend_tc_1991_2000" {
			local graphname bpea_fig_A1f
			gr export "${output}/`graphname'.pdf", replace 
		}
}

* restore default data
use `jorda_data', clear
