clear all
set more off
set matsize 1000
capture mkdir results
capture mkdir temp
capture mkdir results/log
capture mkdir results/figures
global outputs "results"

* Note: Set as working directory the folder where the 0-MASTER.do file is

* Create a panel of employment indicators by CZ from 2006 to 2020. It follows the data construction from ADH 2013. 
qui do "codes/1-ipums_acs"

* Create a panel of employment indicators by CZ from 2006 to 2020. Using LAU and SEER data.
qui do "codes/2-unemp_pop"

* Run regressions in the spirit of ADH 21 for 2006-2020 but using the data construction and exposure measures from ADH 13.
qui do "codes/3-coefs_graphs_decadal"

* Create downward nominal wage rigidity measures.
qui do "codes/4-cps1990_rigmeasures"

* Create trade exposure coef graphs on outcomes with rigidity interaction. 
qui do "codes/5-dnwr_figures"

