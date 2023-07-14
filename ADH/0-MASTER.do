/*
"Trade with Nominal Rigidities: Understanding the unemployment and welfare effects of the China Shock" 
Rodriguez-Clare, A., Ulate, M., Vasquez, J.P.

0-MASTER DATA
* China shock trade exposure on labor market outcomes with nominal wage ridigity measures
*/

clear
clear all
clear mata
set more off
set matsize 1000

* Directories
global jose = 1 
if $jose == 0 {
	global main "C:/Users/alove/Documents/GitHub/RUV/ADH"
	}
if $jose == 1  {
	global main "/Users/jpvasquez/Library/CloudStorage/Dropbox/0-mycomputer/mydocuments/0-LSE/0-Research/NK_trade/JP/Data_Construction/RUV/ADH"
	}
	cd $main
	global outputs "results"

* Prepare outcomes: manufacruting, non-manufacturing, unemployment, and nilf population counts by CZs 
do "codes/1-ipums_acs.do"

* Create trade exposure coef graphs on outcomes and model's estimates
qui do "codes/2-coefs_graphs_decadal"

* Create downward nominal wage rigidity measures
qui do "codes/3-cps1990_rigmeasures"

* Create trade exposure coef graphs on outcomes with rigidity interaction 
qui do "codes/4-dnwr_figures"

* Create tex tables for each outcome
do "codes/5-dnwr_tables"



