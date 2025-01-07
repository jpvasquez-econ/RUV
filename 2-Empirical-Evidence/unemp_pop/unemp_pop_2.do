*******************************
*** Prepare population data ***
*******************************

clear all
cd "D:\RUV\2-Empirical-Evidence"
/*The file format is fixed length ASCII text records (one population per 
record/line). You can consult the data dictionary using the following link:
https://seer.cancer.gov/popdata/popdic.html*/
infix ///
    float Year 1-4 ///         
    str4 State 5-6 ///     
    float FIPS 7-11 ///     
    float Registry 12-13 ///
	float Race 14 ///
	float Origin 15 ///
	float Sex 16 ///
	float Age 17-18 ///
	float Population 19-26 ///
	using "raw_data\us.1969_2022.singleages.adjusted.txt"
*Ages (between 15 and 65).
keep if Age >= 15 & Age <= 65
*Years (between 1990 and 2020)
keep if Year >= 1989 & Year <= 2021
*Sum to get county totals by year
keep Year FIPS Population 
replace Population = 0 if Population == .
collapse (sum) Population, by(FIPS Year)
save "raw_data\population_2.dta", replace

*********************************
*** Prepare unemployment data ***
*********************************

clear all
cd "D:\RUV\2-Empirical-Evidence\"
local states "Alabama Alaska Arizona Arkansas California Colorado Connecticut Delaware Florida Georgia Hawaii Idaho Illinois Indiana Iowa Kansas Kentucky Louisiana Maine Maryland Massachusetts Michigan Minnesota Mississippi Missouri Montana Nebraska Nevada New_Hampshire New_Jersey New_Mexico New_York North_Carolina North_Dakota Ohio Oklahoma Oregon Pennsylvania Rhode_Island South_Carolina South_Dakota Tennessee Texas1 Texas2 Utah Vermont Virginia Washington West_Virginia Wisconsin Wyoming"
tempname unemployment
save `unemployment', emptyok replace
local folder "D:\RUV\2-Empirical-Evidence\raw_data\"
foreach state in `states' {
    local filepath "`folder'\`state'.xlsx"
    import excel "`filepath'", sheet("BLS Data Series") cellrange(A4) firstrow clear
    append using `unemployment'
    save `unemployment', replace
}
*FIPS code
gen FIPS_str = substr(SeriesID, 6, 5)
destring FIPS_str, generate(FIPS) force
drop FIPS_str
*Keep only the unemployment series.
gen last_char = substr(SeriesID, -1, 1)
drop if last_char != "4"
drop last_char SeriesID
*Reshape.
reshape long Annual, i(FIPS) j(Year)

*******************************************
*** Combine population and unemployment ***
*******************************************

keep if Year >= 1989 & Year <= 2021
merge 1:1 FIPS Year using "raw_data\population_2.dta"
drop _merge

***************************
*** From counties to CZ ***
***************************

rename FIPS cty_fips
merge m:1 cty_fips using "raw_data\cw_cty_czone.dta"
drop _merge cty_fips
rename czone CZ
rename Annual unemployment
rename Year year
rename Population pop
replace unemployment = 0 if unemployment == .
replace pop = 0 if pop == .
collapse (sum) pop unemployment, by(CZ year)
order CZ year unemployment pop
drop if CZ == . | year == .
rename year yr 
rename CZ czone

*****************************************************************
*** Replace the two variables with the 3-year moving averages ***
*****************************************************************
sort czone yr
generate unempMA = (unemployment[_n-1] + unemployment[_n] + unemployment[_n+1])/3
generate popMA = (pop[_n-1] + pop[_n] + pop[_n+1])/3
drop if yr <= 1990 | yr == 2021
drop unemployment pop
rename (unempMA popMA) (unemployment pop)

foreach yr in 1991 2000 {

gen l_seer_sh`yr' = 100* unemp / pop if yr == `yr'
bys czone: egen l_sh_unemp_seer`yr' = mean( l_seer_sh`yr' )

foreach v in unemp pop {

gen l_seer_`v'_`yr' = `v' if yr == `yr'
bys czone: egen l_`v'_seer`yr' = mean( l_seer_`v'_`yr')

}
}
drop l_seer*
save "temp\unemp_pop_2.dta", replace
erase "raw_data\population_2.dta"
erase "__000000.dta"