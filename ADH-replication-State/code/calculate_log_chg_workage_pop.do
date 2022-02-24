/*
Calculate ten-year equivalent percentage change in working age population by 
state and year 

First, we describe the construction of the dataset: 

We use 15-64 years old population instead of 16-64 as in ADH, this is done for 
practicity, since getting 16-64 requires using the microdata in all cases. 

1. 1990: Scrap the population tables from summary PDFs available from Census USA
using Tabula and Excel. Can be replicated with the microdata. 

2. 2000: Excel file obtained from data.census.gov. Manually rearranged. 

3. 2006-2008 (2007): ACS 3-year survey microdata. Python script to download and 
calculate population by state. 

In this code, we calculate the log change in working age population. 

Input files/base codes: 

1. data/0-raw_data/popworkage90_07.dta Working age population by state 1990-2007

Output files: 
1. data/2-final_data/lnchg_popworkage.dta Log change in working population by 
state and year. 
*/

* Import the dataset
use ../data/0-raw_data/workfile_china.dta, clear

*aggregating at the state level
bys yr statefip: egen pop = wtmean(lnchg_popworkage), weight(l_popcount)
bys yr statefip: gen dup=cond(_N==1,0,_n)
drop if dup>1
rename yr year
keep statefip year pop
rename pop lnchg_popworkage

* Save the dataset
save ../data/2-final_data/lnchg_popworkage.dta, replace

