clear all

* Appending Several Years of WIOD Data

forvalue i=0/11{
local y=2000+`i'
display "year `y'"
quiet{
if `i'<10{
import excel "1-Intermediate_Processed_Data\WiodFixAgg0`i'.xlsx", ///
sheet("Sheet1") cellrange(A1) firstrow clear
}
if `i'>=10{
import excel "1-Intermediate_Processed_Data\WiodFixAgg`i'.xlsx", ///
sheet("Sheet1") cellrange(A1) firstrow clear
}
*B2:BKC1436
rename * value*
capture rename valueA CountryRow
capture rename valueCountryRow CountryRow

reshape long value, i(CountryRow) j(CountryColumn) string

gen year=2000+`i'
gen row_country=substr(CountryRow,1,3)
gen row_item=substr(CountryRow,5,2)
gen col_country=substr(CountryColumn,1,3)
gen col_item=substr(CountryColumn,5,2)

drop CountryRow CountryColumn
order year row_country col_country row_item col_item value

destring row_item col_item, replace

sort year row_country col_country row_item col_item
}
tempfile file_`i'
save `file_`i'', replace
}
* Appending 
use `file_0', clear
forvalue i=1/11{
append using `file_`i''
}
capture replace row_country="ROU" if row_country=="ROM"
capture replace col_country="ROU" if col_country=="ROM"

keep if row_country!="LVA" & row_country!="LUX" & row_country!="MLT"
keep if col_country!="LVA" & col_country!="LUX" & col_country!="MLT"

keep if row_item!=17 & row_item!=31 & row_item!=35
keep if col_item!=17 & col_item!=31 & col_item!=35

* Saving 
save 1-Intermediate_Processed_Data\wiot_full.dta, replace

