drop _all

*******************************************************************************
*THIS FILE USES NBER ASM DATA TO EVALUATE WHICH PRIMARY METAL INDUSTRIES SUFFERED THE LARGEST EMPLOYMENT DECLINES AND WHEN
*******************************************************************************

*get NBER ASM database
use "${data}/nberces5818v1_s1987.dta" 
egen temp=sum(emp), by(year)
gen sic2=int(sic/100)
gen sic3=int(sic/10)
keep if sic2==33
preserve
collapse (sum) emp (mean) temp, by(year sic3)
gen lt=log(temp)
gen le=log(emp)
gen x=le if year==1980
egen le80=mean(x), by(sic)
gen y=lt if year==1980
egen lt80=mean(y), by(sic)
replace le=le-le80
replace lt=lt-lt80
*evaluate employment in 3 digit primary metals industries (SIC 33)
gr twoway line le year if sic3==331 || line le year if sic3==332 || line le year if sic3==333 || line le year if sic3==334 || line le year if sic3==335
restore

*aggregate to 2 digit level
collapse (sum) emp (mean) temp, by(year sic2)
keep if sic2==33
keep if year>=1969
*merge in coal employment data
merge 1:1 year using "${data}/bea_ces_msha_coal_employment.dta" 
keep if year<=2018
*create single time series on coal employment from bea-sic and ces data
gen sh=bea/ces
sum sh
egen msh=mean(sh)
replace bea=ces*msh if year>=2001
*calculate employment as log value relative to 1980 value
gen lt=log(temp)
gen le=log(emp)
gen lc=log(bea)
gen x=le if year==1980
gen y=lt if year==1980
gen z=lc if year==1980
egen lt80=mean(y), by(sic)
egen le80=mean(x), by(sic)
egen lc80=mean(z), by(sic)
replace le=le-le80
replace lt=lt-lt80
replace lc=lc-lc80

keep if year>=1970
gr twoway line lt year if sic==33, lp(solid) lw(medthick) lc(navy) || line lc year if sic==33, lp(shortdash) lw(medthick) lc(cranberry)  ||, yline(0) legend(col(2) size(small) label(1 "Manufacturing") label(2 "Coal mining")) xtitle("Year", size(small)) ytitle("log employment - log employment in 1980", size(small)) xlab(1970(5)2020, labsize(small)) ylab(-1.5(.25).25, labsize(small)) scheme(s2color) graphregion(color(white)) plotregion(color(white))
gr export "${output}/bpea_fig_11.pdf", replace
