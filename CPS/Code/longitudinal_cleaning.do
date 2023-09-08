
use cps_longitudinal, clear
egen id=group(cpsidp)
egen house_id=group(cpsid)
drop cpsidp cpsid
*Droping inconsistencies. 
keep if age_1>24 & age_2>24
keep if age_1<66 & age_2<66
keep if sex_1==sex_2
keep if race_1==race_2
keep if nativity_1==nativity_2
keep if popstat_1==popstat_2
keep if (age_2==age_1+1 | age_2==age_1)
keep if bpl_1==bpl_2
keep if month_1==month_2
keep if statefip_1==statefip_2
keep if cpsidv_1== cpsidv_2
keep if pernum_1==pernum_2
bys year_1: sum id
drop asecflag* serial* pernum* cpsidv* sex* race* popstat* nativity* bpl* citizen* hispan*
replace lnkfw1ywt_2=lnkfw1ywt_1
reshape long year_ month_ asecwth_ mish_ statefip_ asecwt_ age_  labforce_ ind_ lnkfw1ywt_ , i(id house_id) j(period)
order house_id id year
rename *_ * 
drop age 
gen sector=.
replace sector=0 if (labforce==1)
sum statefip
tab statefip 
codebook statefip
*Industry
bysort year: tab ind
************
*Agriculture.
replace sector=14 if ( ind==10 | ind== 11 |  ind==12 | ind== 20 | ind== 30  | ind== 31  | ind== 32)
*Agriculture, forestry, fishing, hunting
*SECTOR 1
*Only includes food, beverage, tobacco, 311-312
replace sector=1 if (ind==100 | ind==101 | ind==102 | ind==110 | ind==111 | ind==112 | ind==120 | ind==121 | ind==122 | ind==130)
replace sector=2 if (ind==132 | ind== 140 | ind== 141 | ind== 142  | ind== 150  | ind== 151 | ind== 152 )
replace sector=3 if (ind== 160 | ind== 161 | ind==  162 | ind== 171 | ind== 172 )
replace sector=4  if (ind==200 | ind== 201 | ind== 40 | ind==  41 | ind== 42 | ind== 50  )
replace sector=5 if (ind==180 | ind==181 | ind==182 | ind== 190| ind== 191 | ind== 192 )
replace sector=6 if (ind==210 | ind==211 | ind== 212)
replace sector=7 if (ind== 250| ind== 251 | ind== 252 | ind== 261 | ind== 262 )
replace sector=8  if (ind== 270 | ind== 271 | ind== 272 | ind== 280 | ind== 281 | ind== 282 | ind== 290 | ind== 291 )
replace sector=9 if (ind==300 | ind== 301 | ind== 310 | ind== 311 | ind== 312 | ind== 320 )
replace sector=10 if (ind== 321 | ind== 322 | ind== 331| ind== 332 | ind== 340 | ind==341 | ind== 342| ind== 350 )
replace sector=11 if ( ind== 352 | ind== 360| ind== 361| ind== 362| ind== 370 )
replace sector=12 if (ind== 372 | ind== 380 | ind== 381 | ind== 390 | ind== 391 | ind== 392 )
*general services.
replace sector=13 if ind ==60
replace sector=13 if (ind==351 | ind== 242 |  ind== 501 | ind== 502 | ind== 510 | ind== 511 | ind== 512 | ind== 521 | ind== 522 | ind== 530 | ind== 531 | ind== 532)
replace sector=13 if (ind==540 | ind==541 | ind== 542| ind== 550| ind== 551 | ind==552 | ind==560 | ind==561 | ind== 562 | ind== 571 | ind== 580 | ind== 581 | ind== 582) 
*militar and public services
drop if ind>893
*grouping the lasting sectors
tab ind if sector==.
*rest of services 
replace sector=13 if 582<ind
replace sector=13 if (ind==400 | ind==401 | ind== 402 | ind==410 | ind==411 | ind==420 | ind==421 | ind== 422 | ind== 432 | ind== 440| ind== 441 | ind==442 | ind==450 | ind== 451 | ind== 452 | ind== 470| ind== 471| ind==472)
drop if ind==412
tab sector 
replace sector=0 if ind==0

keep id month year period  sector mish statefip ind asecwt lnkfw1ywt 
rename lnkfw1ywt  wtfinl_long 
rename asecwt  wtfinl_period
sort id period
save clean_data_yearly, replace 

