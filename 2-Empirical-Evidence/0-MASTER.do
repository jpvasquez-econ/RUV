clear all
set more off
set matsize 1000
global outputs "results"

* The 1-ipums_acs.do code creates a panel of employment indicators by CZ from 2006 to 2020. It follows the data construction from ADH 2013. 
do "codes/1-ipums_acs.do"

* The coefs_graphs_decadal.do code runs regressions in the spirit of ADH 21 for 2006-2020 but using the data construction and exposure measures from ADH 13.
qui do "codes/2-coefs_graphs_decadal"

* Create downward nominal wage rigidity measures
qui do "codes/3-cps1990_rigmeasures"

* Create trade exposure coef graphs on outcomes with rigidity interaction 
qui do "codes/4-dnwr_figures"

* Create tex tables for each outcome
do "codes/5-dnwr_tables"



