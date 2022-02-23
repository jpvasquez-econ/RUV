/* Calculate imports

This code calculates the import changes to USA and other rich countries from 
China by sector and year. 1990, 2000, 2007

Input files: 

1. "dta/sic87dd_trade_data.dta" (ADH replication package) Imports to USA and 
other countries by year and sector

Output files. 

1. "data/1-intermediate_data/imports_changes.dta" This dataset stores the 
10-year equivalent import changes by sector. (USCH and OTCH)

*/

* Import the dataset
use ../data/0-raw_data/sic87dd_trade_data.dta, clear

* Keep observations of interest
keep if (year == 1991 | year == 2000 | year == 2007) & exporter == "CHN"

* Create importer-exporter group variables
egen trade_part = group(importer exporter)

* Create lagged share for instrument
sort trade_part sic87dd year
by trade_part sic87dd (year): gen import_chg = imports - imports[_n-1]

* Drop first values
drop if year == 1991

* Create treatment variable
gen t2 = (year == 2007)

* Keep variables of interest
keep t2 sic87dd trade_part import_chg

* Reshape the dataset
reshape wide import_chg, i(t2 sic87dd) j(trade_part)
rename import_chg1 import_chg_otch
rename import_chg2 import_chg_usch

* Save the dataset
save ../data/1-intermediate_data/imports_changes.dta, replace