drop _all

*THIS FILE COMBINES SITC TRADE DATA WITH FRED DATA ON INDUSTRIAL PRODUCTION AND US TRADE IN GOODS TO CALCULATE IMPORT PENETRATION BY CHINA AND CHINA + SE ASIA IN THE US

*Get SITC trade data and merge in US manuf. shipments and world trade
use "${data}/L_intensive_sitc2_91_18.dta"
keep if iiso=="USA"

*Capture mfg exports by China and SE Asia to US
gen v_mfg_chn=value_mfg*(eiso=="CHN")
gen v_mfg_sea=value_mfg*(eiso=="SEA")
gen v_mfg=value_mfg
collapse (sum) v_mfg*, by(year iiso)

*Merge in data on US industrial production and trade from FRED
merge m:1 year using "${data}/data_sales_imports_exports.dta" 
keep if year>=1991
keep if _m==3

*China and China + SE Asia import penetration in US
gen ipr_chn = (v_mfg_chn/1000)/(ind_go_no_oil+imp_goods_no_oil-exp_goods_no_oil)
gen ipr_chnsea = ((v_mfg_chn+v_mfg_sea)/1000)/(ind_go_no_oil+imp_goods_no_oil-exp_goods_no_oil)
gen ipr_sea = (v_mfg_sea/1000)/(ind_go_no_oil+imp_goods_no_oil-exp_goods_no_oil)

gr twoway (line ipr_chn year, lp(dash) lw(medthick) lc(cranberry)) (line ipr_chnsea year, lp(dash) lw(medthick) lc(navy)), legend(cols(1) size(small) label(1 "China import penetration in the US")  label(2 "China + SE Asia import penetration in the US")) scheme(s2color) graphregion(color(white)) plotregion(color(white)) xline(2001) xline(2010) xlab(1991(3)2018, labsize(small)) ylab(0(.02).1, labsize(small))
	gr export "${output}/bpea_fig_3b.pdf", replace

*China and China + SE Asia import share in US
gen ish_chn = (v_mfg_chn/imp_goods_no_oil)/1000
gen ish_chnsea = ((v_mfg_chn+v_mfg_sea)/imp_goods_no_oil)/1000
gen ish_sea = ((v_mfg_sea)/imp_goods_no_oil)/1000

gr twoway (line ish_chn year, lp(dash) lw(medthick) lc(cranberry)) (line ish_chnsea year, lp(dash) lw(medthick) lc(navy)), legend(cols(1) size(small) label(1 "China share of US imports")  label(2 "China + SE Asia share of US imports")) scheme(s2color) graphregion(color(white)) plotregion(color(white)) xline(2001) xline(2010) xlab(1991(3)2018, labsize(small)) ylab(0(.05).25, labsize(small))
	gr export "${output}/bpea_fig_3a.pdf", replace

