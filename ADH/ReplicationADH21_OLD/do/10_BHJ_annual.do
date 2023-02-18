drop _all

********************************************************************************
* THIS FILE RUNS CHINA SHOCK REGRESSIONS USING ADH AERi 2020 CONTROLS ON EMPLOYMENT, INCOME, POPULATION, AND GOV'T TRANSFERS
* IMPLEMENTS BORUSYAK-HULL-JARAVEL STANDARD ERROR CORRECTION AND COMPARES TO BASELINE REGRESSIONS
* BASELINE TRADE SHOCKS ARE 2000 TO 2012
********************************************************************************

********************************************************************************
* DATA PREP
********************************************************************************

*DEFINE BASE-END PERIODS FOR THE TIME DIFFERENCES AND TRADE SHOCKS
local base0=1991
local base1=1991
local base2=2000
local base3=2001
local base4=2000
local base5=2000
local base6=2000
local start1=`base1'+1
local start2=`base2'+1
local start3=`base3'+1
local end0=2000
local end1=2012
local end2=2012
local end4=2007
local end5=2010
local end6=2014

* graph names
global bhj_mp	bpea_fig_A2a
global bhj_np	bpea_fig_A2b
global bhj_tp3	bpea_fig_A2c

********************************************************************************
* FOR BHJ IMPLEMENTATION:
********************************************************************************

	* SET BASE YEAR
	local basebhj = 1990 
	* PREPARE EXPOSURE WEIGHTS 
	use "${data}/czone_industry`basebhj'", clear
	cap gen year = `basebhj'
	replace year = `basebhj' if mi(year)
	drop tot*
	drop if czone==35600
	egen double ind_share = pc(imp_emp), by(czone year) prop
	rename sic sic87
	run "${do}/subfile_sic87dd.do"
	replace sic87dd=3999 if sic87dd==3990
	collapse (sum) ind_share, by(czone sic87dd year)
	tempfile Lshares
	save `Lshares'
foreach z of numlist `start2'(1)2019 {
	use `Lshares'
	replace year = `z'
	tempfile Lshares_`z'
	save `Lshares_`z''

}
	*PREPARE TRADE SHOCK AT THE INDUSTRY LEVEL
	local x = 2000
	local z = 2012
	local k = `x'-3
	use "${data}/industry_exposure_9114_brfss_v2_gh.dta" , clear
	* import penetration
	gen d_tradeval_otch=l_import_otch_`z'-l_import_otch_`x'
	gen d_tradeotch_p1_lag_`x'_`z'=100*(10/(`z'-`x'))*(d_tradeval_otch/market1988)
	gen d_tradeotch_pd_lag_`x'_`z'=100*(10/(`z'-`x'))*(d_tradeval_otch/market`k')
	gen d_tradeotch_p1_`x'_`z'=100*(10/(`z'-`x'))*(d_tradeval_otch/market1988)
	gen sic3 = int(sic87dd/10)
	keep d_tradeotch* sic3 sic87dd
	collapse (sum) d_tradeotch*, by(sic3 sic87dd)
	tempfile indshock
	save `indshock'

*-------------------------------------------------------------------------------

*PREPARE CONTROL VARIABLES (FROM WWD AERi PAPER) FOR LATER MERGE
use "${data}/ADH_control_vars"
preserve 
keep if year==1990
drop year
save temp_`base1', replace
restore
preserve 
keep if year==2000
drop year
save temp_`base2', replace
restore
drop _all

*LOAD REIS ANNUAL DATA ON POPULATION, EMPLOYMENT, GOV'T TRANSFERS BY CZ
use "${data}/ADH_pop_emp_transfers.dta"

*MERGE IN TRADE SHOCKS CONSTRUCTED USING MODIFIED VERSION OF DAVID DORN'S DO FILE
merge m:1 czone using "${data}/czone_exposure_by_period_v6_rl.dta"
tab czone if _m==1
drop if _m==1
codebook czone
drop _m
*MERGE IN GRAVITY BASED TRADE SHOCKS INSPIRED BY ADAO ARKOLAKIS & ESPOSITO
merge m:1 czone using "${data}/ipr_gravity"
drop _m

*SUM STATS ON TRADE SHOCKS BEFORE DECADALIZING
sum d_tradeusch_p1_2000* [aw=Pop] if year==2000
sum d_tradeusch_p1_1991* [aw=Pop] if year==1990

*DECADALIZE VALUES FOR TRADE SHOCKS
foreach y in 2 {
	replace d_tradeusch_p1_`base`y''_`end`y''=100*d_tradeusch_p1_`base`y''_`end`y''*(10/(`end`y''-`base`y''))
	replace d_tradeotch_p1_lag_`base`y''_`end`y''=100*d_tradeotch_p1_lag_`base`y''_`end`y''*(10/(`end`y''-`base`y''))
	replace d_tradeotch_p1_`base`y''_`end`y''=100*d_tradeotch_p1_`base`y''_`end`y''*(10/(`end`y''-`base`y''))
	d d_tradeusch_p1_`base`y''_`end`y'' d_tradeotch_p1_lag_`base`y''_`end`y'', full
	sum d_tradeusch_p1_`base`y''_`end`y'' d_tradeotch_p1_lag_`base`y''_`end`y''
	}
foreach y in 2 {
	replace gr1_d_tradeusch_p1_`base`y''_`end`y''=100*gr1_d_tradeusch_p1_`base`y''_`end`y''*(10/(`end`y''-`base`y''))
	replace gr1_d_tradeotch_p1_lag_`base`y''_`end`y''=100*gr1_d_tradeotch_p1_lag_`base`y''_`end`y''*(10/(`end`y''-`base`y''))
	d gr1_d_tradeusch_p1_`base`y''_`end`y'' gr1_d_tradeotch_p1_lag_`base`y''_`end`y'', full
	sum gr1_d_tradeusch_p1_`base`y''_`end`y'' gr1_d_tradeotch_p1_lag_`base`y''_`end`y''
	}

*CREATE DEPENDENT VARIABLES
*EMPLOYMENT-POPULATION RATIOS
gen mp=((Manuf_emp)/pop_1864_all)
gen np=((Wage_salary_employ-Manuf_emp)/pop_1864_all)
gen tp3=((Emp_priv_nonfarm)/pop_1864_all)
gen lmp=log(mp)
gen lnp=log(np)
gen ltp3=log(tp3)
gen tp1=(Employment/pop_1864_all)
gen tp2=(Wage_salary_employ/pop_1864_all)
gen li=log((Wages_salaries+Supp_wage_sal)) - log(Wage_salary_employ)
gen pi=log((Proprietor_inc)) - log(Proprietor_employ)
gen unm=log(Unemploy_insur_comp) - log(pop_1864_all)
gen ltp1=log(tp1)
gen ltp2=log(tp2)
gen up=(unemployment/pop_1864_all)
gen dp=(num_dis_w/pop_1864_all)
*LOG POPULATION HEADCOUNTS
gen wkpop=log(pop_1864_all)
gen wkmen=log(pop_1864_wm+pop_1864_nwm)
gen wkfem=log(pop_1864_wf+pop_1864_nwf)
gen yg1pop=log(pop_1824_all)
gen yg2pop=log(pop_2539_all)
gen odpop=log(pop_1864_all-pop_1839_all)
gen yg1fem=log(pop_1824_wf+pop_1824_nwf)
gen yg1men=log(pop_1824_wm+pop_1824_nwm)
gen yg2fem=log(pop_2539_wf+pop_2539_nwf)
gen yg2men=log(pop_2539_wm+pop_2539_nwm)
gen allpop=log(Pop)
*PERSONAL INCOME PER CAPITA, GOV'T TRANSFERS PER CAPITA AND AS SHARE OF PERSONAL INCOME, COMPONENTS OF GOV'T TRANSFERS
gen lnpop =log(Pop)
gen yi=log(PInc) - lnpop
gen ti=log((PInc-Indv_gov_transfer)) - lnpop
gen di=log((Div_int_rent)) - lnpop
gen tc=log(Indv_gov_transfer) - lnpop
gen ret=log(Retire_insur_bene+Medicare_bene) - lnpop
gen oth=log(Indv_gov_transfer-Retire_insur_bene-Medicare_bene-Unemploy_insur_comp) - lnpop
gen ssa=log(Retire_insur_bene) - lnpop
gen mca=log(Medicare_bene) - lnpop
gen mcd=log(Pub_ass_med) - lnpop
gen inc=log(Incm_main_bene) - lnpop
gen ssi=log(SSI) - lnpop
gen eit=log(EITC) - lnpop
gen snp=log(SNAP) - lnpop
gen oim=log(Other_bene) - lnpop
gen edt=log(Educ_assist) - lnpop
*EXPRESS DOLLARS PER CAPITA IN COMMON DECIMAL TERMS
foreach y of var yi-edt {
    gen `y'_usd = (exp(`y')*1000)/100
	}
gen mw=log(Manuf_comp/Manuf_emp)
gen nw=log((Priv_nonfarm_comp-Manuf_comp)/(Emp_priv_nonfarm-Manuf_emp))
*Definition of personal income
gen y=Wages_salaries+Supp_wage_sal+Proprietor_inc+Div_int_rent+Pers_transfers-Contb_Gov_Soc_Ins+Res_adj
sum PInc y
*Variable definitions
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
local pi_lab "log proprietor's income per proprietor"
local di_lab "log dividents, interest, rent per capita"
local mw_lab "log mfg earnings per worker"  
local nw_lab "log non-mfg earnings per worker"  
local tc_lab "log government transfers per capita"
local ret_lab "log SSA, Medicare benefits per capita"  
local ssa_lab "log SSA, disability benefits per capita"  
local oth_lab "log other transfers per capita"  
local unm_lab "log UI benefits/pop 18-64"  
local inc_lab "log income assistance per capita"  
local mca_lab "log Medicare benefits per capita"
local mcd_lab "log Medicaid benefits per capita"
local ssi_lab "log SSI benefits per capita"
local eit_lab "log EITC payments per capita"
local snp_lab "log SNAP benefits per capita"
local oim_lab "log other income maintenance per capita"
local edt_lab "log education and training per capita"
local yi_usd_lab "personal income per capita"  
local ti_usd_lab "personal income (less transfers) per capita"  
local ci_usd_lab "prviate nonfarm compensation per capita"  
local li_usd_lab "wages, salaries, benefits per capita"  
local pi_usd_lab "proprietor's income"
local di_usd_lab "dividents, interest, rent per capita"
local tc_usd_lab "government transfers per capita"  
local ret_usd_lab "SSA, Medicare benefits per capita"  
local oth_usd_lab "other transfers per capita"  
local ssa_usd_lab "SSA, disability benefits per capita"  
local unm_usd_lab "UI benefits/pop 18-64"  
local inc_usd_lab "income assistance per capita"  
local mca_usd_lab "Medicare benefits per capita"
local mcd_usd_lab "Medicaid benefits per capita"
local ssi_usd_lab "SSI benefits per capita"
local eit_usd_lab "EITC payments per capita"
local snp_usd_lab "SNAP benefits per capita"
local oim_usd_lab "other income maintenance per capita"
local edt_usd_lab "education and training per capita"

*SELECT MARKERS FOR VERTICAL AXIS IN GRAPHS
foreach y in mp np tp1 tp2 tp3 up dp {
	local `y'_ylab="-4(1)2"
	}
foreach y of var wkpop-allpop {
	local `y'_ylab="-12(2)4"
	}
foreach y in lmp lnp ltp1 ltp2 ltp3 {
	local `y'_ylab="-10(5)5"
	}
foreach y in mw nw {
	local `y'_ylab="-4(2)10"
	} 	
foreach y in yi ti li pi di tc ret oth {
	local `y'_ylab="-8(2)8"
	} 
foreach y in yi_usd ti_usd li_usd pi_usd di_usd ri_usd ai_usd oi_usd tc_usd {
	local `y'_ylab="-4000(1000)1000 "
	}    	
foreach y in ssa_usd med_usd inc_usd unm_usd mca_usd mcd_usd ssi_usd eit_usd snp_usd oim_usd edt_usd {
	local `y'_ylab="-300(50)200"
	}    	
foreach y in ssa med inc unm mca mcd ssi eit snp oim edt {
	local `y'_ylab="-15(5)15"
	}
foreach y in unm {
	local `y'_ylab="-30(10)30"
	}   	
	
*CREATE CHANGES IN POP AND EMPLOYMENT VARIABLES FOR EACH TIME ANNUAL DIFFERENCE WITH ALTERNATIVE BASE YEARS AND END YEAR 2019
*FIRST CREATE WEIGHTS FOR REGRESSION (WORKING AGE POP IN BASE YEAR FOR EMP-POP RATIOS, TOTAL POP FOR PERSONAL INCOME, GOV'T TRANSFERS)
foreach x in `base2' {
		*Define total population weights for base yar
		egen tPop=sum(Pop), by(year)
		gen p_`x' = Pop/tPop if year==`x'
		egen pop_`x' = mean(p_`x'), by(czone)
		drop p_`x' tPop
		*Define wking age population weights for base yar
		egen tPop=sum(pop_1864_all), by(year)
		gen p_`x' = Pop/tPop if year==`x'
		egen popwk_`x' = mean(p_`x'), by(czone)
		drop p_`x' tPop
foreach y of var tp1-allpop yi-edt_usd {
		*Define base year for outcome variable
		gen `y'`x' = `y' if year==`x'
		egen `y'_`x' = mean(`y'`x'), by(czone)
		foreach z of numlist `start2'(1)2019 {	
		*Construct progressively longer time differences
		gen d`y'_`x'_`z' = 100*(`y' - `y'_`x') if year==`z'
		}
		drop `y'`x' `y'_`x'
	}
if `x' == `base2' {
foreach z in `base3' {
foreach y of var mp-allpop mw nw yi-edt_usd { 
		*Define base year for outcome variable
		gen `y'`z' = `y' if year==`z'
		egen `y'_`z' = mean(`y'`z'), by(czone)
	foreach u of numlist `start3'(1)2019 {	
		*Construct progressively longer time differences
		gen d`y'_`z'_`u'_2 = 100*(`y' - `y'_`z') if year==`u'
		}
		drop `y'`z' `y'_`z'
		}
	}
}

