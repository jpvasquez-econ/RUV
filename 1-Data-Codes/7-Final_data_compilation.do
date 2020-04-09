***********************************************************
* EXPORTING ALL BILATERAL FLOWS MATRICES IN A UNIQUE FILE
***********************************************************
forvalue i=2000/2007{

import delimited "1-Intermediate_Processed_Data\final_matrix_`i'.csv", clear 
         
export excel using "2-Final_Data\bilat_matrix_allyears.xlsx" ///
	, sheet("year`i'") firstrow(variables) sheetmodify

}
***********************************************************
* EXPORTING ALL AGGREGATE DEFICITS IN A UNIQUE SHEET
***********************************************************
forvalue i=2000/2007{

import delimited "1-Intermediate_Processed_Data\deficits_`i'.csv", clear
distinct region
local dist_=`r(ndistinct)'
gen temp_pos=_n if _n<=`dist_'
bys region: egen pos=mean(temp_pos)
collapse (sum) deficit, by(pos region)
rename deficit deficit_`i'
tempfile file`i'
save `file`i'',replace

}

use `file2000', clear
forvalue i=2001/2007{

merge 1:1 pos using `file`i''
assert _m==3
drop _m

}

drop pos
export excel using "2-Final_Data\deficits_allyears.xlsx" ///
	, firstrow(variables) replace
***********************************************************
* EXPORTING ALL VA SHARES IN A UNIQUE SHEET
***********************************************************
forvalue i=2000/2007{

import delimited "1-Intermediate_Processed_Data\labor_shares`i'.csv", clear
ds year region, not
local vari `r(varlist)'
local y=101

foreach v of local vari{
rename `v' sector_`y'
local y=`y'+1
}
tempfile file`i'
save `file`i'', replace

}
use `file2000', clear

forvalue i=2001/2007{
append using `file`i''
}
export excel using "2-Final_Data\va_shares_allyears.xlsx" ///
	, firstrow(variables) replace

***********************************************************
* EXPORTING ALL IO-TABLES IN A UNIQUE FILE
***********************************************************
forvalue i=2000/2007{

import delimited "1-Intermediate_Processed_Data\io_shares`i'.csv", clear
ds year country, not
local vari `r(varlist)'
local y=101
egen sector = seq(), f(101) t(114)

foreach v of local vari{
rename `v' io`y'
local y=`y'+1
}
order year country sector io*, first

export excel using "2-Final_Data\io_allyears.xlsx" ///
	, sheet("year`i'") firstrow(variables) sheetmodify
}

