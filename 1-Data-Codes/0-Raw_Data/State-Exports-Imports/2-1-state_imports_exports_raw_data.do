capture log close
* Written by JP 
clear all
set more off
set linesize 150

/*
***********************************************************************************************************************************************
***  	THIS DO FILE DOES THE FOLLOWING:
***********************************************************************************************************************************************
Compiles imports and exports data from census 
*/

********************** 
***  OUTPUT FILES  ***  
**********************
global exports_data "1-Intermediate_Processed_Data\census_exports.dta"
global imports_data "1-Intermediate_Processed_Data\census_imports.dta"

***********************************************************************************************************************************************
***  	EXPORTS
***********************************************************************************************************************************************

forvalue i=2002(2)2016{
scalar j=`i'+1
if `i'==2016{
scalar j=`i'+2
}
display "uploading file Exports `i'-`=j'"
quiet{
import delimited "0-Raw_Data\State-Exports\State Exports by NAICS Commodities `i'-`=j'.csv", delimiter(";") varnames(1) rowrange(4) clear
rename stateexp* state
rename v2 naics3d
rename v3 destination
rename v4 year
rename v5 exports
capture drop v6
*ammounts in numbers instead of strings
*the problem here are the commas. One needs to remove them first

replace exports = subinstr(exports, ",", "",.)
destring exports, replace
format exports %16.0g
compress
*saving in temporal file
tempfile file`i'
save `file`i'', replace
}
}
**
** appending all files
** 
use `file2002', clear
forvalue i=2004(2)2016{
append using `file`i''
}
destring year, replace
save $exports_data, replace

***********************************************************************************************************************************************
***  	IMPORTS
***********************************************************************************************************************************************
clear all

*there are 56 files
forvalue i=1/56{
display "uploading file `i'"
quiet{
import delimited 0-Raw_Data\State-Imports\download-`i'.csv, delimiter(comma) varnames(1) rowrange(4) clear
*rename variables
rename stateimp* state
rename v2 naics3d
rename v3 origin
rename v4 year
rename v5 imports
drop v*
*amounts in numbers instead of strings
*the problem here are the commas. One needs to remove them first

replace imports = subinstr(imports, ",", "",.)
destring imports, replace
compress
*saving in temporal file
tempfile file`i'
save `file`i'', replace
}
}
**
** appending all files
** 
use `file1', clear
forvalue i=2/56{
append using `file`i''
}
save $imports_data, replace