*MERGE IN CONTROLS FOR BASE YEAR AND THEN RUN REGRESSIONS
preserve
merge m:1 czone using temp_`x'
tab region, gen(reg)
tab year, gen(yr)

*Define control variable sets
local control0 "reg2-reg9"  
local control1 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9"  
local control2 "l_shind_manuf_cbp_lag l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9"
local control3 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9 sh_65up_all sh_4064_all sh_0017_all sh_00up_nw"  
local control4 "l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg2-reg9 dlnpop7090"  
foreach y of var mp-dp mw nw {
	gen wt_`y' = popwk_`x'
	local control_`y' = "`control3'"
	}
foreach y of var yi-edt_usd {
	gen wt_`y' = pop_`x'
	local control_`y' = "`control3'"
	}
foreach y of var wkpop-allpop {
	gen wt_`y' = pop_`x'
	local control_`y' = "`control4'"
	}

* tempfile for BHJ implementation
//merge m:1 czone using `l_shind_manuf_cbp_1990', assert(3) nogen
tempfile data
save `data'

*2001 T0 2019 -- showing both ADH and BHJ
*Load data
foreach y in  mp np tp3 {
if `x' == `base2' {
foreach u in `base3' {
foreach v in `end2' {    
	foreach z of numlist `start3'(1)2019 {		
	
		* load data and run ADH regression (without BHJ correction)
		use `data', clear
		eststo `y'_`u'_`z' : qui ivreg2 d`y'_`u'_`z'_2 `control_`y'' ///
		(d_tradeusch_p1_2000_2012 = d_tradeotch_p1_lag_2000_2012)  [aw=wt_`y'] ///
		, cluster(statefip) 
		
		* SSAGGREGATE FOR INDUSTRY SHOCKS (BHJ correction)
		ssaggregate d`y'_`u'_`z'_2 d_tradeusch_p1_2000_2012 [aw=wt_`y'] ///
		, n(sic87dd) l(czone) t(year) s(ind_share) sfilename(`Lshares_`z'') ///
		addmissing controls("`control_`y''")
		
		replace sic87dd = 0 if mi(sic87dd)
		merge m:1 sic87dd using `indshock', assert(1 3) nogen
		foreach var of varlist d_tradeotch_p1_2000_2012 d_tradeotch_p1_lag_2000_2012 d_tradeotch_pd_lag_2000_2012 sic3 {
			replace `var'= 0 if sic87dd==0
		}	
		* BHJ regression
		eststo `y'_`u'_`z'_BHJ : qui ivreg2 d`y'_`u'_`z'_2 ///
		(d_tradeusch_p1_2000_2012 = d_tradeotch_p1_lag_2000_2012) [aw=s_n], cluster(sic3) 
	} 
	noi di "ADH RESULTS:"
	esttab `y'_`u'_2002 `y'_`u'_2003 `y'_`u'_2004 `y'_`u'_2005 `y'_`u'_2006 `y'_`u'_2007 `y'_`u'_2008 `y'_`u'_2009 `y'_`u'_2010, ar2 nocon keep(d_tradeusch_p1_2000_2012)
	esttab `y'_`u'_2011 `y'_`u'_2012 `y'_`u'_2013 `y'_`u'_2014 `y'_`u'_2015 `y'_`u'_2016 `y'_`u'_2017 `y'_`u'_2018 `y'_`u'_2019, ar2 nocon keep(d_tradeusch_p1_2000_2012)
	
	noi di "BHJ CORRECTION:"
	esttab `y'_`u'_2002_BHJ `y'_`u'_2003_BHJ `y'_`u'_2004_BHJ `y'_`u'_2005_BHJ `y'_`u'_2006_BHJ `y'_`u'_2007_BHJ `y'_`u'_2008_BHJ `y'_`u'_2009_BHJ `y'_`u'_2010_BHJ, ar2 nocon keep(d_tradeusch_p1_2000_2012)
	esttab `y'_`u'_2011_BHJ `y'_`u'_2012_BHJ `y'_`u'_2013_BHJ `y'_`u'_2014_BHJ `y'_`u'_2015_BHJ `y'_`u'_2016_BHJ `y'_`u'_2017_BHJ `y'_`u'_2018_BHJ `y'_`u'_2019_BHJ, ar2 nocon keep(d_tradeusch_p1_2000_2012)

	*Plot coefficients
