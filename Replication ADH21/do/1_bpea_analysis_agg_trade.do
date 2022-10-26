drop _all

*THIS FILE CALCULATES RCA FOR CHINA, USA, CANADA, GERMANY, JAPAN, MEXICO FOR SITC 3 DIGIT

use "${data}/agg_trade_84_18"
label var year "Year"

*CALCULATE REVEALED COMPARATIVE ADVANTAGE	
foreach x in CAN CHN DEU JPN MEX USA {
	gen mr_`x'=log(m_exports_`x'/m_value) - log((m_exports_`x'+n_exports_`x')/value)
	gen nr_`x'=log(n_exports_`x'/n_value) - log((m_exports_`x'+n_exports_`x')/value)
	gen mesh_`x'=(m_exports_`x'/m_value)
	gen nesh_`x'=(n_exports_`x'/n_value)
	gen mish_`x'=(m_imports_`x'/m_value)
	gen nish_`x'=(n_imports_`x'/n_value)
	}

*CHINA SPECIFIC VALUES
gen mrr = mr_CHN - mr_USA
gen nrr = nr_CHN - nr_USA
gen mesh = mesh_CHN
gen nesh = nesh_CHN
gen mish = mish_CHN
gen nish = nish_CHN
label var mrr "Manufacturing"
label var nrr "Non-manufacturing"
label var mesh "Manufacturing export share" 
label var nesh "Non-manufacturing export share" 
label var mish "Manufacturing import share" 
label var nish "Non-manufacturing import share" 

*SECTOR SHARE OF GLOBAL EXPORTS
gen shm = m_value/value
label var shm "Share"

*CHINA'S SHARE OF EXPORTS
sort year
l year shm mesh nesh mish nish mrr nrr, noobs clean
sum shm mesh nesh mish nish mrr nrr

*STOP IN 2016 GIVEN WEIRDNESS IN CHINA'S EXPORTS OF SITC 93 (SPECIAL TRANSACTIONS) WHICH JUMP HUGELY IN 2017 AND 2018 (AND DISTORT DATA WHETHER THEY'RE LEFT IN OR OUT)
keep if year>=1991 & year<=2018

gr twoway (line mesh year, lp(dash) lw(medthick) lc(cranberry)) (line nesh year, lp(dash) lw(medthick) lc(navy)), scheme(s2color) graphregion(color(white)) plotregion(color(white)) ylab(, labsize(small)) xlab(1991(3)2018, labsize(small)) legend(col(1))
	gr export "${output}/bpea_fig_1a.pdf", replace

gr twoway (line mish year, lp(dash) lw(medthick) lc(cranberry)) (line nish year, lp(dash) lw(medthick) lc(navy)), scheme(s2color) graphregion(color(white)) plotregion(color(white)) ylab(, labsize(small)) xlab(1991(3)2018, labsize(small)) legend(col(1))
	gr export "${output}/bpea_fig_1b.pdf", replace

gr twoway (line mrr year, yaxis(1) lp(dash) lw(medthick) lc(cranberry)) (line nrr year, yaxis(2) lp(dash) lw(medthick) lc(navy)), scheme(s2color) graphregion(color(white)) plotregion(color(white)) ylab(, labsize(small)) xlab(1991(3)2018, labsize(small)) legend(col(1) label(1 "log China-USA RCA, manufacturing") label(2 "log China-USA RCA, non-manufacturing")) 
	gr export "${output}/bpea_fig_2.pdf", replace

