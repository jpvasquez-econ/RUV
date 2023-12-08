*Cleaning and creating the database. 
 cd "C:\Users\Efraín\OneDrive - Universidad de Costa Rica\Desktop\JP_SMALL_TASK\19997_2002"
 use "C:/Users/Efraín/Downloads/cps_panel.dta", clear
order cpsid cpsidp cpsidv sex mish month age sex race popstat nativity 
egen id=group(cpsidp)
egen house_id=group(cpsid)
egen id2=group(cpsidv)
order id id2 year  house_id
drop cpsid cpsidp cpsidv
sort id year month
bysort id: gen quarter=_n
drop if quarter>8
order id
sort id
order id month mish
sort id month
xtset id mish
bysort id: gen times=_N
tab times
egen tag=tag(id)
*We want to keep people that we observe for at least 4 quarters. 
bys id: gen num=_N
drop if num<4
*Primera consistencia: sex
*Alternative approach is accounting the number of times someone changes sex in the first 4 quarters.
sort id quarter
bysort id (sex): gen change= 1000*sex[1]+100*sex[2]+10*sex[3]+sex[4]
tab change if tag
*drop if change ==1
keep if (change==2222 | change==1111)
*Checking for race 
bysort id (race): gen change2=race[1]!=race[_N]
tab change2 if tag
drop if change2==1
*Checking for nativity 
bysort id (nativity): gen change3=nativity[1]!=nativity[_N]
tab change3 if tag
drop if change3==1
*Checking for popstat
bysort id (popstat): gen change4=popstat[1]!=popstat[_N]
tab change4 if tag
drop if change4==1
*Checking for age 
*first we check how many changed the age, nobody should change it more than one year.
bysort id (age): gen change5=age[1]!=age[_N]
tab change5 if tag
bysort id (age): gen dif_age=age[_N]-age[1]
tab change5 if tag
tab dif_age 
drop if dif_age>3
*Wich observations to drop. 
*birthplace
bysort id (bpl): gen change6=bpl[1]!=bpl[_N]
drop if change6==1
*Labor status. *************
gen sector=.
replace sector=0 if (labforce==1)
tab statefip 
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
keep if age<66
keep if age>24
*Jose-data-base 
replace sector=0 if ind==0
bysort id: gen sector_origin1=sector if mish==1
bysort id: gen sector_destination4=sector if mish==4
bysort id: gen sector_origin5=sector if mish==5
bysort id: gen sector_destination8=sector if mish==8


bys id (mish): replace sector_origin5=sector_origin5[_n-1] if missing(sector_origin5)
bys id (mish): replace sector_origin5=sector_origin5[_N] if missing(sector_origin5)
bys id (mish): replace sector_origin1=sector_origin1[_n-1] if missing(sector_origin1)
bys id (mish): replace sector_origin1=sector_origin1[_N] if missing(sector_origin1)
bys id (mish): replace sector_destination4=sector_destination4[_N] if missing(sector_destination4)
bys id (mish): replace sector_destination4=sector_destination4[_n-1] if missing(sector_destination4)
bys id (mish): replace sector_destination8=sector_destination8[_N] if missing(sector_destination8)
bys id (mish): replace sector_destination8=sector_destination8[_n-1] if missing(sector_destination8)
save clean_data, replace 

sort id month mish
keep id month year mish statefip ind sector sector_origin1 sector_destination4  sector_origin5 sector_destination8 wtfinl 
save clean_data, replace 

*Descriptives
*Computing the shares
use clean_data, clear 
collapse (sum) wtfinl, by(sector_origin1 sector_destination4 state mish year) 
*prueba
tab sector_origin1
bysort sector_origin1 statefip mish: egen tot=total(wtfinl) 
*The shares from the changes 1--->4
gen share14= wtfinl/tot
sum share14 if sector_origin1==sector_destination4, detail 
save weights4, replace 
use clean_data, clear
merge m:m sector_origin1 sector_destination4 statefip mish year using weights4
drop _merge 
save data_base_14, replace 
*The shares from the changes 5--->8
use clean_data, clear 
collapse (sum) wtfinl, by(sector_origin5 sector_destination8 state mish year) 
bysort sector_origin5 statefip mish: egen tot2=total(wtfinl) 
gen share58= wtfinl/tot2
save weights5, replace 
use clean_data, clear
merge m:m sector_origin5 sector_destination8 statefip mish year using weights5
drop _merge 
drop tot2
sort id
save data_base_15, replace 
merge id using data_base_14
drop tot _merge migration
save data_base_weights, replace 
