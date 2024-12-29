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
keep if Year >= 1990 & Year <= 2020
*Sum to get county totals by year
keep Year FIPS Population 
collapse (sum) Population, by(FIPS Year)
save "raw_data\population.dta", replace

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

merge 1:1 FIPS Year using "raw_data\population.dta"
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
drop if CZ == . | year == .
replace unemployment = 0 if unemployment == .
replace pop = 0 if pop == .
collapse (sum) pop unemployment, by(CZ year)
order CZ year unemployment pop
save "unemp_pop\unemp_pop.dta", replace
erase "raw_data\population.dta"
erase "__000000.dta"