coefplot (`y'_`u'_2002, label(State-clustered standard errors)) (`y'_`u'_2002_BHJ, label(Borusyak-Hull-Jaravel estimator)), bylab(02) || `y'_`u'_2003 `y'_`u'_2003_BHJ, bylab(03) || `y'_`u'_2004 `y'_`u'_2004_BHJ, bylab(04) || `y'_`u'_2005 `y'_`u'_2005_BHJ, bylab(05) || `y'_`u'_2006 `y'_`u'_2006_BHJ, bylab(06) || `y'_`u'_2007 `y'_`u'_2007_BHJ, bylab(07) || `y'_`u'_2008 `y'_`u'_2008_BHJ, bylab(08) || `y'_`u'_2009 `y'_`u'_2009_BHJ, bylab(09) || `y'_`u'_2010 `y'_`u'_2010_BHJ, bylab(10) || `y'_`u'_2011 `y'_`u'_2011_BHJ, bylab(11) || `y'_`u'_2012 `y'_`u'_2012_BHJ, bylab(12) || `y'_`u'_2013 `y'_`u'_2013_BHJ, bylab(13) || `y'_`u'_2014 `y'_`u'_2014_BHJ, bylab(14) || `y'_`u'_2015 `y'_`u'_2015_BHJ, bylab(15) || `y'_`u'_2016 `y'_`u'_2016_BHJ, bylab(16) || `y'_`u'_2017 `y'_`u'_2017_BHJ, bylab(17) || `y'_`u'_2018 `y'_`u'_2018_BHJ, bylab(18) || `y'_`u'_2019 `y'_`u'_2019_BHJ, bylab(19) keep(d_tradeusch_p1_2000_2012) bycoef vertical yline(0) xtitle("Year", size(small)) xlab(, labsize(small)) ylab(``y'_ylab', labsize(small)) msize(vsmall) scheme(s2color) graphregion(color(white)) plotregion(color(white)) 
	gr export "${output}/${bhj_`y'}.pdf", replace
	eststo clear
			}
			}
			}
	}
	restore
}
	
erase temp_`base2'.dta
erase temp_`base1'.dta

